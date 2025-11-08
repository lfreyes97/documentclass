// TOC tradicional con lista vertical (por defecto)
#let traditional(
  title: "Contenido",
  depth: none,
  indent: 1.5em,
) = {
  page[
    #align(center)[
      #text(size: 20pt, weight: "bold")[#title]
    ]
    #v(2em)

    // Estilos para entradas de nivel 1 (partes)
    #show outline.entry.where(level: 1): it => {
      v(0.8em, weak: true)
      block[
        #text(weight: "bold")[
          #it
        ]
      ]
    }

    // Estilos para entradas de nivel 2 (capítulos)
    #show outline.entry.where(level: 2): it => {
      block[
        #h(indent)
        #it
      ]
    }

    // Estilos para entradas de nivel 3+ (secciones)
    #show outline.entry: it => {
      if it.level >= 3 {
        block[
          #h(indent * (it.level - 1))
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
) = {
  page[
    #align(center)[
      #text(size: 20pt, weight: "bold")[#title]
    ]
    #v(2em)

    // Estilos para entradas de nivel 1 (partes)
    #show outline.entry.where(level: 1): it => {
      v(1em, weak: true)
      strong[#it]
    }

    // Estilos para entradas de nivel 2 (capítulos)
    #show outline.entry.where(level: 2): it => {
      h(indent)
      it
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
      title: none,
      depth: depth,
    )
  ]
}

// Tabla de contenidos simple usando outline nativo
#let simple(
  title: "Contenido",
  depth: none
) = {
  outline(
    title: text(size: 20pt, weight: "bold")[#title],
    depth: depth,
  )
}

// Por defecto usar el estilo tradicional
#let custom = traditional
