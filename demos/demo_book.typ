#import "../lib.typ": appendix, back, book, dedication, epigraph, front, main

#show: book.with(
  title: "Libro de Ejemplo",
  subtitle: "Demostración de la clase book",
  author: "Autor Demo",
  date: "2026",
  publisher: "Editorial Typst",
)

#show: front
#dedication[
  _Para todos los usuarios de Typst_
]

= Prefacio
Este es un libro de demostración creado con la clase `book`.

#show: main
= Capítulo Uno
#epigraph[El viaje de mil millas comienza con un paso.][Lao Tzu]

Este es el primer capítulo.

== Sección 1.1
Texto de prueba.

#show: back
#show: appendix
= Apéndice A
Apéndice de ejemplo.
