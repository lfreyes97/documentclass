#import "../lib.typ": (
  appendix, back, blockquote, book, colophon, dedication, end-appendix, epigraph, front, half-title, main,
  tableofcontents, verse,
)

#show: book.with(
  title: "El Arte de la Programación",
  subtitle: "Una guía completa para programadores",
  author: "Donald Knuth",
  date: "2025",
  publisher: "Editorial Académica",
)

// --- Half-title (antes del frontmatter)
#half-title(title: "El Arte de la Programación")

// --- Colophon (reverso de la portada)
#colophon[
  © 2025 Donald Knuth. Todos los derechos reservados.

  ISBN: 978-0-000-00000-0

  Primera edición, enero de 2025.

  Compuesto con Typst.
]

#show: front

// --- Dedicatoria
#dedication[
  _A mis padres,\
  que me enseñaron a pensar._
]

// --- Prefacio con epígrafe
== Prefacio

#epigraph(
  [Los verdaderos héroes del software son aquellos que escriben código que otros pueden entender.],
  attribution: "Martin Fowler",
)

Este libro trata sobre el arte de escribir buenos programas...

#tableofcontents()

// --- MAINMATTER ---
#show: main

= Parte I

== Capítulo 1: Introducción

#epigraph(
  [Primero, resuelve el problema. Luego, escribe el código.],
  attribution: "John Johnson",
)

=== Sección 1.1
Contenido de la sección 1.1...

#blockquote[
  La ciencia computacional no trata sobre los computadores, como la astronomía no trata sobre los telescopios.
]

==== Subsección 1.1.1
Contenido de la subsección 1.1.1...

==== Subsección 1.1.2
Contenido de la subsección 1.1.2...

=== Sección 1.2

#verse[
  Bit a bit construimos el mundo,\
  línea a línea tejemos la red,\
  de ceros y unos se forma la urdimbre\
  que sostiene nuestra era digital.
]

Contenido de la sección 1.2...

== Capítulo 2: Desarrollo
=== Sección 2.1
Contenido de la sección 2.1...
==== Subsección 2.1.1
Algo más detallado aquí...

// --- BACKMATTER ---
#show: back

#show: appendix

== Tablas de Referencia
=== Tabla de Conversiones
Contenido de la tabla de conversiones...
==== Notas sobre conversiones
Detalles adicionales...
=== Tabla de Constantes
Contenido de la tabla de constantes...

== Glosario Técnico
=== Términos Generales
Contenido de términos generales...
=== Abreviaciones
Contenido de abreviaciones...

#end-appendix()

== Bibliografía
Contenido de la bibliografía...
