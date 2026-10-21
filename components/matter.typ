#import "headings.typ"

// Los `update` de estado van después de `set page`: el salto de página que
// provoca `set page` ocurre ahí, y un update anterior quedaría en la página previa.

#let frontmatter(body) = {
  // Empieza en recto; el reverso de la portada queda en blanco
  headings.break-to-odd()

  // Numeración romana minúscula centrada
  set page(numbering: "i", number-align: center)

  // Actualizar estado a frontmatter
  headings.matter-state.update("front")
  counter(page).update(1)
  body
}

#let mainmatter(body) = {
  // La página 1 arábiga siempre es un recto
  headings.break-to-odd()

  // Numeración arábiga centrada
  set page(numbering: "1", number-align: center)

  // Actualizar estado a mainmatter
  headings.matter-state.update("main")
  counter(page).update(1)

  // Resetear contadores al entrar a mainmatter
  headings.reset-chapter-counter()
  headings.reset-part-counter()
  body
}

#let backmatter(body) = {
  // Continuar numeración arábiga del mainmatter
  set page(numbering: "1", number-align: center)

  // Actualizar estado a backmatter
  headings.matter-state.update("back")
  headings.appendix-state.update(false) // Iniciar sin modo apéndice
  body
}

// Funciones de utilidad para el backmatter

#let appendix(body) = {
  // Activar modo apéndice y resetear contador
  headings.set-appendix-mode(true)
  headings.reset-appendix-counter()
  body
}

// Desactivar modo apéndice (para usar después de los apéndices)
#let end-appendix() = {
  headings.set-appendix-mode(false)
}

/// Abstract — resumen del documento
///
/// - title: Título del resumen ("Resumen" por defecto)
/// - body: Contenido del resumen
#let abstract(
  title: "Resumen",
  body,
) = {
  v(1em)
  align(center)[
    #text(weight: "bold", size: 1.1em)[#title]
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

#let bibliography(title: "Bibliografía", body) = {
  headings.set-appendix-mode(false) // Desactivar modo apéndice
  heading(
    level: 2,
    numbering: none,
    outlined: true,
    title,
  )
  body
}

#let index(title: "Índice Analítico", body) = {
  headings.set-appendix-mode(false) // Desactivar modo apéndice
  heading(
    level: 2,
    numbering: none,
    outlined: true,
    title,
  )
  body
}

#let list-of-figures(title: "Lista de Figuras") = {
  heading(
    level: 2,
    numbering: none,
    outlined: true,
    title,
  )
  context {
    let elems = query(figure.where(kind: image))
    for elem in elems {
      let num = counter(figure.where(kind: image)).at(elem.location()).first()
      grid(
        columns: (20pt, auto),
        gutter: 1em,
        align(right)[#num], link(elem.location())[#elem.caption],
      )
    }
  }
}

#let list-of-tables(title: "Lista de Tablas") = {
  heading(
    level: 2,
    numbering: none,
    outlined: true,
    title,
  )
  context {
    let elems = query(figure.where(kind: table))
    for elem in elems {
      let num = counter(figure.where(kind: table)).at(elem.location()).first()
      grid(
        columns: (20pt, auto),
        gutter: 1em,
        align(right)[#num], link(elem.location())[#elem.caption],
      )
    }
  }
}
