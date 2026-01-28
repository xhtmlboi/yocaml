Eio server returns 500 and detailed required metadata error

  $ pkill -f "eio_server_error.exe 8081" 2>/dev/null || true
  $ fuser -k 8081/tcp >/dev/null 2>&1 || true

  $ ./bin/eio_server_error.exe 8081 content_pp_errors/required_metadata.md >/dev/null 2>&1 &

  $ sleep 1

  $ curl -sS http://127.0.0.1:8081/
  <h1>500 Internal server error</h1><hr /><p>The build failed while refreshing the site.</p><pre>--- Oh dear, an error has occurred ---
  Unable to write to target ./_www/articles/content_pp_errors/required_metadata.html:
  
  Required metadata in: ./content_pp_errors/required_metadata.md
  Entity: `Test_article`
  
  ---
  </pre>

Cleanup
  $ pkill -f "eio_server_error.exe 8081" 2>/dev/null || true
  $ fuser -k 8081/tcp >/dev/null 2>&1 || true
