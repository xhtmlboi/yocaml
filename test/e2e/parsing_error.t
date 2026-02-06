Parsing error diagnostic
  $ ./bin/gen_pp_errors.exe content_pp_errors/parsing_error.md
  ./bin/gen_pp_errors.exe
  content_pp_errors/parsing_error.md
  [DEBUG] Trigger in ./
  [DEBUG] Cache initiated in `./_www/.cache`
  [ERROR] --- Oh dear, an error has occurred ---
  Unable to write to target ./_www/articles/content_pp_errors/parsing_error.html:
  
  Parsing error in: ./content_pp_errors/parsing_error.md
  
  Given:
  title: A broken article
  date 2025-06-08
  
  Message: `Yaml: error calling parser: could not find expected ':' character 0 position 0 returned: 0`
  ---
  
  Fatal error: exception Stdlib.Exit
  [2]

