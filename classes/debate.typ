// Clase debate — transcripción de un debate, entrevista o mesa redonda.
// Los turnos son `#turn("clave")[…]` y los oradores se declaran en la clase (`speakers`).
// Títulos: `=` es `section`, `#segment` (nivel 2) es `segment` y `===` es `subsection` en `heading-style`.

#import "../components/i18n.typ"
#import "../components/lines.typ"
#import "../components/debug.typ" as debug-mod
#import "../components/fonts.typ" as fonts-mod
#import "../components/microtype.typ" as microtype-mod
#import "../components/margins.typ"
#import "../components/headings.typ"
#import "../components/openings.typ"
#import "../components/themes.typ"
#import "../components/quotes.typ"
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
#let segment-start-state = state("dc-debate-segment-start", none)
#let breaks-state = state("dc-debate-breaks", none)
#let program-state = state("dc-debate-program", ())
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
/// - `id`: nombre del turno, para citarlo con `#cite-turn("id")`.
/// - `label`: rótulo de alguien que no está declarado («Miembro del público»); con él, `who` es `none`.
#let turn(who, cont: false, label: none, id: none, body) = {
  // Solo el rótulo lleva `context`: el bloque queda fuera para que el título de un segmento pegue con él
  let mark = context {
    let speakers = speakers-state.get()
    let style = turn-style-state.get()
    if who == none {
      assert(label != none, message: "turn: da la clave de un orador o `label:` con el rótulo")
    } else {
      assert(
        who in speakers,
        message: "turn: orador desconocido «" + repr(who) + "». Oradores declarados: " + speakers.keys().join(", "),
      )
      assert(label == none, message: "turn: `label:` solo va con `none` como orador")
    }
    let (short, role) = if who == none { (label, none) } else { (speakers.at(who).short, speakers.at(who).role) }
    [#metadata(short) <dc-turn>]
    if id != none [#metadata(short) #std.label(id)]
    if not cont { label-of(style, short, role) }
  }
  // Con `breaks: "turn"`, cada turno abre página, salvo el primero tras un título, el que continúa a otro y los de un
  // segmento de intercambio (introducción, preguntas, contrainterrogatorio, ronda, tema)
  let page-break = context {
    if not cont and breaks-state.get() == "turn" {
      let before = selector(heading).before(here(), inclusive: false)
      let last-heading = query(before).at(-1, default: none)
      let first-after-heading = last-heading != none and query(
        selector(<dc-turn>).after(last-heading.location()).before(here(), inclusive: false),
      ).len() == 0
      let first-turn = query(selector(<dc-turn>).before(here(), inclusive: false)).len() == 0
      let segment = query(selector(<dc-segment>).before(here(), inclusive: false)).at(-1, default: none)
      let exchange = segment != none and segment.value.kind in debates.exchange-kinds
      if not first-after-heading and not first-turn and not exchange { pagebreak(weak: true) }
    }
  }
  page-break
  block(above: 1.1em, below: 1.1em, breakable: true, {
    set par(first-line-indent: 0pt)
    mark
    body
  })
}

#let original-keys = ("title", "series", "recording", "transcript")

// Cabecera del debate: título, «A frente a B», proposición, lugar y fecha, moderador y datos de la edición
// original. Con `titlepage: true` ocupa una página propia, centrada; si no, va sobre el texto.
#let title-block(
  title,
  subtitle,
  proposition,
  venue,
  date,
  original,
  speakers,
  template,
  titlepage,
) = {
  let debaters = speakers.values().filter(s => not s.moderator).map(s => s.name)
  let moderators = speakers.values().filter(s => s.moderator).map(s => s.name)
  let size = if titlepage { 1.3 } else { 1 }
  let content = align(center)[
    #set par(justify: false)
    #text(size: 18pt * size, weight: "bold", hyphenate: false)[#title]
    #if subtitle != none { v(0.4em); text(size: 11pt * size, style: "italic")[#subtitle] }
    #if debaters.len() > 0 {
      v(0.9em)
      let versus = debaters.len() == 2 and template in (none, "two-speakers")
      text(size: 12pt * size)[#if versus [#debaters.first() #i18n.term("versus") #debaters.last()] else { debaters.join(", ", last: " · ") }]
    }
    #if proposition != none { v(0.7em); text(size: 11pt * size)[#proposition] }
    #if venue != none or date != none {
      v(0.5em)
      text(size: 10pt * size)[#(venue, date).filter(x => x != none).join(", ")]
    }
    #if moderators.len() > 0 {
      v(0.5em)
      text(size: 10pt * size)[#i18n.term("moderator"): #moderators.join(", ")]
    }
    #if original != none {
      v(1.1em)
      set text(size: 9pt * size, fill: luma(90))
      for (key, label) in (("title", "original-title"), ("series", "series"), ("recording", "recording"), ("transcript", "transcript")) {
        if key in original [#i18n.term(label): #original.at(key)\ ]
      }
    }
  ]
  if titlepage {
    page(numbering: none, header: none, footer: none, { v(1fr); content; v(1fr) })
  } else {
    v(1.5em)
    content
    v(1.5em)
  }
}

