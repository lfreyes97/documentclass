#import "minitoc.typ" as minitoc-mod
#import "titlepage.typ"
#import "fonts.typ" as fonts-mod
#import "i18n.typ"
#import "numbering.typ" as numbering-mod

#let matter-state = state("matter-section", "front")
#let appendix-state = state("appendix-mode", false)
// false: `=` es capítulo (book con `use-parts: false`)
#let use-parts-state = state("dc-use-parts", true)

// Numeración de headings del book, sobre el contador nativo `counter(heading)`
// para que funcionen `@ref` y los prefijos del índice. Partes en romanos;
// capítulos (nivel 2) sin la parte: 3, 3.1, 3.1.2. Cada matter fija la suya.
// El contador reinicia los capítulos en cada parte, pero en el libro siguen la
// cuenta: el número se obtiene contando los capítulos numerados del mainmatter
// hasta aquí. Typst evalúa la numeración en la posición del título numerado.
#let main-numbering(..nums) = {
  let n = nums.pos()
  if n.len() == 1 {
    return numbering("I", n.first())
  }
  let chapter = query(heading.where(level: 2).before(here()))
    .filter(h => h.numbering != none and matter-state.at(h.location()) == "main")
    .len()
  ((str(chapter),) + n.slice(2).map(str)).join(".")
}

// En apéndices el capítulo va en letras: A, A.1, A.1.2
#let appendix-numbering(..nums) = {
  let n = nums.pos()
  if n.len() == 1 {
    numbering("I", n.first())
  } else {
    ((numbering("A", n.at(1)),) + n.slice(2).map(str)).join(".")
  }
}

// Marcas a ambos lados de un salto de página: las páginas que quedan
// estrictamente entre las dos marcas son páginas en blanco. `layout.setup`
// las pone en todo `pagebreak`, también en los que escribe el usuario, con
// `mark-pagebreaks`; `blank-page` las pone a mano porque `page[]` no es un salto.
#let mark-pagebreaks(body) = {
  show pagebreak: it => {
    [#metadata(none) <dc-break-before>]
    it
    [#metadata(none) <dc-break-after>]
  }
  body
}

// Salto a página impar. Es débil para que dos saltos seguidos (parte +
// capítulo) no dejen páginas vacías de más. Las marcas de página en blanco
// las añade `mark-pagebreaks`.
#let break-to-odd() = pagebreak(to: "odd", weak: true)

// Páginas enfrentadas (`facing-pages` de book): la portadilla y el front matter
// empiezan en recto y el reverso queda en blanco
#let facing-pages-state = state("dc-facing-pages", true)

// Reverso en blanco antes de la portadilla, en recto. Va antes de `layout.setup`,
// así que la página en blanco se declara sin numeración en vez de marcarse.
// No hace nada si la página que toca ya es impar (sin portada, o portada de
// dos páginas). Requiere `context`.
#let blank-verso() = if calc.even(here().page()) { page(numbering: none)[] }

// Borde superior del área de texto de la página actual (requiere `context`)
#let body-top() = {
  let m = page.margin
  if type(m) == dictionary {
    m = m.at("top", default: m.at("y", default: m.at("rest", default: 0pt)))
  }
  if type(m) == length { m.to-absolute() } else { 0pt }
}

// Página en blanco intencional, sin cabecera ni folio (usa las mismas marcas que
// mark-pagebreaks)
#let blank-page() = {
  [#metadata(none) <dc-break-before>]
  page[]
  [#metadata(none) <dc-break-after>]
}

// Parte explícita. Con `use-parts: false` en book, `=` es capítulo y las partes
// solo se crean así.
#let part(..args, body) = heading(level: 1, ..args, body)

// Requiere `context`
#let is-blank-page(page) = {
  let before = query(<dc-break-before>)
  let after = query(<dc-break-after>)
  let top = body-top() + 0.5pt
  before.zip(after).any(((b, a)) => {
    let (b-page, a-page) = (b.location().page(), a.location().page())
    // `before` en el borde superior: nada lo precede, así que su página está vacía
    let b-at-top = b.location().position().y <= top
    (b-page < page or (b-page == page and b-at-top)) and page < a-page
  })
}

// Si el heading muestra su número (requiere `context`). Tras `end-appendix()`
// el back matter conserva la numeración de apéndice, pero no la muestra.
#let numbered(it) = {
  let loc = it.location()
  it.numbering != none and (matter-state.at(loc) != "back" or appendix-state.at(loc))
}

