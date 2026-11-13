// Clase report — equivalente a \documentclass{report} de LaTeX

#import "../components/titlepage.typ"
#import "../components/layout.typ"
#import "../components/matter.typ"
#import "../components/fonts.typ" as fonts-mod
#import "../components/microtype.typ" as microtype-mod
#import "../components/i18n.typ"
#import "../components/lines.typ"
#import "../components/debug.typ" as debug-mod
#import "../components/numbering.typ" as numbering-mod
#import "../components/margins.typ"
#import "../components/headings.typ"
#import "../components/openings.typ"
#import "../components/themes.typ"
#import "../components/tocs/toc.typ" as tocs-mod
#import "../components/pagestyle.typ"

#let margin-defaults = (
  facing: (inside: 2.5cm, outside: 1.5cm, y: 2cm),
  single: (x: 2cm, y: 2cm),
)

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
  equation-numbering: false, // Numerar ecuaciones en bloque: (2.1)
  // Ajustes de justificación y espacios de no ruptura (ver components/microtype.typ):
  // true, false o un diccionario con spacing, tracking, hyphenation y glue
  microtype: true,
  // Líneas numeradas para citar por página y línea o para revisar: false, true o un diccionario
  // (ver components/lines.typ)
  line-numbers: false,
  // Ayudas de depuración: false, true o un diccionario con `verify`, `lines` y `frame` (ver
  // components/debug.typ). Con `verify` se ven las marcas `#verify[…]`, que si no son invisibles
  debug: false,
  body,
) = {
  let style = themes.check(style)
  let heading-style = openings.resolve(themes.pick(heading-style, style, "classic"), class: "report")
  let page-style = themes.pick(page-style, style, "plain")
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
  let debug = debug-mod.resolve(debug)
  show: debug-mod.setup.with(debug)
  show: lines.setup.with(if debug.lines and line-numbers == false { true } else { line-numbers })

  set page(
    paper: paper,
    numbering: "1",
    margin: margins.resolve(margin, facing-pages, margin-defaults),
  )
  show: pagestyle.setup.with(
    page-style,
    class: "report",
    title: title,
    author: author,
    header-font: fonts.header,
    facing-pages: facing-pages,
  )

  // Titlepage
  lines.off(titlepage.render(
    custom: custom-titlepage,
    title: title,
    subtitle: subtitle,
    author: author,
    date: date,
    publisher: publisher,
    logo: logo,
  ))

  // Estilo de párrafo (sangría) y marcas de páginas en blanco, como en book
  show: layout.setup
  // Salvo los títulos en línea, que son parte del párrafo
  let blocks = openings.block-headings(heading-style, "report")
  show blocks: set par(first-line-indent: 0pt) if blocks != none

  // Abstract en página separada (común en reportes)
  if abstract != none {
    pagebreak(weak: true)
    v(1fr)
    lines.off(matter.abstract(title: abstract-title, abstract))
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

  // --- TÍTULOS ---
  // Typst da a cada título su propio tamaño; los `em` del estilo se miden contra el cuerpo
  show heading: set text(size: font-size)
  // Las fuentes de cada nivel; el estilo (tamaños, espacios, etiqueta) viene de `heading-style`
  show heading.where(level: 1): set text(font: fonts.h1, weight: "bold", hyphenate: true)
  show heading.where(level: 2): set text(font: fonts.h2, weight: "bold", hyphenate: true)
  show heading.where(level: 3): set text(font: fonts.h3, hyphenate: true)
  show heading.where(level: 4): set text(font: fonts.h4)

  // Los títulos van en bloque: si fueran texto en línea, el párrafo que sigue se sangraría
  show heading.where(level: 1): it => context {
    headings.opening(it, openings.leaf(heading-style, "chapter", none), fonts.h1, none, reset: true, in-block: true)
  }
  show heading.where(level: 2): it => context {
    headings.run-heading(it, openings.run-leaf(heading-style, "section"), fonts.h2, in-block: true, sticky: true)
  }
  show heading.where(level: 3): it => context {
    headings.run-heading(it, openings.run-leaf(heading-style, "subsection"), fonts.h3, in-block: true, sticky: true)
  }
  show heading.where(level: 4): it => context {
    headings.run-heading(it, openings.run-leaf(heading-style, "subsubsection"), fonts.h4, in-block: true, sticky: true)
  }
  show heading.where(level: 5): it => context {
    headings.run-heading(it, openings.run-leaf(heading-style, "paragraph"), fonts.heading, in-block: true, sticky: true)
  }

  // Footnotes
  show footnote.entry: it => {
    let loc = it.note.location()
    numbering("1. ", ..counter(footnote).at(loc))
    it.note.body
  }

  body
}
