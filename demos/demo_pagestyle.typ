// Cabeceras y pies. Un PDF por nombre; con un tema (classic, modern, elegant) cambia todo el
// libro, con una variante (plain, folio-outer, running-outer) solo la cabecera y el pie:
//   typst compile --root . --input style=modern demos/demo_pagestyle.typ modern.pdf
//   typst compile --root . --input style=folio-outer demos/demo_pagestyle.typ folio-outer.pdf
#import "../lib.typ": *

#let name = sys.inputs.at("style", default: "classic")
#let is-theme = name in ("classic", "modern", "elegant")

#show: book.with(
  title: "Estilos de página",
  author: "A. Autor",
  paper: "a5",
  style: if is-theme { name } else { auto },
  page-style: if is-theme { auto } else { name },
)

#show: frontmatter
#tableofcontents()

#show: mainmatter
= Primera parte
== Un capítulo con título largo
=== Una sección
#lorem(250)
=== Otra sección
#lorem(250)
== Segundo capítulo
#lorem(300)
= Segunda parte
== Tercer capítulo
#lorem(500)
