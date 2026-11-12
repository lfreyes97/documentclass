// Estilo de los títulos (el fncychap y el titlesec de LaTeX), parámetro `heading-style`.
//
//   heading-style: "classic"                        un preajuste
//   heading-style: (chapter: (align: left))         cambios sobre "classic"
//   heading-style: (preset: "modern", part: (...), section: (...), h4: (...))
//
// Cada rol (part, chapter, section, subsection, subsubsection, paragraph) es un diccionario.
// El rol de cada nivel depende de la clase: en book `part` es el nivel 1 y `chapter` el 2. `h1`…`h6`
// son alias del rol que tiene ese nivel en la clase.
//
// Aperturas (`part`, `chapter`):
//   start         "odd" (página impar), "page" (página nueva), "facing" (impar solo con
//                 `facing-pages`) o none
//   end           igual, tras el título (una parte ocupa su propia página impar)
//   above, below  Espacio antes y después del título (longitud o fracción: 1.5fr)
//   align         Alineación del bloque
//   label         Palabra ante el número: "part", "chapter", "appendix", contenido o none
//   label-text    Argumentos de `text` para la etiqueta y el número
//   label-upper   La etiqueta en mayúsculas
//   number-format n => contenido: cómo se muestra el número; none = sin número
//   gap           Espacio entre la etiqueta y el título
//   title-text    Argumentos de `text` para el título (size, weight, tracking, style, font…)
//   title-upper, title-smallcaps
//   rule          Filete bajo el título (un trazo) o none; rule-length, rule-gap
//   ornament      Contenido bajo el título; en las partes, auto = `part-ornament`
// Cada apertura tiene variantes que cambian solo lo que indican: `front` (front matter),
// `back` (back matter) y, en `chapter`, `appendix`. Las claves de `part` o `chapter`
// valen para todas las variantes; las de una variante, solo para ella.
//
// Títulos de sección (`section` y los inferiores): above, below, align, number-format,
// number-text, number-sep, title-text, title-upper, title-smallcaps. Cada uno hereda del
// anterior solo lo que no fija; `section` hereda del texto del cuerpo. Así `section:
// (title-smallcaps: true)` pone en versalitas las secciones y las inferiores, y
// `subsection: (title-smallcaps: false)` las quita en las subsecciones.

// Valor de cada clave si el preajuste no la fija
#let base = (
  start: "odd",
  end: none,
  above: 4em,
  below: 4em,
  align: center,
  label: none,
  label-text: (:),
  label-upper: false,
  number-format: n => n,
  gap: 1em,
  title-text: (:),
  title-upper: false,
  title-smallcaps: false,
  rule: none,
  rule-length: 100%,
  rule-gap: 0.6em,
  ornament: none,
)

// Valor de cada clave de un título de sección si el preajuste no la fija: el texto del cuerpo
#let run-base = (
  above: 1em,
  below: 1em,
  align: left,
  number-format: n => n,
  number-text: (:),
  number-sep: h(7pt),
  title-text: (:),
  title-upper: false,
  title-smallcaps: false,
)

#let soft = luma(45%)

// Como las clases estándar de LaTeX, con la etiqueta "CAPÍTULO N" sobre el título centrado
#let classic = (
  part: (
    above: 1.5fr,
    below: 1.5fr,
    end: "odd",
    label: "part",
    label-text: (size: 1.15em, weight: 500, tracking: 0.25em),
    label-upper: true,
    title-text: (size: 1.8em, weight: 700, tracking: 0.05em),
    title-upper: true,
    ornament: auto,
    front: (above: 2em, below: 2em, start: "page", end: none, label: none, number-format: none),
  ),
  chapter: (
    label: "chapter",
    label-text: (size: 1.1em, weight: 500, tracking: 0.25em),
    label-upper: true,
    title-text: (size: 1.8em, weight: 500, tracking: 0.05em),
    appendix: (label: "appendix"),
    back: (label: none, number-format: none, title-text: (tracking: 0pt)),
    front: (start: "facing", above: 2em, below: 1.5em, label: none, number-format: none, title-text: (tracking: 0pt)),
  ),
)

