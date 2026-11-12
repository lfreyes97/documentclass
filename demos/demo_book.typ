// Demostración de la clase book. El estilo se elige con el preajuste que da el nombre:
//   typst compile --root . --input style=modern demos/demo_book.typ modern.pdf
// (classic, modern o elegant; sin `style`, classic). Ver también demo_pagestyle.typ.
#import "../lib.typ": (
  appendix, back, book, dedication, epigraph, front, main, tableofcontents, tocs, verse,
)

#let style = sys.inputs.at("style", default: "classic")

#show: book.with(
  title: "Libro de Ejemplo",
  subtitle: "Demostración de la clase book",
  author: "Autor Demo",
  date: "2026",
  publisher: "Editorial Typst",
  paper: "a5",
  // Doble cara: márgenes interior y exterior, portadilla y front matter en recto
  facing-pages: true,
  margin: (inside: 2.5cm, outside: 1.8cm, y: 2cm),
  // El mismo preajuste para títulos y cabeceras; el índice lo sigue con `tocs.setup`
  heading-style: style,
  page-style: style,
  minitoc: true,
)

#show: tocs.setup.with(style: style)

#show: front
#dedication[
  _Para todos los usuarios de Typst_
]

= Prefacio
Este es un libro de demostración creado con la clase `book`. Muestra las partes que lo componen: front matter con numeración romana, cuerpo con partes y capítulos, y back matter con un apéndice.

Cambia el aspecto con el argumento `style`, que elige a la vez las aperturas de capítulo (`heading-style`) y las cabeceras y pies (`page-style`).

#tableofcontents()

#show: main
= Primera parte
== Capítulo uno
#epigraph[El viaje de mil millas comienza con un paso.][Lao Tzu]

Este es el primer capítulo. Cada capítulo abre en página impar, y las cabeceras muestran la parte en las páginas pares y el capítulo en las impares.

=== Una sección
Las secciones tienen numeración propia (1.1, 1.2…). #lorem(60)

==== Una subsección
Y las subsecciones, un nivel más (1.1.1). #lorem(40)

===== Una sub-subsección
Hasta seis niveles de título, cada uno con su estilo en `heading-style`. #lorem(30)

====== Un párrafo con título
El último nivel, para títulos de párrafo. #lorem(30)

=== Otra sección
#verse[
  En un lugar de la Mancha, de cuyo nombre
  no quiero acordarme, no ha mucho tiempo
  que vivía un hidalgo de los de lanza en astillero.
]

#lorem(80)

== Capítulo dos
Texto del segundo capítulo. #lorem(120)

= Segunda parte
== Capítulo tres
Cada parte abre en su propia página, con su minitoc de capítulos. #lorem(100)

#show: back
#show: appendix
== Apéndice A
Apéndice de ejemplo. Los apéndices llevan letra en lugar de número. #lorem(40)
