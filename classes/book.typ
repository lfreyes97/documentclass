#import "../components/titlepage.typ" as titlepage-mod
#import "../components/matter.typ"
#import "../components/footer.typ"
#import "../components/headings.typ"
#import "../components/fonts.typ" as fonts-mod
#import "../components/microtype.typ" as microtype-mod
#import "../components/i18n.typ"
#import "../components/lines.typ"
#import "../components/debug.typ" as debug-mod
#import "../components/numbering.typ" as numbering-mod

#import "../components/layout.typ"
#import "../components/pagestyle.typ"
#import "../components/margins.typ"
#import "../components/themes.typ"
#import "../components/tocs/toc.typ" as tocs-mod

#let margin-defaults = (
  facing: (inside: 2.5cm, outside: 1.5cm, y: 2cm),
  single: (x: 2cm, y: 2cm),
)

#let book(
  title: none,
  subtitle: none,
  author: none,
  date: none,
  publisher: none,
  logo: none,
  // Portada: auto (la de la clase, con título, subtítulo, autor, editorial, fecha y logo), none (sin
  // portada) o contenido (una propia, p. ej. `include "portada.typ"`)
  titlepage: auto,
  custom-titlepage: none, // Obsoleto: ahora es `titlepage`
  part-ornament: none,
  // Parámetros de página (equivalente a \documentclass[a5paper]{book})
  paper: "a5",
  font-size: 11pt, // Tamaño base (10pt, 11pt, 12pt)
  // Márgenes: auto, una longitud o un diccionario (ver components/margins.typ). Con
  // `facing-pages: true` llevan `inside` y `outside`; con `false`, `x` o `left` y `right`
  margin: auto,
  // Tipografía: diccionario parcial de roles (ver components/fonts.typ)
  // body, heading, h1..h4, title, header, toc, minitoc, initials, mono
  fonts: (:),
  lang: "es",
  // Etiquetas que reemplazan las traducidas: part, chapter, appendix, section,
  // contents, abstract, figures, tables (ver components/i18n.typ)
  labels: (:),
  equation-numbering: false, // Numerar ecuaciones en bloque: (2.1)
  // Portada y contraportada, compatibles con coverbook. `cover` es contenido ya
  // armado (p. ej. de `cover-pages`) o una función de estilo (`minimal-cover`…),
  // que se llama con title, subtitle, author y publisher más `cover-data`.
  cover: none,
  back-cover: auto, // auto = la de `cover` si es una función; o contenido; none = sin ella
  cover-data: (:), // Datos extra para la función de portada: isbn, back-text, volume…
  cover-options: (:), // Opciones de la función de portada: trim, spine, colores…
  // true: `=` es parte y `==` capítulo. false: `=` es capítulo y las partes se
  // crean con `#part[...]`
  use-parts: true,
  // Doble cara (el `twoside` de LaTeX): márgenes interior y exterior que alternan; tras la
  // portada, la portadilla va en recto, y el índice y el resto del front matter también;
  // los reversos quedan en blanco, sin cabecera ni folio. false = márgenes iguales en
  // todas las páginas y sin saltos (PDF para pantalla)
  facing-pages: true,
  // Cabeceras y pies: un tema o variante ("classic", "plain"…), none o un diccionario con
  // header y footer (ver components/pagestyle.typ)
  page-style: auto,
  // Tema visual (classic, modern, elegant): lo comparten heading-style, page-style y el
  // índice (`tocs`). auto = el de cada parte. Los parámetros de cada parte lo sustituyen
  style: auto,
  // Estilo de los títulos: un tema o un diccionario (ver components/openings.typ)
  heading-style: auto,
  // Minitoc en la página de cada parte: false, true (sus capítulos, sin número) o
  // un diccionario con opciones de `tocs.partial`, p. ej. `(depth: 2, size: 1em)`
  minitoc: false,
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
  titlepage-mod.check-old(custom-titlepage, "book")
  let style = themes.check(style)
  let page-style = themes.pick(page-style, style, "classic")
  let heading-style = themes.pick(heading-style, style, "classic")
  // El tema también fija el estilo de los índices; un `tocs.setup` posterior lo sustituye
  show: body => if style != auto { tocs-mod.setup(style: style, body) } else { body }
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
  show: microtype-mod.setup.with(microtype)
  let debug = debug-mod.resolve(debug)
  show: debug-mod.setup.with(debug)
  show: lines.setup.with(if debug.lines and line-numbers == false { true } else { line-numbers })

  // Configuración de página base (márgenes para todo el documento, incluida la portada)
  set page(
    paper: paper,
    numbering: "1",
    margin: margins.resolve(margin, facing-pages, margin-defaults),
  )

  // Datos del libro para una función de portada de coverbook
  let cover-book = (title: title, subtitle: subtitle, author: author, publisher: publisher)
    .pairs()
    .filter(((_, value)) => value != none)
    .to-dict() + cover-data
  let make-cover(side) = cover(cover-book, side: side, ..cover-options)
  let back-cover = if back-cover != auto { back-cover } else if type(cover) == function {
    make-cover("back")
  }
  if type(cover) == function { make-cover("front") } else { cover }

  headings.facing-pages-state.update(facing-pages)
  if facing-pages { context headings.blank-verso() }

  lines.off(titlepage-mod.render(
    titlepage: titlepage,
    class: "book",
    title: title,
    subtitle: subtitle,
    author: author,
    date: date,
    publisher: publisher,
    logo: logo,
  ))

  // Aplicar Layout (Headers, Footers, Párrafos)
  // Envuelve el resto del documento — márgenes ya están configurados arriba
  show: pagestyle.setup.with(
    page-style,
    class: "book",
    title: title,
    author: author,
    header-font: fonts.header,
    facing-pages: facing-pages,
  )
  show: layout.setup

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
    heading-style: heading-style,
    font-size: font-size,
    fonts: fonts,
    minitoc: minitoc != false and minitoc != none,
    minitoc-options: if type(minitoc) == dictionary { minitoc } else { (:) },
  )

  // Sin partes, `=` baja a capítulo; `#part[...]` fija su nivel 1 explícitamente
  set heading(offset: 1) if not use-parts
  headings.use-parts-state.update(use-parts)

  body
  back-cover
}
