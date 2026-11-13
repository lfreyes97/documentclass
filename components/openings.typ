// Estilo de los títulos (el fncychap y el titlesec de LaTeX), parámetro `heading-style`.
//
//   heading-style: "classic"                        un preajuste
//   heading-style: (chapter: (align: left))         cambios sobre "classic"
//   heading-style: (preset: "modern", part: (...), section: (...), h4: (...))
//   heading-style: (scale: 1.2)                     todos los tamaños, más grandes
//
// `scale` agranda cuánto sobresale cada tamaño del texto del cuerpo (1em): con `scale: 1.5`,
// 1.8em pasa a 2.2em y 1.2em a 1.3em, y un título a 1em sigue a 1em. Vale 1 por defecto. Afecta a
// `size` de `title-text` y de `label-text`.
//
// Cada rol (part, chapter, section, subsection, subsubsection, paragraph) es un diccionario.
// El rol de cada nivel depende de la clase: en book `part` es el nivel 1 y `chapter` el 2. `h1`…`h6`
// son alias del rol que tiene ese nivel en la clase. En debate el nivel 1 es `section` y el 2 es
// `segment`, el título ligero de cada segmento del debate (entre `section` y `subsection`).
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
// Títulos de sección (`section` y los inferiores): start (solo debate), above, below, align, number-format,
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
  start: none, // En debate: "page" o "odd" abren página nueva (o impar) antes del título; none, sigue de corrido
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

#import "themes.typ"

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

#let variants = ("front", "back", "appendix")
#let text-keys = ("label-text", "title-text", "number-text")

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

// Debate: la sección (`=`) y, más ligero, el segmento del debate; el resto, como en book
#let for-debate(theme, section, segment) = (
  // Las secciones y los segmentos abren página nueva; `start: none` los deja de corrido
  section: merge(theme.section, section + (start: "page")),
  segment: segment + (start: "page"),
  subsection: theme.subsection,
  subsubsection: theme.subsubsection,
  paragraph: theme.paragraph,
)

// Los preajustes de report y article reutilizan los de book con los niveles que les tocan: el
// capítulo de report abre en página nueva, y en article la sección es el primer nivel y sobresale
// como lo hacía el capítulo
#let for-report(theme) = (
  chapter: merge(theme.chapter, (start: "page", above: 2em, below: 2.5em)),
  section: theme.section,
  subsection: theme.subsection,
  subsubsection: theme.subsubsection,
  paragraph: theme.paragraph,
)
#let for-article(theme, size) = (
  section: merge(theme.section, (title-text: (size: size))),
  subsection: theme.section,
  subsubsection: theme.subsection,
  paragraph: theme.subsubsection,
)

// Capítulos en línea con su etiqueta y títulos en negrita, como las clases estándar de LaTeX.
// Los tamaños son los de un cuerpo de 11 pt (16/11 em = 16 pt) y siguen al cuerpo si cambia
#let classic-report = (
  chapter: (
    start: "page",
    above: 2.8em,
    below: 3.78em,
    align: left,
    label: "chapter",
    label-text: (size: 14 / 11 * 1em, style: "italic"),
    gap: 1.791em,
    title-text: (size: 24 / 11 * 1em, weight: "bold"),
  ),
  section: (above: 2.88em, below: 2.4em, number-sep: [], title-text: (size: 14 / 11 * 1em, weight: "bold"), title-smallcaps: false),
  subsection: (above: 2.2em, below: 1.8em, title-text: (size: 12 / 11 * 1em)),
  subsubsection: (above: 1.4em, below: 0.64em, title-text: (size: 1em)),
  paragraph: (:),
)

#let classic-article = (
  section: (above: 2.1em, below: 1.12em, number-sep: [.], title-text: (size: 16 / 11 * 1em, weight: "bold"), title-smallcaps: false),
  subsection: (above: 1.2em, below: 0.72em, number-sep: [], title-text: (size: 13 / 11 * 1em)),
  subsubsection: (above: 0.8em, below: 0.5em, title-text: (size: 1em, weight: "semibold")),
  paragraph: (:),
)

