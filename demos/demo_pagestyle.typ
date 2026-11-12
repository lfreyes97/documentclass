// Preajustes de `page-style`. Un PDF por preajuste:
//   typst compile --root . --input style=modern demos/demo_pagestyle.typ modern.pdf
#import "../lib.typ": *

#let style = sys.inputs.at("style", default: "classic")
#let toc-style = if style in ("modern", "elegant") { style } else { "classic" }

#show: book.with(
  title: "Estilos de página",
  author: "A. Autor",
  paper: "a5",
  page-style: style,
)
#show: tocs.setup.with(style: toc-style)

#show: front
#tableofcontents()

#show: main
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
