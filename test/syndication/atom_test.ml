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
open Test_util

(* Exemples extracted from https://datatracker.ietf.org/doc/html/rfc4287 *)

let%expect_test "Create a simple feed without entries" =
  let title = Atom.text "Example Feed"
  and url = Atom.self "https://msp.com/atom.xml"
  and updated = Atom.updated_from_entries ()
  and authors =
    Yocaml.Nel.singleton
    @@ Person.make ~uri:"https://github.com/mspwn" ~email:"msp@msp.com"
         "M. Spawn"
  and id = "urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6"
  and entries = [] in
  let document =
    Atom.feed ~title ~updated ~links:[ url ] ~authors ~id Fun.id entries
  in
  print_endline @@ Xml.to_string document;
  [%expect
    {|
    <?xml version="1.0" encoding="utf-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <id>urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6</id>
      <title type="text">Example Feed</title>
      <generator uri="https://github.com/xhtmlboi/yocaml" version="2">YOCaml</generator>
      <updated>1970-01-01T00:00:00Z</updated>
      <author>
        <name>M. Spawn</name>
        <uri>https://github.com/mspwn</uri>
        <email>msp@msp.com</email>
      </author>
      <link href="https://msp.com/atom.xml" rel="self"/>
    </feed>
    |}]

let%expect_test "Create a simple feed without entries" =
  let msp =
    Person.make ~uri:"https://github.com/mspwn" ~email:"msp@msp.com" "M. Spawn"
  in
  let xhtmlboi = Person.make "XHTMLBoy" ~email:"xml@xml.com" in
  let xvw = Person.make "Xavier Van de Woestyne" ~uri:"https://xvw.site" in
  let pry = Person.make "Pierre Ruyter" in
  let title = Atom.text "Example Feed"
  and url = Atom.self "https://msp.com/atom.xml"
  and updated = Atom.updated_from_entries ()
  and authors = Yocaml.Nel.singleton msp
  and id = "urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6"
  and entries =
    [
      Atom.entry ~authors:[ msp; xvw ] ~contributors:[ xhtmlboi; pry ]
        ~title:(Atom.text "Atom-Powered Robots Run Amok")
        ~id:"urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a"
        ~updated:(date (2024, 7, 1) (10, 0, 0))
        ~links:[ Atom.alternate "https://msp.com/atom-powered-robot" ]
        ~content:(Atom.content_text "a text example")
        ()
    ; Atom.entry
        ~title:(Atom.text "Atom-Powered Robots Run Amok 2")
        ~id:"urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6d"
        ~updated:(date (2024, 7, 8) (10, 0, 0))
        ~links:[ Atom.alternate "https://msp.com/atom-powered-robot-2" ]
        ~content:(Atom.content_text "an other text example")
        ()
    ]
  in
  let document =
    Atom.feed ~title ~updated ~links:[ url ] ~authors ~id Fun.id entries
  in
  print_endline @@ Xml.to_string document;
  [%expect
    {|
    <?xml version="1.0" encoding="utf-8"?>
    <feed xmlns="http://www.w3.org/2005/Atom">
      <id>urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6</id>
      <title type="text">Example Feed</title>
      <generator uri="https://github.com/xhtmlboi/yocaml" version="2">YOCaml</generator>
      <updated>2024-07-08T10:00:00Z</updated>
      <author>
        <name>M. Spawn</name>
        <uri>https://github.com/mspwn</uri>
        <email>msp@msp.com</email>
      </author>
      <link href="https://msp.com/atom.xml" rel="self"/>
      <entry>
        <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a</id>
        <title type="text">Atom-Powered Robots Run Amok</title>
        <updated>2024-07-01T10:00:00Z</updated>
        <content type="text">a text example</content>
        <author>
          <name>M. Spawn</name>
          <uri>https://github.com/mspwn</uri>
          <email>msp@msp.com</email>
        </author>
        <author>
          <name>Xavier Van de Woestyne</name>
          <uri>https://xvw.site</uri>
        </author>
        <contributor>
          <name>XHTMLBoy</name>
          <email>xml@xml.com</email>
        </contributor>
        <contributor>
          <name>Pierre Ruyter</name>
        </contributor>
        <link href="https://msp.com/atom-powered-robot" rel="alternate"/>
      </entry>
      <entry>
        <id>urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6d</id>
        <title type="text">Atom-Powered Robots Run Amok 2</title>
        <updated>2024-07-08T10:00:00Z</updated>
        <content type="text">an other text example</content>
        <link href="https://msp.com/atom-powered-robot-2" rel="alternate"/>
      </entry>
    </feed>
    |}]