#let presets = (
  classic: (
    book: classic + classic-run,
    report: classic-report,
    article: classic-article,
    debate: for-debate(
      classic-run,
      (above: 2em, below: 1em, title-text: (size: 16 / 11 * 1em, weight: "bold"), title-smallcaps: false),
      (above: 1.6em, below: 0.6em, title-text: (size: 1.1em, weight: "bold", tracking: 0pt)),
    ),
  ),
  modern: (
    book: modern + modern-run,
    report: for-report(modern + modern-run),
    article: for-article(modern + modern-run, 1.45em),
    debate: for-debate(
      modern-run,
      (above: 2em, below: 1em, title-text: (size: 1.45em)),
      (above: 1.6em, below: 0.6em, title-text: (size: 0.8em, weight: 600, tracking: 0.14em, fill: soft), title-upper: true),
    ),
  ),
  elegant: (
    book: elegant + elegant-run,
    report: for-report(elegant + elegant-run),
    article: for-article(elegant + elegant-run, 1.45em),
    debate: for-debate(
      elegant-run,
      (above: 2em, below: 1em, title-text: (size: 1.45em)),
      (above: 1.6em, below: 0.7em, align: center, title-text: (size: 1.05em, weight: 400, tracking: 0.08em), title-smallcaps: true),
    ),
  ),
)
#let names = presets.keys()

#let openings = ("part", "chapter")
#let runs = ("section", "segment", "subsection", "subsubsection", "paragraph")
#let roles = openings + runs

// Nivel de cada rol según la clase
#let levels = (
  book: (part: 1, chapter: 2, section: 3, subsection: 4, subsubsection: 5, paragraph: 6),
  report: (chapter: 1, section: 2, subsection: 3, subsubsection: 4, paragraph: 5),
  article: (section: 1, subsection: 2, subsubsection: 3, paragraph: 4),
  debate: (section: 1, segment: 2, subsection: 3, subsubsection: 4, paragraph: 5),
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
  let scale = spec.at("scale", default: 1)
  assert(type(scale) in (int, float, ratio), message: "heading-style: scale debe ser un número positivo, p. ej. `scale: 1.2`")
  let scale = if type(scale) == ratio { scale / 100% } else { scale }
  assert(scale > 0, message: "heading-style: scale debe ser un número positivo, p. ej. `scale: 1.2`")
  for (key, value) in spec {
    if key in ("preset", "scale") { continue }
    let role = key
    if key in aliases {
      let level = int(key.slice(1))
      role = levels.at(class).pairs().find(((_, l)) => l == level)
      assert(role != none, message: "heading-style: la clase " + class + " no tiene nivel " + str(level) + " (" + key + ")")
      role = role.first()
    }
    assert(
      role in roles,
      message: "heading-style: clave desconocida «" + key + "». Claves válidas: preset, scale, " + roles.join(", ") + ", " + aliases.join(", "),
    )
    assert(
      role in levels.at(class),
      message: "heading-style: la clase " + class + " no tiene el rol «" + role + "». Roles de " + class + ": " + levels.at(class).keys().join(", "),
    )
    assert(role not in user, message: "heading-style: «" + role + "» está dos veces (por su nombre y por su alias)")
    user.insert(role, value)
  }
  let name = spec.at("preset", default: "classic")
  assert(name in presets, message: "heading-style: preajuste desconocido «" + str(name) + "». Preajustes: " + names.join(", ") + "." + themes.hint(name))
  let out = (:)
  for role in roles.filter(r => r in levels.at(class)) {
    let own = user.at(role, default: (:))
    check-role(role, own)
    out.insert(role, merge(presets.at(name).at(class).at(role), own))
  }
  out.insert("scale", scale)
  out
}

// `size` agrandado por `scale` en cuanto sobresale del cuerpo; las longitudes absolutas no cambian
#let scale-size(size, scale) = {
  if type(size) == length and size.abs == 0pt { 1em + (size - 1em) * scale } else { size }
}

#let scale-text(text-args, scale) = {
  if "size" in text-args { text-args + (size: scale-size(text-args.size, scale)) } else { text-args }
}

// Aplica `scale` a los tamaños de un estilo ya resuelto
#let scaled(s, scale) = {
  if scale == 1 { return s }
  let out = s
  for key in ("title-text", "label-text") {
    if key in out { out.insert(key, scale-text(out.at(key), scale)) }
  }
  out
}

// Estilo de una apertura para una variante (none = la base): base ← claves del rol ← variante
#let leaf(style, role, variant) = {
  let own = style.at(role)
  let plain = own.pairs().filter(((k, _)) => k not in variants).to-dict()
  scaled(merge(merge(base, plain), if variant != none { own.at(variant, default: (:)) } else { (:) }), style.scale)
}

// Estilo de un título de sección: cada rol hereda del anterior, y el primero del cuerpo
#let run-leaf(style, role) = {
  let out = run-base
  for name in runs {
    if name not in style { continue }
    out = merge(out, style.at(name))
    if name == role { break }
  }
  scaled(out, style.scale)
}
