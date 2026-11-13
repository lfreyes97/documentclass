// Referencias cruzadas, numeración por capítulo, apéndices e idioma en book
#import "../lib.typ": *

#show: book.with(title: "Prueba", author: "A", equation-numbering: true)

#show: frontmatter
= Prefacio <pref>
#tableofcontents()
#listoffigures()

#show: mainmatter
= Primera parte <p1>
== Uno <c1>
=== Sección <s11>
#figure(rect(), caption: [Primera]) <f11>
$ a = b $ <e11>
== Dos <c2>
#figure(rect(), caption: [Segunda]) <f21>
#figure(table[x], caption: [Tabla]) <t21>
= Segunda parte <p2>
== Tres <c3>
==== Sub <ss>
#figure(rect(), caption: [Tercera]) <f31>

REFS: @p1 | @p2 | @c1 | @c2 | @c3 | @s11 | @ss | @f11 | @f21 | @t21 | @f31 | @e11 | @a1 | @a1s | @fa1 FIN

#show: backmatter
#show: appendix
== Tablas <a1>
=== Datos <a1s>
#figure(rect(), caption: [En apéndice]) <fa1>
#show: end-appendix
#bibliography("refs.bib")
@vantil
