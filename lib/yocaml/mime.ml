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

let pp ppf x =
  Format.fprintf
    ppf
    "%s"
    (match x with
     | Audio_aac -> {|audio/aac|}
     | Application_x_abiword -> {|application/x-abiword|}
     | Application_x_freearc -> {|application/x-freearc|}
     | Video_x_msvideo -> {|video/x-msvideo|}
     | Application_vnd_amazon_ebook -> {|application/vnd.amazon.ebook|}
     | Application_octet_stream -> {|application/octet-stream|}
     | Image_bmp -> {|image/bmp|}
     | Application_x_bzip -> {|application/x-bzip|}
     | Application_x_bzip2 -> {|application/x-bzip2|}
     | Application_x_cdf -> {|application/x-cdf|}
     | Application_x_csh -> {|application/x-csh|}
     | Text_css -> {|text/css|}
     | Text_csv -> {|text/csv|}
     | Application_msword -> {|application/msword|}
     | Application_vnd_openxmlformats_officedocument_wordprocessingml_document
       ->
       {|application/vnd.openxmlformats-officedocument.wordprocessingml.document|}
     | Application_vnd_ms_fontobject -> {|application/vnd.ms-fontobject|}
     | Application_epub_zip -> {|application/epub+zip|}
     | Application_gzip -> {|application/gzip|}
     | Image_gif -> {|image/gif|}
     | Text_html -> {|text/html|}
     | Image_vnd_microsoft_icon -> {|image/vnd.microsoft.icon|}
     | Text_calendar -> {|text/calendar|}
     | Application_java_archive -> {|application/java-archive|}
     | Image_jpeg -> {|image/jpeg|}
     | Text_javascript -> {|text/javascript|}
     | Application_json -> {|application/json|}
     | Application_ld_json -> {|application/ld+json|}
     | Audio_midi -> {|audio/midi|}
     | Audio_x_midi -> {|audio/x-midi|}
     | Audio_mpeg -> {|audio/mpeg|}
     | Video_mp4 -> {|video/mp4|}
     | Video_mpeg -> {|video/mpeg|}
     | Application_vnd_apple_installer_xml ->
       {|application/vnd.apple.installer+xml|}
     | Application_vnd_oasis_opendocument_presentation ->
       {|application/vnd.oasis.opendocument.presentation|}
     | Application_vnd_oasis_opendocument_spreadsheet ->
       {|application/vnd.oasis.opendocument.spreadsheet|}
     | Application_vnd_oasis_opendocument_text ->
       {|application/vnd.oasis.opendocument.text|}
     | Audio_ogg -> {|audio/ogg|}
     | Video_ogg -> {|video/ogg|}
     | Application_ogg -> {|application/ogg|}
     | Audio_opus -> {|audio/opus|}
     | Font_otf -> {|font/otf|}
     | Image_png -> {|image/png|}
     | Application_pdf -> {|application/pdf|}
     | Application_x_httpd_php -> {|application/x-httpd-php|}
     | Application_vnd_ms_powerpoint -> {|application/vnd.ms-powerpoint|}
     | Application_vnd_openxmlformats_officedocument_presentationml_presentation
       ->
       {|application/vnd.openxmlformats-officedocument.presentationml.presentation|}
     | Application_vnd_rar -> {|application/vnd.rar|}
     | Application_rtf -> {|application/rtf|}
     | Application_x_sh -> {|application/x-sh|}
     | Image_svg_xml -> {|image/svg+xml|}
     | Application_x_shockwave_flash -> {|application/x-shockwave-flash|}
     | Application_x_tar -> {|application/x-tar|}
     | Image_tiff -> {|image/tiff|}
     | Video_mp2T -> {|video/mp2t|}
     | Font_ttf -> {|font/ttf|}
     | Text_plain -> {|text/plain|}
     | Application_vnd_visio -> {|application/vnd.visio|}
     | Audio_wav -> {|audio/wav|}
     | Audio_webm -> {|audio/webm|}
     | Video_webm -> {|video/webm|}
     | Image_webp -> {|image/webp|}
     | Font_woff -> {|font/woff|}
     | Font_woff2 -> {|font/woff2|}
     | Application_xhtml_xml -> {|application/xhtml+xml|}
     | Application_vnd_ms_excel -> {|application/vnd.ms-excel|}
     | Application_vnd_openxmlformats_officedocument_spreadsheetml_sheet ->
       {|application/vnd.openxmlformats-officedocument.spreadsheetml.sheet|}
     | Application_xml -> {|application/xml |}
     | Text_xml -> {|text/xml|}
     | Application_vnd_mozilla_xul_xml -> {|application/vnd.mozilla.xul+xml|}
     | Application_zip -> {|application/zip|}
     | Video_3Gpp -> {|video/3gpp|}
     | Audio_3Gpp -> {|audio/3gpp|}
     | Video_3Gpp2 -> {|video/3gpp2|}
     | Audio_3Gpp2 -> {|audio/3gpp2|}
     | Application_x_7Z_compressed -> {|application/x-7z-compressed|})
