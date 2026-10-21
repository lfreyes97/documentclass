// Clase report — equivalente a \documentclass{report} de LaTeX

#import "../components/titlepage.typ"
#import "../components/layout.typ"
#import "../components/matter.typ"
#import "../components/fonts.typ" as fonts-mod
#import "../components/i18n.typ"
#import "../components/numbering.typ" as numbering-mod

#let report(
  title: none,
  subtitle: none,
  author: none,
  date: none,
  publisher: none,
  logo: none,
  abstract: none,
  abstract-title: auto, // auto = etiqueta traducida
  custom-titlepage: none,
  // Parámetros de página
  paper: "a4",
  font-size: 11pt,
  margin-inside: 2.5cm,
  margin-outside: 1.5cm,
  margin-y: 2cm,
  // Tipografía: diccionario parcial de roles (ver components/fonts.typ)
  // body, heading, h1..h4, title, header, toc, minitoc, initials, mono
  fonts: (:),
  lang: "es",
  // Etiquetas que reemplazan las traducidas: part, chapter, appendix, section,
  // contents, abstract, figures, tables (ver components/i18n.typ)
  labels: (:),
  equation-numbering: false, // Numerar ecuaciones en bloque: (2.1)
  body,
) = {
  set document(author: if author == none { () } else { author }, title: title)
  let fonts = fonts-mod.resolve(fonts)
  fonts-mod.current.update(fonts)
  i18n.check(labels)
  i18n.overrides.update(labels)
  set text(
    font: fonts.body,
    size: font-size,
    lang: lang,
  )
  show raw: set text(font: fonts.mono)

  set page(
    paper: paper,
    numbering: "1",
    margin: (inside: margin-inside, outside: margin-outside, y: margin-y),
  )

  // Titlepage
  titlepage.render(
    custom: custom-titlepage,
    title: title,
    subtitle: subtitle,
    author: author,
    date: date,
    publisher: publisher,
    logo: logo,
  )

  // Abstract en página separada (común en reportes)
  if abstract != none {
    pagebreak(weak: true)
    v(1fr)
    matter.abstract(title: abstract-title, abstract)
    v(1fr)
    pagebreak(weak: true)
  }

  // --- NUMERACIÓN ---
  // Nativa (1, 1.1, 1.1.1) para que funcionen las referencias; figuras y
  // ecuaciones por capítulo (2.3)
  set heading(numbering: "1.1")
  show heading: set heading(supplement: i18n.term("section"))
  show heading.where(level: 1): set heading(supplement: i18n.term("chapter"))
  show bibliography: set heading(numbering: none)
  show outline: set heading(numbering: none)
  set figure(numbering: numbering-mod.in-chapter.with(1))
  set math.equation(numbering: numbering-mod.equation-in-chapter.with(1)) if equation-numbering

  // Número del título seguido de un espacio, o nada si no está numerado
  let number(it) = if it.numbering != none [#counter(heading).display(it.numbering) ]

  // --- SHOW RULES ---

  // H1 = CAPÍTULO
  show heading.where(level: 1): set text(font: fonts.h1, weight: "bold", hyphenate: true)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(2em)
    if it.numbering != none {
      numbering-mod.reset-in-chapter()
      context text(size: 14pt, style: "italic")[
        #i18n.get("chapter") #counter(heading).display(it.numbering)
      ]
      v(0.5em)
    }
    text(size: 24pt, weight: "bold")[#it.body]
    v(1.5em)
  }

  // H2 = SECCIÓN
  show heading.where(level: 2): set text(font: fonts.h2, weight: "bold", hyphenate: true)
  show heading.where(level: 2): it => {
    v(1.2em)
    context text(size: 14pt, weight: "bold")[#number(it)#it.body]
    v(0.8em)
  }

  // H3 = SUBSECCIÓN
  show heading.where(level: 3): set text(font: fonts.h3, hyphenate: true)
  show heading.where(level: 4): set text(font: fonts.h4)
  show heading.where(level: 3): it => {
    v(1em)
    context text(size: 12pt, weight: "bold")[#number(it)#it.body]
    v(0.6em)
  }

  // Footnotes
  show footnote.entry: it => {
    let loc = it.note.location()
    numbering("1. ", ..counter(footnote).at(loc))
    it.note.body
  }

  body
}
