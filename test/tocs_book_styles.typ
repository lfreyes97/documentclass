#import "../lib.typ": *

#show: book.with(title: "Índices", author: "Autor", fonts: (toc: "Libertinus Serif"))

#show: frontmatter
== Prefacio
Texto.
#tocs.toc()
#tocs.toc(style: "modern", title: [Contenido (modern)])
#tocs.toc(style: "elegant", title: [Contenido (elegant)])
#tocs.toc(style: "compact", title: [Contenido (compact)], depth: 3)
#tocs.lof()
#tocs.lot()

#show: mainmatter
= Fundamentos
== Introducción a un tema con un título deliberadamente largo para que ocupe más de una línea en el índice #tocs.short[Introducción]
#tocs.partial()
=== Primera sección
==== Una subsección
=== Segunda sección con un título también bastante largo que obligue a partir la línea
#figure(rect(), caption: [Un rectángulo])
== Método
=== Datos
#figure(table[a], caption: [Una tabla])
=== Notas internas #tocs.omit()
= Aplicaciones
== Casos
#tocs.add-entry(role: "section")[Entrada manual]
=== Caso A
#figure(circle(radius: 5pt), caption: [Un círculo])
#show: backmatter
#show: appendix
== Tablas auxiliares
=== Detalle
#show: end-appendix
== Glosario