;;

let pp_extension ppf x =
  Format.fprintf
    ppf
    "%s"
    (match x with
     | Audio_aac -> {|.aac|}
     | Application_x_abiword -> {|.abw|}
     | Application_x_freearc -> {|.arc|}
     | Video_x_msvideo -> {|.avi|}
     | Application_vnd_amazon_ebook -> {|.azw|}
     | Application_octet_stream -> {|.bin|}
     | Image_bmp -> {|.bmp|}
     | Application_x_bzip -> {|.bz|}
     | Application_x_bzip2 -> {|.bz2|}
     | Application_x_cdf -> {|.cda|}
     | Application_x_csh -> {|.csh|}
     | Text_css -> {|.css|}
     | Text_csv -> {|.csv|}
     | Application_msword -> {|.doc|}
     | Application_vnd_openxmlformats_officedocument_wordprocessingml_document
       -> {|.docx|}
     | Application_vnd_ms_fontobject -> {|.eot|}
     | Application_epub_zip -> {|.epub|}
     | Application_gzip -> {|.gz|}
     | Image_gif -> {|.gif|}
     | Text_html -> {|.htm .html|}
     | Image_vnd_microsoft_icon -> {|.ico|}
     | Text_calendar -> {|.ics|}
     | Application_java_archive -> {|.jar|}
     | Image_jpeg -> {|.jpeg .jpg|}
     | Text_javascript -> {|.js|}
     | Application_json -> {|.json|}
     | Application_ld_json -> {|.jsonld|}
     | Audio_midi -> {|.mid .midi|}
     | Audio_x_midi -> {|.mid .midi|}
     | Audio_mpeg -> {|.mp3|}
     | Video_mp4 -> {|.mp4|}
     | Video_mpeg -> {|.mpeg|}
     | Application_vnd_apple_installer_xml -> {|.mpkg|}
     | Application_vnd_oasis_opendocument_presentation -> {|.odp|}
     | Application_vnd_oasis_opendocument_spreadsheet -> {|.ods|}
     | Application_vnd_oasis_opendocument_text -> {|.odt|}
     | Audio_ogg -> {|.oga|}
     | Video_ogg -> {|.ogv|}
     | Application_ogg -> {|.ogx|}
     | Audio_opus -> {|.opus|}
     | Font_otf -> {|.otf|}
     | Image_png -> {|.png|}
     | Application_pdf -> {|.pdf|}
     | Application_x_httpd_php -> {|.php|}
     | Application_vnd_ms_powerpoint -> {|.ppt|}
     | Application_vnd_openxmlformats_officedocument_presentationml_presentation
       -> {|.pptx|}
     | Application_vnd_rar -> {|.rar|}
     | Application_rtf -> {|.rtf|}
     | Application_x_sh -> {|.sh|}
     | Image_svg_xml -> {|.svg|}
     | Application_x_shockwave_flash -> {|.swf|}
     | Application_x_tar -> {|.tar|}
     | Image_tiff -> {|.tif .tiff|}
     | Video_mp2T -> {|.ts|}
     | Font_ttf -> {|.ttf|}
     | Text_plain -> {|.txt|}
     | Application_vnd_visio -> {|.vsd|}
     | Audio_wav -> {|.wav|}
     | Audio_webm -> {|.weba|}
     | Video_webm -> {|.webm|}
     | Image_webp -> {|.webp|}
     | Font_woff -> {|.woff|}
     | Font_woff2 -> {|.woff2|}
     | Application_xhtml_xml -> {|.xhtml|}
     | Application_vnd_ms_excel -> {|.xls|}
     | Application_vnd_openxmlformats_officedocument_spreadsheetml_sheet ->
       {|.xlsx|}
     | Application_xml -> {|.xml|}
     | Text_xml -> {|.xml|}
     | Application_vnd_mozilla_xul_xml -> {|.xul|}
     | Application_zip -> {|.zip|}
     | Video_3Gpp -> {|.3gp|}
     | Audio_3Gpp -> {|.3gp|}
     | Video_3Gpp2 -> {|.3g2|}
     | Audio_3Gpp2 -> {|.3g2|}
     | Application_x_7Z_compressed -> {|.7z|})
