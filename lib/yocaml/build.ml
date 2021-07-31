open Util

type ('a, 'b) t =
  { dependencies : Deps.t
  ; task : 'a -> 'b Effect.t
  }

let dependencies { dependencies; _ } = dependencies
let task { task; _ } = task

let perform_if_update_needed target deps do_something do_nothing =
  let open Effect in
  let* may_need_update = Deps.need_update deps target in
  match may_need_update with
  | Error err -> throw err
  | Ok need_update -> if need_update then do_something else do_nothing
;;

module Category = Preface.Make.Category.Via_id_and_compose (struct
  type nonrec ('a, 'b) t = ('a, 'b) t

  let id =
    let dependencies = Deps.Monoid.neutral in
    let task = Effect.return in
    { dependencies; task }
  ;;

  let compose a b =
    let dependencies = Deps.union a.dependencies b.dependencies in
    let task = Effect.(a.task <=< b.task) in
    { dependencies; task }
  ;;
end)

module Arrow =
  Preface.Make.Arrow.Over_category_and_via_arrow_and_fst
    (Category)
    (struct
      type nonrec ('a, 'b) t = ('a, 'b) t

      let arrow f =
        let dependencies = Deps.Monoid.neutral in
        let task x = Effect.return (f x) in
        { dependencies; task }
      ;;

      let fst build =
        let dependencies = build.dependencies in
        let task (x, y) = Effect.(build.task x >>= fun r -> return (r, y)) in
        { dependencies; task }
      ;;
    end)

module Arrow_choice =
  Preface.Make.Arrow_choice.Over_arrow_with_left
    (Arrow)
    (struct
      type nonrec ('a, 'b) t = ('a, 'b) t

      let left build =
        let dependencies = build.dependencies in
        let task = function
          | Either.Left x -> Effect.map Either.left $ build.task x
          | Either.Right x -> Effect.(map Either.right $ return x)
        in
        { dependencies; task }
      ;;
    end)

include (
  Arrow_choice : Preface_specs.ARROW_CHOICE with type ('a, 'b) t := ('a, 'b) t)

let create_file target build_rule =
  perform_if_update_needed
    target
    build_rule.dependencies
    Effect.(
      info (Lexicon.target_need_to_be_built target)
      >> build_rule.task ()
      >>= write_file target
      >>= function
      | Error err -> alert (Lexicon.crap_there_is_an_error err) >> throw err
      | Ok () -> return ())
    Effect.(trace (Lexicon.target_is_up_to_date target))
;;

let read_file path =
  { dependencies = Deps.singleton (Deps.file path)
  ; task =
      (fun () ->
        let open Effect.Monad in
        Effect.read_file path
        >>= function
        | Error e -> Effect.throw e
        | Ok content -> return content)
  }
;;

let fold_dependencies arr_list =
  let dependencies, tasks =
    List.fold_left
      (fun (d, l) x -> Deps.union x.dependencies d, x.task :: l)
      (Deps.empty, [])
      arr_list
  in
  (fun task -> { dependencies; task }), tasks
;;

let failable_task task = { dependencies = Deps.empty; task }

let watch path =
  { dependencies = Deps.singleton (Deps.file path)
  ; task = (fun () -> Effect.return ())
  }
;;

let copy_file ?new_name path ~into =
  let destination =
    Option.fold ~none:(Filename.basename path) ~some:Fun.id new_name
    |> Filename.concat into
  in
  create_file destination $ read_file path
;;

let pipe_content ?(separator = "\n") path =
  let open Preface in
  let c (x, y) = x ^ separator ^ y in
  Fun.flip Pair.( & ) () ^>> snd (read_file path) >>^ c
;;

let concat_files ?separator first_file second_file =
  read_file first_file >>> pipe_content ?separator second_file
;;

let read_file_with_metadata
    (type a)
    (module P : Metadata.PROVIDER)
    (module M : Metadata.PARSABLE with type t = a)
    path
  =
  let open Preface.Fun in
  read_file path
  >>^ Preface.Pair.Bifunctor.map_fst (M.from_string (module P))
      % split_metadata
  >>^ (fun (m, c) -> Validate.Monad.(m >|= flip Preface.Pair.( & ) c))
  >>> failable_task (function
          | Preface.Validation.Valid x -> Effect.return x
          | Preface.Validation.Invalid x -> Effect.throw (Error.List x))
;;

let apply_as_template
    (type a)
    (module M : Metadata.INJECTABLE with type t = a)
    ?(strict = true)
    template
  =
  let piped = Preface.(Fun.flip Pair.( & ) ()) in
  let action ((obj, content), tpl_content) =
    let values = M.to_mustache obj in
    let variables = `O (("body", `String content) :: values) in
    try
      let layout = Mustache.of_string tpl_content in
      Effect.return (obj, Mustache.render ~strict layout variables)
    with
    | e -> Effect.raise_ e
  in
  piped ^>> snd (read_file template) >>> failable_task action
;;

let without_body x = x, ""

let collection effect arrow process =
  let open Effect in
  let open Preface.Fun in
  effect
  >|= fold_dependencies % List.map arrow
  >|= fun (task, effects) ->
  task (fun (meta, content) ->
      List.map (fun f -> f ()) effects
      |> Traverse.sequence
      >|= fun x -> process x meta content)
;;
