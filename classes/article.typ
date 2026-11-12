// Clase article — equivalente a \documentclass{article} de LaTeX

#import "../components/matter.typ"
#import "../components/i18n.typ"
#import "../components/fonts.typ" as fonts-mod
#import "../components/microtype.typ" as microtype-mod
#import "../components/margins.typ"
#import "../components/headings.typ"
#import "../components/openings.typ"
#import "../components/themes.typ"
#import "../components/tocs/toc.typ" as tocs-mod
#import "../components/pagestyle.typ"

#let margin-defaults = (
  facing: (inside: 3cm, outside: 2cm, y: 2.5cm),
  single: (x: 2.5cm, y: 2.5cm),
)

/// Titleblock inline — título, autor y fecha en la misma página
#let titleblock(
  title: none,
  subtitle: none,
  author: none,
  date: none,
) = {
  v(2em)
  align(center)[
    #text(size: 20pt, weight: "bold")[#title]
    #if subtitle != none {
      v(0.5em)
      text(size: 12pt, style: "italic")[#subtitle]
    }
    #v(1.2em)
    #text(size: 12pt)[#author]
    #if date != none {
      v(0.3em)
      text(size: 11pt)[#date]
    }
  ]
  v(2em)
}

#let article(
  title: none,
  subtitle: none,
  author: none,
  date: none,
  abstract: none,
  abstract-title: auto, // auto = etiqueta traducida
  // Parámetros de página
  paper: "a4",
  font-size: 11pt,
  // Márgenes: auto, una longitud o un diccionario (ver components/margins.typ)
  margin: auto,
  // Doble cara (el `twoside` de LaTeX): márgenes interior y exterior que alternan
  facing-pages: false,
  // Tema visual (classic, modern, elegant): lo comparten heading-style, page-style y el
  // índice (`tocs`). auto = el de cada parte. Los parámetros de cada parte lo sustituyen
  style: auto,
  // Estilo de los títulos: un tema o un diccionario (ver components/openings.typ)
  heading-style: auto,
  // Cabeceras y pies: un tema o variante ("classic", "plain"…), none (los de Typst) o un
  // diccionario con header y footer (ver components/pagestyle.typ)
  page-style: auto,
  // Tipografía: diccionario parcial de roles (ver components/fonts.typ)
  // body, heading, h1..h4, title, header, toc, minitoc, initials, mono
  fonts: (:),
  lang: "es",
  // Etiquetas que reemplazan las traducidas: part, chapter, appendix, section,
  // contents, abstract, figures, tables (ver components/i18n.typ)
  labels: (:),
  cols: 1,
  // Ajustes de justificación y espacios de no ruptura (ver components/microtype.typ):
  // true, false o un diccionario con spacing, tracking, hyphenation y glue
  microtype: true,
  body,
) = {
  let style = themes.check(style)
  let heading-style = openings.resolve(themes.pick(heading-style, style, "classic"), class: "article")
  let page-style = themes.pick(page-style, style, none)
  // El tema también fija el estilo de los índices; un `tocs.setup` posterior lo sustituye
  show: body => if style != auto { tocs-mod.setup(style: style, body) } else { body }
  set document(author: if type(author) in (str, array) { author } else { () }, title: title) // Los metadatos solo aceptan texto
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
  show: microtype-mod.setup.with(microtype)

  // Por defecto, una sola cara: márgenes simétricos, numeración desde pág. 1
  set page(
    paper: paper,
    numbering: "1",
    number-align: center,
    margin: margins.resolve(margin, facing-pages, margin-defaults),
  )
  show: pagestyle.setup.with(
    page-style,
    class: "article",
    title: title,
    author: author,
    header-font: fonts.header,
    facing-pages: facing-pages,
  )

  // Párrafos
  set par(leading: 0.55em, justify: true, spacing: 0.55em)

  // --- SHOW RULES PARA HEADINGS ---
  // Numeración nativa (1, 1.1, 1.1.1) para que funcionen las referencias
  set heading(numbering: "1.1")
  show heading: set heading(supplement: i18n.term("section"))
  show bibliography: set heading(numbering: none)
  show outline: set heading(numbering: none)

  // Las fuentes de cada nivel; el estilo (tamaños, espacios) viene de `heading-style`
  // Typst da a cada título su propio tamaño; los `em` del estilo se miden contra el cuerpo
  show heading: set text(size: font-size)
  show heading.where(level: 1): set text(font: fonts.h1, weight: "bold", hyphenate: true)
  show heading.where(level: 2): set text(font: fonts.h2, weight: "bold", hyphenate: true)
  show heading.where(level: 3): set text(font: fonts.h3, weight: "semibold", hyphenate: true)
  show heading.where(level: 4): set text(font: fonts.h4)

  show heading.where(level: 1): it => context {
    headings.run-heading(it, openings.run-leaf(heading-style, "section"), fonts.h1)
  }
  show heading.where(level: 2): it => context {
    headings.run-heading(it, openings.run-leaf(heading-style, "subsection"), fonts.h2)
  }
  show heading.where(level: 3): it => context {
    headings.run-heading(it, openings.run-leaf(heading-style, "subsubsection"), fonts.h3)
  }
  show heading.where(level: 4): it => context {
    headings.run-heading(it, openings.run-leaf(heading-style, "paragraph"), fonts.h4)
  }

  // Footnotes
  show footnote.entry: it => {
    let loc = it.note.location()
    numbering("1. ", ..counter(footnote).at(loc))
    it.note.body
  }

  // Título inline
  fonts-mod.use("title", titleblock(
    title: title,
    subtitle: subtitle,
    author: author,
    date: date,
  ))

  // Abstract
  if abstract != none {
    matter.abstract(title: abstract-title, abstract)
  }

  // Aplicar columnas si se pidieron
  if cols > 1 {
    columns(cols, body)
  } else {
    body
  }
}