;;

let pp_document ppf x =
  Format.fprintf
    ppf
    "%s"
    (match x with
     | Audio_aac -> {|AAC audio|}
     | Application_x_abiword -> {|AbiWord document|}
     | Application_x_freearc -> {|Archive document (multiple files embedded)|}
     | Video_x_msvideo -> {|AVI: Audio Video Interleave|}
     | Application_vnd_amazon_ebook -> {|Amazon Kindle eBook format|}
     | Application_octet_stream -> {|Any kind of binary data|}
     | Image_bmp -> {|Windows OS/2 Bitmap Graphics|}
     | Application_x_bzip -> {|BZip archive|}
     | Application_x_bzip2 -> {|BZip2 archive|}
     | Application_x_cdf -> {|CD audio|}
     | Application_x_csh -> {|C-Shell script|}
     | Text_css -> {|Cascading Style Sheets (CSS)|}
     | Text_csv -> {|Comma-separated values (CSV)|}
     | Application_msword -> {|Microsoft Word|}
     | Application_vnd_openxmlformats_officedocument_wordprocessingml_document
       -> {|Microsoft Word (OpenXML)|}
     | Application_vnd_ms_fontobject -> {|MS Embedded OpenType fonts|}
     | Application_epub_zip -> {|Electronic publication (EPUB)|}
     | Application_gzip -> {|GZip Compressed Archive|}
     | Image_gif -> {|Graphics Interchange Format (GIF)|}
     | Text_html -> {|HyperText Markup Language (HTML)|}
     | Image_vnd_microsoft_icon -> {|Icon format|}
     | Text_calendar -> {|iCalendar format|}
     | Application_java_archive -> {|Java Archive (JAR)|}
     | Image_jpeg -> {|JPEG images|}
     | Text_javascript -> {|JavaScript|}
     | Application_json -> {|JSON format|}
     | Application_ld_json -> {|JSON-LD format|}
     | Audio_midi -> {|Musical Instrument Digital Interface (MIDI)|}
     | Audio_x_midi -> {|Musical Instrument Digital Interface (MIDI)|}
     | Audio_mpeg -> {|MP3 audio|}
     | Video_mp4 -> {|MP4 audio|}
     | Video_mpeg -> {|MPEG Video|}
     | Application_vnd_apple_installer_xml -> {|Apple Installer Package|}
     | Application_vnd_oasis_opendocument_presentation ->
       {|OpenDocument presentation document|}
     | Application_vnd_oasis_opendocument_spreadsheet ->
       {|OpenDocument spreadsheet document|}
     | Application_vnd_oasis_opendocument_text ->
       {|OpenDocument text document|}
     | Audio_ogg -> {|OGG audio|}
     | Video_ogg -> {|OGG video|}
     | Application_ogg -> {|OGG|}
     | Audio_opus -> {|Opus audio|}
     | Font_otf -> {|OpenType font|}
     | Image_png -> {|Portable Network Graphics|}
     | Application_pdf -> {|Adobe Portable Document Format (PDF)|}
     | Application_x_httpd_php ->
       {|Hypertext Preprocessor (Personal Home Page)|}
     | Application_vnd_ms_powerpoint -> {|Microsoft PowerPoint|}
     | Application_vnd_openxmlformats_officedocument_presentationml_presentation
       -> {|Microsoft PowerPoint (OpenXML)|}
     | Application_vnd_rar -> {|RAR archive|}
     | Application_rtf -> {|Rich Text Format (RTF)|}
     | Application_x_sh -> {|Bourne shell script|}
     | Image_svg_xml -> {|Scalable Vector Graphics (SVG)|}
     | Application_x_shockwave_flash ->
       {|Small web format (SWF) or Adobe Flash document|}
     | Application_x_tar -> {|Tape Archive (TAR)|}
     | Image_tiff -> {|Tagged Image File Format (TIFF)|}
     | Video_mp2T -> {|MPEG transport stream|}
     | Font_ttf -> {|TrueType Font|}
     | Text_plain -> {|Text, (generally ASCII or ISO 8859-n)|}
     | Application_vnd_visio -> {|Microsoft Visio|}
     | Audio_wav -> {|Waveform Audio Format|}
     | Audio_webm -> {|WEBM audio|}
     | Video_webm -> {|WEBM video|}
     | Image_webp -> {|WEBP image|}
     | Font_woff -> {|Web Open Font Format (WOFF)|}
     | Font_woff2 -> {|Web Open Font Format (WOFF)|}
     | Application_xhtml_xml -> {|XHTML|}
     | Application_vnd_ms_excel -> {|Microsoft Excel|}
     | Application_vnd_openxmlformats_officedocument_spreadsheetml_sheet ->
       {|Microsoft Excel (OpenXML)|}
     | Application_xml -> {|XML|}
     | Text_xml -> {|XML|}
     | Application_vnd_mozilla_xul_xml -> {|XUL|}
     | Application_zip -> {|ZIP archive|}
     | Video_3Gpp -> {|3GPP audio/video container|}
     | Audio_3Gpp -> {|3GPP audio/video container|}
     | Video_3Gpp2 -> {|3GPP2 audio/video container|}
     | Audio_3Gpp2 -> {|3GPP2 audio/video container|}
     | Application_x_7Z_compressed -> {|7-zip archive|})
