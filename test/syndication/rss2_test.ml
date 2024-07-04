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

let date ?(tz = Tz.Edt) (year, month, day) (h, m, s) =
  match Yocaml.Archetype.Datetime.make ~time:(h, m, s) ~year ~month ~day () with
  | Ok d -> Datetime.make ~tz d
  | _ -> assert false

(* Exemples extracted from https://www.rssboard.org/rss-specification#sampleFiles *)

let%expect_test "Create a simple feed" =
  let title = "NASA Space Station News"
  and link = "http://www.nasa.gov/"
  and url = "https://www.rssboard.org/files/sample-rss-2.xml"
  and description =
    "A RSS news feed containing the latest NASA press releases on the \
     International Space Station."
  and items =
    Rss2.
      [
        item
          ~title:
            "Louisiana Students to Hear from NASA Astronauts Aboard Space \
             Station"
          ~link:
            "http://www.nasa.gov/press-release/louisiana-students-to-hear-from-nasa-astronauts-aboard-space-station"
          ~description:
            "As part of the state's first Earth-to-space call, students from \
             Louisiana will have an opportunity soon to hear from NASA \
             astronauts aboard the International Space Station."
          ~guid:guid_from_link
          ~pub_date:(date (2023, 7, 21) (9, 4, 0))
          ()
      ]
  in
  let document = Rss2.feed ~title ~link ~url ~description Fun.id items in
  print_endline @@ Xml.to_string document;
  [%expect
    {|
    <?xml version="1.0" encoding="utf-8"?>
    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
      <channel>
        <title>NASA Space Station News</title>
        <link>http://www.nasa.gov/</link>
        <description>
          <![CDATA[A RSS news feed containing the latest NASA press releases on the International Space Station.]]>
        </description>
        <atom:link href="https://www.rssboard.org/files/sample-rss-2.xml" rel="self" type="application/rss+xml"/>
        <docs>https://www.rssboard.org/rss-specification</docs>
        <generator>YOCaml</generator>
        <item>
          <title>Louisiana Students to Hear from NASA Astronauts Aboard Space Station</title>
          <link>
            http://www.nasa.gov/press-release/louisiana-students-to-hear-from-nasa-astronauts-aboard-space-station
          </link>
          <description>
            <![CDATA[As part of the state's first Earth-to-space call, students from Louisiana will have an opportunity soon to hear from NASA astronauts aboard the International Space Station.]]>
          </description>
          <guid isPermaLink="true">
            http://www.nasa.gov/press-release/louisiana-students-to-hear-from-nasa-astronauts-aboard-space-station
          </guid>
          <pubDate>Fri, 21 Jul 2023 09:04:00 EDT</pubDate>
        </item>
      </channel>
    </rss>
    |}]

let%expect_test "Create a complex feed" =
  let title = "NASA Space Station News"
  and link = "http://www.nasa.gov/"
  and pub_date = date (2003, 6, 10) (4, 0, 0)
  and last_build_date = date (2023, 7, 21) (9, 4, 0)
  and url = "https://www.rssboard.org/files/sample-rss-2.xml"
  and managing_editor =
    Rss2.email ~name:"Neil Armstrong" "neil.armstrong@example.com"
  and webmaster = Rss2.email ~name:"Sally Ride" "sally.ride@example.com"
  and description =
    "A RSS news feed containing the latest NASA press releases on the \
     International Space Station."
  and items =
    Rss2.
      [
        item
          ~title:
            "Louisiana Students to Hear from NASA Astronauts Aboard Space \
             Station"
          ~link:
            "http://www.nasa.gov/press-release/louisiana-students-to-hear-from-nasa-astronauts-aboard-space-station"
          ~description:
            "As part of the state's first Earth-to-space call, students from \
             Louisiana will have an opportunity soon to hear from NASA \
             astronauts aboard the International Space Station."
          ~guid:guid_from_link
          ~pub_date:(date (2023, 7, 21) (9, 4, 0))
          ()
      ; item ~title:"NASA Expands Options for Spacewalking, Moonwalking Suits"
          ~link:
            "http://www.nasa.gov/press-release/nasa-expands-options-for-spacewalking-moonwalking-suits-services"
          ~description:
            "NASA has awarded Axiom Space and Collins Aerospace task orders \
             under existing contracts to advance spacewalking capabilities in \
             low Earth orbit, as well as moonwalking services for Artemis \
             missions."
          ~guid:guid_from_link
          ~enclosure:
            (enclosure
               ~url:
                 "http://www.nasa.gov/sites/default/files/styles/1x1_cardfeed/public/thumbnails/image/iss068e027836orig.jpg?itok=ucNUaaGx"
               ~media_type:Media_type.Image_jpeg ~length:1032272)
          ~pub_date:(date (2023, 7, 10) (14, 14, 0))
          ()
      ]
  in
  let document =
    Rss2.feed ~title ~link ~url ~description ~pub_date ~last_build_date
      ~managing_editor ~webmaster Fun.id items
  in
  print_endline @@ Xml.to_string document;
  [%expect
    {|
    <?xml version="1.0" encoding="utf-8"?>
    <rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
      <channel>
        <title>NASA Space Station News</title>
        <link>http://www.nasa.gov/</link>
        <description>
          <![CDATA[A RSS news feed containing the latest NASA press releases on the International Space Station.]]>
        </description>
        <atom:link href="https://www.rssboard.org/files/sample-rss-2.xml" rel="self" type="application/rss+xml"/>
        <managingEditor>neil.armstrong@example.com (Neil Armstrong)</managingEditor>
        <webMaster>sally.ride@example.com (Sally Ride)</webMaster>
        <pubDate>Tue, 10 Jun 2003 04:00:00 EDT</pubDate>
        <lastBuildDate>Fri, 21 Jul 2023 09:04:00 EDT</lastBuildDate>
        <docs>https://www.rssboard.org/rss-specification</docs>
        <generator>YOCaml</generator>
        <item>
          <title>Louisiana Students to Hear from NASA Astronauts Aboard Space Station</title>
          <link>
            http://www.nasa.gov/press-release/louisiana-students-to-hear-from-nasa-astronauts-aboard-space-station
          </link>
          <description>
            <![CDATA[As part of the state's first Earth-to-space call, students from Louisiana will have an opportunity soon to hear from NASA astronauts aboard the International Space Station.]]>
          </description>
          <guid isPermaLink="true">
            http://www.nasa.gov/press-release/louisiana-students-to-hear-from-nasa-astronauts-aboard-space-station
          </guid>
          <pubDate>Fri, 21 Jul 2023 09:04:00 EDT</pubDate>
        </item>
        <item>
          <title>NASA Expands Options for Spacewalking, Moonwalking Suits</title>
          <link>
            http://www.nasa.gov/press-release/nasa-expands-options-for-spacewalking-moonwalking-suits-services
          </link>
          <description>
            <![CDATA[NASA has awarded Axiom Space and Collins Aerospace task orders under existing contracts to advance spacewalking capabilities in low Earth orbit, as well as moonwalking services for Artemis missions.]]>
          </description>
          <enclosure length="1032272" type="image/jpeg" url="http://www.nasa.gov/sites/default/files/styles/1x1_cardfeed/public/thumbnails/image/iss068e027836orig.jpg?itok=ucNUaaGx"/>
          <guid isPermaLink="true">
            http://www.nasa.gov/press-release/nasa-expands-options-for-spacewalking-moonwalking-suits-services
          </guid>
          <pubDate>Mon, 10 Jul 2023 14:14:00 EDT</pubDate>
        </item>
      </channel>
    </rss>
    |}]
