// TOC tradicional con lista vertical (por defecto)
#import "headings.typ": appendix-counter, appendix-state, chapter-counter, matter-state, part-counter
#let traditional(
  title: "Contenido",
  depth: none,
  indent: 1.5em,
  font: none,
  h1-font: "Bebas NEUE",
  h2-font: none,
  numbering: none,
) = {
  page[
    #align(center)[
      #if font != none {
        text(font: font, size: 20pt, weight: "bold")[#title]
      } else {
        text(size: 20pt, weight: "bold")[#title]
      }
    ]
    #v(2em)

    // Estilos para entradas de nivel 1 (partes)
    #show outline.entry.where(level: 1): it => context {
      v(0.8em, weak: true)
      block[
        #if h1-font != none {
          let loc = it.element.location()
          let num = part-counter.at(loc).first()
          if num > 0 {
            text(font: h1-font, weight: "bold")[PARTE #std.numbering("I", num) #h(0.5em) #it.element.body]
          } else {
            text(font: h1-font, weight: "bold")[#it.element.body]
          }
        } else {
          let loc = it.element.location()
          let num = part-counter.at(loc).first()
          if num > 0 {
            text(weight: "bold")[PARTE #std.numbering("I", num) #h(0.5em) #it.element.body]
          } else {
            text(weight: "bold")[#it.element.body]
          }
        }
        #box(width: 1fr, repeat[.])
        #let loc = it.element.location()
        #let dim = matter-state.at(loc)
        #let page-num = counter(page).at(loc).first()
        #let pattern = if dim == "front" { "i" } else { "1" }
        #std.numbering(pattern, page-num)
      ]
    }

    // Estilos para entradas de nivel 2 (capítulos)
    #show outline.entry.where(level: 2): it => context {
      block[
        #if h2-font != none {
          let loc = it.element.location()
          let num = chapter-counter.at(loc).first()
          if num > 0 {
            text(font: h2-font)[#num. #it.element.body]
          } else {
            text(font: h2-font)[#it.element.body]
          }
        } else {
          let loc = it.element.location()
          let num = chapter-counter.at(loc).first()
          if num > 0 {
            [#num. #it.element.body]
          } else {
            it.element.body
          }
        }
        #box(width: 1fr, repeat[.])
        #let loc = it.element.location()
        #let dim = matter-state.at(loc)
        #let page-num = counter(page).at(loc).first()
        #let pattern = if dim == "front" { "i" } else { "1" }
        #std.numbering(pattern, page-num)
      ]
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
  ]
}

// TOC estilo párrafo/libro antiguo
#let paragraph-style(
  title: "Contenido",
  depth: none,
  indent: 1.5em,
  font: none,
  h1-font: "Bebas NEUE",
  h2-font: none,
  numbering: none,
) = {
  page[
    #align(center)[
      #if font != none {
        text(font: font, size: 20pt, weight: "bold")[#title]
      } else {
        text(size: 20pt, weight: "bold")[#title]
      }
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
  ]
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
  outline(
    title: if font != none {
      text(font: font, size: 20pt, weight: "bold")[#title]
    } else {
      text(size: 20pt, weight: "bold")[#title]
    },
    depth: depth,
  )
}

// Por defecto usar el estilo tradicional
#let custom = traditional