;;

let identifier = Format.asprintf "%a" pp
let extension = Format.asprintf "%a" pp_extension
let document = Format.asprintf "%a" pp_document

let equal a b =
  match a, b with
  | Audio_aac, Audio_aac -> true
  | Application_x_abiword, Application_x_abiword -> true
  | Application_x_freearc, Application_x_freearc -> true
  | Video_x_msvideo, Video_x_msvideo -> true
  | Application_vnd_amazon_ebook, Application_vnd_amazon_ebook -> true
  | Application_octet_stream, Application_octet_stream -> true
  | Image_bmp, Image_bmp -> true
  | Application_x_bzip, Application_x_bzip -> true
  | Application_x_bzip2, Application_x_bzip2 -> true
  | Application_x_cdf, Application_x_cdf -> true
  | Application_x_csh, Application_x_csh -> true
  | Text_css, Text_css -> true
  | Text_csv, Text_csv -> true
  | Application_msword, Application_msword -> true
  | ( Application_vnd_openxmlformats_officedocument_wordprocessingml_document
    , Application_vnd_openxmlformats_officedocument_wordprocessingml_document
    ) -> true
  | Application_vnd_ms_fontobject, Application_vnd_ms_fontobject -> true
  | Application_epub_zip, Application_epub_zip -> true
  | Application_gzip, Application_gzip -> true
  | Image_gif, Image_gif -> true
  | Text_html, Text_html -> true
  | Image_vnd_microsoft_icon, Image_vnd_microsoft_icon -> true
  | Text_calendar, Text_calendar -> true
  | Application_java_archive, Application_java_archive -> true
  | Image_jpeg, Image_jpeg -> true
  | Text_javascript, Text_javascript -> true
  | Application_json, Application_json -> true
  | Application_ld_json, Application_ld_json -> true
  | Audio_midi, Audio_midi -> true
  | Audio_x_midi, Audio_x_midi -> true
  | Audio_mpeg, Audio_mpeg -> true
  | Video_mp4, Video_mp4 -> true
  | Video_mpeg, Video_mpeg -> true
  | Application_vnd_apple_installer_xml, Application_vnd_apple_installer_xml
    -> true
  | ( Application_vnd_oasis_opendocument_presentation
    , Application_vnd_oasis_opendocument_presentation ) -> true
  | ( Application_vnd_oasis_opendocument_spreadsheet
    , Application_vnd_oasis_opendocument_spreadsheet ) -> true
  | ( Application_vnd_oasis_opendocument_text
    , Application_vnd_oasis_opendocument_text ) -> true
  | Audio_ogg, Audio_ogg -> true
  | Video_ogg, Video_ogg -> true
  | Application_ogg, Application_ogg -> true
  | Audio_opus, Audio_opus -> true
  | Font_otf, Font_otf -> true
  | Image_png, Image_png -> true
  | Application_pdf, Application_pdf -> true
  | Application_x_httpd_php, Application_x_httpd_php -> true
  | Application_vnd_ms_powerpoint, Application_vnd_ms_powerpoint -> true
  | ( Application_vnd_openxmlformats_officedocument_presentationml_presentation
    , Application_vnd_openxmlformats_officedocument_presentationml_presentation
    ) -> true
  | Application_vnd_rar, Application_vnd_rar -> true
  | Application_rtf, Application_rtf -> true
  | Application_x_sh, Application_x_sh -> true
  | Image_svg_xml, Image_svg_xml -> true
  | Application_x_shockwave_flash, Application_x_shockwave_flash -> true
  | Application_x_tar, Application_x_tar -> true
  | Image_tiff, Image_tiff -> true
  | Video_mp2T, Video_mp2T -> true
  | Font_ttf, Font_ttf -> true
  | Text_plain, Text_plain -> true
  | Application_vnd_visio, Application_vnd_visio -> true
  | Audio_wav, Audio_wav -> true
  | Audio_webm, Audio_webm -> true
  | Video_webm, Video_webm -> true
  | Image_webp, Image_webp -> true
  | Font_woff, Font_woff -> true
  | Font_woff2, Font_woff2 -> true
  | Application_xhtml_xml, Application_xhtml_xml -> true
  | Application_vnd_ms_excel, Application_vnd_ms_excel -> true
  | ( Application_vnd_openxmlformats_officedocument_spreadsheetml_sheet
    , Application_vnd_openxmlformats_officedocument_spreadsheetml_sheet ) ->
    true
  | Application_xml, Application_xml -> true
  | Text_xml, Text_xml -> true
  | Application_vnd_mozilla_xul_xml, Application_vnd_mozilla_xul_xml -> true
  | Application_zip, Application_zip -> true
  | Video_3Gpp, Video_3Gpp -> true
  | Audio_3Gpp, Audio_3Gpp -> true
  | Video_3Gpp2, Video_3Gpp2 -> true
  | Audio_3Gpp2, Audio_3Gpp2 -> true
  | Application_x_7Z_compressed, Application_x_7Z_compressed -> true
  | _ -> false
;;
