#import "lib.typ": book, front, main, back, tableofcontents

#show: book.with(
  title: "El Arte de la Programación",
  author: "Donald Knuth",
  date: "2025",
)

#show: front

= Prefacio
Contenido del prefacio...

#tableofcontents()

#show: main

= Capítulo 1: Introducción
== Sección 1.1
=== Subsección 1.1.1

= Capítulo 2: Desarrollo
== Sección 2.1

#show: back

= Apéndice A
