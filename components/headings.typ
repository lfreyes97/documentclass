// Contadores
#import "minitoc.typ" as minitoc-mod
#let part-counter = counter("part-num")
#let chapter-counter = counter("chapter")
#let section-counter = counter("section")
#let subsection-counter = counter("subsection")
#let appendix-counter = counter("appendix")
#let matter-state = state("matter-section", "front")
#let appendix-state = state("appendix-mode", false)

// Estado para rastrear páginas donde se suprimen cabeceras
// (Ya no se usa - ahora usamos set page(header: none) directamente)

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
  h3-font: ("EB Garamond", "Latin Modern Sans"),
  h3-weight: 400,
  h3-size: 1.2em, // Tamaño base para la sección
  h3-smallcaps: true, // Por defecto true para Ysabeau SC
  h4-font: none, // none = hereda del cuerpo
  h4-weight: "bold",
  h4-size: 1.05em,
  h4-smallcaps: false,
  minitoc: false, // Opción booleana para mostrar minitoc
  outline-font: none, // Fuente para el minitoc
  body,
) = {
  // Estilos globaloes pre-establecidos para los encabezados.
  show heading.where(level: 1): set text(font: h1-font, weight: h1-weight, hyphenate: true)
  show heading.where(level: 2): set text(font: h2-font, weight: h2-weight, hyphenate: true)
  show heading.where(level: 3): set text(font: h3-font, weight: h3-weight, hyphenate: true)
  show heading.where(level: 4): set text(weight: h4-weight, hyphenate: true)

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
        #text(size: 2em, weight: 500, tracking: 0.15em)[PARTE #numbering("I", num)]

        #v(1em)
        #let h1-content = if h1-smallcaps { smallcaps(it.body) } else { it.body }
        #text(font: h1-font, hyphenate: true, h1-size, weight: h1-weight, tracking: 0.05em, upper(h1-content))

        #if part-ornament != none {
          v(1em)
          figure(image(part-ornament, width: 80%))
        }

        #if minitoc {
          v(1em)
          minitoc-mod.minitoc(font: outline-font)
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
        #text(h1-size, font: h1-font, weight: h1-weight, tracking: 0.05em, upper(h1-content))
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
        #section-counter.update(1) // Resetear contador de secciones
        #text(2.2em, weight: 500, tracking: 0.15em)[
          CAPÍTULO #chapter-counter.display()
        ]

        #v(1em)
        #let h2-content = if h2-smallcaps { smallcaps(it.body) } else { it.body }
        #text(h2-size, font: h2-font, weight: h2-weight, tracking: 0.05em, h2-content)
      ]

      v(4em)
    } else if current-matter == "back" {
      pagebreak(to: "odd")
      v(4em)

      let is-appendix = appendix-state.get()
      if is-appendix {
        // Estilo APÉNDICE con letra (A, B, C...)
        align(center)[
          #appendix-counter.step()
          #section-counter.update(1) // Resetear secciones para cada apéndice
          #text(2.2em, weight: 500, tracking: 0.15em)[
            APÉNDICE #appendix-counter.display("A")
          ]

          #v(1em)
          #let h2-content = if h2-smallcaps { smallcaps(it.body) } else { it.body }
          #text(h2-size, font: h2-font, weight: h2-weight, tracking: 0.05em, h2-content)
        ]
      } else {
        // Backmatter sin apéndice (bibliografía, índice, etc.)
        align(center)[
          #let h2-content = if h2-smallcaps { smallcaps(it.body) } else { it.body }
          #text(h2-size, font: h2-font, weight: h2-weight, h2-content)
        ]
      }

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
  show heading.where(level: 3): it => context {
    let current-matter = matter-state.get()

    v(1em)
    let h3-content = if h3-smallcaps { smallcaps(it.body) } else { it.body }

    if current-matter == "main" {
      // En mainmatter: mostrar número de capítulo.sección
      // Restamos 1 porque get() devuelve el valor después del step() del próximo H2
      let chap-num = chapter-counter.get().first() - 1
      text(h3-size, font: h3-font, weight: h3-weight, tracking: 0.03em)[
        #section-counter.step()
        #subsection-counter.update(1) // Resetear subsecciones
        #chap-num\.#section-counter.display()
        #h(7pt)
        #h3-content
      ]
    } else if current-matter == "back" and appendix-state.get() {
      // En backmatter con apéndice: mostrar A.1, A.2...
      // Restamos 1 porque at(here()) lee el valor post-step del H2
      let app-num = appendix-counter.at(here()).first() - 1
      text(h3-size, font: h3-font, weight: h3-weight, tracking: 0.03em)[
        #section-counter.step()
        #subsection-counter.update(1) // Resetear subsecciones
        #numbering("A", app-num)\.#section-counter.display()
        #h(7pt)
        #h3-content
      ]
    } else {
      // En frontmatter/backmatter sin apéndice: solo el título sin número
      text(h3-size, font: h3-font, weight: h3-weight, tracking: 0.03em)[#h3-content]
    }
    v(1em)
  }

  // NIVEL 4: SUBSECCIONES
  show heading.where(level: 4): it => context {
    let current-matter = matter-state.get()

    v(0.8em)
    let h4-content = if h4-smallcaps { smallcaps(it.body) } else { it.body }

    if current-matter == "main" {
      // En mainmatter: mostrar cap.sec.subsec (ej. 1.1.1)
      let chap-num = chapter-counter.get().first() - 1
      let sec-num = section-counter.get().first() - 1
      text(h4-size, weight: h4-weight)[
        #subsection-counter.step()
        #chap-num\.#sec-num\.#subsection-counter.display()
        #h(7pt)
        #h4-content
      ]
    } else if current-matter == "back" and appendix-state.get() {
      // En apéndice: A.1.1, A.1.2...
      let app-num = appendix-counter.at(here()).first() - 1
      let sec-num = section-counter.get().first() - 1
      text(h4-size, weight: h4-weight)[
        #subsection-counter.step()
        #numbering("A", app-num)\.#sec-num\.#subsection-counter.display()
        #h(7pt)
        #h4-content
      ]
    } else {
      // En frontmatter/backmatter sin apéndice: solo el título
      text(h4-size, weight: h4-weight)[#h4-content]
    }
    v(0.5em)
  }

  body
}

#let reset-chapter-counter() = {
  chapter-counter.update(1)
}

#let reset-part-counter() = {
  part-counter.update(1)
}

#let reset-appendix-counter() = {
  appendix-counter.update(1)
}

#let set-appendix-mode(val) = {
  appendix-state.update(val)
}
