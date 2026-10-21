// Clase article — equivalente a \documentclass{article} de LaTeX

#import "../components/headings.typ": matter-state, section-counter, subsection-counter
#import "../components/matter.typ"
#import "../components/fonts.typ" as fonts-mod

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
  abstract-title: "Resumen",
  // Parámetros de página
  paper: "a4",
  font-size: 11pt,
  margin-x: 2.5cm,
  margin-y: 2.5cm,
  // Tipografía: diccionario parcial de roles (ver components/fonts.typ)
  // body, heading, h1..h4, title, header, toc, minitoc, initials, mono
  fonts: (:),
  lang: "es",
  cols: 1,
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

  // Una sola cara: márgenes simétricos, numeración desde pág. 1
  set page(
    paper: paper,
    numbering: "1",
    number-align: center,
    margin: (x: margin-x, y: margin-y),
  )

  // Párrafos
  set par(leading: 0.55em, justify: true, spacing: 0.55em)

  // --- SHOW RULES PARA HEADINGS ---
  let sec-counter = counter("article-section")
  let subsec-counter = counter("article-subsection")
  let subsubsec-counter = counter("article-subsubsection")

  show heading.where(level: 1): set text(font: fonts.h1, weight: "bold", hyphenate: true)
  show heading.where(level: 2): set text(font: fonts.h2, weight: "bold", hyphenate: true)
  show heading.where(level: 3): set text(font: fonts.h3, weight: "semibold", hyphenate: true)
  show heading.where(level: 4): set text(font: fonts.h4)

  show heading.where(level: 1): it => {
    v(1.5em)
    sec-counter.step()
    subsec-counter.update(0)
    subsubsec-counter.update(0)
    context {
      let num = sec-counter.display()
      text(size: 16pt, weight: "bold")[
        #num. #it.body
      ]
    }
    v(0.8em)
  }

  show heading.where(level: 2): it => {
    v(1em)
    subsec-counter.step()
    subsubsec-counter.update(0)
    context {
      let s-num = sec-counter.display()
      let ss-num = subsec-counter.display()
      text(size: 13pt, weight: "bold")[
        #s-num.#ss-num #it.body
      ]
    }
    v(0.6em)
  }

  show heading.where(level: 3): it => {
    v(0.8em)
    subsubsec-counter.step()
    context {
      let s-num = sec-counter.display()
      let ss-num = subsec-counter.display()
      let sss-num = subsubsec-counter.display()
      text(size: 11pt, weight: "semibold")[
        #s-num.#ss-num.#sss-num #it.body
      ]
    }
    v(0.5em)
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
