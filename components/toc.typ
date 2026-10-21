// TOC tradicional con lista vertical (por defecto)
#import "headings.typ": appendix-counter, appendix-state, chapter-counter, matter-state, part-counter
#import "fonts.typ" as fonts-mod
#let traditional(
  title: "Contenido",
  depth: none,
  indent: 1.5em,
  font: none,
  h1-font: none,
  h2-font: none,
  numbering: none,
) = {
  fonts-mod.use("toc", font: font, page[
    #align(center)[
      #text(size: 20pt, weight: "bold")[#title]
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
      let num = part-counter.at(it.element.location()).first()
      let label = if num > 0 [PARTE #std.numbering("I", num)#h(0.6em)]
      set text(font: h1-font) if h1-font != none
      set text(weight: "bold")
      entry-line(label, it.element.body, it)
    }

    // Estilos para entradas de nivel 2 (capítulos)
    #show outline.entry.where(level: 2): it => context {
      let num = chapter-counter.at(it.element.location()).first()
      let label = if num > 0 [#num.#h(0.4em)]
      set text(font: h2-font) if h2-font != none
      entry-line(label, it.element.body, it)
    }

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

    #outline(
      title: none,
      depth: depth,
    )
  ])
}

// TOC estilo párrafo/libro antiguo
#let paragraph-style(
  title: "Contenido",
  depth: none,
  indent: 1.5em,
  font: none,
  h1-font: none,
  h2-font: none,
  numbering: none,
) = {
  fonts-mod.use("toc", font: font, page[
    #align(center)[
      #text(size: 20pt, weight: "bold")[#title]
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

    // Estilos para entradas de nivel 3+ (secciones)
    #show outline.entry: it => {
      if it.level >= 3 {
        h(indent * (it.level - 1))
        it
      } else {
        it
      }
    }

    #outline(
      indent: true,
      title: none,
      depth: depth,
    )
  ])
}

// Tabla de contenidos simple usando outline nativo
#let simple(
  title: "Contenido",
  depth: none,
  font: none,
  indent: none, // Kept for interface compatibility
  h1-font: none,
  h2-font: none,
  numbering: none,
) = {
  fonts-mod.use("toc", font: font, outline(
    title: text(size: 20pt, weight: "bold")[#title],
    depth: depth,
  ))
}

// Por defecto usar el estilo tradicional
#let custom = traditional
