// Cabeceras y pies de página (el fancyhdr de LaTeX), parámetro `page-style`.
//
//   page-style: "classic"                      un preajuste
//   page-style: none                           sin cabecera ni pie propios
//   page-style: (header: (...), footer: (...)) cambios sobre "classic"
//   page-style: (preset: "classic", footer: (center: none, right: ctx => ctx.folio))
//
// `header` y `footer` son `none` (sin él) o un diccionario con:
//   left, center, right   Contenido de cada espacio, o `ctx => contenido`
//   odd, even             Los mismos espacios para recto y verso. Solo cuentan con
//                         `facing-pages: true`; sin ella todas las páginas usan `odd`
//   rule                  Filete: un trazo (`0.5pt + gray`) o `none`
//   text                  Argumentos de `text` (size, style, weight…)
//   when                  `ctx => bool`: en qué páginas aparece
// Si das algún espacio (left, center, right, odd, even), tus espacios sustituyen a los
// del preajuste; `rule`, `text` y `when` se combinan uno a uno con los suyos.
//
// El contexto `ctx` describe la página:
//   part, chapter, section  Título vigente de cada nivel (contenido) o none. Un nivel se
//                           reinicia al empezar el superior, como `\markboth`
//   folio                   Número de página ya formateado con la numeración de la página
//   page                    Número físico de página
//   title, author           Los del documento
//   started                 false antes de la primera división del documento
//   opening                 "part" o "chapter" si la página abre una; si no, none
//   blank                   Página en blanco intencional (reverso antes de una parte)
//   numbered                false si la página no lleva numeración
//   matter                  "front", "main" o "back" en book; none en otras clases
//   segment, speaker        En debate: título del segmento de la página (el vigente en lo alto, o el que
//                           empieza en su tercio superior) y el orador que le dio `#segment(speaker:)`; none fuera de un segmento o sin orador
//   speakers                En debate: los oradores que hablan en la página, sin repetir, en orden
//                           (lista de textos; vacía en las demás clases)

#import "headings.typ"
#import "tocs/bridge.typ"

// Título corrido del recto (capítulo, o sección, o parte, o el título del documento) y del
// verso (parte, o el título del documento)
#let chain(..options) = options.pos().find(o => o != none)
#let recto-title(ctx) = chain(ctx.chapter, ctx.section, ctx.part, ctx.title)
#let verso-title(ctx) = chain(ctx.part, ctx.title)

// Folio y título de la cabecera: antes de la primera división solo el folio
#let with-title(ctx, title, first: false) = {
  if not ctx.started { return ctx.folio }
  if first [#ctx.folio#h(1.2em)#title] else [#title#h(1.2em)#ctx.folio]
}

#let soft = luma(45%)

// Páginas que llevan algo: con numeración y no en blanco. Cada preajuste añade si quiere
// la cabecera en las páginas de apertura (`ctx.opening`) y el folio en las de parte
#let visible(ctx) = ctx.numbered and not ctx.blank
#let running(ctx) = ctx.started and visible(ctx) and ctx.opening == none
#let folio-shown(ctx) = visible(ctx) and ctx.opening != "part"

// Como las clases estándar de LaTeX: en el recto el capítulo, en el verso la parte, con un
// filete gris; el folio al centro del pie. La cabecera no aparece en el front matter ni en
// las páginas de apertura, en blanco o sin numeración
#let classic = (
  header: (
    odd: (right: ctx => emph(recto-title(ctx))),
    even: (left: ctx => emph(verso-title(ctx))),
    rule: 0.5pt + gray,
    text: (size: 9pt, weight: "regular"),
    when: running,
  ),
  footer: (
    center: ctx => ctx.folio,
    rule: none,
    text: (size: 10pt),
    when: folio-shown,
  ),
)

// `running-segment` (debate): a la izquierda los oradores que hablan en la página, a la derecha el segmento
// vigente, con un filete gris. Sin cabecera en la primera página, donde va el título del debate
#let running-segment = (
  header: (
    // Un solo espacio, de ancho completo: con tres columnas, una lista larga de oradores se partiría
    left: ctx => [#ctx.speakers.join(" · ")#h(1fr)#emph(ctx.segment)],
    rule: 0.5pt + gray,
    text: (size: 9pt, weight: "regular"),
    when: ctx => visible(ctx) and ctx.page > 1 and (ctx.segment != none or ctx.speakers.len() > 0),
  ),
  footer: classic.footer,
)

// `plain`: solo el folio al centro, como el `plain` de LaTeX
#let plain = (
  header: none,
  footer: classic.footer,
)

