// Orden de la primera parte del libro con portada: portada, reverso en blanco,
// portadilla en recto, reverso en blanco, índice en recto
#import "../lib.typ": *

#show: book.with(
  title: "Con portada", author: "A",
  cover: page(margin: 0pt, numbering: none, fill: teal)[#align(center + horizon)[PORTADA]],
)
#show: frontmatter
#tableofcontents()
#show: mainmatter
= Parte
== Capítulo
Texto.
