open Yocaml

let entity_name = "Test_article"

type t = { title : string; date : string }

let neutral : (t, Required.provider_error) result =
  Error (Required.Required_metadata { entity = entity_name })

let validate =
  let open Data.Validation in
  record (fun fields ->
      let+ title = required fields "title" string
      and+ date = required fields "date" string in
      { title; date })

let normalize { title; date } =
  let open Data in
  [ ("title", string title); ("date", string date) ]
