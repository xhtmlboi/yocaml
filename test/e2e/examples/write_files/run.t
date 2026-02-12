Run the generator in an empty tree


  $ ./bin/write_files.exe
  [DEBUG] Cache initiated in `./_cache`
  [WARNING] ./content does not exist
  [INFO] Remove residuals for ./_www
  [WARNING] ./_www does not exist
  [DEBUG] Cache stored in `./_cache`

Create files

  $ mkdir content

  $ cat >content/1.yml <<EOF
  > title: Hello
  > subtitle: World
  > EOF

Run the generator with one file

  $ ./bin/write_files.exe
  [DEBUG] Cache restored from `./_cache`
  [DEBUG] `./_www/1/title` will be written
  [INFO] `./_www/1/title` has been written
  [DEBUG] `./_www/1/subtitle` will be written
  [INFO] `./_www/1/subtitle` has been written
  [DEBUG] `./_www/1/tags` will be written
  [INFO] `./_www/1/tags` has been written
  [INFO] Remove residuals for ./_www
  [DEBUG] Cache stored in `./_cache`

  $ cat _www/1/title
  Hello
  $ cat _www/1/subtitle
  World
  $ cat _www/1/tags


Run the generator with one file


  $ ./bin/write_files.exe
  [DEBUG] Cache restored from `./_cache`
  [DEBUG] `./_www/1/title` is already up-to-date
  [DEBUG] `./_www/1/subtitle` is already up-to-date
  [DEBUG] `./_www/1/tags` is already up-to-date
  [INFO] Remove residuals for ./_www
  [DEBUG] Cache stored in `./_cache`

  $ cat _www/1/title
  Hello
  $ cat _www/1/subtitle
  World
  $ cat _www/1/tags

  $ ./bin/write_files.exe
  [DEBUG] Cache restored from `./_cache`
  [DEBUG] `./_www/1/title` is already up-to-date
  [DEBUG] `./_www/1/subtitle` is already up-to-date
  [DEBUG] `./_www/1/tags` is already up-to-date
  [INFO] Remove residuals for ./_www
  [DEBUG] Cache stored in `./_cache`

  $ cat _www/1/title
  Hello
  $ cat _www/1/subtitle
  World
  $ cat _www/1/tags


Clean Sandbox

  $ rm _cache
  $ rm -rf content
  $ rm -rf _www
