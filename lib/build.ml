open Util

type ('a, 'b) t =
  { dependencies : Deps.t
  ; task : 'a -> 'b Effect.t
  }

let dependencies { dependencies; _ } = dependencies
let task { task; _ } = task

let auxiliary_create_file_with_deps target deps task =
  let open Effect.Monad in
  let* may_need_update = Deps.need_update deps target in
  match may_need_update with
  | Error err ->
    Effect.alert (Lexicon.crap_there_is_an_error err) >> Effect.throw err
  | Ok need_update ->
    if need_update
    then
      Effect.info (Lexicon.target_need_to_be_built target)
      >>= Fun.const task
      >>= Effect.write_file target
      >>= function
      | Error err ->
        Effect.alert (Lexicon.crap_there_is_an_error err) >> Effect.throw err
      | Ok () -> return ()
    else Effect.trace (Lexicon.target_is_up_to_date target) >|= Fun.const ()
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
        let open Preface in
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
  auxiliary_create_file_with_deps
    target
    build_rule.dependencies
    (build_rule.task ())
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

let process_markdown =
  let open Preface.Fun in
  arrow $ Omd.to_html % Omd.of_string
;;

let pipe_content ?(separator = "\n") path =
  let open Preface in
  let c (x, y) = x ^ separator ^ y in
  Fun.flip Tuple.( & ) () ^>> snd (read_file path) >>^ c
;;

let concat_files ?separator first_file second_file =
  read_file first_file >>> pipe_content ?separator second_file
;;
