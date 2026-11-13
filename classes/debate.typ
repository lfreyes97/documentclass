// Clase debate — transcripción de un debate, entrevista o mesa redonda.
// Los turnos son `#turn("clave")[…]` y los oradores se declaran en la clase (`speakers`).
// Los segmentos (`#segment`) son títulos de nivel 2, más ligeros que `=`; los títulos (`=`, `==`) siguen el preajuste de `article` hasta que haya segmentos propios.

#import "../components/i18n.typ"
#import "../components/lines.typ"
#import "../components/debug.typ" as debug-mod
#import "../components/fonts.typ" as fonts-mod
#import "../components/microtype.typ" as microtype-mod
#import "../components/margins.typ"
#import "../components/headings.typ"
#import "../components/openings.typ"
#import "../components/themes.typ"
#import "../components/pagestyle.typ"
#import "../components/debates.typ" as debates

#let margin-defaults = (
  facing: (inside: 3cm, outside: 2cm, y: 2.5cm),
  single: (x: 2.5cm, y: 2.5cm),
)

#let turn-styles = ("classic", "modern")
#let mark-defaults = (crowd: true, inaudible: true, timecodes: false)
#let speaker-keys = ("name", "short", "role", "moderator")

// Oradores y plantilla declarados en la clase (requieren `context`)
#let template-state = state("dc-debate-template", none)
#let marks-state = state("dc-debate-marks", mark-defaults)
#let speakers-state = state("dc-debate-speakers", (:))
#let turn-style-state = state("dc-debate-turn-style", "classic")

// `speakers` sin errores de tecleo: cada orador es un diccionario con `name` y, si se quiere, `short`
// (la etiqueta del turno, por defecto `name`), `role` y `moderator` (true: no cuenta como orador de la plantilla)
#let check-speakers(speakers) = {
  assert(type(speakers) == dictionary, message: "speakers debe ser un diccionario, p. ej. `speakers: (sproul: (name: \"R. C. Sproul\"))`")
  let resolved = (:)
  for (key, speaker) in speakers {
    let speaker = if type(speaker) == str { (name: speaker) } else { speaker }
    assert(type(speaker) == dictionary, message: "speakers: «" + key + "» debe ser un nombre o un diccionario con name, short y role")
    for field in speaker.keys() {
      assert(field in speaker-keys, message: "speakers: «" + key + "» tiene la clave desconocida «" + field + "». Claves válidas: " + speaker-keys.join(", "))
    }
    assert("name" in speaker, message: "speakers: a «" + key + "» le falta `name`")
    resolved.insert(key, (short: speaker.name, role: none, moderator: false) + speaker)
  }
  resolved
}

// El rótulo de un turno según el estilo: `classic` en línea (en negrita), `modern` en su propia línea
#let label-of(style, name, role) = if style == "modern" {
  block(above: 0.9em, below: 0.35em, sticky: true)[
    #strong(name)#if role != none [ #h(0.4em) #text(size: 0.85em, fill: luma(110), style: "italic")[#role]]
  ]
} else {
  [#strong(name):#h(0.3em, weak: true)]
}

// `marks`: true (reacciones del público e [inaudible], sin códigos de tiempo), false (ninguna) o un
// diccionario con crowd, inaudible y timecodes
#let check-marks(marks) = {
  if marks == true { return mark-defaults }
  if marks == false { return (crowd: false, inaudible: false, timecodes: false) }
  assert(type(marks) == dictionary, message: "marks debe ser true, false o un diccionario con " + mark-defaults.keys().join(", "))
  for key in marks.keys() {
    assert(key in mark-defaults, message: "marks: clave desconocida «" + key + "». Claves válidas: " + mark-defaults.keys().join(", "))
  }
  mark-defaults + marks
}

/// Reacción del público dentro de un turno: `#crowd[risas]` sale «(risas)», en cursiva.
#let crowd(body) = context if marks-state.get().crowd { text(style: "italic")[(#body)] }

