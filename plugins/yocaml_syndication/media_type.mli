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

(** A very simple representation of media types to describe, in particular, the
    enclosures of an item. *)

(** {1 Types} *)

(** The type describing a media type. *)
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

(** {1 Helpers} *)

val to_string : t -> string
(** [to_string media_type] returns the representation of a media-type in a
    string. *)