// Alineado a la izquierda, etiqueta pequeña y gris, título en negrita y un filete corto debajo;
// con el índice y las cabeceras `modern`
#let modern = (
  part: (
    above: 1.5fr,
    below: 1.5fr,
    end: "odd",
    align: left,
    label: "part",
    label-text: (size: 0.9em, weight: 600, tracking: 0.2em, fill: soft),
    label-upper: true,
    gap: 0.8em,
    title-text: (size: 2.2em, weight: 700),
    rule: 0.5pt + soft,
    rule-length: 4em,
    rule-gap: 0.8em,
    ornament: auto,
    front: (above: 2em, below: 2em, start: "page", end: none, label: none, number-format: none, rule: none),
  ),
  chapter: (
    align: left,
    above: 3em,
    below: 3em,
    label: "chapter",
    label-text: (size: 0.85em, weight: 600, tracking: 0.2em, fill: soft),
    label-upper: true,
    gap: 0.6em,
    title-text: (size: 2em, weight: 700),
    rule: 0.5pt + soft,
    rule-length: 3em,
    rule-gap: 0.8em,
    appendix: (label: "appendix"),
    back: (label: none, number-format: none, rule: none),
    front: (start: "facing", above: 2em, below: 1.5em, label: none, number-format: none, rule: none),
  ),
)

// Centrado, etiqueta en cursiva, título en versalitas espaciadas y un filete corto como
// adorno; con el índice y las cabeceras `elegant`
#let elegant = (
  part: (
    above: 1.5fr,
    below: 1.5fr,
    end: "odd",
    label: "part",
    label-text: (size: 1.05em, weight: 400, style: "italic", tracking: 0.05em),
    gap: 0.8em,
    title-text: (size: 1.7em, weight: 400, tracking: 0.12em),
    title-smallcaps: true,
    ornament: auto,
    front: (above: 2em, below: 2em, start: "page", end: none, label: none, number-format: none),
  ),
  chapter: (
    label: "chapter",
    label-text: (size: 1.05em, weight: 400, style: "italic", tracking: 0.05em),
    gap: 0.8em,
    title-text: (size: 1.7em, weight: 400, tracking: 0.1em),
    title-smallcaps: true,
    ornament: line(length: 2.5em, stroke: 0.5pt),
    appendix: (label: "appendix"),
    back: (label: none, number-format: none, ornament: none),
    front: (start: "facing", above: 2em, below: 1.5em, label: none, number-format: none, ornament: none),
  ),
)

// Secciones en versalitas con su número y, más abajo, títulos en negrita
#let classic-run = (
  section: (above: 1em, below: 1em, title-text: (size: 1.2em, weight: 400, tracking: 0.03em), title-smallcaps: true),
  subsection: (above: 0.8em, below: 0.5em, title-text: (size: 1.05em, weight: "bold", tracking: 0pt), title-smallcaps: false),
  subsubsection: (above: 0.8em, below: 0.4em, title-text: (size: 1em)),
  paragraph: (above: 0.8em, below: 0.3em, title-text: (style: "italic")),
)

#let modern-run = (
  section: (
    above: 1.4em,
    below: 0.8em,
    number-text: (fill: soft),
    number-sep: h(0.8em),
    title-text: (size: 1.15em, weight: 700, tracking: 0em),
    title-smallcaps: false,
  ),
  subsection: (above: 1.2em, below: 0.5em, title-text: (size: 1em, weight: 600)),
  subsubsection: (above: 1em, below: 0.4em, title-text: (style: "italic")),
  paragraph: (above: 0.8em, below: 0.3em),
)

#let elegant-run = (
  section: (
    above: 1.6em,
    below: 1em,
    align: center,
    number-sep: h(0.6em),
    title-text: (size: 1.1em, weight: 400, tracking: 0.08em),
    title-smallcaps: true,
  ),
  subsection: (above: 1.2em, below: 0.6em, align: left, title-text: (size: 1.05em, weight: 400, style: "italic", tracking: 0pt), title-smallcaps: false),
  subsubsection: (above: 1em, below: 0.4em, title-text: (size: 1em)),
  paragraph: (above: 0.8em, below: 0.3em),
)

