// `quote-style`: los temas se resuelven con los tres roles, un diccionario cambia solo lo que dice, y las
// funciones de cita (epigraph, blockquote, verse) siguen el estilo de la clase
#import "../lib.typ": article, blockquote, epigraph, verse
#import "../components/quotes.typ": presets, resolve

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

#show: article.with(title: "Citas", paper: "a5", style: "modern", quote-style: (epigraph: (align: center)))
#epigraph[Soli Deo gloria.][J. S. Bach]
#blockquote[#lorem(30)]
#verse[Una línea del poema \ y otra línea.]
