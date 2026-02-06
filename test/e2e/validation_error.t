Validation error diagnostic
  $ ./bin/gen_pp_errors.exe content_pp_errors/validation_error.md
  ./bin/gen_pp_errors.exe
  content_pp_errors/validation_error.md
  [DEBUG] Trigger in ./
  [DEBUG] Cache initiated in `./_www/.cache`
  [ERROR] --- Oh dear, an error has occurred ---
  Unable to write to target ./_www/articles/content_pp_errors/validation_error.html:
  
  Validation error in: ./content_pp_errors/validation_error.md
  Entity: `Test_article`
  
  
  Invalid record:
    Errors (1):
    1) Invalid field `date`:
         Invalid shape:
           Expected: strict-string
           Given: `[1, 2, 3]`
    
    Given record:
      title = `"Valid title"`
      date = `[1, 2, 3]`---
  
  Fatal error: exception Stdlib.Exit
  [2]

