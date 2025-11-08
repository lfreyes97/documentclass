#import "../components/titlepage.typ"
#import "../components/matter.typ"
#import "../components/footer.typ"
#import "../components/headings.typ"

#let book(
  custom-titlepage: none,
  title: none,
  author: none,
  date: none,
  part-ornament: none,  // Nuevo parámetro
  // Nuevos parámetros de tipografía
  font-serif: ("Garamond Libre", "Source Serif Pro", "Latin Modern Roman"), // Fuentes serif por defecto, con fallback
  font-sans: ("Source Sans Pro", "Arial"), // Fuentes sans-serif por defecto, con fallback
  font-mono: ("Source Code Pro", "Fira Mono"), // Fuentes monospace por defecto, con fallback
  lang: "es", // Hacer el idioma configurable, con 'es' como defecto
  body
) = {

  // Configuración base
  set document(author: author, title: title)
  // Usar los parámetros de fuente, priorizando las fuentes proporcionadas
  set text(
    font: (font-serif),
    lang: lang // Usar el parámetro de idioma
  )
  set page(paper: "a4")

  // Párrafos
  set par(leading: 0.7em, spacing: 1.35em, justify: true, linebreaks: "optimized")

  // Footnotes
  show footnote.entry: it => {
    let loc = it.note.location()
    numbering("1. ", ..counter(footnote).at(loc))
    it.note.body
  }

  // Titlepage sin numeración
  set page(numbering: none)

  if custom-titlepage == none {
    titlepage.default(title: title, author: author, date: date)
  } else if type(custom-titlepage) == str {
    include custom-titlepage
  }

  // Aplicar estilos de headings
  show: headings.setup.with(part-ornament: part-ornament)

  body
}

#let front = matter.frontmatter
#let main = matter.mainmatter
#let back = matter.backmatter
