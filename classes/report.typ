// Clase report — equivalente a \documentclass{report} de LaTeX

#import "../components/titlepage.typ"
#import "../components/layout.typ"
#import "../components/matter.typ"
#import "../components/fonts.typ" as fonts-mod

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
  // Tipografía: diccionario parcial de roles (ver components/fonts.typ)
  // body, heading, h1..h4, title, header, toc, minitoc, initials, mono
  fonts: (:),
  lang: "es",
  body,
) = {
  set document(author: if author == none { () } else { author }, title: title)
  let fonts = fonts-mod.resolve(fonts)
  fonts-mod.current.update(fonts)
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

  // --- CONTADORES ---
  let chap-counter = counter("report-chapter")
  let sec-counter = counter("report-section")
  let subsec-counter = counter("report-subsection")

  // --- SHOW RULES ---

  // H1 = CAPÍTULO
  show heading.where(level: 1): set text(font: fonts.h1, weight: "bold", hyphenate: true)
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
  show heading.where(level: 2): set text(font: fonts.h2, weight: "bold", hyphenate: true)
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
  show heading.where(level: 3): set text(font: fonts.h3, hyphenate: true)
  show heading.where(level: 4): set text(font: fonts.h4)
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
