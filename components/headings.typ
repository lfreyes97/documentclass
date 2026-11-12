#import "tocs/toc.typ" as tocs-mod
#import "tocs/presets.typ" as tocs-presets
#import "titlepage.typ"
#import "fonts.typ" as fonts-mod
#import "i18n.typ"
#import "numbering.typ" as numbering-mod
#import "openings.typ"

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

// Minitoc de cada parte: sus capítulos, en peso normal, con puntos y sin número.
// Son opciones de `tocs.partial`; las que da el usuario reemplazan a estas, así que
// pasar `levels` repone los números y el peso del preset si no se repiten aquí.
#let minitoc-defaults = (
  depth: 1,
  fill: tocs-presets.dots,
  levels: (chapter: (number: false, text: (weight: "regular"))),
)

// Apertura de un título de parte o capítulo con el estilo `s` de openings.leaf. Requiere
// `context`. `reset` reinicia la numeración de figuras y ecuaciones si el título está numerado
#let opening(it, s, font, part-ornament, extra: none, reset: false) = {
  if s.start == "odd" {
    break-to-odd()
  } else if s.start == "facing" {
    if facing-pages-state.get() { break-to-odd() } else { pagebreak(weak: true) }
  } else if s.start == "page" {
    pagebreak(weak: true)
  }
  v(s.above)
  let numbered = it.numbering != none
  if reset and numbered { numbering-mod.reset-in-chapter() }
  let label = if type(s.label) == str {
    let word = i18n.get(s.label)
    if s.label-upper { upper(word) } else { word }
  } else { s.label }
  let title = {
    let body = if s.title-smallcaps { smallcaps(it.body) } else { it.body }
    text(..(font: font) + s.title-text, if s.title-upper { upper(body) } else { body })
  }
  let ornament = if s.ornament == auto { part-ornament } else { s.ornament }
  align(s.align)[
    #if numbered and (label != none or s.number-format != none) {
      let number = (s.number-format)(counter(heading).display(it.numbering))
      text(..s.label-text)[#if label != none [#label #number] else [#number]]
      v(s.gap)
    }
    #title
    #if s.rule != none {
      v(s.rule-gap)
      line(length: s.rule-length, stroke: s.rule)
    }
    #if ornament != none {
      v(1em)
      ornament
    }
    #if extra != none {
      v(2em)
      extra
    }
  ]
  v(s.below)
  if s.end == "odd" { break-to-odd() }
}

// Configuración de headings para book
#let setup(
  part-ornament: none,
  font-size: 11pt, // Base de los tamaños en em de los headings
  fonts: fonts-mod.resolve((:)), // Fuentes ya resueltas (h1..h4, minitoc)
  // Aperturas de parte y de capítulo: preajuste o diccionario (ver components/openings.typ)
  heading-style: "classic",
  // Parámetros de tipografía para headings
  h3-weight: 400,
  h3-size: 1.2em, // Tamaño base para la sección
  h3-smallcaps: true,
  h4-weight: "bold",
  h4-size: 1.05em,
  h4-smallcaps: false,
  minitoc: false, // Mostrar el minitoc en la página de cada parte
  minitoc-options: (:), // Opciones de `tocs.partial`, sobre `minitoc-defaults`
  body,
) = {
  titlepage.check-content("part-ornament", part-ornament)

  // Estilos globaloes pre-establecidos para los encabezados.
  show heading.where(level: 1): set text(font: fonts.h1, weight: 700, hyphenate: false)
  show heading.where(level: 2): set text(font: fonts.h2, weight: 500, hyphenate: false)
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

  let style = openings.resolve(heading-style)

  // NIVEL 1: PARTES. En mainmatter y backmatter, con su página; en frontmatter, simples
  show heading.where(level: 1): it => context {
    let variant = if matter-state.get() in ("main", "back") { none } else { "front" }
    let extra = if minitoc and variant == none {
      block(width: 85%, {
        set align(left)
        set text(weight: "regular", tracking: 0pt)
        tocs-mod.partial(..(minitoc-defaults + minitoc-options))
      })
    }
    opening(it, openings.leaf(style, "part", variant), fonts.h1, part-ornament, extra: extra)
  }

  // NIVEL 2: CAPÍTULOS
  show heading.where(level: 2): it => context {
    let matter = matter-state.get()
    let variant = if matter == "main" { none } else if matter == "back" {
      if appendix-state.get() and it.numbering != none { "appendix" } else { "back" }
    } else { "front" }
    opening(it, openings.leaf(style, "chapter", variant), fonts.h2, none, reset: variant in (none, "appendix"))
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
