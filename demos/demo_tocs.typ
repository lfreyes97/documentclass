// Libro con los índices de tocs: preset, título corto, parciales y apéndices
#import "../lib.typ": *

#show: book.with(
  title: "Ensayos reunidos",
  author: "Autor",
  fonts: (toc: "Libertinus Serif"),
  labels: (contents: "Índice"),
)
#show: tocs.setup.with(
  style: "elegant",
  levels: (chapter: (appendix-label: true)),
)

#show: front
== Prefacio
Este libro reúne…

#tocs.toc(depth: 2)
#tocs.lof()

#show: main
= Fundamentos
== Sobre el conocimiento y sus condiciones previas #tocs.short[Sobre el conocimiento]
#tocs.partial()
=== El punto de partida
=== La autoridad
#figure(rect(width: 4cm, height: 2cm), caption: [Esquema general])
== Sobre el método
=== Presuposiciones

= Aplicaciones
== La historia
=== Fuentes

#show: back
#show: appendix
== Cronología
#show: end-appendix
== Bibliografía
