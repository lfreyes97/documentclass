// Clase essay — ensayo con notas al margen, sobre el motor glosa (components/glosa).
// El título del ensayo es el heading de nivel 1 y las secciones son de nivel 2.

#import "../components/glosa/glosa.typ"
#import "../components/fonts.typ" as fonts-mod
#import "../components/microtype.typ" as microtype-mod
#import "../components/i18n.typ"

/// Numeral arábigo volado para las notas al margen, continuo en todo el documento (el
/// contador nunca se reinicia), para poder citarlas como «nota 42».
#let note-numbering(..n) = super(numbering("1", n.pos().last()))

/// «Pág. 3 de 12». Requiere `context`.
#let page-counter() = {
  let current = counter(page).get().first()
  let total = counter(page).final().first()
  [#i18n.get("page") #current #i18n.get("of") #total]
}

/// Cabecera corrida en los espacios de `glosa.header`: autor y fecha y, con `counter: true`, a
/// su izquierda «Pág. 3 de 12», en la columna interior. Requiere `context`.
#let running-header(author, date, counter: false) = {
  let style = (size: 8.5pt, number-type: "old-style")
  if counter { glosa.header(text-style: style, page-counter(), author, date) } else {
    glosa.header(text-style: style, author, date)
  }
}

/// Pie con «Pág. 3 de 12» en el borde exterior, bajo la columna de notas. Requiere `context`.
#let running-footer() = glosa.header(text-style: (size: 8.5pt, number-type: "old-style"), page-counter())

