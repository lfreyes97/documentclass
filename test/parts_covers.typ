// use-parts: false con #part, blank-page, opciones del minitoc y h3-font en el índice
#import "../lib.typ": *

#show: book.with(
  title: "Sin partes",
  author: "A",
  use-parts: false,
  minitoc: true,
  minitoc-numbered: true,
)

#show: front
#tableofcontents(h3-font: "DejaVu Sans Mono")

#show: main
#blank-page()
= Capítulo uno <c1>
== Sección <s1>
#part[Primera parte] <p1>
= Capítulo dos <c2>
== Otra sección
REFS: @c1 | @s1 | @p1 | @c2 FIN
