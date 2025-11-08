// Contadores
#let part-counter = counter("part-num")
#let chapter-counter = counter("chapter")
#let matter-state = state("matter-section", "front")

// Configuración de headings para book
#let setup(
  part-ornament: none,
  // Parámetros de tipografía para headings
  h1-font: ("Bebas Neue", "Arial Narrow"),
  h1-weight: 700,
  h1-size: 1.6em, // Tamaño base para el título de la parte
  h1-smallcaps: false,

  h2-font: ("Bebas Neue", "Arial Narrow"),
  h2-weight: 500,
  h2-size: 1.8em, // Tamaño base para el título del capítulo
  h2-smallcaps: false,

  h3-font: ("Ysabeau SC", "Latin Modern Sans"),
  h3-weight: 400,
  h3-size: 1.2em, // Tamaño base para la sección
  h3-smallcaps: true, // Por defecto true para Ysabeau SC

  body
) = {

  // Estilos globales pre-establecidos para los encabezados.
  show heading.where(level: 1): set text(font: h1-font, weight: h1-weight, hyphenate: true)
  show heading.where(level: 2): set text(font: h2-font, weight: h2-weight, hyphenate: true)
  show heading.where(level: 3): set text(font: h3-font, weight: h3-weight, hyphenate: true)

  // NIVEL 1: PARTES (solo en mainmatter)
  show heading.where(level: 1): it => context {
    let current-matter = matter-state.get()

    if current-matter == "main" or current-matter == "back" {
      // Estilo de PARTE para mainmatter/backmatter
      pagebreak(to: "odd")
      v(1.5fr)

      align(center)[
        #part-counter.step()
        #let num = part-counter.at(here()).first()
        #text(size: 2em, weight: 500)[PARTE #numbering("I", num)]

        #v(1em)
        #let h1-content = if h1-smallcaps { smallcaps(it.body) } else { it.body }
        #text(font: h1-font, hyphenate: true, h1-size, weight: h1-weight, upper(h1-content))

        #if part-ornament != none {
          v(1em)
          figure(image(part-ornament, width: 80%))
        }

        #v(1em)
        #context {
          set text(font: "Akshar", 11pt) // Esta fuente sigue hardcodeada
          let nexth2 = heading.where(level: 2).after(here())
          let nexth1 = heading.where(level: 1, outlined: true).after(here(), inclusive: false)
          outline(
            target: nexth2.before(nexth1),
            indent: 0pt,
            depth: 2,
            title: none
          )
        }
      ]

      v(1.5fr)
      pagebreak()
    } else {
      // Estilo simple para frontmatter
      pagebreak(weak: true)
      v(2em)
      align(center)[
        #let h1-content = if h1-smallcaps { smallcaps(it.body) } else { it.body }
        #text(h1-size, font: h1-font, weight: h1-weight, upper(h1-content))
      ]
      v(2em)
    }
  }

  // NIVEL 2: CAPÍTULOS
  show heading.where(level: 2): it => context {
    let current-matter = matter-state.get()

    if current-matter == "main" {
      // Estilo de CAPÍTULO para mainmatter
      pagebreak(to: "odd")
      v(4em)

      align(center)[
        #chapter-counter.step()
        #text(1.1em, weight: 500, fill: gray)[
          CAPÍTULO #chapter-counter.display()
        ]

        #v(1em)
        #let h2-content = if h2-smallcaps { smallcaps(it.body) } else { it.body }
        #text(h2-size, font: h2-font, weight: h2-weight, h2-content)
      ]

      v(4em)
    } else if current-matter == "back" {
      // Estilo para backmatter (sin número de capítulo)
      pagebreak(to: "odd")
      v(4em)

      align(center)[
        #let h2-content = if h2-smallcaps { smallcaps(it.body) } else { it.body }
        #text(h2-size, font: h2-font, weight: h2-weight, h2-content)
      ]

      v(4em)
    } else {
      pagebreak(to: "odd")
      // Estilo simple para frontmatter
      v(2em)
      align(center)[
        #let h2-content = if h2-smallcaps { smallcaps(it.body) } else { it.body }
        #text(h2-size, font: h2-font, weight: h2-weight, h2-content)
      ]
      v(1.5em)
    }
  }

  // NIVEL 3: SECCIONES
  show heading.where(level: 3): it => {
    v(1em)
    let h3-content = if h3-smallcaps { smallcaps(it.body) } else { it.body }
    text(h3-size, font: h3-font, weight: h3-weight)[
      #counter(heading).display()
      #h(7pt)
      #h3-content
    ]
    v(1em)
  }

  // Espacio después de headings
  show heading: it => {
    it
    v(2%, weak: true)
  }

  body
}

#let reset-chapter-counter() = {
  chapter-counter.update(1)
}

#let reset-part-counter() = {
  part-counter.update(1)
}
