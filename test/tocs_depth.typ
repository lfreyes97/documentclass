// Entradas del índice a cada `depth` (structure.py lo comprueba): `depth` cuenta los niveles bajo las partes,
// así que 1 lista partes y capítulos, 2 añade secciones y 3 subsecciones; `parts: false` quita las partes
#import "../lib.typ": *
#show: book.with(title: "Profundidad", facing-pages: false)
#show: frontmatter
#for (depth, parts) in ((1, true), (2, true), (3, true), (2, false)) {
  tableofcontents(depth: depth, parts: parts, title: [Indice#depth#if not parts [SinPartes]])
  pagebreak()
}
#show: mainmatter
= ParteA
== CapA
=== SecA
==== SubA
===== SubsubA
#lorem(20)