/// Cita de un turno por orador, página y línea: `#cite-turn("t12")` sale «Bahnsen, p. 12, l. 4» (la primera
/// línea del turno `#turn(…, id: "t12")`). Se calcula al compilar, así que no se desactualiza al cambiar el
/// papel, los márgenes o la fuente, pero la cita impresa solo vale para esa edición. Pide `line-numbers`.
#let cite-turn(id) = context {
  let found = query(label(id))
  assert(found.len() > 0, message: "cite-turn: no hay ningún turno con id «" + id + "»")
  let at = found.first().location()
  let page-text = std.numbering(page.numbering, ..counter(page).at(at))
  // `counter(par.line)` no sirve: cada línea numerada deja la marca <dc-line> con su número (ver lines.typ) y la
  // del turno es la de la misma página con la posición vertical más cercana
  let pos = at.position()
  let lines = query(<dc-line>).filter(m => m.location().page() == pos.page)
  assert(lines.len() > 0, message: "cite-turn: el documento no numera las líneas; pide `line-numbers`")
  let line = lines.sorted(key: m => calc.abs(m.location().position().y - pos.y)).first().value
  [#found.first().value, #i18n.get("page") #page-text, #i18n.get("line") #line]
}

// Páginas de una lista de posiciones, sin repetir y con los tramos seguidos juntos («2–4, 7»), cada una
// con un enlace (requiere `context`)
#let page-list(locations) = {
  let numbered(loc) = if page.numbering == none { str(loc.page()) } else { std.numbering(page.numbering, ..counter(page).at(loc)) }
  let firsts = (:)
  for loc in locations {
    let n = loc.page()
    if str(n) not in firsts { firsts.insert(str(n), loc) }
  }
  let pages = firsts.keys().map(int).sorted()
  let runs = ()
  for n in pages {
    if runs.len() > 0 and runs.last().last() == n - 1 { runs.last().push(n) } else { runs.push((n,)) }
  }
  runs.map(run => {
    let first = link(firsts.at(str(run.first())), numbered(firsts.at(str(run.first()))))
    if run.len() == 1 { first } else {
      [#first–#link(firsts.at(str(run.last())), numbered(firsts.at(str(run.last()))))]
    }
  }).join[, ]
}

/// Índice de oradores: cada orador declarado en `speakers` con las páginas en que habla, y después quienes
/// solo salen con `label:` («Miembro del público»). Lo que se escribe con `#turn` es lo que cuenta.
#let speakers-index(title: auto) = {
  heading(level: 1, i18n.title-or(title, "speakers-index"))
  lines.off(context {
    let speakers = speakers-state.get()
    let turns = query(<dc-turn>)
    let by-short = (:)
    for t in turns {
      let name = t.value
      if name not in by-short { by-short.insert(name, ()) }
      by-short.at(name).push(t.location())
    }
    let declared = speakers.values().filter(s => s.short in by-short)
    let entries = declared.map(s => (s.name, s.role, by-short.at(s.short)))
    let others = by-short.keys().filter(k => k not in speakers.values().map(s => s.short))
    entries += others.map(k => (k, none, by-short.at(k)))
    for (name, role, locations) in entries {
      block(above: 0.5em, below: 0.5em, breakable: false)[
        #name#if role != none [ #text(fill: luma(110), style: "italic")[(#role)]]
        #box(width: 1fr, repeat[.]) #page-list(locations)
      ]
    }
  })
}

// Sin tildes ni mayúsculas, para ordenar el glosario como un diccionario
#let sort-key(term) = lower(term).replace("á", "a").replace("é", "e").replace("í", "i").replace("ó", "o").replace("ú", "u").replace("ü", "u").replace("ñ", "n~")

/// Marca en el texto un término del glosario: `#gloss("fideismo")[fideísmo]` lo deja como está y apunta la
/// página para el glosario.
#let gloss(key, body) = [#metadata(key) <dc-gloss>#body]

