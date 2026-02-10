// Componentes de página de título para libros

/// Titlepage por defecto — portada estándar con título, subtítulo, autor, editorial y fecha
#let default(
  title: none,
  subtitle: none,
  author: none,
  date: none,
  publisher: none,
  logo: none,
) = {
  page(numbering: none)[
    #v(1fr)
    #align(center)[
      // Logo/escudo editorial
      #if logo != none {
        image(logo, width: 30%)
        v(1.5em)
      }
      // Título principal
      #text(size: 24pt, weight: "bold")[#title]
      // Subtítulo
      #if subtitle != none {
        v(0.8em)
        text(size: 14pt, weight: "regular", style: "italic")[#subtitle]
      }
      #v(2em)
      // Autor
      #text(size: 16pt)[#author]
      #v(1em)
      // Editorial
      #if publisher != none {
        v(1em)
        smallcaps(text(size: 11pt, tracking: 0.1em)[#publisher])
      }
      // Fecha
      #v(0.5em)
      #text(size: 12pt)[#date]
    ]
    #v(1fr)
  ]
}

/// Half-title page — página con solo el título (tradición editorial).
/// Se coloca antes de la portada completa.
#let half-title(title: none) = {
  page(numbering: none)[
    #v(1fr)
    #align(center)[
      #text(size: 18pt, weight: "regular")[#title]
    ]
    #v(2fr)
  ]
}

/// Colophon — página de créditos editoriales, derechos de autor, ISBN, etc.
/// Normalmente va en el reverso de la portada.
///
/// - body: Contenido libre del colofón (copyright, ISBN, agradecimientos de diseño, etc.)
/// - size: Tamaño de fuente
#let colophon(
  body,
  size: 8.5pt,
) = {
  page(numbering: none)[
    #v(1fr)
    #set text(size: size)
    #set par(leading: 0.6em, justify: false, first-line-indent: 0pt)
    #body
  ]
}

// Lógica del componente
#let render(
  custom: none, // none = default, string = ruta personalizada
  title: none,
  subtitle: none,
  author: none,
  date: none,
  publisher: none,
  logo: none,
) = {
  if custom == none {
    // Usar titlepage por defecto
    default(
      title: title,
      subtitle: subtitle,
      author: author,
      date: date,
      publisher: publisher,
      logo: logo,
    )
  } else if type(custom) == str {
    // Incluir titlepage personalizado
    include custom
  } else {
    panic("custom debe ser none o una ruta (string)")
  }
}
