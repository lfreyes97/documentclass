#import "headings.typ"

#let frontmatter(body) = {
  // Actualizar estado a frontmatter
  headings.matter-state.update("front")

  // Numeración romana minúscula centrada
  set page(numbering: "i", number-align: center)
  counter(page).update(1)
  body
}

#let mainmatter(body) = {
  // Actualizar estado a mainmatter
  headings.matter-state.update("main")

  // Numeración arábiga centrada
  set page(numbering: "1", number-align: center)
  counter(page).update(1)

  // Resetear contadores al entrar a mainmatter
  headings.reset-chapter-counter()
  headings.reset-part-counter()
  body
}

#let backmatter(body) = {
  // Actualizar estado a backmatter
  headings.matter-state.update("back")

  // Continuar numeración arábiga del mainmatter
  set page(numbering: "1", number-align: center)
  body
}

// Funciones de utilidad para el backmatter

#let appendix(body) = {
  heading(
    level: 2,
    numbering: none,
    outlined: true,
    body
  )
}

#let bibliography(title: "Bibliografía", body) = {
  heading(
    level: 2,
    numbering: none,
    outlined: true,
    title
  )
  body
}

#let index(title: "Índice Analítico", body) = {
  heading(
    level: 2,
    numbering: none,
    outlined: true,
    title
  )
  body
}

#let list-of-figures(title: "Lista de Figuras") = {
  heading(
    level: 2,
    numbering: none,
    outlined: true,
    title
  )
  locate(loc => {
    let elems = query(figure.where(kind: image), loc)
    for elem in elems {
      let num = counter(figure.where(kind: image)).at(elem.location()).first()
      grid(
        columns: (20pt, auto),
        gutter: 1em,
        align(right)[#num],
        link(elem.location())[#elem.caption]
      )
    }
  })
}

#let list-of-tables(title: "Lista de Tablas") = {
  heading(
    level: 2,
    numbering: none,
    outlined: true,
    title
  )
  locate(loc => {
    let elems = query(figure.where(kind: table), loc)
    for elem in elems {
      let num = counter(figure.where(kind: table)).at(elem.location()).first()
      grid(
        columns: (20pt, auto),
        gutter: 1em,
        align(right)[#num],
        link(elem.location())[#elem.caption]
      )
    }
  })
}
