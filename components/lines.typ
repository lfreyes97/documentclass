// Líneas numeradas (parámetro `line-numbers`), para citar por página y línea o para la revisión con
// otra persona. Usa `par.line` de Typst: numera las líneas del cuerpo, no las de títulos, notas al
// pie ni pies de figura.
//
//   line-numbers: false                    sin números (por defecto)
//   line-numbers: true                     una vez por línea, reinician en cada página, margen gris pequeño
//   line-numbers: (every: 5, scope: "document")
//
// Claves:
//   scope      "page" (reinician en cada página) o "document" (siguen)
//   every      Se muestra cada `every` líneas: 1, 5, 10…
//   size, fill Tamaño y color del número
//   clearance  Distancia entre el número y el texto
//   side       `start` (a la izquierda) o `end`

#let defaults = (scope: "page", every: 1, size: 7pt, fill: luma(55%), clearance: 8pt, side: start)

#let check(options) = {
  assert(
    options == true or options == false or options == none or type(options) == dictionary,
    message: "line-numbers debe ser true, false o un diccionario, p. ej. `line-numbers: (every: 5)`",
  )
  if type(options) == dictionary {
    for key in options.keys() {
      assert(
        key in defaults,
        message: "line-numbers: clave desconocida «" + key + "». Claves válidas: " + defaults.keys().join(", "),
      )
    }
    assert(options.at("scope", default: "page") in ("page", "document"), message: "line-numbers: scope debe ser \"page\" o \"document\"")
    assert(
      type(options.at("every", default: 1)) == int and options.at("every", default: 1) > 0,
      message: "line-numbers: every debe ser un entero positivo",
    )
  }
  options
}

#let setup(options, body) = {
  let options = check(options)
  if options == false or options == none { return body }
  let o = defaults + if type(options) == dictionary { options } else { (:) }
  set par.line(
    numbering: n => if calc.rem(n, o.every) == 0 { text(size: o.size, fill: o.fill, str(n)) },
    numbering-scope: o.scope,
    number-clearance: o.clearance,
    number-margin: o.side,
  )
  show heading: set par.line(numbering: none)
  show footnote.entry: set par.line(numbering: none)
  show figure: set par.line(numbering: none)
  body
}

// Sin números en lo que no es cuerpo de texto: portada, bloque de título, resumen
#let off(body) = {
  set par.line(numbering: none)
  body
}
