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

(* Examples from various sources *)

let%expect_test "simple example to opml 1 - 1" =
  let title = "Sample OPML file for RSSReader" in
  let outlines =
    Opml.
      [
        outline ~title:"News" ~text:"News"
          [
            subscription
              ~feed_url:"http://www.bignewsnetwork.com/?rss=37e8860164ce009a"
              ~title:"Big News Finland" ()
          ; subscription
              ~feed_url:"http://feeds.feedburner.com/euronews/en/news/"
              ~title:"Euronews" ()
          ]
      ]
  in
  let feed = Opml.(feed ~title outlines |> to_opml1) in
  print_endline @@ Xml.to_string feed;
  [%expect
    {|
    <?xml version="1.0" encoding="utf-8"?>
    <opml version="1.0">
      <head>
        <title>Sample OPML file for RSSReader</title>
      </head>
      <body>
        <outline text="News" title="News">
          <outline text="Big News Finland" title="Big News Finland" type="rss" xmlUrl="http://www.bignewsnetwork.com/?rss=37e8860164ce009a"/>
          <outline text="Euronews" title="Euronews" type="rss" xmlUrl="http://feeds.feedburner.com/euronews/en/news/"/>
        </outline>
      </body>
    </opml>
    |}]

let%expect_test "simple example to opml 2 - 1" =
  let title = "Sample OPML file for RSSReader" in
  let outlines =
    Opml.
      [
        outline ~title:"News" ~text:"News"
          [
            subscription
              ~feed_url:"http://www.bignewsnetwork.com/?rss=37e8860164ce009a"
              ~title:"Big News Finland" ()
          ; subscription
              ~feed_url:"http://feeds.feedburner.com/euronews/en/news/"
              ~title:"Euronews" ()
          ]
      ; outline ~title:"Leisure" ~text:"Leisure"
          [
            subscription
              ~feed_url:"http://rss.cnn.com/rss/edition_entertainment.rss"
              ~title:"CNN Entertainment" ()
          ; subscription ~feed_url:"http://rss.news.yahoo.com/rss/entertainment"
              ~title:"Yahoo Entertainment" ()
          ]
      ]
  in
  let feed = Opml.(feed ~title outlines |> to_opml2) in
  print_endline @@ Xml.to_string feed;
  [%expect
    {|
    <?xml version="1.0" encoding="utf-8"?>
    <opml version="2.0">
      <head>
        <title>Sample OPML file for RSSReader</title>
        <docs>http://opml.org/spec2.opml</docs>
      </head>
      <body>
        <outline text="News" title="News">
          <outline text="Big News Finland" title="Big News Finland" type="rss" xmlUrl="http://www.bignewsnetwork.com/?rss=37e8860164ce009a"/>
          <outline text="Euronews" title="Euronews" type="rss" xmlUrl="http://feeds.feedburner.com/euronews/en/news/"/>
        </outline>
        <outline text="Leisure" title="Leisure">
          <outline text="CNN Entertainment" title="CNN Entertainment" type="rss" xmlUrl="http://rss.cnn.com/rss/edition_entertainment.rss"/>
          <outline text="Yahoo Entertainment" title="Yahoo Entertainment" type="rss" xmlUrl="http://rss.news.yahoo.com/rss/entertainment"/>
        </outline>
      </body>
    </opml>
    |}]