// Configuración de headings para book
#let setup(
  part-ornament: none,
  font-size: 11pt, // Base de los tamaños en em de los headings
  fonts: fonts-mod.resolve((:)), // Fuentes ya resueltas (h1..h4, minitoc)
  // Parámetros de tipografía para headings
  h1-weight: 700,
  h1-size: 1.8em, // Tamaño base para el título de la parte
  h1-smallcaps: false,
  h2-weight: 500,
  h2-size: 1.8em, // Tamaño base para el título del capítulo
  h2-smallcaps: false,
  h3-weight: 400,
  h3-size: 1.2em, // Tamaño base para la sección
  h3-smallcaps: true,
  h4-weight: "bold",
  h4-size: 1.05em,
  h4-smallcaps: false,
  minitoc: false, // Opción booleana para mostrar minitoc
  // Opciones del minitoc de cada parte (ver minitoc.minitoc)
  minitoc-options: (:),
  body,
) = {
  titlepage.check-content("part-ornament", part-ornament)

  // Estilos globaloes pre-establecidos para los encabezados.
  show heading.where(level: 1): set text(font: fonts.h1, weight: h1-weight, hyphenate: false)
  show heading.where(level: 2): set text(font: fonts.h2, weight: h2-weight, hyphenate: false)
  show heading.where(level: 3): set text(font: fonts.h3, weight: h3-weight, hyphenate: false)
  show heading.where(level: 4): set text(font: fonts.h4, weight: h4-weight, hyphenate: false)
  // Typst aplica su tamaño por defecto (1.4em, 1.2em...) también dentro de las
  // reglas show propias; se fija la base para que h1-size, h2-size... sean exactos.
  show heading: set text(size: font-size)
  show heading: set par(justify: false, first-line-indent: 0pt, linebreaks: "simple")

  // Nombre que acompaña a `@ref`; matter.appendix cambia el del nivel 2
  show heading: set heading(supplement: i18n.term("section"))
  show heading.where(level: 1): set heading(supplement: i18n.term("part"))
  show heading.where(level: 2): set heading(supplement: i18n.term("chapter"))

  // NIVEL 1: PARTES (solo en mainmatter)
  show heading.where(level: 1): it => context {
    let current-matter = matter-state.get()

    if current-matter == "main" or current-matter == "back" {
      // Estilo de PARTE para mainmatter/backmatter
      break-to-odd()

      v(1.5fr)

      align(center)[
        #if it.numbering != none {
          text(size: 1.15em, weight: 500, tracking: 0.25em)[
            #upper(i18n.get("part")) #counter(heading).display(it.numbering)
          ]
          v(1em)
        }
        #let h1-content = if h1-smallcaps { smallcaps(it.body) } else { it.body }
        #text(font: fonts.h1, h1-size, weight: h1-weight, tracking: 0.05em, upper(h1-content))

        #if part-ornament != none {
          v(1em)
          part-ornament
        }

        #if minitoc {
          v(2em)
          block(width: 85%, {
            set align(left)
            set text(weight: "regular", tracking: 0pt)
            minitoc-mod.minitoc(font: fonts.minitoc, ..minitoc-options)
          })
        }
      ]

      v(1.5fr)
      // La parte ocupa su propia página impar y deja el reverso en blanco
      break-to-odd()
    } else {
      // Estilo simple para frontmatter
      pagebreak(weak: true)
      v(2em)
      align(center)[
        #let h1-content = if h1-smallcaps { smallcaps(it.body) } else { it.body }
        #text(h1-size, font: fonts.h1, weight: h1-weight, tracking: 0.05em, upper(h1-content))
      ]
      v(2em)
    }
  }

  // NIVEL 2: CAPÍTULOS
  show heading.where(level: 2): it => context {
    let current-matter = matter-state.get()

    if current-matter == "main" {
      // Estilo de CAPÍTULO para mainmatter
      break-to-odd()
      v(4em)

      align(center)[
        #if it.numbering != none {
          numbering-mod.reset-in-chapter()
          text(1.1em, weight: 500, tracking: 0.25em)[
            #upper(i18n.get("chapter")) #counter(heading).display(it.numbering)
          ]
          v(1em)
        }
        #let h2-content = if h2-smallcaps { smallcaps(it.body) } else { it.body }
        #text(h2-size, font: fonts.h2, weight: h2-weight, tracking: 0.05em, h2-content)
      ]

      v(4em)
    } else if current-matter == "back" {
      break-to-odd()
      v(4em)

      let is-appendix = appendix-state.get()
      if is-appendix and it.numbering != none {
        // Estilo APÉNDICE con letra (A, B, C...)
        align(center)[
          #numbering-mod.reset-in-chapter()
          #text(1.1em, weight: 500, tracking: 0.25em)[
            #upper(i18n.get("appendix")) #counter(heading).display(it.numbering)
          ]

          #v(1em)
          #let h2-content = if h2-smallcaps { smallcaps(it.body) } else { it.body }
          #text(h2-size, font: fonts.h2, weight: h2-weight, tracking: 0.05em, h2-content)
        ]
      } else {
        // Backmatter sin apéndice (bibliografía, índice, etc.)
        align(center)[
          #let h2-content = if h2-smallcaps { smallcaps(it.body) } else { it.body }
          #text(h2-size, font: fonts.h2, weight: h2-weight, h2-content)
        ]
      }

      v(4em)
    } else {
      break-to-odd()
      // Estilo simple para frontmatter
      v(2em)
      align(center)[
        #let h2-content = if h2-smallcaps { smallcaps(it.body) } else { it.body }
        #text(h2-size, font: fonts.h2, weight: h2-weight, h2-content)
      ]
      v(1.5em)
    }
  }

  // NIVEL 3: SECCIONES (3.1, A.1)
  show heading.where(level: 3): it => context {
    v(1em)
    let h3-content = if h3-smallcaps { smallcaps(it.body) } else { it.body }
    text(h3-size, font: fonts.h3, weight: h3-weight, tracking: 0.03em)[
      #if numbered(it) [#counter(heading).display(it.numbering)#h(7pt)]
      #h3-content
    ]
    v(1em)
  }

  // NIVEL 4: SUBSECCIONES (3.1.1, A.1.1)
  show heading.where(level: 4): it => context {
    v(0.8em)
    let h4-content = if h4-smallcaps { smallcaps(it.body) } else { it.body }
    text(h4-size, weight: h4-weight)[
      #if numbered(it) [#counter(heading).display(it.numbering)#h(7pt)]
      #h4-content
    ]
    v(0.5em)
  }

  body
}

#let set-appendix-mode(val) = {
  appendix-state.update(val)
}
