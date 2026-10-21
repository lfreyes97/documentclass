#import "../components/titlepage.typ"
#import "../components/matter.typ"
#import "../components/footer.typ"
#import "../components/headings.typ"
#import "../components/fonts.typ" as fonts-mod
#import "../components/i18n.typ"
#import "../components/numbering.typ" as numbering-mod

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
  // Etiquetas que reemplazan las traducidas: part, chapter, appendix, section,
  // contents, abstract, figures, tables (ver components/i18n.typ)
  labels: (:),
  equation-numbering: false, // Numerar ecuaciones en bloque: (2.1)
  minitoc: false,
  body,
) = {
  // Configuración base
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

  // Numeración: los títulos la reciben de cada matter; figuras y ecuaciones
  // van por capítulo (nivel 2): 2.3, A.1
  set heading(numbering: none)
  set figure(numbering: numbering-mod.in-chapter.with(2))
  set math.equation(numbering: numbering-mod.equation-in-chapter.with(2)) if equation-numbering
  // El título de bibliografía y de outline() es de nivel 1, que en book es una
  // parte: se baja a nivel de capítulo, sin número
  show bibliography: set heading(offset: 1, numbering: none)
  show outline: set heading(offset: 1, numbering: none)

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
