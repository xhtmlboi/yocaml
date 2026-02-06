Unix server returns 500 and detailed metadata validation error

  $ pkill -f "unix_server_error.exe 8091" 2>/dev/null || true
  $ fuser -k 8091/tcp >/dev/null 2>&1 || true

  $ ./bin/unix_server_error.exe 8091 content_pp_errors/validation_error.md >/dev/null 2>&1 &

  $ sleep 1

  $ curl -sS http://127.0.0.1:8091/
  <h1>500 Internal server error</h1><hr /><p>The build failed while refreshing the site.</p><pre>--- Oh dear, an error has occurred ---
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
  </pre>

Cleanup
  $ pkill -f "unix_server_error.exe 8091" 2>/dev/null || true
  $ fuser -k 8091/tcp >/dev/null 2>&1 || true
