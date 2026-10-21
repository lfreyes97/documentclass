// Función para letra capital (Drop Cap)
#import "fonts.typ" as fonts-mod

#let dropcap(
  initial,
  body,
  font: none, // none = rol `initials` de las fuentes del documento
  size: 3em,
  gap: 0.5em,
  color: black,
  transform-case: upper,
) = {
  // Configurar la letra capital
  let cap-letter = context text(
    font: if font != none { font } else { fonts-mod.current.get().initials },
    size: size,
    weight: "bold",
    fill: color,
    transform-case(initial),
  )

  // Usar un grid para colocar la letra a la izquierda y el texto a la derecha
  // Nota: Esto crea una "letra capital colgante" (margin/hanging cap)
  // donde todo el primer párrafo está indentado respecto a la letra.
  // Es la forma más robusta sin paquetes externos para evitar colisiones.
  grid(
    columns: (auto, 1fr),
    gutter: gap,
    align(center + horizon, cap-letter),
    [
      // Eliminar indentación del primer párrafo del cuerpo si existiera
      #set par(first-line-indent: 0pt)
      #body
    ],
  )
}
