// Clase report — equivalente a \documentclass{report} de LaTeX

#import "../components/titlepage.typ"
#import "../components/layout.typ"
#import "../components/matter.typ"

#let report(
  title: none,
  subtitle: none,
  author: none,
  date: none,
  publisher: none,
  logo: none,
  abstract: none,
  abstract-title: "Resumen",
  custom-titlepage: none,
  // Parámetros de página
  paper: "a4",
  font-size: 11pt,
  margin-inside: 2.5cm,
  margin-outside: 1.5cm,
  margin-y: 2cm,
  // Tipografía
  font-serif: "Libertinus Serif",
  lang: "es",
  // Fuentes para headings
  h1-font: "Libertinus Sans",
  h2-font: "Libertinus Sans",
  h3-font: "Libertinus Sans",
  body,
) = {
  set document(author: author, title: title)
  set text(
    font: font-serif,
    size: font-size,
    lang: lang,
  )

  set page(
    paper: paper,
    numbering: "1",
    margin: (inside: margin-inside, outside: margin-outside, y: margin-y),
  )

  // Titlepage
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

  // Abstract en página separada (común en reportes)
  if abstract != none {
    pagebreak(weak: true)
    v(1fr)
    matter.abstract(title: abstract-title, abstract)
    v(1fr)
    pagebreak(weak: true)
  }

  // --- CONTADORES ---
  let chap-counter = counter("report-chapter")
  let sec-counter = counter("report-section")
  let subsec-counter = counter("report-subsection")

  // --- SHOW RULES ---

  // H1 = CAPÍTULO
  show heading.where(level: 1): set text(font: h1-font, weight: "bold", hyphenate: true)
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(2em)
    chap-counter.step()
    sec-counter.update(0)
    subsec-counter.update(0)

    context {
      let num = chap-counter.display()
      text(size: 14pt, style: "italic")[Capítulo #num]
    }
    v(0.5em)
    text(size: 24pt, weight: "bold")[#it.body]
    v(1.5em)
  }

  // H2 = SECCIÓN
  show heading.where(level: 2): set text(font: h2-font, weight: "bold", hyphenate: true)
  show heading.where(level: 2): it => {
    v(1.2em)
    sec-counter.step()
    subsec-counter.update(0)
    context {
      let c-num = chap-counter.display()
      let s-num = sec-counter.display()
      text(size: 14pt, weight: "bold")[
        #c-num.#s-num #it.body
      ]
    }
    v(0.8em)
  }

  // H3 = SUBSECCIÓN
  show heading.where(level: 3): it => {
    v(1em)
    subsec-counter.step()
    context {
      let c-num = chap-counter.display()
      let s-num = sec-counter.display()
      let ss-num = subsec-counter.display()
      text(size: 12pt, weight: "bold")[
        #c-num.#s-num.#ss-num #it.body
      ]
    }
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