/// Glosario: `#glossary((fideismo: (term: "Fideísmo", def: [Postura…]), …))`. Cada entrada lleva las páginas
/// donde se marcó con `#gloss`. Por defecto va en orden alfabético; con `sort: false`, en el dado.
#let glossary(entries, title: auto, sort: true) = {
  assert(type(entries) == dictionary, message: "glossary: las entradas son un diccionario `(clave: (term:, def:), …)`")
  for (key, entry) in entries {
    assert(
      type(entry) == dictionary and entry.keys().sorted() == ("def", "term"),
      message: "glossary: «" + key + "» debe ser un diccionario con `term` y `def`",
    )
  }
  heading(level: 1, i18n.title-or(title, "glossary"))
  lines.off(context {
    let marks = query(<dc-gloss>)
    for m in marks {
      assert(m.value in entries, message: "gloss: «" + m.value + "» no está en el glosario. Entradas: " + entries.keys().join(", "))
    }
    let keys = if sort { entries.keys().sorted(key: k => sort-key(entries.at(k).term)) } else { entries.keys() }
    for key in keys {
      let pages = marks.filter(m => m.value == key).map(m => m.location())
      block(above: 0.7em, below: 0.7em, breakable: false)[
        *#entries.at(key).term*#if pages.len() > 0 [ #text(fill: luma(110))[(#page-list(pages))]]. #entries.at(key).def
      ]
    }
  })
}

// Salto de página antes de un título (`start` de `heading-style`): "page" o "odd". El primer título del documento no
// salta, para que el título del debate no se quede solo en su página (requiere `context`)
#let break-before(start) = context {
  if start != none and query(selector(heading).before(here(), inclusive: false)).len() > 0 {
    pagebreak(weak: true, to: if start == "odd" { "odd" })
  }
}

/// Segmento del debate, un título ligero (nivel 2): `#segment("opening", speaker: "bahnsen", time: duration(minutes: 30))`.
/// Sin tipo, `#segment()` abre el siguiente del programa (`program`, por defecto el de la plantilla), con su
/// orador y su tiempo; lo que se dé con nombre lo sustituye.
/// - `kind`: presentación (`opening`), réplica (`rebuttal`), contrainterrogatorio (`cross`), preguntas del
///   público (`questions`), conclusión (`closing`), introducción, ronda o tema; la plantilla fija cuáles
///   admite. Con `none`, `title` es obligatorio. Un segmento con tipo no gasta uno del programa.
/// - `speaker`: clave del orador del segmento, que se añade al título.
/// - `time`: duración (`duration(minutes: 30)`) o texto, en una línea bajo el título.
/// - `title`: título propio; por defecto, la etiqueta traducida del tipo.
#let segment(..args, speaker: auto, time: auto, title: auto) = {
  assert(args.pos().len() <= 1, message: "segment: lleva a lo sumo un tipo, p. ej. `#segment(\"opening\")`")
  if args.named().len() > 0 { panic("segment: argumento desconocido «" + args.named().keys().first() + "»") }
  let kind = args.pos().at(0, default: auto)
  let counter = counter("dc-segment-program")
  // El salto va fuera del `context` del segmento: dentro, el contador del programa no converge
  context break-before(segment-start-state.get())
  context {
    let speakers = speakers-state.get()
    let step = if kind == auto {
      let program = program-state.get()
      let n = counter.get().first()
      assert(
        n < program.len(),
        message: "segment: no queda ningún segmento en el programa (" + str(program.len()) + "). Da el tipo, `#segment(\"closing\")`, o amplía `program`",
      )
      program.at(n)
    } else { (kind: kind) }
    let kind = step.kind
    let speaker = if speaker != auto { speaker } else { step.at("speaker", default: none) }
    let time = if time != auto { time } else { step.at("time", default: none) }
    let title = if title != auto { title } else { step.at("title", default: auto) }
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
    if args.pos().len() == 0 { counter.step() }
    [#metadata((title: shown, speaker: if speaker != none { speakers.at(speaker).short }, kind: kind)) <dc-segment>]
    heading(level: 2, shown)
    if duration != none {
      v(-0.3em)
      block(above: 0pt, below: 0.6em, text(size: 0.85em, style: "italic", fill: luma(110), duration))
    }
  }
}

