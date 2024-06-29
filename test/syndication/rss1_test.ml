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

(* Exemples extracted from https://web.resource.org/rss/1.0/spec#s7*)

let%expect_test "Create a simple feed" =
  let title = "XML.com"
  and url = "http://www.xml.com/xml/news.rss"
  and link = "http://xml.com/pub"
  and description =
    "XML.com features a rich mix of information and services  for the XML \
     community."
  in
  let items =
    Rss1.
      [
        item ~title:"Putting RDF to Work"
          ~link:"http://xml.com/pub/2000/08/09/rdfdb/index.html"
          ~description:
            "Tool and API support for the Resource Description Framework is \
             slowly coming of age. Edd Dumbill takes a look at RDFDB, one of \
             the most exciting new RDF toolkits."
      ]
  in
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
        <items>
          <rdf:Seq>
            <rdf:li resource="http://xml.com/pub/2000/08/09/rdfdb/index.html"/>
          </rdf:Seq>
        </items>
      </channel>
      <item rdf:about="http://xml.com/pub/2000/08/09/rdfdb/index.html">
        <title>Putting RDF to Work</title>
        <link>http://xml.com/pub/2000/08/09/rdfdb/index.html</link>
        <description>
          <![CDATA[Tool and API support for the Resource Description Framework is slowly coming of age. Edd Dumbill takes a look at RDFDB, one of the most exciting new RDF toolkits.]]>
        </description>
      </item>
    </rdf:RDF>
    |}]

let%expect_test "Create a complete feed feed" =
  let title = "XML.com"
  and url = "http://www.xml.com/xml/news.rss"
  and link = "http://xml.com/pub"
  and description =
    "XML.com features a rich mix of information and services  for the XML \
     community."
  and image =
    Rss1.image ~title:"XML.com" ~link:"http://www.xml.com"
      ~url:"http://xml.com/universal/images/xml_tiny.gif"
  and textinput =
    Rss1.textinput ~title:"Search XML.com"
      ~description:"Search XML.com's XML collection" ~name:"s"
      ~link:"http://search.xml.com"
  and items =
    Rss1.
      [
        item ~title:"Processing Inclusions with XSLT"
          ~link:"http://xml.com/pub/2000/08/09/xslt/xslt.html"
          ~description:
            "Processing document inclusions with general XML tools can be \
             problematic. This article proposes a way of preserving inclusion \
             information through SAX-based processing."
      ; item ~title:"Putting RDF to Work"
          ~link:"http://xml.com/pub/2000/08/09/rdfdb/index.html"
          ~description:
            "Tool and API support for the Resource Description Framework is \
             slowly coming of age. Edd Dumbill takes a look at RDFDB, one of \
             the most exciting new RDF toolkits."
      ]
  in
  let document =
    Rss1.feed ~title ~image ~textinput ~url ~link ~description items
  in
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
        <image rdf:resource="http://xml.com/universal/images/xml_tiny.gif"/>
        <textinput rdf:resource="http://search.xml.com"/>
        <items>
          <rdf:Seq>
            <rdf:li resource="http://xml.com/pub/2000/08/09/xslt/xslt.html"/>
            <rdf:li resource="http://xml.com/pub/2000/08/09/rdfdb/index.html"/>
          </rdf:Seq>
        </items>
      </channel>
      <image rdf:about="http://xml.com/universal/images/xml_tiny.gif">
        <title>XML.com</title>
        <link>http://www.xml.com</link>
        <url>http://xml.com/universal/images/xml_tiny.gif</url>
      </image>
      <textinput rdf:about="http://search.xml.com">
        <title>Search XML.com</title>
        <description><![CDATA[Search XML.com's XML collection]]></description>
        <name>s</name>
        <link>http://search.xml.com</link>
      </textinput>
      <item rdf:about="http://xml.com/pub/2000/08/09/xslt/xslt.html">
        <title>Processing Inclusions with XSLT</title>
        <link>http://xml.com/pub/2000/08/09/xslt/xslt.html</link>
        <description>
          <![CDATA[Processing document inclusions with general XML tools can be problematic. This article proposes a way of preserving inclusion information through SAX-based processing.]]>
        </description>
      </item>
      <item rdf:about="http://xml.com/pub/2000/08/09/rdfdb/index.html">
        <title>Putting RDF to Work</title>
        <link>http://xml.com/pub/2000/08/09/rdfdb/index.html</link>
        <description>
          <![CDATA[Tool and API support for the Resource Description Framework is slowly coming of age. Edd Dumbill takes a look at RDFDB, one of the most exciting new RDF toolkits.]]>
        </description>
      </item>
    </rdf:RDF>
    |}]
