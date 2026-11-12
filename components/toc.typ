// TOC tradicional con lista vertical (por defecto)
#import "headings.typ": matter-state, numbered, use-parts-state
#import "fonts.typ" as fonts-mod
#import "i18n.typ"

// Con `use-parts: false` el capítulo es de nivel 2: `depth` cuenta desde el
// capítulo, como lo escribe el documento. Requiere `context`.
#let document-depth(depth) = if depth != none and not use-parts-state.get() { depth + 1 } else { depth }
#let traditional(
  title: auto, // auto = etiqueta traducida
  depth: none,
  indent: 1.5em,
  font: none,
  h1-font: none,
  h2-font: none,
  h3-font: none, // Entradas de nivel 3 (secciones)
  chapter-label: false, // true = "Capítulo N:" / "Apéndice N:" en lugar de "N."
  nest-indent: auto, // Sangría de cada nivel anidado (auto = por defecto de Typst)
  chapter-gap: 0em, // Espacio antes de cada capítulo (nivel 2)
  numbering: none,
) = {
  fonts-mod.use("toc", font: font, page[
    #align(center)[
      #text(size: 20pt, weight: "bold")[#i18n.title-or(title, "contents")]
    ]
    #v(2em)

    // Página de la entrada con la numeración de su sección (romana en frontmatter)
    #let entry-page(it) = {
      let loc = it.element.location()
      let pattern = if matter-state.at(loc) == "front" { "i" } else { "1" }
      std.numbering(pattern, counter(page).at(loc).first())
    }

    // Línea de índice: sangría francesa para títulos largos y relleno hasta el folio
    #let entry-line(label, body, it) = block(
      par(hanging-indent: indent, justify: false)[
        #label#body#h(0.3em)#box(width: 1fr, it.fill)#h(0.3em)#entry-page(it)
      ],
    )

    // Estilos para entradas de nivel 1 (partes)
    #show outline.entry.where(level: 1): it => context {
      v(0.8em, weak: true)
      let label = if numbered(it.element) [#upper(i18n.get("part")) #it.prefix()#h(0.6em)]
      set text(font: h1-font) if h1-font != none
      set text(weight: "bold")
      entry-line(label, it.element.body, it)
    }

    // Estilos para entradas de nivel 2 (capítulos)
    #show outline.entry.where(level: 2): it => context {
      // Un espacio débil de 0em anularía el espacio entre bloques y las líneas se montarían
      if chapter-gap != 0em { v(chapter-gap, weak: true) }
      // El documento marca cada capítulo con <chapter-kind> (true = apéndice)
      let loc = it.element.location()
      let kinds = query(selector(<chapter-kind>).before(loc, inclusive: true))
      let is-appendix = kinds.len() > 0 and kinds.last().value
      let label = if chapter-label and is-appendix {
        // Los apéndices se cuentan con romanos aparte de la numeración del cuerpo
        let count = kinds.filter(k => k.value).len()
        [#i18n.get("appendix") #std.numbering("I", count):#h(0.4em)]
      } else if not numbered(it.element) {
        none
      } else if chapter-label {
        [#i18n.get("chapter") #it.prefix():#h(0.4em)]
      } else {
        [#it.prefix().#h(0.4em)]
      }
      set text(font: h2-font) if h2-font != none
      set text(weight: "bold") if chapter-label and label != none
      entry-line(label, it.element.body, it)
    }

    #show outline.entry.where(level: 3): set text(font: h3-font) if h3-font != none

    // Estilos para entradas de nivel 3+ (secciones)
    #show outline.entry: it => {
      if it.level >= 3 {
        block[
          //#h(indent * (it.level - 1))
          #it
        ]
      } else {
        it
      }
    }

    #context outline(
      title: none,
      depth: document-depth(depth),
      indent: nest-indent,
    )
  ])
}

// TOC estilo párrafo/libro antiguo
#let paragraph-style(
  title: auto, // auto = etiqueta traducida
  depth: none,
  indent: 1.5em,
  font: none,
  h1-font: none,
  h2-font: none,
  h3-font: none, // Entradas de nivel 3 (secciones)
  numbering: none,
) = {
  fonts-mod.use("toc", font: font, page[
    #align(center)[
      #text(size: 20pt, weight: "bold")[#i18n.title-or(title, "contents")]
    ]
    #v(2em)

    // Estilos para entradas de nivel 1 (partes)
    #show outline.entry.where(level: 1): it => {
      v(1em, weak: true)
      if h1-font != none {
        text(font: h1-font, weight: "bold")[#it]
      } else {
        strong[#it]
      }
    }

    // Estilos para entradas de nivel 2 (capítulos)
    #show outline.entry.where(level: 2): it => {
      h(indent)
      if h2-font != none {
        text(font: h2-font)[#it]
      } else {
        it
      }
    }

    #show outline.entry.where(level: 3): set text(font: h3-font) if h3-font != none

    // Estilos para entradas de nivel 3+ (secciones)
    #show outline.entry: it => {
      if it.level >= 3 {
        h(indent * (it.level - 1))
        it
      } else {
        it
      }
    }

    #context outline(
      indent: true,
      title: none,
      depth: document-depth(depth),
    )
  ])
}

// Tabla de contenidos simple usando outline nativo
#let simple(
  title: auto, // auto = etiqueta traducida
  depth: none,
  font: none,
  indent: none, // Kept for interface compatibility
  h1-font: none,
  h2-font: none,
  h3-font: none, // Entradas de nivel 3 (secciones)
  numbering: none,
) = {
  show outline.entry.where(level: 1): set text(font: h1-font) if h1-font != none
  show outline.entry.where(level: 2): set text(font: h2-font) if h2-font != none
  show outline.entry.where(level: 3): set text(font: h3-font) if h3-font != none
  fonts-mod.use("toc", font: font, context outline(
    title: text(size: 20pt, weight: "bold")[#i18n.title-or(title, "contents")],
    depth: document-depth(depth),
  ))
}

// Por defecto usar el estilo tradicional
#let custom = traditional
