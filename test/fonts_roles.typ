// Cada rol tipográfico con una fuente distinta, para comprobar la herencia
#import "../lib.typ": back, book, dropcap, front, main, tableofcontents

#show: book.with(
  title: "Prueba de fuentes",
  author: "Tester",
  minitoc: true,
  fonts: (
    body: "EB Garamond",
    heading: "DM Sans", // h2, h3, h4 lo heredan
    h1: "Bebas Neue",
    title: "Bodoni Moda",
    header: "Akshar",
    toc: "Cormorant Garamond",
    initials: "DM Serif Display",
    mono: "DM Mono",
  ),
)

#show: front
#tableofcontents()

#show: main
= Parte
== Capítulo
#dropcap[E][ste párrafo empieza con letra capital.]
=== Sección
==== Subsección
Texto con `código` y más texto. #lorem(400)
