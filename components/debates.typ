// Plantillas de debate (parámetro `template` de la clase debate): qué segmentos admite cada formato y
// cuántos oradores lleva. Los nombres de los segmentos son claves de `i18n` (opening, rebuttal…).

// Cada plantilla: `kinds` (segmentos permitidos), `debaters` (oradores que no son moderador: un número o un
// rango min..max) y `moderators` (máximo)
#let templates = (
  "two-speakers": (
    kinds: ("introduction", "opening", "rebuttal", "cross", "questions", "closing"),
    debaters: (2, 2),
    moderators: 1,
  ),
  panel: (
    kinds: ("introduction", "round", "questions", "closing"),
    debaters: (2, none),
    moderators: 1,
  ),
  interview: (
    kinds: ("introduction", "topic", "questions", "closing"),
    debaters: (2, 2),
    moderators: 0,
  ),
)

#let all-kinds = ("introduction", "opening", "rebuttal", "cross", "questions", "closing", "round", "topic")

// `template`: none (formato libre: cualquier segmento, cualquier número de oradores) o el nombre de una plantilla
#let check(template) = {
  assert(
    template == none or template in templates,
    message: "template: «" + repr(template) + "» no es una plantilla. Plantillas: " + templates.keys().join(", "),
  )
  template
}

// Los oradores ya resueltos (`moderator: true` los aparta como moderadores) cumplen las reglas de la plantilla
#let check-speakers(template, speakers) = if template != none {
  let rules = templates.at(template)
  let moderators = speakers.values().filter(s => s.moderator).len()
  let debaters = speakers.len() - moderators
  let (min, max) = rules.debaters
  assert(
    debaters >= min and (max == none or debaters <= max),
    message: "template «" + template + "»: lleva " + if max == min { str(min) } else if max == none { "al menos " + str(min) } else { str(min) + " a " + str(max) } + " oradores sin contar al moderador, y `speakers` declara " + str(debaters),
  )
  assert(
    moderators <= rules.moderators,
    message: "template «" + template + "»: admite " + str(rules.moderators) + " moderador(es) (`moderator: true`), y `speakers` declara " + str(moderators),
  )
}

// El segmento `kind` está permitido en la plantilla
#let check-kind(template, kind) = {
  assert(
    kind in all-kinds,
    message: "segment: «" + repr(kind) + "» no es un tipo de segmento. Tipos: " + all-kinds.join(", "),
  )
  if template != none {
    assert(
      kind in templates.at(template).kinds,
      message: "segment: «" + kind + "» no existe en la plantilla «" + template + "». Segmentos de esa plantilla: " + templates.at(template).kinds.join(", "),
    )
  }
}
