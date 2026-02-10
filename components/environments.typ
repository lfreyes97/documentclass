// Entornos tipográficos para documentos de libro
// Equivalentes a los entornos de LaTeX: epigraph, quote, verse

/// Epígrafe — cita decorativa al inicio de capítulo o sección.
/// Equivalente al paquete `epigraph` de LaTeX.
///
/// - quote: Texto de la cita
/// - attribution: Autor o fuente de la cita
/// - width: Ancho del bloque (por defecto 70%)
/// - align-to: Alineación del bloque (por defecto derecha)
#let epigraph(quote, ..args) = {
  // Extraer argumentos opcionales
  let attribution = args.named().at("attribution", default: args.pos().at(0, default: none))
  let width = args.named().at("width", default: 70%)
  let align-to = args.named().at("align-to", default: right)

  v(1em)
  align(align-to)[
    #block(width: width)[
      #set text(style: "italic", size: 0.95em)
      #set par(leading: 0.6em, justify: false)
      #quote
      #if attribution != none {
        v(0.3em)
        align(right)[
          #set text(style: "normal", size: 0.85em)
          — #attribution
        ]
      }
    ]
  ]
  v(1em)
}

/// Cita en bloque — texto indentado para citas largas.
/// Equivalente a `\begin{quote}` o `\begin{quotation}` de LaTeX.
///
/// - body: Contenido de la cita
/// - indent: Indentación lateral
/// - size: Tamaño de fuente relativo
#let blockquote(
  body,
  indent: 2em,
  size: 0.95em,
) = {
  v(0.5em)
  pad(left: indent, right: indent)[
    #set text(size: size)
    #set par(leading: 0.6em)
    #body
  ]
  v(0.5em)
}

/// Verso — entorno para poesía con interlineado especial.
/// Equivalente a `\begin{verse}` de LaTeX.
/// Cada línea se muestra tal cual (sin justificar).
///
/// - body: Contenido del poema
/// - indent: Indentación izquierda
/// - size: Tamaño de fuente
/// - style: Estilo de texto ("italic" o "normal")
#let verse(
  body,
  indent: 3em,
  size: 1em,
  style: "italic",
) = {
  v(0.8em)
  pad(left: indent)[
    #set text(size: size, style: style)
    #set par(leading: 0.7em, justify: false, first-line-indent: 0pt)
    #body
  ]
  v(0.8em)
}
