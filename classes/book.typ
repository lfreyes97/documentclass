#import "../components/titlepage.typ"
#import "../components/matter.typ"
#import "../components/footer.typ"
#import "../components/headings.typ"

#import "../components/layout.typ"
#let book(
  custom-titlepage: none,
  title: none,
  subtitle: none,
  author: none,
  date: none,
  publisher: none,
  logo: none,
  part-ornament: none,
  // Parámetros de página (equivalente a \documentclass[a5paper]{book})
  paper: "a5",
  font-size: 11pt, // Tamaño base (10pt, 11pt, 12pt)
  margin-inside: 2.5cm,
  margin-outside: 1.5cm,
  margin-y: 2cm,
  // Parámetros de tipografía
  font-serif: ("EB Garamond 12", "Source Serif Pro", "Latin Modern Roman"),
  font-sans: ("Source Sans Pro", "Arial"),
  font-mono: ("Source Code Pro", "Fira Mono"),
  lang: "es",
  // Parámetros de fuentes para headings
  h1-font: ("Bebas Neue", "Arial Narrow"),
  h2-font: ("Bebas Neue", "Arial Narrow"),
  h3-font: ("EB Garamond", "Latin Modern Sans"),
  h4-font: none, // none = hereda del cuerpo
  minitoc: false,
  outline-font: none,
  body,
) = {
  // Configuración base
  set document(author: author, title: title)
  // Usar los parámetros de fuente, priorizando las fuentes proporcionadas
  set text(
    font: (font-serif),
    size: font-size,
    lang: lang,
  )

  // Configuración de página base (márgenes para todo el documento, incluida la portada)
  set page(
    paper: paper,
    numbering: none,
    margin: (inside: margin-inside, outside: margin-outside, y: margin-y),
  )

  if custom-titlepage == none {
    titlepage.default(
      title: title,
      subtitle: subtitle,
      author: author,
      date: date,
      publisher: publisher,
      logo: logo,
    )
  } else if type(custom-titlepage) == str {
    include custom-titlepage
  }

  // Aplicar Layout (Headers, Footers, Párrafos)
  // Envuelve el resto del documento — márgenes ya están configurados arriba
  show: layout.setup.with(
    title: title,
    author: author,
    header-font: font-serif,
  )

  // Footnotes
  show footnote.entry: it => {
    let loc = it.note.location()
    numbering("1. ", ..counter(footnote).at(loc))
    it.note.body
  }

  // Aplicar estilos de headings
  show: headings.setup.with(
    part-ornament: part-ornament,
    h1-font: h1-font,
    h2-font: h2-font,
    h3-font: h3-font,
    h4-font: h4-font,
    minitoc: minitoc,
    outline-font: outline-font,
  )

  body
}

#let front = matter.frontmatter
#let main = matter.mainmatter
#let back = matter.backmatter
#let appendix = matter.appendix
#let end-appendix = matter.end-appendix
#let dedication = matter.dedication
