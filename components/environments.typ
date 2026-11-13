// Entornos tipográficos para documentos de libro
// Equivalentes a los entornos de LaTeX: epigraph, quote, verse
// Su aspecto lo da `quote-style` de la clase (ver components/quotes.typ); los argumentos de cada llamada lo sustituyen.

#import "quotes.typ"
#import "headings.typ"

#let attribution-keys = ("author", "work", "article", "year", "note")

// La atribución de un epígrafe: contenido tal cual, o un diccionario que se arma como «Autor, *Obra* (año), nota»:
// `author`, `work` (en cursiva: un libro), `article` (entre «»: un artículo, un poema), `year` y `note`
#let format-attribution(attribution) = {
  if type(attribution) != dictionary { return attribution }
  for key in attribution.keys() {
    assert(
      key in attribution-keys,
      message: "epigraph: clave desconocida «" + key + "» en la atribución. Claves válidas: " + attribution-keys.join(", "),
    )
  }
  assert(not ("work" in attribution and "article" in attribution), message: "epigraph: la atribución lleva `work` o `article`, no los dos")
  let title = if "work" in attribution { emph(attribution.work) } else if "article" in attribution { [«#attribution.article»] }
  let main = (attribution.at("author", default: none), title).filter(x => x != none)
  let main = if main.len() == 0 { none } else { main.join[, ] }
  let main = if "year" in attribution { if main == none [(#attribution.year)] else [#main (#attribution.year)] } else { main }
  if "note" in attribution { if main == none { attribution.note } else [#main, #attribution.note] } else { main }
}

/// Epígrafe — cita decorativa al inicio de capítulo o sección.
/// Equivalente al paquete `epigraph` de LaTeX. Para varios seguidos, `epigraphs`.
///
/// - quote: Texto de la cita
/// - attribution: Autor o fuente (también el segundo argumento posicional): contenido, o un diccionario con
///   `author`, `work` (cursiva), `article` (entre «»), `year` y `note`: «— Autor, *Obra* (año), nota»
/// - width: Ancho del bloque
/// - align: Dónde va el bloque en la página (`left`, `center`, `right`)
/// - above, below: Espacio antes y después
#let epigraph(quote, ..args) = context {
  let style = quotes.current.get().epigraph
  let attribution = args.named().at("attribution", default: args.pos().at(0, default: none))
  let width = args.named().at("width", default: style.width)
  let placement = args.named().at("align", default: style.align)
  let attribution = format-attribution(attribution)

  v(args.named().at("above", default: style.above))
  align(placement, block(width: width, {
    set text(..(size: style.size) + style.text)
    set par(leading: 0.6em, justify: style.justify)
    align(style.text-align, quote)
    if attribution != none {
      v(0.3em)
      align(style.attribution-align, {
        set text(..style.attribution-text)
        [— #if style.attribution-upper { upper(attribution) } else { attribution }]
      })
    }
  }))
  v(args.named().at("below", default: style.below))
}

/// Varios epígrafes seguidos: cada uno es una lista `(cita, atribución)`. Entre ellos va `gap` (1em) en lugar del
/// espacio de dos epígrafes sueltos; antes del primero y después del último, el del estilo.
///
/// `#epigraphs(([Primera cita.], [Autor uno]), ([Segunda cita.], [Autor dos]))`
#let epigraphs(..items, gap: 1em) = {
  let items = items.pos()
  for (n, item) in items.enumerate() {
    assert(type(item) == array and item.len() in (1, 2), message: "epigraphs: cada epígrafe es una lista `(cita, atribución)`")
    let first = n == 0
    let last = n == items.len() - 1
    epigraph(
      item.first(),
      ..if item.len() == 2 { (item.at(1),) } else { () },
      ..if not first { (above: 0pt) } else { (:) },
      ..if not last { (below: gap) } else { (:) },
    )
  }
}

/// Epígrafe en página propia, como en un libro: en página impar (con `facing-pages`), centrado, sin folio ni cabecera. Admite los
/// mismos argumentos que `epigraph`; `width` y `align` se aplican al bloque dentro de la página.
#let epigraph-page(quote, ..args) = {
  // En página impar solo con doble cara (`facing-pages`); si no, página nueva
  context if headings.facing-pages-state.get() { headings.break-to-odd() } else { pagebreak(weak: true) }
  page(numbering: none, {
    v(1fr)
    align(center, epigraph(quote, ..args))
    v(1.5fr)
  })
}

// Cuerpo de una cita larga o un verso: con filete lateral si el estilo lo pide. La cita larga se sangra a los dos
// lados; el verso, solo a la izquierda. `footer` (la atribución) va bajo el cuerpo, sin la alineación del texto
#let indented(style, indent, body, both: true, footer: none) = {
  let content = {
    set text(..(size: style.size) + style.text)
    align(style.text-align, body)
    footer
  }
  v(style.above)
  pad(left: indent, right: if style.rule == none and both { indent } else { 0pt }, if style.rule == none { content } else {
    block(stroke: (left: style.rule), inset: (left: style.rule-gap), content)
  })
  v(style.below)
}

/// Cita en bloque — texto indentado para citas largas.
/// Equivalente a `\begin{quote}` o `\begin{quotation}` de LaTeX. También se usa para `#quote(block: true)`.
///
/// - body: Contenido de la cita
/// - attribution: La fuente: contenido, o un diccionario como el de `epigraph` (`author`, `work`, `article`,
///   `year`, `note`); va bajo la cita según `attribution-*` del estilo
/// - indent: Indentación lateral
/// - size: Tamaño de fuente relativo
#let blockquote(body, attribution: none, indent: auto, size: auto) = context {
  let style = quotes.current.get().blockquote
  if size != auto { style.insert("size", size) }
  let attribution = format-attribution(attribution)
  // Con comillas, las del idioma y, dentro, las de segundo nivel
  let body = if style.marks {
    let marks = quotes.marks.at(text.lang, default: quotes.marks.en)
    [#marks.outer.first()#{
      set smartquote(quotes: (double: marks.inner, single: marks.third))
      body
    }#marks.outer.last()]
  } else { body }
  let footer = if attribution != none {
    v(0.3em)
    align(style.attribution-align, {
      set text(..style.attribution-text)
      [— #if style.attribution-upper { upper(attribution) } else { attribution }]
    })
  }
  set par(leading: 0.6em)
  indented(style, if indent == auto { style.indent } else { indent }, body, footer: footer)
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

// Las citas de la clase: en línea con comillas anidadas y en bloque con el estilo de `blockquote`
#let setup(body) = {
  show quote.where(block: false): quotes.inline-quote
  show quote.where(block: true): it => blockquote(it.body, attribution: it.attribution)
  body
}
