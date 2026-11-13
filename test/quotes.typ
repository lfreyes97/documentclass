// `quote-style`: los temas se resuelven con los tres roles, un diccionario cambia solo lo que dice, y las
// funciones de cita (epigraph, blockquote, verse) siguen el estilo de la clase
#import "../lib.typ": article, blockquote, epigraph, epigraph-page, epigraphs, verse
#import "../components/quotes.typ": presets, resolve
#import "../components/environments.typ": format-attribution

#for name in presets.keys() {
  assert.eq(resolve(name).keys(), ("epigraph", "blockquote", "verse"), message: name)
}
#assert.eq(resolve("classic").epigraph.align, right)
#assert.eq(resolve("elegant").epigraph.align, center)
#assert.eq(resolve("modern").blockquote.rule, 1.5pt + luma(45%))
// Un cambio suelto va sobre el tema, y `text` se combina con el del tema en lugar de reemplazarlo
#assert.eq(resolve((preset: "elegant", epigraph: (width: 80%))).epigraph.width, 80%)
#assert.eq(resolve((preset: "elegant", epigraph: (text: (weight: "bold")))).epigraph.text, (style: "italic", weight: "bold"))
#assert.eq(resolve((verse: (rule: none))).verse.rule, none)

// Atribución estructurada («Autor, *Obra* (año), nota»): sin diccionario se deja tal cual; el resultado se ve en la página
#assert.eq(format-attribution("Lao Tzu"), "Lao Tzu")
#assert.eq(format-attribution((author: "Bach")), "Bach")

#show: article.with(title: "Citas", paper: "a5", style: "modern", quote-style: (epigraph: (align: center)))
#epigraph[Soli Deo gloria.][J. S. Bach]
#blockquote[#lorem(30)]
#verse[Una línea del poema \ y otra línea.]

#epigraphs(
  ([Primer epígrafe.], (author: "Scott Alexander", article: "Meditations on Moloch", year: 2014, note: "trad. propia")),
  ([Segundo epígrafe.], (author: "Calvino", work: "Institución", year: 1559)),
)

Un párrafo tras los dos epígrafes.

#epigraph-page[Soli Deo gloria.][J. S. Bach]

Texto tras la página del epígrafe.
