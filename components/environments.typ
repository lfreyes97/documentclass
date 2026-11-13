// Entornos tipográficos para documentos de libro
// Equivalentes a los entornos de LaTeX: epigraph, quote, verse
// Su aspecto lo da `quote-style` de la clase (ver components/quotes.typ); los argumentos de cada llamada lo sustituyen.

#import "quotes.typ"

/// Epígrafe — cita decorativa al inicio de capítulo o sección.
/// Equivalente al paquete `epigraph` de LaTeX.
///
/// - quote: Texto de la cita
/// - attribution: Autor o fuente de la cita (también el segundo argumento posicional)
/// - width: Ancho del bloque
/// - align: Dónde va el bloque en la página (`left`, `center`, `right`)
#let epigraph(quote, ..args) = context {
  let style = quotes.current.get().epigraph
  let attribution = args.named().at("attribution", default: args.pos().at(0, default: none))
  let width = args.named().at("width", default: style.width)
  let placement = args.named().at("align", default: style.align)

  v(style.above)
  align(placement, block(width: width, {
    set text(..(size: style.size) + style.text)
    set par(leading: 0.6em, justify: false)
    align(style.text-align, quote)
    if attribution != none {
      v(0.3em)
      align(style.attribution-align, {
        set text(..style.attribution-text)
        [— #if style.attribution-upper { upper(attribution) } else { attribution }]
      })
    }
  }))
  v(style.below)
}

// Cuerpo de una cita larga o un verso: con filete lateral si el estilo lo pide. La cita larga se sangra a los dos
// lados; el verso, solo a la izquierda
#let indented(style, indent, body, both: true) = {
  let content = {
    set text(..(size: style.size) + style.text)
    align(style.text-align, body)
  }
  v(style.above)
  pad(left: indent, right: if style.rule == none and both { indent } else { 0pt }, if style.rule == none { content } else {
    block(stroke: (left: style.rule), inset: (left: style.rule-gap), content)
  })
  v(style.below)
}

/// Cita en bloque — texto indentado para citas largas.
/// Equivalente a `\begin{quote}` o `\begin{quotation}` de LaTeX.
///
/// - body: Contenido de la cita
/// - indent: Indentación lateral
/// - size: Tamaño de fuente relativo
#let blockquote(body, indent: auto, size: auto) = context {
  let style = quotes.current.get().blockquote
  if size != auto { style.insert("size", size) }
  set par(leading: 0.6em)
  indented(style, if indent == auto { style.indent } else { indent }, body)
}

/// Verso — entorno para poesía con interlineado especial.
/// Equivalente a `\begin{verse}` de LaTeX.
/// Cada línea se muestra tal cual (sin justificar).
///
/// - body: Contenido del poema
/// - indent: Indentación izquierda
/// - size: Tamaño de fuente
/// - style: Estilo de texto ("italic" o "normal")
#let verse(body, indent: auto, size: auto, style: auto) = context {
  let look = quotes.current.get().verse
  if size != auto { look.insert("size", size) }
  if style != auto { look.text += (style: style) }
  set par(leading: 0.7em, justify: false, first-line-indent: 0pt)
  indented(look, if indent == auto { look.indent } else { indent }, body, both: false)
}
