#import "headings.typ"
#import "i18n.typ"

// Los `update` de estado van después de `set page`: el salto de página que
// provoca `set page` ocurre ahí, y un update anterior quedaría en la página previa.

#let frontmatter(body) = {
  // Con `facing-pages` el front matter empieza en recto: el reverso de la
  // portadilla queda en blanco, sin cabecera ni folio
  context if headings.facing-pages-state.get() { headings.break-to-odd() }

  // Numeración romana minúscula centrada; títulos sin número
  set page(numbering: "i", number-align: center)
  set heading(numbering: none)

  // Actualizar estado a frontmatter
  headings.matter-state.update("front")
  counter(page).update(1)
  body
}

#let mainmatter(body) = {
  // La página 1 arábiga siempre es un recto
  headings.break-to-odd()

  // Numeración arábiga centrada; partes, capítulos y secciones numerados
  set page(numbering: "1", number-align: center)
  set heading(numbering: headings.main-numbering)

  // Actualizar estado a mainmatter
  headings.matter-state.update("main")
  counter(page).update(1)
  counter(heading).update(0)
  body
}

#let backmatter(body) = {
  // Continuar numeración arábiga del mainmatter; títulos sin número
  set page(numbering: "1", number-align: center)
  set heading(numbering: none)

  // Actualizar estado a backmatter
  headings.matter-state.update("back")
  headings.appendix-state.update(false) // Iniciar sin modo apéndice
  body
}

// Funciones de utilidad para el backmatter

#let appendix(body) = {
  // Capítulos con letra (A, B...) que empiezan de nuevo
  set heading(numbering: headings.appendix-numbering)
  show heading.where(level: 2): set heading(supplement: i18n.term("appendix"))
  headings.set-appendix-mode(true)
  counter(heading).update((..n) => (n.pos().at(0, default: 0), 0))
  body
}

// Desactivar modo apéndice. Como `#show: end-appendix` los títulos siguientes
// quedan sin número; como `#end-appendix()` solo dejan de mostrarlo.
#let end-appendix(..body) = {
  headings.set-appendix-mode(false)
  set heading(numbering: none)
  body.pos().join()
}

/// Abstract — resumen del documento
///
/// - title: Título del resumen (auto = "Resumen" en el idioma del documento)
/// - body: Contenido del resumen
#let abstract(
  title: auto, // auto = etiqueta traducida
  body,
) = {
  v(1em)
  align(center)[
    #text(weight: "bold", size: 1.1em)[#i18n.title-or(title, "abstract")]
  ]
  v(0.5em)
  pad(left: 2em, right: 2em)[
    #set text(size: 0.95em)
    #set par(leading: 0.55em)
    #body
  ]
  v(1em)
}

/// Página de dedicatoria — centrada vertical y horizontalmente.
/// Equivalente a `\dedicatory{}` en clases LaTeX como memoir.
///
/// - body: Contenido de la dedicatoria
/// - style: Estilo del texto ("italic" o "normal")
/// - size: Tamaño de la fuente
#let dedication(
  body,
  style: "italic",
  size: 1.1em,
) = {
  headings.break-to-odd()
  page(numbering: none)[
    #v(1fr)
    #align(center)[
      #set text(size: size, style: style)
      #set par(justify: false)
      #body
    ]
    #v(1.5fr)
  ]
}
