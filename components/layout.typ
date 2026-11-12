#import "headings.typ": mark-pagebreaks

// Estilo de párrafo y marcas de página en blanco. Cabeceras y pies: pagestyle.typ
#let setup(body) = {
  // Configuración de párrafos: la sangría separa los párrafos, sin espacio extra.
  // Typst no sangra el primer párrafo tras un título o un bloque.
  set par(
    leading: 0.7em,
    spacing: 0.7em,
    justify: true,
    linebreaks: "optimized",
    first-line-indent: 1.5em,
  )

  mark-pagebreaks(body)
}