/// Pasaje que no se entiende en la grabación: `#inaudible` sale «[inaudible]».
#let inaudible = context if marks-state.get().inaudible { text(style: "italic")[\[inaudible\]] }

/// Código de tiempo de la grabación, solo con `marks: (timecodes: true)`: `#at("12:30")`.
#let at(time) = context if marks-state.get().timecodes { text(size: 0.8em, fill: luma(110), font: fonts-mod.current.get().mono)[\[#time\]] }

// Numeración de la nota del traductor: un símbolo propio, para no mezclarla con las del editor
#let tnote-mark(..n) = "†"

/// Nota del traductor, distinta de la nota del editor (`footnote`): lleva † y «N. del T.».
#let tnote(body) = {
  footnote(numbering: tnote-mark, body)
  // La nota del traductor no cuenta en la serie de las del editor
  counter(footnote).update(n => n - 1)
}

/// Turno de palabra de un orador declarado en `speakers`: `#turn("sproul")[…]`.
/// - `cont: true`: el mismo orador sigue tras una interrupción, sin repetir el rótulo.
/// - `label`: rótulo de alguien que no está declarado («Miembro del público»); con él, `who` es `none`.
#let turn(who, cont: false, label: none, body) = context {
  let speakers = speakers-state.get()
  let style = turn-style-state.get()
  let mark = if cont { none } else if who == none {
    assert(label != none, message: "turn: da la clave de un orador o `label:` con el rótulo")
    label-of(style, label, none)
  } else {
    assert(
      who in speakers,
      message: "turn: orador desconocido «" + repr(who) + "». Oradores declarados: " + speakers.keys().join(", "),
    )
    assert(label == none, message: "turn: `label:` solo va con `none` como orador")
    let speaker = speakers.at(who)
    label-of(style, speaker.short, speaker.role)
  }
  block(above: 1.1em, below: 1.1em, breakable: true, {
    set par(first-line-indent: 0pt)
    mark
    body
  })
}

