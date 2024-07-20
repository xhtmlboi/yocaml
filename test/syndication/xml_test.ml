(* YOCaml a static blog generator.
   Copyright (C) 2024 The Funkyworkers and The YOCaml's developers

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>. *)

open Yocaml_syndication

let address ~number ~street ~zipcode ~city ~country =
  let open Xml in
  node ~name:"address"
    [
      leaf ~name:"number" (Some (string_of_int number))
    ; leaf ~name:"street"
        ~attr:Attr.[ string ~key:"kind" @@ fst street ]
        (Some (snd street))
    ; leaf ~name:"zipcode" (Some zipcode)
    ; leaf ~name:"city" (Some city)
    ; leaf ~name:"country" (Some country)
    ]

let phone ~kind ~value =
  let open Xml in
  leaf ~name:"phone" ~attr:Attr.[ string ~key:"kind" kind ] (Some value)

let email ~kind ~value =
  let open Xml in
  leaf ~name:"email" ~attr:Attr.[ string ~key:"kind" kind ] (Some value)

let person ?(phones = []) ?(emails = []) ~gender ~first_name ~last_name ~address
    () =
  let open Xml in
  node ~name:"person"
    ~attr:Attr.[ string ~key:"gender" gender ]
    [
      leaf ~name:"first_name" (Some first_name)
    ; leaf ~name:"last_name" (Some last_name)
    ; address
    ; node ~name:"phones" phones
    ; node ~name:"email" emails
    ]

let%expect_test "Pretty-printing a simple xml document" =
  let open Xml in
  let document = document @@ leaf ~name:"element" (Some "Hello World") in
  print_endline @@ to_string document;
  [%expect
    {|
    <?xml version="1.0" encoding="utf-8"?>
    <element>Hello World</element>
    |}]

let%expect_test "Pretty-printing a simple xml document with custom encoding \
                 and version" =
  let open Xml in
  let document =
    document ~version:"2.0" ~encoding:"utf-16" ~standalone:true
    @@ leaf ~name:"element" (Some "Hello World")
  in
  print_endline @@ to_string document;
  [%expect
    {|
    <?xml standalone="yes" version="2.0" encoding="utf-16"?>
    <element>Hello World</element>
    |}]

let%expect_test "Pretty-printing an empty xml document (using a leaf)" =
  let open Xml in
  let document = document @@ leaf ~name:"element" None in
  print_endline @@ to_string document;
  [%expect {|
    <?xml version="1.0" encoding="utf-8"?>
    <element/>
    |}]

let%expect_test "Pretty-printing an empty xml document (using a node)" =
  let open Xml in
  let document = document @@ node ~name:"element" [] in
  print_endline @@ to_string document;
  [%expect {|
    <?xml version="1.0" encoding="utf-8"?>
    <element/>
    |}]

let%expect_test "Pretty-printing a complex xml document" =
  let open Xml in
  let document =
    document
    @@ node ~name:"repository"
         [
           person ~gender:"M" ~first_name:"John" ~last_name:"Doe"
             ~address:
               (address ~number:10
                  ~street:("regular", "Street of OCaml")
                  ~zipcode:"42" ~city:"FPCity" ~country:"OCamland")
             ()
         ; person ~gender:"F" ~first_name:"Jeanne" ~last_name:"Doe"
             ~address:
               (address ~number:12
                  ~street:("avenue", "Avenue of OCaml")
                  ~zipcode:"43" ~city:"CityOfApp" ~country:"OcamlIsland")
             ()
         ]
  in
  print_endline @@ to_string document;
  [%expect
    {|
    <?xml version="1.0" encoding="utf-8"?>
    <repository>
      <person gender="M">
        <first_name>John</first_name>
        <last_name>Doe</last_name>
        <address>
          <number>10</number>
          <street kind="regular">Street of OCaml</street>
          <zipcode>42</zipcode>
          <city>FPCity</city>
          <country>OCamland</country>
        </address>
        <phones/>
        <email/>
      </person>
      <person gender="F">
        <first_name>Jeanne</first_name>
        <last_name>Doe</last_name>
        <address>
          <number>12</number>
          <street kind="avenue">Avenue of OCaml</street>
          <zipcode>43</zipcode>
          <city>CityOfApp</city>
          <country>OcamlIsland</country>
        </address>
        <phones/>
        <email/>
      </person>
    </repository>
    |}]

