// Estilo de epígrafes, citas largas y versos, parámetro `quote-style`.
//
//   quote-style: "classic"                          un preajuste (un tema)
//   quote-style: (epigraph: (align: center))        cambios sobre "classic"
//   quote-style: (preset: "modern", verse: (rule: none))
//
// Tres roles, cada uno un diccionario:
//   epigraph    width, align (el bloque en la página), text-align (del texto), justify, size, text, attribution-text,
//               attribution-align, attribution-upper, above, below
//   blockquote  indent, size, text, text-align, rule, rule-gap, above, below
//   verse       indent, size, text, text-align, rule, rule-gap, above, below
// `text` y `attribution-text` son argumentos de `text` (style, weight, fill, tracking…); `rule` es un trazo o none.
// Los argumentos de `epigraph`, `blockquote` y `verse` sustituyen al estilo en esa llamada.

#import "themes.typ"

#let soft = luma(45%)

#let epigraph-keys = ("width", "align", "text-align", "justify", "size", "text", "attribution-text", "attribution-align", "attribution-upper", "above", "below")
#let block-keys = ("indent", "size", "text", "text-align", "rule", "rule-gap", "above", "below")
#let roles = (epigraph: epigraph-keys, blockquote: block-keys, verse: block-keys)
#let text-keys = ("text", "attribution-text")

// Lo que un preajuste no fija
#let base = (
  epigraph: (
    width: 70%,
    align: right,
    text-align: start,
    justify: false,
    size: 0.95em,
    text: (:),
    attribution-text: (style: "normal", size: 0.85em),
    attribution-align: right,
    attribution-upper: false,
    above: 1em,
    below: 1em,
  ),
  blockquote: (indent: 2em, size: 0.95em, text: (:), text-align: start, rule: none, rule-gap: 0.8em, above: 0.5em, below: 0.5em),
  verse: (indent: 3em, size: 1em, text: (:), text-align: start, rule: none, rule-gap: 0.8em, above: 0.8em, below: 0.8em),
)

// Epígrafe a la derecha, con el texto también a la derecha, como era antes de `quote-style`; epígrafe y verso en
// cursiva y cita larga sangrada, como las clases estándar de LaTeX
#let classic = (
  epigraph: (text-align: right, text: (style: "italic")),
  blockquote: (:),
  verse: (text: (style: "italic")),
)

// Alineado a la izquierda, sin cursiva; la atribución en mayúsculas pequeñas y grises y un filete lateral en
// la cita larga y el verso
#let modern = (
  epigraph: (
    align: left,
    attribution-align: left,
    attribution-upper: true,
    attribution-text: (size: 0.75em, weight: 500, tracking: 0.12em, fill: soft),
  ),
  blockquote: (indent: 0.5em, rule: 1.5pt + soft),
  verse: (indent: 1.5em, rule: 1.5pt + soft),
)

// Centrado: epígrafe en cursiva con la atribución centrada, cita larga y verso centrados
#let elegant = (
  epigraph: (
    width: 60%,
    align: center,
    text-align: center,
    attribution-align: center,
    text: (style: "italic"),
  ),
  blockquote: (indent: 3em, text-align: center, text: (style: "italic")),
  verse: (indent: 0em, text-align: center, text: (style: "italic")),
)

#let presets = (classic: classic, modern: modern, elegant: elegant)

// Une dos diccionarios de un rol; los de texto se combinan en lugar de reemplazarse
#let merge(a, b) = {
  let out = a
  for (key, value) in b {
    out.insert(key, if key in text-keys and type(value) == dictionary { out.at(key, default: (:)) + value } else { value })
  }
  out
}

// `quote-style` ya validado y completo: un diccionario por rol
#let resolve(spec) = {
  let spec = if type(spec) == str { (preset: spec) } else { spec }
  assert(
    type(spec) == dictionary,
    message: "quote-style debe ser el nombre de un tema (" + presets.keys().join(", ") + ") o un diccionario",
  )
  for key in spec.keys() {
    assert(
      key == "preset" or key in roles,
      message: "quote-style: clave desconocida «" + key + "». Claves válidas: preset, " + roles.keys().join(", "),
    )
  }
  let name = spec.at("preset", default: "classic")
  assert(
    name in presets,
    message: "quote-style: preajuste desconocido «" + str(name) + "». Preajustes: " + presets.keys().join(", ") + "." + themes.hint(name),
  )
  let out = (:)
  for (role, keys) in roles {
    let own = spec.at(role, default: (:))
    assert(type(own) == dictionary, message: "quote-style: " + role + " debe ser un diccionario")
    for key in own.keys() {
      assert(
        key in keys,
        message: "quote-style: clave desconocida «" + key + "» en " + role + ". Claves válidas: " + keys.join(", "),
      )
    }
    out.insert(role, merge(merge(base.at(role), presets.at(name).at(role)), own))
  }
  out
}

// Estilo del documento, para las funciones que el usuario llama directamente (requiere `context`)
#let current = state("dc-quote-style", resolve("classic"))