/// Segmento del debate, un título ligero (nivel 2): `#segment("opening", speaker: "bahnsen", time: duration(minutes: 30))`.
/// - `kind`: presentación (`opening`), réplica (`rebuttal`), contrainterrogatorio (`cross`), preguntas del
///   público (`questions`), conclusión (`closing`), introducción, ronda o tema; la plantilla fija cuáles
///   admite. Con `none`, `title` es obligatorio.
/// - `speaker`: clave del orador del segmento, que se añade al título.
/// - `time`: duración (`duration(minutes: 30)`) o texto, en una línea bajo el título.
/// - `title`: título propio; por defecto, la etiqueta traducida del tipo.
#let segment(kind, speaker: none, time: none, title: auto) = context {
  let speakers = speakers-state.get()
  if kind == none { assert(title != auto, message: "segment: sin tipo (`none`) hay que dar `title`") } else {
    debates.check-kind(template-state.get(), kind)
  }
  if speaker != none {
    assert(
      speaker in speakers,
      message: "segment: orador desconocido «" + repr(speaker) + "». Oradores declarados: " + speakers.keys().join(", "),
    )
  }
  let name = if title != auto { title } else { i18n.get(kind) }
  let shown = if speaker != none { [#name — #speakers.at(speaker).short] } else { name }
  let duration = if type(time) == duration { [#calc.round(time.minutes()) min] } else { time }
  heading(level: 2, shown)
  if duration != none {
    v(-0.3em)
    block(above: 0pt, below: 0.6em, text(size: 0.85em, style: "italic", fill: luma(110), duration))
  }
}

#let debate(
  title: none,
  subtitle: none,
  // Tema del debate o proposición, bajo el título
  proposition: none,
  author: none,
  date: none,
  // Oradores por clave: (sproul: (name: "R. C. Sproul", short: "Sproul", role: "clásico"), …)
  speakers: (:),
  // Formato del debate: "two-speakers", "panel" o "interview" fijan los segmentos admitidos y cuántos
  // oradores lleva; none = formato libre
  template: none,
  // Marcas de la transcripción (`crowd`, `inaudible`, `at`): true, false o un diccionario
  marks: true,
  // Estilo de los turnos: "classic" (rótulo en línea) o "modern" (rótulo en su línea). auto = el del tema
  turn-style: auto,
  paper: "a5",
  font-size: 11pt,
  margin: auto,
  facing-pages: false,
  style: auto,
  heading-style: auto,
  page-style: auto,
  fonts: (:),
  lang: "es",
  labels: (:),
  microtype: true,
  line-numbers: false,
  debug: false,
  body,
) = {
  let style = themes.check(style)
  let turn-style = if turn-style != auto { turn-style } else if style == "modern" { "modern" } else { "classic" }
  assert(
    turn-style in turn-styles,
    message: "turn-style: «" + repr(turn-style) + "» no es un estilo de turno. Estilos: " + turn-styles.join(", "),
  )
  let template = debates.check(template)
  let speakers = check-speakers(speakers)
  debates.check-speakers(template, speakers)
  let heading-style = openings.resolve(themes.pick(heading-style, style, "classic"), class: "article")
  let page-style = themes.pick(page-style, style, none)
  speakers-state.update(speakers)
  template-state.update(template)
  turn-style-state.update(turn-style)
  marks-state.update(check-marks(marks))

  set document(author: if type(author) in (str, array) { author } else { () }, title: title)
  let fonts = fonts-mod.resolve(fonts)
  fonts-mod.current.update(fonts)
  i18n.check(labels)
  i18n.overrides.update(labels)
  set text(font: fonts.body, size: font-size, lang: lang)
  show raw: set text(font: fonts.mono)
  show: microtype-mod.setup.with(microtype)
  let debug = debug-mod.resolve(debug)
  show: debug-mod.setup.with(debug)
  show: lines.setup.with(if debug.lines and line-numbers == false { true } else { line-numbers })

  set page(
    paper: paper,
    numbering: "1",
    number-align: center,
    margin: margins.resolve(margin, facing-pages, margin-defaults),
  )
  show: pagestyle.setup.with(
    page-style,
    class: "article",
    title: title,
    author: author,
    header-font: fonts.header,
    facing-pages: facing-pages,
  )

  set par(leading: 0.55em, justify: true, spacing: 0.75em)

  set heading(numbering: none)
  show heading: set heading(supplement: i18n.term("section"))
  show heading: set text(size: font-size)
  show heading.where(level: 1): set text(font: fonts.h1, weight: "bold", hyphenate: true)
  show heading.where(level: 2): set text(font: fonts.h2, weight: "bold", hyphenate: true)
  show heading.where(level: 1): it => context {
    headings.run-heading(it, openings.run-leaf(heading-style, "section"), fonts.h1)
  }
  show heading.where(level: 2): it => context {
    headings.run-heading(it, openings.run-leaf(heading-style, "subsection"), fonts.h2)
  }

  show footnote.entry: it => {
    let loc = it.note.location()
    if it.note.numbering == tnote-mark {
      [† #i18n.term("translator"): #it.note.body]
    } else {
      numbering("1. ", ..counter(footnote).at(loc))
      it.note.body
    }
  }

  // Cabecera de título: título, proposición, y fecha
  lines.off(fonts-mod.use("title", {
    v(1.5em)
    align(center)[
      #text(size: 18pt, weight: "bold")[#title]
      #if subtitle != none { v(0.4em); text(size: 11pt, style: "italic")[#subtitle] }
      #if proposition != none { v(0.9em); text(size: 11pt)[#proposition] }
      #if date != none { v(0.5em); text(size: 10pt)[#date] }
    ]
    v(1.5em)
  }))

  body
}
