open Yocaml

module T = struct
  type t = { title : string; subtitle : string; tags : string list }

  let entity_name = "T"
  let neutral = Metadata.required entity_name

  let validate =
    let open Data.Validation in
    record (fun x ->
        let+ title = req x "title" string
        and+ subtitle = req x "subtitle" string
        and+ tags = opt x "tags" (list_of string) in
        { title; subtitle; tags = Option.value ~default:[] tags })
end

let target = Path.rel [ "_www" ]
let cache = Path.rel [ "_cache" ]

let make_page path =
  let main_path = path |> Path.move ~into:target |> Path.remove_extension in
  Action.Static.write_files
    (Yocaml_yaml.Pipeline.read_file_as_metadata (module T) path)
    Task.
      [
        ( Path.(main_path / "title")
        , lift ~has_dynamic_dependencies:false (fun T.{ title; _ } -> title) )
      ; ( Path.(main_path / "subtitle")
        , lift ~has_dynamic_dependencies:false (fun T.{ subtitle; _ } ->
              subtitle) )
      ; Path.
          ( main_path / "tags"
          , lift ~has_dynamic_dependencies:false (fun T.{ tags; _ } ->
                String.concat ", " tags) )
      ]

let program () =
  let open Eff.Infix in
  Action.with_cache ~on:`Source cache
    (Action.batch ~only:`Files (Path.rel [ "content" ]) make_page
    >=> Action.remove_residuals ~target)

let () = Yocaml_unix.run ~level:`Debug program
