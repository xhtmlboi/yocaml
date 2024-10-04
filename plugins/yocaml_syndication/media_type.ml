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

type t =
  | Audio_aac
  | Application_x_abiword
  | Application_x_freearc
  | Video_x_msvideo
  | Application_vnd_amazon_ebook
  | Application_octet_stream
  | Image_bmp
  | Application_x_bzip
  | Application_x_bzip2
  | Application_x_cdf
  | Application_x_csh
  | Text_css
  | Text_csv
  | Application_msword
  | Application_vnd_openxmlformats_officedocument_wordprocessingml_document
  | Application_vnd_ms_fontobject
  | Application_epub_zip
  | Application_gzip
  | Image_gif
  | Text_html
  | Image_vnd_microsoft_icon
  | Text_calendar
  | Application_java_archive
  | Image_jpeg
  | Text_javascript
  | Application_json
  | Application_ld_json
  | Audio_midi
  | Audio_x_midi
  | Audio_mpeg
  | Video_mp4
  | Video_mpeg
  | Application_vnd_apple_installer_xml
  | Application_vnd_oasis_opendocument_presentation
  | Application_vnd_oasis_opendocument_spreadsheet
  | Application_vnd_oasis_opendocument_text
  | Audio_ogg
  | Video_ogg
  | Application_ogg
  | Audio_opus
  | Font_otf
  | Image_png
  | Application_pdf
  | Application_x_httpd_php
  | Application_vnd_ms_powerpoint
  | Application_vnd_openxmlformats_officedocument_presentationml_presentation
  | Application_vnd_rar
  | Application_rtf
  | Application_x_sh
  | Image_svg_xml
  | Application_x_shockwave_flash
  | Application_x_tar
  | Image_tiff
  | Video_mp2T
  | Font_ttf
  | Text_plain
  | Application_vnd_visio
  | Audio_wav
  | Audio_webm
  | Video_webm
  | Image_webp
  | Font_woff
  | Font_woff2
  | Application_xhtml_xml
  | Application_vnd_ms_excel
  | Application_vnd_openxmlformats_officedocument_spreadsheetml_sheet
  | Application_xml
  | Text_xml
  | Application_vnd_mozilla_xul_xml
  | Application_zip
  | Video_3Gpp
  | Audio_3Gpp
  | Video_3Gpp2
  | Audio_3Gpp2
  | Application_x_7Z_compressed

let to_string = function
  | Audio_aac -> "audio/aac"
  | Application_x_abiword -> "application/x-abiword"
  | Application_x_freearc -> "application/x-freearc"
  | Video_x_msvideo -> "video/x-msvideo"
  | Application_vnd_amazon_ebook -> "application/vnd.amazon.ebook"
  | Application_octet_stream -> "application/octet-stream"
  | Image_bmp -> "image/bmp"
  | Application_x_bzip -> "application/x-bzip"
  | Application_x_bzip2 -> "application/x-bzip2"
  | Application_x_cdf -> "application/x-cdf"
  | Application_x_csh -> "application/x-csh"
  | Text_css -> "text/css"
  | Text_csv -> "text/csv"
  | Application_msword -> "application/msword"
  | Application_vnd_openxmlformats_officedocument_wordprocessingml_document ->
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
  | Application_vnd_ms_fontobject -> "application/vnd.ms-fontobject"
  | Application_epub_zip -> "application/epub+zip"
  | Application_gzip -> "application/gzip"
  | Image_gif -> "image/gif"
  | Text_html -> "text/html"
  | Image_vnd_microsoft_icon -> "image/vnd.microsoft.icon"
  | Text_calendar -> "text/calendar"
  | Application_java_archive -> "application/java-archive"
  | Image_jpeg -> "image/jpeg"
  | Text_javascript -> "text/javascript"
  | Application_json -> "application/json"
  | Application_ld_json -> "application/ld+json"
  | Audio_midi -> "audio/midi"
  | Audio_x_midi -> "audio/x-midi"
  | Audio_mpeg -> "audio/mpeg"
  | Video_mp4 -> "video/mp4"
  | Video_mpeg -> "video/mpeg"
  | Application_vnd_apple_installer_xml -> "application/vnd.apple.installer+xml"
  | Application_vnd_oasis_opendocument_presentation ->
      "application/vnd.oasis.opendocument.presentation"
  | Application_vnd_oasis_opendocument_spreadsheet ->
      "application/vnd.oasis.opendocument.spreadsheet"
  | Application_vnd_oasis_opendocument_text ->
      "application/vnd.oasis.opendocument.text"
  | Audio_ogg -> "audio/ogg"
  | Video_ogg -> "video/ogg"
  | Application_ogg -> "application/ogg"
  | Audio_opus -> "audio/opus"
  | Font_otf -> "font/otf"
  | Image_png -> "image/png"
  | Application_pdf -> "application/pdf"
  | Application_x_httpd_php -> "application/x-httpd-php"
  | Application_vnd_ms_powerpoint -> "application/vnd.ms-powerpoint"
  | Application_vnd_openxmlformats_officedocument_presentationml_presentation ->
      "application/vnd.openxmlformats-officedocument.presentationml.presentation"
  | Application_vnd_rar -> "application/vnd.rar"
  | Application_rtf -> "application/rtf"
  | Application_x_sh -> "application/x-sh"
  | Image_svg_xml -> "image/svg+xml"
  | Application_x_shockwave_flash -> "application/x-shockwave-flash"
  | Application_x_tar -> "application/x-tar"
  | Image_tiff -> "image/tiff"
  | Video_mp2T -> "video/mp2t"
  | Font_ttf -> "font/ttf"
  | Text_plain -> "text/plain"
  | Application_vnd_visio -> "application/vnd.visio"
  | Audio_wav -> "audio/wav"
  | Audio_webm -> "audio/webm"
  | Video_webm -> "video/webm"
  | Image_webp -> "image/webp"
  | Font_woff -> "font/woff"
  | Font_woff2 -> "font/woff2"
  | Application_xhtml_xml -> "application/xhtml+xml"
  | Application_vnd_ms_excel -> "application/vnd.ms-excel"
  | Application_vnd_openxmlformats_officedocument_spreadsheetml_sheet ->
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
  | Application_xml -> "application/xml "
  | Text_xml -> "text/xml"
  | Application_vnd_mozilla_xul_xml -> "application/vnd.mozilla.xul+xml"
  | Application_zip -> "application/zip"
  | Video_3Gpp -> "video/3gpp"
  | Audio_3Gpp -> "audio/3gpp"
  | Video_3Gpp2 -> "video/3gpp2"
  | Audio_3Gpp2 -> "audio/3gpp2"
  | Application_x_7Z_compressed -> "application/x-7z-compressed"
