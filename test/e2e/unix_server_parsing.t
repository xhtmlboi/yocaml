Unix server returns 500 and detailed parsing error

  $ pkill -f "unix_server_error.exe 8090" 2>/dev/null || true
  $ fuser -k 8090/tcp >/dev/null 2>&1 || true

  $ ./bin/unix_server_error.exe 8090 content_pp_errors/parsing_error.md >/dev/null 2>&1 &

  $ sleep 1

  $ curl -sS http://127.0.0.1:8090/
  <h1>500 Internal server error</h1><hr /><p>The build failed while refreshing the site.</p><pre>--- Oh dear, an error has occurred ---
  Unable to write to target ./_www/articles/content_pp_errors/parsing_error.html:
  
  Parsing error in: ./content_pp_errors/parsing_error.md
  
  Given:
  title: A broken article
  date 2025-06-08
  
  Message: `Yaml: error calling parser: could not find expected ':' character 0 position 0 returned: 0`
  ---
  </pre>

Cleanup
  $ pkill -f "unix_server_error.exe 8090" 2>/dev/null || true
  $ fuser -k 8090/tcp >/dev/null 2>&1 || true
