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

// Programa por defecto de una plantilla: los segmentos que `#segment()` va abriendo uno tras otro. Los oradores
// salen del orden de `speakers` (el primero, el segundo…) y el moderador abre y cierra. Sin tiempos: se dan en
// `program`. Para otro orden de intervenciones, `program` explícito.
#let default-program(template, speakers) = {
  if template == none { return () }
  let keys = speakers.keys()
  let debaters = keys.filter(k => not speakers.at(k).moderator)
  let moderator = keys.find(k => speakers.at(k).moderator)
  if template == "two-speakers" {
    let (a, b) = debaters
    (
      if moderator != none { (kind: "introduction", speaker: moderator) },
      (kind: "opening", speaker: a),
      (kind: "opening", speaker: b),
      (kind: "rebuttal", speaker: a),
      (kind: "rebuttal", speaker: b),
      (kind: "questions"),
      (kind: "closing", speaker: a),
      (kind: "closing", speaker: b),
    ).filter(s => s != none)
  } else if template == "panel" {
    (
      (kind: "introduction", speaker: moderator),
      (kind: "round"),
      (kind: "questions"),
      (kind: "closing", speaker: moderator),
    )
  } else {
    ((kind: "introduction"), (kind: "topic"), (kind: "closing"))
  }
}

#let program-keys = ("kind", "speaker", "time", "title")

// `program`: auto (el de la plantilla), none o una lista de diccionarios (kind, speaker, time, title) ya
// completos; devuelve la lista validada
#let resolve-program(program, template, speakers) = {
  let program = if program == auto { default-program(template, speakers) } else if program == none { () } else { program }
  assert(type(program) == array, message: "program debe ser auto, none o una lista de diccionarios `(kind:, speaker:, time:, title:)`")
  for (n, step) in program.enumerate(start: 1) {
    assert(type(step) == dictionary, message: "program: el segmento " + str(n) + " debe ser un diccionario `(kind:, speaker:, time:, title:)`")
    for key in step.keys() {
      assert(key in program-keys, message: "program: clave desconocida «" + key + "» en el segmento " + str(n) + ". Claves válidas: " + program-keys.join(", "))
    }
    assert("kind" in step, message: "program: al segmento " + str(n) + " le falta `kind`")
    check-kind(template, step.kind)
    if step.at("speaker", default: none) != none {
      assert(
        step.speaker in speakers,
        message: "program: el segmento " + str(n) + " tiene el orador desconocido «" + repr(step.speaker) + "». Oradores declarados: " + speakers.keys().join(", "),
      )
    }
  }
  program
}

// Dónde salta la página: "turn" (cada turno, además de cada segmento y sección), "segment" (cada segmento y sección),
// "section" (solo las secciones `=`) o none. Por plantilla; el formato libre va por segmentos
#let breaks = ("turn", "segment", "section")
#let default-breaks = (
  "two-speakers": "turn",
  panel: "turn",
  interview: "turn",
)

#let check-breaks(breaks-option, template) = {
  if breaks-option == auto { return if template == none { "segment" } else { default-breaks.at(template) } }
  assert(
    breaks-option == none or breaks-option in breaks,
    message: "breaks: «" + repr(breaks-option) + "» no es válido. Valores: auto, none, " + breaks.join(", "),
  )
  breaks-option
}
