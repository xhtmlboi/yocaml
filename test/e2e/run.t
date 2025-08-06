Run the generator
  $ ./bin/gen.exe
  ./bin/gen.exe
  [DEBUG]Trigger in ./
  [DEBUG]Cache initiated in `./_www/.cache`
  [DEBUG]`./_www/style.css` will be written
  [INFO]`./_www/style.css` has been written
  [DEBUG]`./_www/articles/second_article.html` will be written
  [INFO]`./_www/articles/second_article.html` has been written
  [DEBUG]./content/templates/article.html already stored
  [DEBUG]./content/templates/layout.html already stored
  [DEBUG]`./_www/articles/first_article.html` will be written
  [INFO]`./_www/articles/first_article.html` has been written
  [DEBUG]Cache stored in `./_www/.cache`

Inspect tree
  $ tree _www
  _www
  |-- articles
  |   |-- first_article.html
  |   `-- second_article.html
  `-- style.css
  
  2 directories, 3 files

Inspect CSS files
  $ cat _www/style.css
  
  body {
      font-family: sans-serif;
  }
  
  body {
      color: red;
  }

Inspect First Article
  $ cat _www/articles/first_article.html
  <!doctype html>
  <html lang="en-US">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width" />
      <title>Test.com - A first article</title>
    </head>
    <body>
      <header>
        <h1>Test.com</h1>
      </header>
      <main><h2>A first article</h2>
  <section><p>Test <em>Test of an article</em></p>
  </section>
  </main>
      <footer>
        Copyright YOCaml
      </footer>
    </body>
  </html>

Inspect Second Article
  $ cat _www/articles/second_article.html
  <!doctype html>
  <html lang="en-US">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width" />
      <title>Test.com - A second article</title>
    </head>
    <body>
      <header>
        <h1>Test.com</h1>
      </header>
      <main><h2>A second article</h2>
  <section><blockquote>
  <p>A <em>new</em> <strong>article</strong>!</p>
  </blockquote>
  </section>
  </main>
      <footer>
        Copyright YOCaml
      </footer>
    </body>
  </html>

Clean the sandbox
  $ rm -r _www