#let essay(
  title: none, // Título de la portada (`titlepage: true`) y de los metadatos
  author: none, // Autor de la cabecera y de la portada
  date: none, // Contenido o `datetime` para la cabecera; none = hoy
  paper: "a4",
  // Márgenes: cada lado tiene `far` (borde a columna de notas), `width` (columna de
  // notas) y `sep` (columna de notas a texto). `facing-pages: true` alterna interior/exterior.
  inner: (far: 16mm, width: 15mm, sep: 8mm),
  outer: (far: 16mm, width: 45mm, sep: 8mm),
  top: 2.5cm,
  bottom: 2.5cm,
  facing-pages: false, // Doble cara (el `twoside` de LaTeX): `inner` y `outer` alternan
  clearance: 12pt, // Distancia mínima entre notas
  // Notas que no caben en la columna de su página: "carry" (las últimas pasan al principio de la
  // columna de la página siguiente, marcadas con una flecha) o "none" (se desbordan por arriba)
  overflow: "carry",
  // Marca junto a una nota que viene de la página anterior: auto (una flecha), none o contenido
  overflow-mark: auto,
  font-size: 10pt,
  text-fill: luma(30),
  // Tipografía: diccionario parcial de roles (ver components/fonts.typ)
  // body, heading, h1..h4, title, header, toc, minitoc, note, initials, mono
  fonts: (:),
  lang: "es",
  // Etiquetas que reemplazan las traducidas (ver components/i18n.typ)
  labels: (:),
  // Notas al pie, que van con símbolos (*, †, ‡…): "page" reinicia la serie en cada página, como el
  // `perpage` de LaTeX; "document" la sigue a lo largo de todo el documento
  footnote-counter: "page",
  // Notas al margen: tamaño y numeración de `note` y `notefigure`
  note-size: 8.5pt,
  note-numbering: note-numbering,
  header-ascent: 16mm,
  // «Pág. 3 de 12»: "footer" (borde exterior del pie, deja libre la columna interior de la cabecera),
  // "header" (a la izquierda de la cabecera, en la columna interior) o none
  page-counter: "footer",
  // Título de nivel 1 con su número e índice de secciones en el margen, y secciones de
  // nivel 2 numeradas con `section-numbering`
  sections: true,
  // El título de nivel 1 va en la cabecera de su página en lugar de en el cuerpo
  title-in-header: true,
  chapter-numbering: none, // El título del ensayo no lleva numeral; "1" lo pone, para varios capítulos
  chapter-number-style: (size: 40pt, weight: "black"), // Sin `font` = rol `title`
  chapter-title-style: (size: 1.3em, weight: "black"), // Sin `font` = rol `title`
  section-numbering: "I.",
  section-block-style: (above: 42pt, below: 14pt),
  titlepage: false, // Portada con `title` y `author`
  debug-frame: false, // Dibuja los límites de márgenes y columnas
  // Ajustes de justificación y espacios de no ruptura (ver components/microtype.typ):
  // true, false o un diccionario con spacing, tracking, hyphenation y glue
  microtype: true,
  body,
) = {
  let fonts = fonts-mod.resolve(fonts)
  fonts-mod.current.update(fonts)
  i18n.check(labels)
  i18n.overrides.update(labels)
  glosa.note-defaults.update((
    text-style: (size: note-size, font: fonts.note),
    par-style: (:),
    numbering: note-numbering,
  ))

  set document(author: if type(author) in (str, array) { author } else { () }, title: title) // Los metadatos solo aceptan texto
  set text(font: fonts.body, lang: lang)
  show raw: set text(font: fonts.mono)
  show: microtype-mod.setup.with(microtype)
  set page(paper: paper)

  let number-style = (font: fonts.title, ..chapter-number-style)
  let title-style = (font: fonts.title, ..chapter-title-style)
  let date = if date == none {
    i18n.date(datetime.today())
  } else if type(date) == datetime {
    i18n.date(date)
  } else {
    date
  }

  assert(
    footnote-counter in ("page", "document"),
    message: "essay: footnote-counter debe ser \"page\" o \"document\", no " + repr(footnote-counter),
  )
  assert(
    page-counter in ("footer", "header", none),
    message: "essay: page-counter debe ser \"footer\", \"header\" o none, no " + repr(page-counter),
  )
  let header = () => if here().page() > 1 {
    set text(font: fonts.header)
    running-header(author, date, counter: page-counter == "header")
  }

  set page(
    footer: if page-counter == "footer" {
      context {
        set text(font: fonts.header)
        running-footer()
      }
    },
    header-ascent: header-ascent,
    // El reinicio del contador de notas al pie va en la cabecera: se evalúa al empezar cada página
    header: {
      if footnote-counter == "page" { counter(footnote).update(0) }
      if title-in-header {
        glosa.title-header(style: title-style, number-style: number-style, fallback: header)
      } else {
        context header()
      }
    },
  )

  let titlepage-content = if titlepage {
    assert(title != none, message: "essay: pasa `title:` cuando `titlepage: true`")
    [
      #align(center + horizon)[
        #set text(font: fonts.title)
        #text(size: 2em, weight: "black", title)
        #v(1.5em)
        #text(size: 1.1em, author)
      ]
      #pagebreak()
    ]
  }

  // Párrafos justificados, enlaces subrayados y pies de figura como notas al margen
  let styled = {
    set par(justify: true, linebreaks: "optimized")
    set text(fill: text-fill, size: font-size)
    show link: underline
    set figure(gap: 0pt)
    set figure.caption(position: std.bottom) // `bottom` es aquí el margen inferior
    show figure.caption.where(position: std.bottom): glosa.note.with(
      alignment: "bottom",
      anchor-numbering: none,
      numbering: none,
      shift: "avoid",
      keep-order: true,
    )
    body
  }

  // Las remisiones van en minúscula dentro de la frase («la sección V»), salvo en alemán
  let ref-word(key) = {
    let word = i18n.get(key)
    if text.lang == "de" { word } else { lower(word) }
  }

  let is-note(el) = (
    el.has("children")
      and el.children.len() > 1
      and el.children.first().func() == metadata
      and el.children.first().value == "_glosa_note"
  )

  let result = glosa.setup(
    inner: inner,
    outer: outer,
    top: top,
    bottom: bottom,
    book: facing-pages,
    clearance: clearance,
    overflow: overflow,
    overflow-mark: overflow-mark,
    {
      titlepage-content
      // Las notas al margen llevan los numerales; las notas al pie van con *, †, ‡…
      set footnote(numbering: "*")
      // `@etiqueta` de una nota se imprime «nota 42», con enlace; `@etiqueta[n.]` cambia
      // la palabra. Esta regla, interior, precede a la de glosa.setup.
      show ref: it => {
        let el = it.element
        if el != none and is-note(el) {
          let dest = query(selector(<_glosa_note>).after(el.location()))
          assert(dest.len() > 0, message: "Could not find referenced note")
          let n = glosa.notecounter.at(dest.first().location()).last()
          let word = if it.supplement == auto { ref-word("note") } else { it.supplement }
          show link: l => {
            show underline: u => u.body
            l
          }
          link(dest.first().location(), [#word~#n])
        } else { it }
      }
      if sections {
        show heading.where(level: 1): set heading(outlined: false, numbering: chapter-numbering)
        show heading.where(level: 1): glosa.chapter.with(
          show-title: not title-in-header,
          show-number: not title-in-header,
          number-style: number-style,
          title-style: title-style,
          outline-style: (size: 7.5pt, font: fonts.minitoc),
          sublevel: 2,
          shift: false,
        )
        show heading.where(level: 2): set heading(numbering: glosa.level-numbering(section-numbering))
        show heading.where(level: 2): set block(..section-block-style)
        show heading.where(level: 2): set text(font: fonts.h2)
        // `@etiqueta` de una sección se imprime «sección V» (sin el punto del patrón),
        // con enlace; `@etiqueta[capítulo]` cambia la palabra.
        show ref: it => {
          let el = it.element
          if el != none and el.func() == heading and el.level == 2 {
            let n = counter(heading).at(el.location()).last()
            let num = numbering(section-numbering.trim(".", at: end), n)
            let word = if it.supplement == auto { ref-word("section") } else { it.supplement }
            show link: l => {
              show underline: u => u.body
              l
            }
            link(el.location(), [#word~#num])
          } else { it }
        }
        styled
      } else {
        styled
      }
    },
  )

  if debug-frame { glosa.show-frame(result) } else { result }
}