// `running-outer`: folio siempre en el borde exterior, junto al título corrido; en las aperturas, el folio
// abajo y al centro. Para doble cara: sin ella todas las páginas son rectos
#let running-outer = (
  header: (
    odd: (right: ctx => with-title(ctx, emph(recto-title(ctx)))),
    even: (left: ctx => with-title(ctx, emph(verso-title(ctx)), first: true)),
    rule: none,
    text: (size: 9pt, weight: "regular"),
    when: ctx => visible(ctx) and ctx.opening == none,
  ),
  footer: (
    center: ctx => ctx.folio,
    rule: none,
    text: (size: 10pt),
    when: ctx => visible(ctx) and ctx.opening == "chapter",
  ),
)

// `folio-outer`: un folio pequeño y gris en el borde exterior del pie y nada más
#let folio-outer = (
  header: none,
  footer: (
    odd: (right: ctx => ctx.folio),
    even: (left: ctx => ctx.folio),
    rule: none,
    text: (size: 8.5pt, fill: soft),
    when: folio-shown,
  ),
)

// Cabecera en mayúsculas espaciadas, pequeñas y grises, y folio gris en el borde exterior;
// con el índice `modern`
#let modern = (
  header: (
    odd: (right: ctx => upper(recto-title(ctx))),
    even: (left: ctx => upper(verso-title(ctx))),
    rule: none,
    text: (size: 7.5pt, weight: 500, tracking: 0.12em, fill: soft),
    when: running,
  ),
  footer: folio-outer.footer,
)

// Título corrido centrado en versalitas y folio entre rayas; con el índice `elegant`
#let elegant = (
  header: (
    odd: (center: ctx => smallcaps(recto-title(ctx))),
    even: (center: ctx => smallcaps(verso-title(ctx))),
    rule: none,
    text: (size: 10pt, tracking: 0.08em),
    when: running,
  ),
  footer: (
    center: ctx => [— #ctx.folio —],
    rule: none,
    text: (size: 9pt),
    when: folio-shown,
  ),
)

#let presets = (
  classic: classic,
  modern: modern,
  elegant: elegant,
  plain: plain,
  folio-outer: folio-outer,
  running-outer: running-outer,
  running-segment: running-segment,
)
#let names = presets.keys()

#let slot-keys = ("left", "center", "right")
#let area-keys = slot-keys + ("odd", "even", "rule", "text", "when")

#let check-area(name, area) = {
  assert(
    area == none or type(area) == dictionary,
    message: "page-style: " + name + " debe ser none o un diccionario",
  )
  if area == none { return }
  for key in area.keys() {
    assert(
      key in area-keys,
      message: "page-style: clave desconocida «" + key + "» en " + name + ". Claves válidas: " + area-keys.join(", "),
    )
  }
  for side in ("odd", "even") {
    if side in area {
      assert(type(area.at(side)) == dictionary, message: "page-style: " + name + "." + side + " debe ser un diccionario con " + slot-keys.join(", "))
      for key in area.at(side).keys() {
        assert(
          key in slot-keys,
          message: "page-style: clave desconocida «" + key + "» en " + name + "." + side + ". Claves válidas: " + slot-keys.join(", "),
        )
      }
    }
  }
}

// Combina un área (header o footer) del preajuste con la del usuario
#let merge-area(base, user) = {
  if user == none { return none }
  if base == none { return if user.len() == 0 { none } else { user } }
  let own-slots = user.keys().any(k => k in slot-keys + ("odd", "even"))
  let out = if own-slots {
    base.pairs().filter(((k, _)) => k not in slot-keys + ("odd", "even")).to-dict()
  } else { base }
  for (key, value) in user {
    out.insert(key, if key == "text" { out.at("text", default: (:)) + value } else { value })
  }
  out
}

// `page-style` ya validado y completo: un diccionario (header:, footer:)
#let resolve(spec) = {
  if spec == none { return none }
  let spec = if type(spec) == str { (preset: spec) } else { spec }
  assert(
    type(spec) == dictionary,
    message: "page-style debe ser el nombre de un preajuste (" + names.join(", ") + "), none o un diccionario",
  )
  for key in spec.keys() {
    assert(
      key in ("preset", "header", "footer"),
      message: "page-style: clave desconocida «" + key + "». Claves válidas: preset, header, footer",
    )
  }
  let name = spec.at("preset", default: "classic")
  assert(name in presets, message: "page-style: preajuste desconocido «" + str(name) + "». Preajustes: " + names.join(", "))
  let base = presets.at(name)
  check-area("header", spec.at("header", default: (:)))
  check-area("footer", spec.at("footer", default: (:)))
  (
    header: merge-area(base.header, spec.at("header", default: (:))),
    footer: merge-area(base.footer, spec.at("footer", default: (:))),
  )
}

