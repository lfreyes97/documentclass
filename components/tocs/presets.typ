// Estilos predefinidos. Cada estilo da el formato de las partes (`part`), de
// cada rango de división (`ranks`: 0 = capítulo en book y report, sección en
// article; 1, 2, 3 debajo) y de las listas de figuras (`figure`), más el del
// título cuando no es un heading (`title`).

// Claves de una entrada y su valor por defecto
#let base = (
  text: (:), // Argumentos de `text` para toda la entrada
  number-text: (:), // … solo para el número (y su etiqueta)
  page-text: (:), // … solo para el folio
  smallcaps: false,
  upper: false,
  indent: 0pt, // Sangría izquierda de la entrada
  number-width: auto, // Ancho fijo del número (alinea los títulos); auto = el suyo
  number-gap: 0.6em, // Espacio tras el número cuando number-width es auto
  number-format: none, // n => contenido, p. ej. n => [#n.]
  number-break: false, // Número (con su etiqueta) en su propia línea
  label: none, // Palabra antes del número: clave ("part", "chapter"), contenido o e => contenido
  appendix-label: false, // En apéndices usa la etiqueta "appendix" (Apéndice A)
  fill: none, // Relleno hasta el folio, p. ej. repeat[.]
  page: true, // Mostrar el folio
  gutter: 2.4em, // Columna derecha reservada al folio
  above: 0.45em,
  below: 0.45em,
  align: left,
  stroke: none, // Borde del bloque, p. ej. (bottom: 0.5pt)
  run-in: false, // Seguidas en un párrafo, como los índices de libros antiguos
  separator: [ · ], // Entre entradas run-in
  format: none, // (entry, style) => contenido: reemplaza todo el formato
)

#let dots = repeat(gap: 0.45em)[.]
#let wide-dots = repeat(gap: 0.9em)[.]
#let soft = luma(45%)

#let presets = (
  // Como las clases estándar de LaTeX
  classic: (
    title: (text: (size: 1.6em, weight: "bold"), align: left),
    part: (text: (weight: "bold", size: 1.2em), label: "part", number-gap: 1em, above: 1.8em, below: 0.9em),
    ranks: (
      (text: (weight: "bold"), number-width: 1.6em, above: 1.1em, below: 0.5em),
      (indent: 1.6em, number-width: 2.4em, fill: dots),
      (indent: 4em, number-width: 3.2em, fill: dots),
      (indent: 7.2em, number-width: 4.1em, fill: dots),
    ),
    figure: (number-width: 2.6em, fill: dots),
  ),
  // Sin rellenos, números en gris y partes en versalitas con filete
  modern: (
    title: (text: (size: 1.4em, weight: 600, tracking: 0.04em), align: left),
    part: (
      text: (weight: 600, size: 0.9em, tracking: 0.12em),
      upper: true,
      label: "part",
      page: false,
      above: 2em,
      below: 0.9em,
      stroke: (bottom: 0.5pt + soft),
    ),
    ranks: (
      (text: (weight: 600), number-text: (fill: soft), number-width: 2em, above: 1em, below: 0.4em),
      (indent: 2em, number-width: 2.6em, number-text: (fill: soft), page-text: (fill: soft)),
      (indent: 4.6em, number-width: 3.2em, text: (size: 0.95em), number-text: (fill: soft), page-text: (fill: soft)),
      (indent: 7.8em, number-width: 4em, text: (size: 0.9em), number-text: (fill: soft), page-text: (fill: soft)),
    ),
    figure: (number-width: 3em, number-text: (fill: soft)),
  ),
  // Libro clásico: partes centradas en versalitas, secciones en cursiva
  elegant: (
    title: (text: (size: 1.4em, tracking: 0.15em), smallcaps: true, align: center),
    part: (
      text: (size: 1.1em, tracking: 0.08em),
      smallcaps: true,
      label: "part",
      number-break: true,
      page: false,
      align: center,
      above: 2.2em,
      below: 1.2em,
    ),
    ranks: (
      (text: (size: 1.05em), number-width: 2em, number-format: n => [#n.], fill: wide-dots, above: 0.9em, below: 0.35em),
      (indent: 2em, number-width: 2.6em, text: (style: "italic"), fill: wide-dots),
      (indent: 4.6em, number-width: 3.2em, text: (style: "italic", size: 0.95em), fill: wide-dots),
      (indent: 7.8em, number-width: 4em, text: (style: "italic", size: 0.9em), fill: wide-dots),
    ),
    figure: (number-width: 2.6em, fill: wide-dots),
  ),
  // Capítulos en líneas y secciones seguidas en un párrafo
  compact: (
    title: (text: (size: 1.4em, weight: "bold"), align: left),
    part: (text: (weight: "bold", size: 0.9em, tracking: 0.08em), upper: true, label: "part", page: false, above: 1.4em, below: 0.6em),
    ranks: (
      (text: (weight: "bold"), number-width: 1.6em, fill: dots, above: 0.8em, below: 0.3em),
      (indent: 1.6em, run-in: true, text: (size: 0.92em), above: 0.2em, below: 0.3em),
      (indent: 1.6em, run-in: true, text: (size: 0.92em), above: 0.2em, below: 0.3em),
      (indent: 1.6em, run-in: true, text: (size: 0.92em), above: 0.2em, below: 0.3em),
    ),
    figure: (number-width: 2.6em, fill: dots),
  ),
)

#let names = presets.keys()

// Une estilos; los diccionarios de texto se combinan en lugar de reemplazarse
#let merge(a, b) = {
  let out = a
  for (key, value) in b {
    if key in ("text", "number-text", "page-text") and type(value) == dictionary {
      out.insert(key, out.at(key, default: (:)) + value)
    } else {
      out.insert(key, value)
    }
  }
  out
}

#let check(style) = {
  for key in style.keys() {
    assert(key in base, message: "tocs: clave de estilo desconocida «" + key + "». Claves válidas: " + base.keys().join(", "))
  }
  style
}

#let get(name) = {
  if type(name) == dictionary { return name } // Estilo propio con la forma de un preset
  assert(name in presets, message: "tocs: estilo desconocido «" + str(name) + "». Estilos: " + names.join(", "))
  presets.at(name)
}

// Estilo de una entrada: base ← preset ← opciones generales ← rol (`levels`)
#let for-entry(preset, entry, general: (:), levels: (:)) = {
  let ranks = preset.ranks
  let own = if entry.role == "part" { preset.part } else if entry.kind == "figure" { preset.figure } else {
    ranks.at(calc.clamp(entry.rank, 0, ranks.len() - 1))
  }
  let style = merge(merge(base, own), general)
  let override = levels.at(entry.role, default: (:))
  merge(style, check(override))
}
