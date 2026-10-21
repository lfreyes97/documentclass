#import "../components/titlepage.typ"
#import "../components/matter.typ"
#import "../components/footer.typ"
#import "../components/headings.typ"
#import "../components/fonts.typ" as fonts-mod

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
  // Tipografía: diccionario parcial de roles (ver components/fonts.typ)
  // body, heading, h1..h4, title, header, toc, minitoc, initials, mono
  fonts: (:),
  lang: "es",
  minitoc: false,
  body,
) = {
  // Configuración base
  set document(author: if author == none { () } else { author }, title: title)
  let fonts = fonts-mod.resolve(fonts)
  fonts-mod.current.update(fonts)
  set text(
    font: fonts.body,
    size: font-size,
    lang: lang,
  )
  show raw: set text(font: fonts.mono)

  // Configuración de página base (márgenes para todo el documento, incluida la portada)
  set page(
    paper: paper,
    numbering: "1",
    margin: (inside: margin-inside, outside: margin-outside, y: margin-y),
  )

  titlepage.render(
    custom: custom-titlepage,
    title: title,
    subtitle: subtitle,
    author: author,
    date: date,
    publisher: publisher,
    logo: logo,
  )

  // Aplicar Layout (Headers, Footers, Párrafos)
  // Envuelve el resto del documento — márgenes ya están configurados arriba
  show: layout.setup.with(
    title: title,
    author: author,
    header-font: fonts.header,
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
    font-size: font-size,
    fonts: fonts,
    minitoc: minitoc,
  )

  body
}

#let front = matter.frontmatter
#let main = matter.mainmatter
#let back = matter.backmatter
#let appendix = matter.appendix
#let end-appendix = matter.end-appendix
#let dedication = matter.dedication
#let abstract = matter.abstract