#let presets = (classic: classic + classic-run, modern: modern + modern-run, elegant: elegant + elegant-run)
#let names = presets.keys()

#let openings = ("part", "chapter")
#let runs = ("section", "subsection", "subsubsection", "paragraph")
#let roles = openings + runs
#let variants = ("front", "back", "appendix")
#let text-keys = ("label-text", "title-text", "number-text")

// Nivel de cada rol según la clase
#let levels = (
  book: (part: 1, chapter: 2, section: 3, subsection: 4, subsubsection: 5, paragraph: 6),
)

#let check-role(name, spec) = {
  assert(type(spec) == dictionary, message: "heading-style: " + name + " debe ser un diccionario")
  let valid = if name in openings { base } else { run-base }
  for (key, value) in spec {
    if name in openings and key in variants {
      assert(
        name == "chapter" or key != "appendix",
        message: "heading-style: «appendix» solo existe en chapter",
      )
      assert(type(value) == dictionary, message: "heading-style: " + name + "." + key + " debe ser un diccionario")
      for inner in value.keys() {
        assert(
          inner in base,
          message: "heading-style: clave desconocida «" + inner + "» en " + name + "." + key + ". Claves válidas: " + base.keys().join(", "),
        )
      }
    } else {
      assert(
        key in valid,
        message: "heading-style: clave desconocida «"
          + key
          + "» en "
          + name
          + ". Claves válidas: "
          + valid.keys().join(", ")
          + if name in openings { "; variantes: " + variants.join(", ") } else { "" },
      )
    }
  }
}

// Une dos diccionarios; los de texto se combinan en lugar de reemplazarse
#let merge(a, b) = {
  let out = a
  for (key, value) in b {
    if key in text-keys and type(value) == dictionary {
      out.insert(key, out.at(key, default: (:)) + value)
    } else if key in variants {
      out.insert(key, merge(out.at(key, default: (:)), value))
    } else {
      out.insert(key, value)
    }
  }
  out
}

// `heading-style` ya validado y completo: un diccionario por rol. `h1`…`h6` se traducen
// al rol que tiene ese nivel en `class`
#let resolve(spec, class: "book") = {
  let spec = if type(spec) == str { (preset: spec) } else { spec }
  assert(
    type(spec) == dictionary,
    message: "heading-style debe ser el nombre de un preajuste (" + names.join(", ") + ") o un diccionario",
  )
  let aliases = range(1, 7).map(n => "h" + str(n))
  let user = (:)
  for (key, value) in spec {
    if key == "preset" { continue }
    let role = key
    if key in aliases {
      let level = int(key.slice(1))
      role = levels.at(class).pairs().find(((_, l)) => l == level)
      assert(role != none, message: "heading-style: la clase " + class + " no tiene nivel " + str(level) + " (" + key + ")")
      role = role.first()
    }
    assert(
      role in roles,
      message: "heading-style: clave desconocida «" + key + "». Claves válidas: preset, " + roles.join(", ") + ", " + aliases.join(", "),
    )
    assert(role not in user, message: "heading-style: «" + role + "» está dos veces (por su nombre y por su alias)")
    user.insert(role, value)
  }
  let name = spec.at("preset", default: "classic")
  assert(name in presets, message: "heading-style: preajuste desconocido «" + str(name) + "». Preajustes: " + names.join(", "))
  let out = (:)
  for role in roles {
    let own = user.at(role, default: (:))
    check-role(role, own)
    out.insert(role, merge(presets.at(name).at(role), own))
  }
  out
}

// Estilo de una apertura para una variante (none = la base): base ← claves del rol ← variante
#let leaf(style, role, variant) = {
  let own = style.at(role)
  let plain = own.pairs().filter(((k, _)) => k not in variants).to-dict()
  merge(merge(base, plain), if variant != none { own.at(variant, default: (:)) } else { (:) })
}

// Estilo de un título de sección: cada rol hereda del anterior, y el primero del cuerpo
#let run-leaf(style, role) = {
  let out = run-base
  for name in runs {
    out = merge(out, style.at(name))
    if name == role { break }
  }
  out
}