// Contexto de la página actual (requiere `context`). `class` fija qué nivel de título
// es parte, capítulo y sección (ver bridge.classes)
#let page-context(class, title, author) = {
  let n = here().page()
  let roles = bridge.classes.at(class)
  let current = (part: none, chapter: none, section: none)
  let first-level = roles.values().first()
  let started = false
  for h in query(heading).filter(h => h.location().page() <= n) {
    let role = bridge.role-of(class, h.level)
    if h.level == first-level { started = true }
    if role == "part" {
      current = (part: h, chapter: none, section: none)
    } else if role == "chapter" {
      current.chapter = h
      current.section = none
    } else if role == "section" {
      current.section = h
    }
  }
  let on-page(h) = h != none and h.location().page() == n
  let is-book = class == "book"
  let part-here = on-page(current.part)
  let opening = if part-here {
    if is-book and headings.matter-state.at(current.part.location()) != "front" { "part" } else { "chapter" }
  } else if on-page(current.chapter) { "chapter" }
  let body(h) = if h != none { h.body }
  // Segmentos y turnos de un debate (`#segment` y `#turn` dejan una marca invisible)
  // El segmento de la cabecera: el que manda en lo alto de la página, salvo que otro empiece en su tercio
  // superior (una página que abre con un título lleva ese título, no el anterior)
  let before = query(<dc-segment>).filter(m => m.location().page() < n)
  let starting = query(<dc-segment>).filter(m => m.location().page() == n)
  let near-top = starting.filter(m => m.location().position().y < page.height / 3)
  let segments = if near-top.len() > 0 { (near-top.first(),) } else if before.len() > 0 { (before.last(),) } else { starting }
  let speakers = query(<dc-turn>).filter(m => m.location().page() == n).map(m => m.value).dedup()
  (
    segment: if segments.len() > 0 { segments.first().value.title },
    speaker: if segments.len() > 0 { segments.first().value.speaker },
    speakers: speakers,
    part: body(current.part),
    chapter: body(current.chapter),
    section: body(current.section),
    folio: if page.numbering != none { std.numbering(page.numbering, ..counter(page).get()) },
    page: n,
    title: title,
    author: author,
    started: started,
    opening: opening,
    blank: headings.is-blank-page(n),
    numbered: page.numbering != none,
    matter: if is-book { headings.matter-state.get() },
  )
}

// Contenido de un espacio: un valor o una función de `ctx`
#let fill(slot, ctx) = if type(slot) == function { slot(ctx) } else { slot }

// Espacios (left, center, right) de la página, ya evaluados
#let slots-of(area, ctx, side) = {
  let own = area.at(side, default: (:))
  slot-keys.map(key => (key, fill(own.at(key, default: area.at(key, default: none)), ctx))).to-dict()
}

// Un espacio solo: ocupa todo el ancho; varios: tres columnas
#let lay-out(slots) = {
  let present = slot-keys.filter(k => slots.at(k) != none)
  if present.len() == 0 { return none }
  if present.len() == 1 {
    return align(
      (left: left, center: center, right: right).at(present.first()),
      slots.at(present.first()),
    )
  }
  grid(
    columns: (1fr, auto, 1fr),
    align(left, slots.left), align(center, slots.center), align(right, slots.right),
  )
}

// Cabecera o pie de la página actual (requiere `context`)
#let render(area, ctx, facing-pages, font, above: false) = {
  if area == none or not (area.at("when", default: _ => true))(ctx) { return none }
  let side = if facing-pages and calc.even(ctx.page) { "even" } else { "odd" }
  let content = lay-out(slots-of(area, ctx, side))
  let rule = area.at("rule", default: none)
  set text(font: font) if font != none
  set text(..area.at("text", default: (:)))
  if above {
    if rule != none { line(length: 100%, stroke: rule); v(0.5em) }
    content
  } else {
    content
    if rule != none { v(-0.5em); line(length: 100%, stroke: rule) }
  }
}

// Fija cabecera y pie de las páginas que siguen. `class` es "book", "report"…
#let setup(
  style,
  class: "book",
  title: none,
  author: none,
  header-font: none, // none = hereda del cuerpo
  facing-pages: true,
  body,
) = {
  let style = resolve(style)
  if style == none { return body }
  set page(
    header: context {
      let ctx = page-context(class, title, author)
      render(style.header, ctx, facing-pages, header-font)
    },
    footer: context {
      let ctx = page-context(class, title, author)
      render(style.footer, ctx, facing-pages, none, above: true)
    },
  )
  body
}