#let debate(
  title: none,
  subtitle: none,
  // Tema o proposición del debate, bajo los nombres de los oradores
  proposition: none,
  author: none,
  date: none,
  // Lugar del debate («Reformed Theological Seminary, Jackson»)
  venue: none,
  // Datos de la edición original, todos opcionales: (title:, series:, recording:, transcript:)
  original: none,
  // true: cabecera del debate en una página propia (la portadilla «A frente a B»)
  titlepage: false,
  // Oradores por clave: (sproul: (name: "R. C. Sproul", short: "Sproul", role: "clásico"), …)
  speakers: (:),
  // Formato del debate: "two-speakers", "panel" o "interview" fijan los segmentos admitidos y cuántos
  // oradores lleva; none = formato libre
  template: none,
  // Marcas de la transcripción (`crowd`, `inaudible`, `at`): true, false o un diccionario
  marks: true,
  // Segmentos que `#segment()` abre uno tras otro: auto (los de la plantilla, con los oradores en el orden de
  // `speakers`), none, o una lista de diccionarios `(kind:, speaker:, time:, title:)`
  program: auto,
  // Dónde salta la página: auto (según la plantilla: "turn" en todas; "segment" en formato libre), "turn" (cada turno,
  // segmento y sección), "segment", "section" (solo las secciones `=`) o none
  breaks: auto,
  // Estilo de los turnos: "classic" (rótulo en línea) o "modern" (rótulo en su línea). auto = el del tema
  turn-style: auto,
  paper: "a5",
  font-size: 11pt,
  margin: auto,
  facing-pages: false,
  // Portada y contraportada, compatibles con coverbook, como en book. `cover` es contenido ya armado (p. ej. de
  // `cover-pages`) o una función de estilo (`bahnsen-cover`…), que se llama con title, subtitle y author más
  // `cover-data`; `back-cover` es auto (la de `cover` si es una función), contenido o none
  cover: none,
  back-cover: auto,
  cover-data: (:), // Datos extra para la función de portada: isbn, back-text, volume…
  cover-options: (:), // Opciones de la función de portada: trim, spine, colores…

  style: auto,
  // Estilo de los títulos: un tema o un diccionario (ver components/openings.typ). En debate, `section` es `=`,
  // `segment` es `#segment` y `subsection` es `===`
  heading-style: auto,
  // Estilo de epígrafes, citas largas y versos: un tema o un diccionario (ver components/quotes.typ)
  quote-style: auto,
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
  if original != none {
    assert(type(original) == dictionary, message: "original debe ser un diccionario con " + original-keys.join(", "))
    for key in original.keys() {
      assert(key in original-keys, message: "original: clave desconocida «" + key + "». Claves válidas: " + original-keys.join(", "))
    }
  }
  let speakers = check-speakers(speakers)
  debates.check-speakers(template, speakers)
  let heading-style = openings.resolve(themes.pick(heading-style, style, "classic"), class: "debate")
  quotes.current.update(quotes.resolve(themes.pick(quote-style, style, "classic")))
  // Por defecto la cabecera lleva los oradores de la página y el segmento vigente (ver components/pagestyle.typ)
  let page-style = themes.pick(page-style, style, "running-segment")
  speakers-state.update(speakers)
  template-state.update(template)
  let breaks = debates.check-breaks(breaks, template)
  breaks-state.update(breaks)
  // `heading-style` dice cómo salta (page, odd) y `breaks` dónde
  segment-start-state.update(if breaks in ("turn", "segment") { openings.run-leaf(heading-style, "segment").start })
  program-state.update(debates.resolve-program(program, template, speakers))
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
  show: lines.setup.with(if debug.lines and line-numbers == false { true } else { line-numbers }, track: true)

  set page(
    paper: paper,
    numbering: "1",
    number-align: center,
    margin: margins.resolve(margin, facing-pages, margin-defaults),
  )
  // Portada, antes de la cabecera y el pie: la función de portada recibe los datos del libro
  let cover-book = (title: title, subtitle: subtitle, author: author)
    .pairs()
    .filter(((_, value)) => value != none)
    .to-dict() + cover-data
  let make-cover(side) = cover(cover-book, side: side, ..cover-options)
  let back-cover = if back-cover != auto { back-cover } else if type(cover) == function { make-cover("back") }
  if type(cover) == function { make-cover("front") } else { cover }
  // El cuerpo empieza en la página 1, no tras la portada
  if cover != none { counter(page).update(1) }

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
  show heading.where(level: 1): set text(font: fonts.h1, hyphenate: true)
  show heading.where(level: 2): set text(font: fonts.h2, hyphenate: true)
  show heading.where(level: 3): set text(font: fonts.h3, hyphenate: true)
  show heading.where(level: 1): it => context {
    let leaf = openings.run-leaf(heading-style, "section")
    break-before(if breaks != none { leaf.start })
    headings.run-heading(it, leaf, fonts.h1)
  }
  // Los segmentos (nivel 2) van pegados al turno que sigue: `run-heading` no deja un bloque
  show heading.where(level: 2): it => context {
    block(sticky: true, headings.run-heading(it, openings.run-leaf(heading-style, "segment"), fonts.h2, in-block: true))
  }
  show heading.where(level: 3): it => context {
    headings.run-heading(it, openings.run-leaf(heading-style, "subsection"), fonts.h3)
  }
  show heading.where(level: 4): it => context {
    headings.run-heading(it, openings.run-leaf(heading-style, "subsubsection"), fonts.h4)
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

  lines.off(fonts-mod.use("title", title-block(title, subtitle, proposition, venue, date, original, speakers, template, titlepage)))

  body
  back-cover
}
