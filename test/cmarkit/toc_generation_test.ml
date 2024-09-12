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

let run document =
  let arrow =
    let open Yocaml.Task in
    const document >>> Yocaml_cmarkit.to_html_with_toc () >>| fun (toc, doc) ->
    let toc =
      Option.fold ~none:""
        ~some:(fun toc -> "Table of content\n\n" ^ toc ^ "\n\n")
        toc
    in
    toc ^ doc
  in
  let program cache =
    let open Yocaml.Eff in
    return cache
    >>= Yocaml.Action.write_static_file Yocaml.Path.(rel [ "test.md" ]) arrow
  in
  let trace =
    Test_lib.Fs.create_trace ~time:0 Test_lib.Fs.(from_list [ dir "." [] ])
  in
  let trace, _ = Test_lib.Fs.run ~trace program Yocaml.Cache.empty in
  let fs = Test_lib.Fs.trace_system trace in
  Format.printf "%a\n" Test_lib.Fs.pp fs

let%expect_test "test without toc" =
  run {|
A document _without_ any **headings**
|};
  [%expect
    {|
    └─⟤ . (mtime: 0) /
                  └─⟢ test.md (mtime: 0) -> "<p>A document <em>without</em> any <strong>headings</strong></p>
    "
    |}]

let%expect_test "test with toc" =
  run
    {|
A document _with_ some **headings**

# A big title
    
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et eleifend orci. Nulla id lacinia purus. Sed quis enim sed justo rutrum gravida. Cras non tellus ex. Suspendisse potenti. Sed dictum, dolor in pretium malesuada, felis nisl vestibulum metus, posuere tincidunt dui lorem vitae ipsum. Pellentesque consectetur diam mauris, sed maximus leo sodales in. Proin vel condimentum diam. Nullam aliquet ante vel eros imperdiet, non laoreet orci maximus. Mauris vel ultricies sem. Interdum et malesuada fames ac ante ipsum primis in faucibus. Phasellus quam massa, consequat ac luctus non, commodo non turpis. Aenean sed dolor nec lectus commodo posuere molestie ac nulla.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et eleifend orci. Nulla id lacinia purus. Sed quis enim sed justo rutrum gravida. Cras non tellus ex. Suspendisse potenti. Sed dictum, dolor in pretium malesuada, felis nisl vestibulum metus, posuere tincidunt dui lorem vitae ipsum. Pellentesque consectetur diam mauris, sed maximus leo sodales in. Proin vel condimentum diam. Nullam aliquet ante vel eros imperdiet, non laoreet orci maximus. Mauris vel ultricies sem. Interdum et malesuada fames ac ante ipsum primis in faucibus. Phasellus quam massa, consequat ac luctus non, commodo non turpis. Aenean sed dolor nec lectus commodo posuere molestie ac nulla.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et eleifend orci. Nulla id lacinia purus. Sed quis enim sed justo rutrum gravida. Cras non tellus ex. Suspendisse potenti. Sed dictum, dolor in pretium malesuada, felis nisl vestibulum metus, posuere tincidunt dui lorem vitae ipsum. Pellentesque consectetur diam mauris, sed maximus leo sodales in. Proin vel condimentum diam. Nullam aliquet ante vel eros imperdiet, non laoreet orci maximus. Mauris vel ultricies sem. Interdum et malesuada fames ac ante ipsum primis in faucibus. Phasellus quam massa, consequat ac luctus non, commodo non turpis. Aenean sed dolor nec lectus commodo posuere molestie ac nulla.

    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et eleifend orci. Nulla id lacinia purus. Sed quis enim sed justo rutrum gravida. Cras non tellus ex. Suspendisse potenti. Sed dictum, dolor in pretium malesuada, felis nisl vestibulum metus, posuere tincidunt dui lorem vitae ipsum. Pellentesque consectetur diam mauris, sed maximus leo sodales in. Proin vel condimentum diam. Nullam aliquet ante vel eros imperdiet, non laoreet orci maximus. Mauris vel ultricies sem. Interdum et malesuada fames ac ante ipsum primis in faucibus. Phasellus quam massa, consequat ac luctus non, commodo non turpis. Aenean sed dolor nec lectus commodo posuere molestie ac nulla.

    
## An other title

 Vestibulum dapibus lorem at sem fermentum, a iaculis est auctor. Pellentesque convallis ipsum at odio congue ultrices. Proin efficitur mi diam, nec facilisis erat commodo et. Donec arcu magna, sagittis a eros id, bibendum semper dui. Pellentesque bibendum aliquet diam, porta consequat nisi malesuada vel. In aliquet volutpat sapien id luctus. Aliquam erat volutpat. Curabitur ut dui tincidunt, mattis felis sit amet, hendrerit enim. Fusce pulvinar pellentesque turpis ut ullamcorper. Nullam non libero felis. Sed dapibus euismod neque, nec interdum nisi pharetra egestas. Etiam nec lacus sed nisi ultricies porttitor rhoncus id nibh.

Nullam laoreet aliquam justo, vel consectetur quam vehicula ac. Suspendisse pellentesque, metus nec fermentum semper, neque leo laoreet urna, nec hendrerit massa justo vel magna. Donec faucibus lorem ut dictum mattis. In mattis, ex a viverra fermentum, ante magna tincidunt tellus, non suscipit nunc augue eget nibh. Quisque luctus, nibh eu blandit efficitur, diam nisi feugiat enim, sit amet viverra velit metus sit amet diam. Phasellus vel nulla vitae eros lobortis rutrum. Donec quis libero dolor. Ut vitae efficitur elit. Duis pulvinar eleifend gravida. Nulla ut egestas massa. Aliquam consequat tellus sed massa blandit, a iaculis mauris aliquam. Duis sed nisl laoreet, egestas ex eu, porttitor orci. Vivamus non aliquam velit. Praesent pretium facilisis lacinia. Ut eget libero diam. Praesent rhoncus molestie orci pretium dignissim.

     Vestibulum dapibus lorem at sem fermentum, a iaculis est auctor. Pellentesque convallis ipsum at odio congue ultrices. Proin efficitur mi diam, nec facilisis erat commodo et. Donec arcu magna, sagittis a eros id, bibendum semper dui. Pellentesque bibendum aliquet diam, porta consequat nisi malesuada vel. In aliquet volutpat sapien id luctus. Aliquam erat volutpat. Curabitur ut dui tincidunt, mattis felis sit amet, hendrerit enim. Fusce pulvinar pellentesque turpis ut ullamcorper. Nullam non libero felis. Sed dapibus euismod neque, nec interdum nisi pharetra egestas. Etiam nec lacus sed nisi ultricies porttitor rhoncus id nibh.

Nullam laoreet aliquam justo, vel consectetur quam vehicula ac. Suspendisse pellentesque, metus nec fermentum semper, neque leo laoreet urna, nec hendrerit massa justo vel magna. Donec faucibus lorem ut dictum mattis. In mattis, ex a viverra fermentum, ante magna tincidunt tellus, non suscipit nunc augue eget nibh. Quisque luctus, nibh eu blandit efficitur, diam nisi feugiat enim, sit amet viverra velit metus sit amet diam. Phasellus vel nulla vitae eros lobortis rutrum. Donec quis libero dolor. Ut vitae efficitur elit. Duis pulvinar eleifend gravida. Nulla ut egestas massa. Aliquam consequat tellus sed massa blandit, a iaculis mauris aliquam. Duis sed nisl laoreet, egestas ex eu, porttitor orci. Vivamus non aliquam velit. Praesent pretium facilisis lacinia. Ut eget libero diam. Praesent rhoncus molestie orci pretium dignissim. 
    
### A third level

Nulla lacinia massa nec felis vestibulum, vel ullamcorper purus tristique. Integer nisi urna, molestie at feugiat a, pulvinar et tellus. Curabitur sollicitudin, orci sit amet consequat hendrerit, ante odio pretium purus, et accumsan enim augue at justo. In at mauris tristique, ullamcorper ex in, pharetra dolor. Nullam porta sagittis vestibulum. Suspendisse ultricies sem dui, eget ullamcorper velit consectetur sed. Vestibulum ac dignissim ante. Cras mattis bibendum felis vitae convallis. Donec ultrices nec lectus eget malesuada. Praesent eget erat rhoncus, lacinia massa vitae, iaculis risus. Donec vestibulum ut tellus id facilisis. Fusce nibh ipsum, cursus a auctor lacinia, dictum ornare est. Curabitur lobortis, dui vel malesuada euismod, turpis arcu sodales nibh, ac hendrerit elit risus non nulla. 
    
# Yo

 Nulla lacinia massa nec felis vestibulum, vel ullamcorper purus tristique. Integer nisi urna, molestie at feugiat a, pulvinar et tellus. Curabitur sollicitudin, orci sit amet consequat hendrerit, ante odio pretium purus, et accumsan enim augue at justo. In at mauris tristique, ullamcorper ex in, pharetra dolor. Nullam porta sagittis vestibulum. Suspendisse ultricies sem dui, eget ullamcorper velit consectetur sed. Vestibulum ac dignissim ante. Cras mattis bibendum felis vitae convallis. Donec ultrices nec lectus eget malesuada. Praesent eget erat rhoncus, lacinia massa vitae, iaculis risus. Donec vestibulum ut tellus id facilisis. Fusce nibh ipsum, cursus a auctor lacinia, dictum ornare est. Curabitur lobortis, dui vel malesuada euismod, turpis arcu sodales nibh, ac hendrerit elit risus non nulla.

     Vestibulum dapibus lorem at sem fermentum, a iaculis est auctor. Pellentesque convallis ipsum at odio congue ultrices. Proin efficitur mi diam, nec facilisis erat commodo et. Donec arcu magna, sagittis a eros id, bibendum semper dui. Pellentesque bibendum aliquet diam, porta consequat nisi malesuada vel. In aliquet volutpat sapien id luctus. Aliquam erat volutpat. Curabitur ut dui tincidunt, mattis felis sit amet, hendrerit enim. Fusce pulvinar pellentesque turpis ut ullamcorper. Nullam non libero felis. Sed dapibus euismod neque, nec interdum nisi pharetra egestas. Etiam nec lacus sed nisi ultricies porttitor rhoncus id nibh.

Nullam laoreet aliquam justo, vel consectetur quam vehicula ac. Suspendisse pellentesque, metus nec fermentum semper, neque leo laoreet urna, nec hendrerit massa justo vel magna. Donec faucibus lorem ut dictum mattis. In mattis, ex a viverra fermentum, ante magna tincidunt tellus, non suscipit nunc augue eget nibh. Quisque luctus, nibh eu blandit efficitur, diam nisi feugiat enim, sit amet viverra velit metus sit amet diam. Phasellus vel nulla vitae eros lobortis rutrum. Donec quis libero dolor. Ut vitae efficitur elit. Duis pulvinar eleifend gravida. Nulla ut egestas massa. Aliquam consequat tellus sed massa blandit, a iaculis mauris aliquam. Duis sed nisl laoreet, egestas ex eu, porttitor orci. Vivamus non aliquam velit. Praesent pretium facilisis lacinia. Ut eget libero diam. Praesent rhoncus molestie orci pretium dignissim. 

#### Test
    
Vestibulum accumsan dapibus neque eget finibus. Mauris eleifend placerat aliquet. Maecenas luctus tincidunt turpis ac tincidunt. Nulla metus dolor, lacinia id dolor non, aliquam mattis est. Suspendisse sit amet suscipit tellus. Ut iaculis malesuada risus at convallis. Aenean efficitur tortor et ligula finibus, at tristique nisl blandit. Nunc tempor porttitor tellus ut congue. Curabitur interdum mollis arcu in rutrum. Donec molestie eget enim a scelerisque. Nullam libero arcu, molestie eu fringilla eu, volutpat vitae lorem. Phasellus tincidunt lectus gravida, lobortis felis eu, vehicula ipsum. Aliquam quam sapien, venenatis id massa a, tempus mollis ex. 
    
|};
  [%expect
    {|
    └─⟤ . (mtime: 0) /
                  └─⟢ test.md (mtime: 0) -> "Table of content

    <ul><li><a href="#a-big-title">A big title</a><ul><li><a href="#an-other-title">An other title</a><ul><li><a href="#a-third-level">A third level</a></li></ul></li></ul></li><li><a href="#yo">Yo</a><ul><li><a href="#test">Test</a></li></ul></li></ul>

    <p>A document <em>with</em> some <strong>headings</strong></p>
    <h1 id="a-big-title"><a class="anchor" aria-hidden="true" href="#a-big-title"></a>A big title</h1>
    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et eleifend orci. Nulla id lacinia purus. Sed quis enim sed justo rutrum gravida. Cras non tellus ex. Suspendisse potenti. Sed dictum, dolor in pretium malesuada, felis nisl vestibulum metus, posuere tincidunt dui lorem vitae ipsum. Pellentesque consectetur diam mauris, sed maximus leo sodales in. Proin vel condimentum diam. Nullam aliquet ante vel eros imperdiet, non laoreet orci maximus. Mauris vel ultricies sem. Interdum et malesuada fames ac ante ipsum primis in faucibus. Phasellus quam massa, consequat ac luctus non, commodo non turpis. Aenean sed dolor nec lectus commodo posuere molestie ac nulla.</p>
    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et eleifend orci. Nulla id lacinia purus. Sed quis enim sed justo rutrum gravida. Cras non tellus ex. Suspendisse potenti. Sed dictum, dolor in pretium malesuada, felis nisl vestibulum metus, posuere tincidunt dui lorem vitae ipsum. Pellentesque consectetur diam mauris, sed maximus leo sodales in. Proin vel condimentum diam. Nullam aliquet ante vel eros imperdiet, non laoreet orci maximus. Mauris vel ultricies sem. Interdum et malesuada fames ac ante ipsum primis in faucibus. Phasellus quam massa, consequat ac luctus non, commodo non turpis. Aenean sed dolor nec lectus commodo posuere molestie ac nulla.</p>
    <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et eleifend orci. Nulla id lacinia purus. Sed quis enim sed justo rutrum gravida. Cras non tellus ex. Suspendisse potenti. Sed dictum, dolor in pretium malesuada, felis nisl vestibulum metus, posuere tincidunt dui lorem vitae ipsum. Pellentesque consectetur diam mauris, sed maximus leo sodales in. Proin vel condimentum diam. Nullam aliquet ante vel eros imperdiet, non laoreet orci maximus. Mauris vel ultricies sem. Interdum et malesuada fames ac ante ipsum primis in faucibus. Phasellus quam massa, consequat ac luctus non, commodo non turpis. Aenean sed dolor nec lectus commodo posuere molestie ac nulla.</p>
    <pre><code>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam et eleifend orci. Nulla id lacinia purus. Sed quis enim sed justo rutrum gravida. Cras non tellus ex. Suspendisse potenti. Sed dictum, dolor in pretium malesuada, felis nisl vestibulum metus, posuere tincidunt dui lorem vitae ipsum. Pellentesque consectetur diam mauris, sed maximus leo sodales in. Proin vel condimentum diam. Nullam aliquet ante vel eros imperdiet, non laoreet orci maximus. Mauris vel ultricies sem. Interdum et malesuada fames ac ante ipsum primis in faucibus. Phasellus quam massa, consequat ac luctus non, commodo non turpis. Aenean sed dolor nec lectus commodo posuere molestie ac nulla.
    </code></pre>
    <h2 id="an-other-title"><a class="anchor" aria-hidden="true" href="#an-other-title"></a>An other title</h2>
    <p>Vestibulum dapibus lorem at sem fermentum, a iaculis est auctor. Pellentesque convallis ipsum at odio congue ultrices. Proin efficitur mi diam, nec facilisis erat commodo et. Donec arcu magna, sagittis a eros id, bibendum semper dui. Pellentesque bibendum aliquet diam, porta consequat nisi malesuada vel. In aliquet volutpat sapien id luctus. Aliquam erat volutpat. Curabitur ut dui tincidunt, mattis felis sit amet, hendrerit enim. Fusce pulvinar pellentesque turpis ut ullamcorper. Nullam non libero felis. Sed dapibus euismod neque, nec interdum nisi pharetra egestas. Etiam nec lacus sed nisi ultricies porttitor rhoncus id nibh.</p>
    <p>Nullam laoreet aliquam justo, vel consectetur quam vehicula ac. Suspendisse pellentesque, metus nec fermentum semper, neque leo laoreet urna, nec hendrerit massa justo vel magna. Donec faucibus lorem ut dictum mattis. In mattis, ex a viverra fermentum, ante magna tincidunt tellus, non suscipit nunc augue eget nibh. Quisque luctus, nibh eu blandit efficitur, diam nisi feugiat enim, sit amet viverra velit metus sit amet diam. Phasellus vel nulla vitae eros lobortis rutrum. Donec quis libero dolor. Ut vitae efficitur elit. Duis pulvinar eleifend gravida. Nulla ut egestas massa. Aliquam consequat tellus sed massa blandit, a iaculis mauris aliquam. Duis sed nisl laoreet, egestas ex eu, porttitor orci. Vivamus non aliquam velit. Praesent pretium facilisis lacinia. Ut eget libero diam. Praesent rhoncus molestie orci pretium dignissim.</p>
    <pre><code> Vestibulum dapibus lorem at sem fermentum, a iaculis est auctor. Pellentesque convallis ipsum at odio congue ultrices. Proin efficitur mi diam, nec facilisis erat commodo et. Donec arcu magna, sagittis a eros id, bibendum semper dui. Pellentesque bibendum aliquet diam, porta consequat nisi malesuada vel. In aliquet volutpat sapien id luctus. Aliquam erat volutpat. Curabitur ut dui tincidunt, mattis felis sit amet, hendrerit enim. Fusce pulvinar pellentesque turpis ut ullamcorper. Nullam non libero felis. Sed dapibus euismod neque, nec interdum nisi pharetra egestas. Etiam nec lacus sed nisi ultricies porttitor rhoncus id nibh.
    </code></pre>
    <p>Nullam laoreet aliquam justo, vel consectetur quam vehicula ac. Suspendisse pellentesque, metus nec fermentum semper, neque leo laoreet urna, nec hendrerit massa justo vel magna. Donec faucibus lorem ut dictum mattis. In mattis, ex a viverra fermentum, ante magna tincidunt tellus, non suscipit nunc augue eget nibh. Quisque luctus, nibh eu blandit efficitur, diam nisi feugiat enim, sit amet viverra velit metus sit amet diam. Phasellus vel nulla vitae eros lobortis rutrum. Donec quis libero dolor. Ut vitae efficitur elit. Duis pulvinar eleifend gravida. Nulla ut egestas massa. Aliquam consequat tellus sed massa blandit, a iaculis mauris aliquam. Duis sed nisl laoreet, egestas ex eu, porttitor orci. Vivamus non aliquam velit. Praesent pretium facilisis lacinia. Ut eget libero diam. Praesent rhoncus molestie orci pretium dignissim.</p>
    <h3 id="a-third-level"><a class="anchor" aria-hidden="true" href="#a-third-level"></a>A third level</h3>
    <p>Nulla lacinia massa nec felis vestibulum, vel ullamcorper purus tristique. Integer nisi urna, molestie at feugiat a, pulvinar et tellus. Curabitur sollicitudin, orci sit amet consequat hendrerit, ante odio pretium purus, et accumsan enim augue at justo. In at mauris tristique, ullamcorper ex in, pharetra dolor. Nullam porta sagittis vestibulum. Suspendisse ultricies sem dui, eget ullamcorper velit consectetur sed. Vestibulum ac dignissim ante. Cras mattis bibendum felis vitae convallis. Donec ultrices nec lectus eget malesuada. Praesent eget erat rhoncus, lacinia massa vitae, iaculis risus. Donec vestibulum ut tellus id facilisis. Fusce nibh ipsum, cursus a auctor lacinia, dictum ornare est. Curabitur lobortis, dui vel malesuada euismod, turpis arcu sodales nibh, ac hendrerit elit risus non nulla.</p>
    <h1 id="yo"><a class="anchor" aria-hidden="true" href="#yo"></a>Yo</h1>
    <p>Nulla lacinia massa nec felis vestibulum, vel ullamcorper purus tristique. Integer nisi urna, molestie at feugiat a, pulvinar et tellus. Curabitur sollicitudin, orci sit amet consequat hendrerit, ante odio pretium purus, et accumsan enim augue at justo. In at mauris tristique, ullamcorper ex in, pharetra dolor. Nullam porta sagittis vestibulum. Suspendisse ultricies sem dui, eget ullamcorper velit consectetur sed. Vestibulum ac dignissim ante. Cras mattis bibendum felis vitae convallis. Donec ultrices nec lectus eget malesuada. Praesent eget erat rhoncus, lacinia massa vitae, iaculis risus. Donec vestibulum ut tellus id facilisis. Fusce nibh ipsum, cursus a auctor lacinia, dictum ornare est. Curabitur lobortis, dui vel malesuada euismod, turpis arcu sodales nibh, ac hendrerit elit risus non nulla.</p>
    <pre><code> Vestibulum dapibus lorem at sem fermentum, a iaculis est auctor. Pellentesque convallis ipsum at odio congue ultrices. Proin efficitur mi diam, nec facilisis erat commodo et. Donec arcu magna, sagittis a eros id, bibendum semper dui. Pellentesque bibendum aliquet diam, porta consequat nisi malesuada vel. In aliquet volutpat sapien id luctus. Aliquam erat volutpat. Curabitur ut dui tincidunt, mattis felis sit amet, hendrerit enim. Fusce pulvinar pellentesque turpis ut ullamcorper. Nullam non libero felis. Sed dapibus euismod neque, nec interdum nisi pharetra egestas. Etiam nec lacus sed nisi ultricies porttitor rhoncus id nibh.
    </code></pre>
    <p>Nullam laoreet aliquam justo, vel consectetur quam vehicula ac. Suspendisse pellentesque, metus nec fermentum semper, neque leo laoreet urna, nec hendrerit massa justo vel magna. Donec faucibus lorem ut dictum mattis. In mattis, ex a viverra fermentum, ante magna tincidunt tellus, non suscipit nunc augue eget nibh. Quisque luctus, nibh eu blandit efficitur, diam nisi feugiat enim, sit amet viverra velit metus sit amet diam. Phasellus vel nulla vitae eros lobortis rutrum. Donec quis libero dolor. Ut vitae efficitur elit. Duis pulvinar eleifend gravida. Nulla ut egestas massa. Aliquam consequat tellus sed massa blandit, a iaculis mauris aliquam. Duis sed nisl laoreet, egestas ex eu, porttitor orci. Vivamus non aliquam velit. Praesent pretium facilisis lacinia. Ut eget libero diam. Praesent rhoncus molestie orci pretium dignissim.</p>
    <h4 id="test"><a class="anchor" aria-hidden="true" href="#test"></a>Test</h4>
    <p>Vestibulum accumsan dapibus neque eget finibus. Mauris eleifend placerat aliquet. Maecenas luctus tincidunt turpis ac tincidunt. Nulla metus dolor, lacinia id dolor non, aliquam mattis est. Suspendisse sit amet suscipit tellus. Ut iaculis malesuada risus at convallis. Aenean efficitur tortor et ligula finibus, at tristique nisl blandit. Nunc tempor porttitor tellus ut congue. Curabitur interdum mollis arcu in rutrum. Donec molestie eget enim a scelerisque. Nullam libero arcu, molestie eu fringilla eu, volutpat vitae lorem. Phasellus tincidunt lectus gravida, lobortis felis eu, vehicula ipsum. Aliquam quam sapien, venenatis id massa a, tempus mollis ex.</p>
    "
    |}]
