// `page-multiple`: páginas en blanco antes de la contraportada hasta un total múltiplo de 4 (o de lo que diga
// `--input multiple=…`), como pide una imprenta. structure.py comprueba el total, que la contraportada sigue
// siendo la última y que las páginas añadidas van en blanco, sin folio
#import "../lib.typ": *

#let multiple = int(sys.inputs.at("multiple", default: "4"))
#let back = sys.inputs.at("back", default: "yes") == "yes"
#show: book.with(
  title: "Imprenta",
  author: "A",
  cover: (front: page(numbering: none)[PORTADA], back: if back { page(numbering: none)[CONTRAPORTADA] }),
  page-multiple: multiple,
)
#show: frontmatter
#tableofcontents()
#show: mainmatter
= Parte
== Capítulo
#lorem(500)
