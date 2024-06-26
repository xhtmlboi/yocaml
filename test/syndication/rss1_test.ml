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

let%expect_test "Create a simple feed" =
  let title = "XML.com"
  and url = "http://www.xml.com/xml/news.rss"
  and link = "http://xml.com/pub"
  and description =
    "XML.com features a rich mix of information and services  for the XML \
     community."
  in
  let items = [] in
  let document = Rss1.feed ~title ~url ~link ~description items in
  print_endline @@ Xml.to_string document;
  [%expect
    {|
    <?xml version="1.0" encoding="utf-8"?>
    <rdf:RDF xmlns="http://purl.org/rss/1.0/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
      <channel rdf:about="http://www.xml.com/xml/news.rss">
        <title>XML.com</title>
        <link>http://xml.com/pub</link>
        <description>
          <![CDATA[XML.com features a rich mix of information and services  for the XML community.]]>
        </description>
      </channel>
    </rdf:RDF>
    |}]
