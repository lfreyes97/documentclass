// Títulos huérfanos: ningún título de sección queda solo al pie de una página o columna; pasa a la
// siguiente con su párrafo. Párrafos de largo creciente ponen los títulos a todas las alturas.
// `--input class=article` lo prueba a dos columnas y `class=report` en bloque
#import "../lib.typ": *

#let class = sys.inputs.at("class", default: "book")
#show: if class == "article" { article.with(title: "Huérfanos", cols: 2) } else if class == "report" {
  report.with(title: "Huérfanos")
} else { book.with(title: "Huérfanos", facing-pages: false, use-parts: false) }
#show: if class == "book" { mainmatter } else { it => it }

= Capítulo
#for i in range(36) [
  #lorem(18 + 7 * i)

  == Sección #i
  #metadata(i)<after-heading>#lorem(30)
]

#context {
  let headings = query(heading.where(level: if class == "book" { 3 } else { 2 }))
  let after = query(<after-heading>)
  assert.eq(headings.len(), after.len())
  for (h, a) in headings.zip(after) {
    let (hp, ap) = (h.location().position(), a.location().position())
    assert(
      hp.page == ap.page and calc.abs(hp.x - ap.x) < 1pt,
      message: "el título «" + repr(h.body) + "» (pág. " + str(hp.page) + ") quedó separado de su párrafo (pág. " + str(ap.page) + ")",
    )
  }
}
