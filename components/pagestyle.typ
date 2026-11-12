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

#import "headings.typ"
#import "tocs/bridge.typ"

// Como las clases estándar de LaTeX: en el recto el capítulo (o la parte, o el título),
// en el verso la parte (o el título), con un filete gris; el folio al centro del pie. No
// aparecen en el front matter, ni en las páginas de apertura, en blanco o sin numeración
#let classic = (
  header: (
    odd: (right: ctx => emph(
      if ctx.chapter != none { ctx.chapter } else if ctx.section != none { ctx.section } else if ctx.part != none {
        ctx.part
      } else { ctx.title },
    )),
    even: (left: ctx => emph(if ctx.part != none { ctx.part } else { ctx.title })),
    rule: 0.5pt + gray,
    text: (size: 9pt, weight: "regular"),
    when: ctx => ctx.started and ctx.numbered and not ctx.blank and ctx.opening == none,
  ),
  footer: (
    center: ctx => ctx.folio,
    rule: none,
    text: (size: 10pt),
    when: ctx => ctx.numbered and not ctx.blank and ctx.opening != "part",
  ),
)

#let presets = (classic: classic)
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
  if base == none { return user }
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
  (
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
