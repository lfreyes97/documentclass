// Titlepage por defecto
#let default(title: none, author: none, date: none) = {
  page(numbering: none)[
    #v(1fr)
    #align(center)[
      #text(size: 24pt, weight: "bold")[#title]
      #v(2em)
      #text(size: 16pt)[#author]
      #v(1em)
      #text(size: 12pt)[#date]
    ]
    #v(1fr)
  ]
}

// Lógica del componente
#let render(
  custom: none,  // none = default, string = ruta personalizada
  title: none,
  author: none,
  date: none,
) = {
  if custom == none {
    // Usar titlepage por defecto
    default(title: title, author: author, date: date)
  } else if type(custom) == str {
    // Incluir titlepage personalizado
    include custom
  } else {
    panic("custom debe ser none o una ruta (string)")
  }
}