let%expect_test "Pretty-printing yet another complex xml document" =
  let open Xml in
  let document =
    document
    @@ node ~name:"repository"
         [
           person ~gender:"M" ~first_name:"John" ~last_name:"Doe"
             ~phones:
               [
                 phone ~kind:"mobile" ~value:"+33 06 11 11 11 11"
               ; phone ~kind:"mobile" ~value:"+33 06 11 11 11 12"
               ; phone ~kind:"fixe" ~value:"+33 06 11 11 11 13"
               ]
             ~emails:
               [
                 email ~kind:"perso" ~value:"jhonnydony@yahoo.fr"
               ; email ~kind:"pro" ~value:"j.doe@corporate.org"
               ]
             ~address:
               (address ~number:10
                  ~street:("regular", "Street of OCaml")
                  ~zipcode:"42" ~city:"FPCity" ~country:"OCamland")
             ()
         ; person ~gender:"F" ~first_name:"Jeanne" ~last_name:"Doe"
             ~emails:[ email ~kind:"pro" ~value:"je.doee@corporate.org" ]
             ~phones:
               [
                 phone ~kind:"mobile" ~value:"+33 06 11 11 11 14"
               ; phone ~kind:"fixe" ~value:"+33 06 11 11 11 15"
               ]
             ~address:
               (address ~number:12
                  ~street:("avenue", "Avenue of OCaml")
                  ~zipcode:"43" ~city:"CityOfApp" ~country:"OcamlIsland")
             ()
         ]
  in
  print_endline @@ to_string document;
  [%expect
    {|
    <?xml version="1.0" encoding="utf-8"?>
    <repository>
      <person gender="M">
        <first_name>John</first_name>
        <last_name>Doe</last_name>
        <address>
          <number>10</number>
          <street kind="regular">Street of OCaml</street>
          <zipcode>42</zipcode>
          <city>FPCity</city>
          <country>OCamland</country>
        </address>
        <phones>
          <phone kind="mobile">+33 06 11 11 11 11</phone>
          <phone kind="mobile">+33 06 11 11 11 12</phone>
          <phone kind="fixe">+33 06 11 11 11 13</phone>
        </phones>
        <email>
          <email kind="perso">jhonnydony@yahoo.fr</email>
          <email kind="pro">j.doe@corporate.org</email>
        </email>
      </person>
      <person gender="F">
        <first_name>Jeanne</first_name>
        <last_name>Doe</last_name>
        <address>
          <number>12</number>
          <street kind="avenue">Avenue of OCaml</street>
          <zipcode>43</zipcode>
          <city>CityOfApp</city>
          <country>OcamlIsland</country>
        </address>
        <phones>
          <phone kind="mobile">+33 06 11 11 11 14</phone>
          <phone kind="fixe">+33 06 11 11 11 15</phone>
        </phones>
        <email>
          <email kind="pro">je.doee@corporate.org</email>
        </email>
      </person>
    </repository>
    |}]

let%expect_test "test with some escapes" =
  let open Xml in
  let document =
    document
    @@ node ~ns:"foo" ~name:"a"
         [
           node ~name:"k"
             ~attr:Attr.[ escaped ~key:"value" "a&b" ]
             [
               leaf ~ns:"fwrk" ~name:"msp" @@ cdata "Hello \"World\""
             ; leaf ~name:"r" @@ escape "Hi \"World\", l'oo <p>"
             ; opt None
             ; opt (Some (leaf ~name:"b" @@ cdata "f"))
             ]
         ]
  in
  print_endline @@ to_string document;
  [%expect
    {|
    <?xml version="1.0" encoding="utf-8"?>
    <foo:a>
      <k value="a&amp;b">
        <fwrk:msp><![CDATA[Hello "World"]]></fwrk:msp>
        <r>Hi &quot;World&quot;, l&apos;oo &lt;p&gt;</r>
        <b><![CDATA[f]]></b>
      </k>
    </foo:a>
    |}]

let%expect_test "test a renamespacing" =
  let open Xml in
  let document =
    document
    @@ (node ~name:"repository"
          [
            person ~gender:"M" ~first_name:"John" ~last_name:"Doe"
              ~address:
                (address ~number:10
                   ~street:("regular", "Street of OCaml")
                   ~zipcode:"42" ~city:"FPCity" ~country:"OCamland")
              ()
          ; person ~gender:"F" ~first_name:"Jeanne" ~last_name:"Doe"
              ~address:
                (address ~number:12
                   ~street:("avenue", "Avenue of OCaml")
                   ~zipcode:"43" ~city:"CityOfApp" ~country:"OcamlIsland")
              ()
          ]
       |> namespace ~ns:"yocaml")
  in
  print_endline @@ to_string document;
  [%expect
    {|
    <?xml version="1.0" encoding="utf-8"?>
    <yocaml:repository>
      <yocaml:person gender="M">
        <yocaml:first_name>John</yocaml:first_name>
        <yocaml:last_name>Doe</yocaml:last_name>
        <yocaml:address>
          <yocaml:number>10</yocaml:number>
          <yocaml:street kind="regular">Street of OCaml</yocaml:street>
          <yocaml:zipcode>42</yocaml:zipcode>
          <yocaml:city>FPCity</yocaml:city>
          <yocaml:country>OCamland</yocaml:country>
        </yocaml:address>
        <yocaml:phones/>
        <yocaml:email/>
      </yocaml:person>
      <yocaml:person gender="F">
        <yocaml:first_name>Jeanne</yocaml:first_name>
        <yocaml:last_name>Doe</yocaml:last_name>
        <yocaml:address>
          <yocaml:number>12</yocaml:number>
          <yocaml:street kind="avenue">Avenue of OCaml</yocaml:street>
          <yocaml:zipcode>43</yocaml:zipcode>
          <yocaml:city>CityOfApp</yocaml:city>
          <yocaml:country>OcamlIsland</yocaml:country>
        </yocaml:address>
        <yocaml:phones/>
        <yocaml:email/>
      </yocaml:person>
    </yocaml:repository>
    |}]

let%expect_test "Empty nodes should produce a leaf" =
  let open Xml in
  let document =
    document ~version:"2.0" ~encoding:"utf-16" ~standalone:true
    @@ node ~name:"element"
         [ may_leaf ~name:"foo" Fun.id None; may_leaf ~name:"bar" Fun.id None ]
  in
  print_endline @@ to_string document;
  [%expect
    {|
    <?xml standalone="yes" version="2.0" encoding="utf-16"?>
    <element/>
    |}]
