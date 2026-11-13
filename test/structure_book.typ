// Fixture de test/structure.py: un libro con las partes habituales para comprobar folios,
// cabeceras de `classic` y páginas en blanco. Los títulos son únicos y fáciles de buscar.
#import "../lib.typ": *

#show: book.with(
  title: "LibroEstructura",
  author: "Autor",
  cover: page(margin: 0pt, numbering: none)[PORTADA],
)
#show: frontmatter
#tableofcontents()
#show: mainmatter
= ParteUno
== CapituloAlfa
=== SeccionUno
#lorem(350)
=== SeccionDos
#lorem(350)
== CapituloBeta
#lorem(250)
= ParteDos
== CapituloGamma
#lorem(500)
#show: backmatter
== Bibliografia
#lorem(40)
