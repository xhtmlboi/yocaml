Run the generator
  $ ./bin/gen.exe
  ./bin/gen.exe
  [DEBUG]Trigger in ./
  [DEBUG]Cache initiated in `./_www/.cache`
  [DEBUG]`./_www/style.css` will be written
  [INFO]`./_www/style.css` has been written
  [DEBUG]`./_www/articles/first_article.html` will be written
  [INFO]`./_www/articles/first_article.html` has been written
  [DEBUG]./content/templates/article.html already stored
  [DEBUG]./content/templates/layout.html already stored
  [DEBUG]`./_www/articles/second_article.html` will be written
  [INFO]`./_www/articles/second_article.html` has been written
  [DEBUG]./content/templates/article.html already stored
  [DEBUG]./content/templates/layout.html already stored
  [DEBUG]`./_www/articles-with-applicative-read/first_article.html` will be written
  [INFO]`./_www/articles-with-applicative-read/first_article.html` has been written
  [DEBUG]./content/templates/article.html already stored
  [DEBUG]./content/templates/layout.html already stored
  [DEBUG]`./_www/articles-with-applicative-read/second_article.html` will be written
  [INFO]`./_www/articles-with-applicative-read/second_article.html` has been written
  [DEBUG]./content/templates/article.html already stored
  [DEBUG]./content/templates/layout.html already stored
  [DEBUG]`./_www/articles-with-applicative-read-2/first_article.html` will be written
  [INFO]`./_www/articles-with-applicative-read-2/first_article.html` has been written
  [DEBUG]./content/templates/article.html already stored
  [DEBUG]./content/templates/layout.html already stored
  [DEBUG]`./_www/articles-with-applicative-read-2/second_article.html` will be written
  [INFO]`./_www/articles-with-applicative-read-2/second_article.html` has been written
  [DEBUG]Cache stored in `./_www/.cache`

Inspect tree
  $ tree _www
  _www
  |-- articles
  |   |-- first_article.html
  |   `-- second_article.html
  |-- articles-with-applicative-read
  |   |-- first_article.html
  |   `-- second_article.html
  |-- articles-with-applicative-read-2
  |   |-- first_article.html
  |   `-- second_article.html
  `-- style.css
  
  4 directories, 7 files

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

Inspect First Applicative read (same content of article)
  $ cat _www/articles-with-applicative-read/first_article.html
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

Inspect Second Applicative read (same content of article)
  $ cat _www/articles-with-applicative-read/second_article.html
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


Inspect First Applicative read (same content of article)
  $ cat _www/articles-with-applicative-read-2/first_article.html
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

Inspect Second Applicative read (same content of article)
  $ cat _www/articles-with-applicative-read-2/second_article.html
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

Run the Liquid generator
  $ ./bin/gen_liquid.exe
  ./bin/gen_liquid.exe
  [DEBUG]Trigger in ./
  [DEBUG]Cache restored from `./_www/.cache`
  [DEBUG]`./_www/liquid-articles/first_article.html` will be written
  [INFO]`./_www/liquid-articles/first_article.html` has been written
  [DEBUG]./content/templates/article.liquid already stored
  [DEBUG]./content/templates/layout.liquid already stored
  [DEBUG]`./_www/liquid-articles/second_article.html` will be written
  [INFO]`./_www/liquid-articles/second_article.html` has been written
  [DEBUG]Cache stored in `./_www/.cache`
Inspect tree after Liquid generation
  $ tree _www
  _www
  |-- articles
  |   |-- first_article.html
  |   `-- second_article.html
  |-- articles-with-applicative-read
  |   |-- first_article.html
  |   `-- second_article.html
  |-- articles-with-applicative-read-2
  |   |-- first_article.html
  |   `-- second_article.html
  |-- liquid-articles
  |   |-- first_article.html
  |   `-- second_article.html
  `-- style.css
  
  5 directories, 9 files

Inspect Liquid First Article
  $ cat _www/liquid-articles/first_article.html | head -15
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

Inspect Liquid Second Article
  $ cat _www/liquid-articles/second_article.html
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
        Copyright YOCaml with Liquid
      </footer>
    </body>
  </html>
Clean the sandbox
  $ rm -r _www

Observe Residual Removing
  $ ./bin/gen_residuals.exe
  ./bin/gen_residuals.exe
  [DEBUG]Cache initiated in `./residuals_build/cache`
  [DEBUG]`./residuals_build/1.txt` will be written
  [INFO]`./residuals_build/1.txt` has been written
  [DEBUG]`./residuals_build/2.txt` will be written
  [INFO]`./residuals_build/2.txt` has been written
  [DEBUG]`./residuals_build/3.txt` will be written
  [INFO]`./residuals_build/3.txt` has been written
  [INFO]Remove residuals for ./residuals_build
  [INFO]./residuals_build/4.txt deleted!
  [INFO]./residuals_build/5.txt deleted!
  [DEBUG]Cache stored in `./residuals_build/cache`

  $ ls residuals_build
  1.txt
  2.txt
  3.txt
  cache
