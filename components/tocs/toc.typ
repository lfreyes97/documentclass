// Índices: general (`toc`), parcial (`partial`) y listas de figuras (`list-of`)
#import "bridge.typ"
#import "i18n.typ"
#import "entries.typ"
#import "presets.typ"
#import "render.typ"

// Opciones comunes y su valor por defecto
#let defaults = (
  style: "classic", // Nombre de un preset o un diccionario con su forma
  class: auto, // auto = la de documentclass; o "book", "report", "article", "essay"
  depth: 2, // Niveles bajo las partes: 1 = capítulos, 2 = + secciones…
  parts: true, // Incluir las partes (book)
  matter: auto, // auto = todo; o los de book que se incluyen: ("front", "main", "back")
  title: auto, // auto = etiqueta traducida; none = sin título
  title-level: auto, // auto = heading al nivel de capítulo de la clase; none = texto
  outlined: false, // Si el título del índice aparece en el índice
  levels: (:), // Estilo por rol: (chapter: (...), section: (...), part: (...))
  fill: auto, // Relleno de todas las entradas salvo las partes; auto = el del preset
  font: auto, // auto = rol `toc` (`minitoc` en parciales) de documentclass
  size: none, // Tamaño del texto de todo el índice
  columns: 1,
  column-gutter: 2em,
  gutter: auto, // Columna del folio; auto = la del preset
  target: auto, // Selector propio en lugar de los niveles de `depth`
)

// Configuración del documento (`setup`), por encima de los valores por defecto
#let config = state("tocs-config", (:))

#let check(args) = {
  assert(args.pos().len() == 0, message: "tocs: las opciones van con nombre, p. ej. `toc(depth: 1)`")
  for key in args.named().keys() {
    assert(key in defaults, message: "tocs: opción desconocida «" + key + "». Opciones: " + defaults.keys().join(", "))
  }
  args.named()
}

// Fija opciones para todos los índices del documento:
//   #show: tocs.setup.with(style: "modern", depth: 3)
// o en cualquier punto, para los índices que siguen: #tocs.setup(fill: none)
#let setup(..args) = {
  let body = args.pos()
  let options = check(arguments(..args.named()))
  let update = config.update(c => c + options)
  if body.len() > 0 [#update#body.first()] else { update }
}

// Requiere `context`. `extra` son los valores por defecto propios de un tipo
// de índice; van por encima de `setup` porque este fija los del índice general.
#let options(args, extra: (:)) = defaults + config.get() + extra + check(args)

#let in-matter(entry, matter) = matter == auto or entry.matter == none or entry.matter in matter

// Compone título y entradas con las opciones resueltas
#let compose(o, class, list, key, gap: none, font-role: "toc", title-style: auto, renormalize: false) = {
  let preset = presets.get(o.style)
  let pairs = list.map(entry => {
    let general = (:)
    if o.gutter != auto { general.gutter = o.gutter }
    if o.fill != auto and entry.role != "part" { general.fill = o.fill }
    (entry, presets.for-entry(preset, entry, general: general, levels: o.levels))
  })
  // Un índice parcial empieza en el margen aunque su primer nivel sea profundo
  if renormalize and pairs.len() > 0 {
    let shift = pairs.map(((_, s)) => s.indent).fold(pairs.first().at(1).indent, calc.min)
    pairs = pairs.map(((e, s)) => (e, s + (indent: s.indent - shift)))
  }

  let font = if o.font != auto { o.font } else { bridge.font(font-role) }
  set text(font: font) if font != none
  set text(size: o.size) if o.size != none

  let level = if o.title-level == auto { bridge.top-level(class) } else { o.title-level }
  render.title(
    i18n.title-or(o.title, key),
    level: level,
    outlined: o.outlined,
    style: if title-style == auto { preset.title } else { title-style },
  )

  let body = render.entries(pairs, gap: gap)
  if o.columns > 1 { columns(o.columns, gutter: o.column-gutter, body) } else { body }
}

/// Tabla de contenidos del documento.
#let toc(..args) = context {
  let o = options(args)
  let class = bridge.resolve-class(o.class)
  let top = bridge.top-level(class)
  let part = bridge.part-level(class)
  let levels = range(top, top + o.depth)
  if o.parts and part != none { levels = (part,) + levels }

  let list = if o.target != auto { entries.collect(o.target, class) } else {
    entries.collect(entries.toc-selector(levels), class).filter(e => e.level in levels)
  }
  compose(o, class, list.filter(e => in-matter(e, o.matter)), "contents")
}

/// Índice parcial de la división donde se coloca: la parte o el capítulo
/// actual (`scope: auto`, el heading anterior más cercano), o el rol que se
/// indique ("part", "chapter", "section"…). Lista sus divisiones internas.
#let partial(scope: auto, ..args) = context {
  let o = options(args, extra: (title: none, title-level: none, size: 0.9em, depth: 2))
  let class = bridge.resolve-class(o.class)

  let before = query(selector(heading).before(here())).filter(h => h.outlined)
  let scope-level = if scope == auto {
    if before.len() > 0 { before.last().level }
  } else { bridge.level-of(class, scope) }
  if scope-level == none { return }
  let start = before.filter(h => h.level == scope-level)
  if start.len() == 0 { return }

  let levels = range(scope-level + 1, scope-level + 1 + o.depth)
  let target = entries.toc-selector(levels).after(start.last().location())
  let end = query(selector(heading).after(here())).find(h => h.level <= scope-level)
  if end != none { target = target.before(end.location(), inclusive: false) }

  let list = entries.collect(target, class).filter(e => e.level in levels and in-matter(e, o.matter))
  compose(o, class, list, "contents", font-role: "minitoc", title-style: (text: (weight: "bold")), renormalize: true)
}

/// Lista de figuras de un tipo (`target`), con el estilo `figure` del preset.
/// En las clases con capítulos separa las figuras de cada capítulo con
/// `chapter-gap`, como LaTeX.
#let list-of(target: figure.where(kind: image), key: "figures", supplement: false, chapter-gap: auto, ..args) = context {
  let o = options(args)
  let class = bridge.resolve-class(o.class)
  let list = query(target)
    .filter(f => f.outlined)
    .map(f => entries.from-figure(f, supplement: supplement))
    .filter(e => e != none and in-matter(e, o.matter))

  let has-chapters = class in ("book", "report")
  let gap = if chapter-gap == auto { if has-chapters { 0.8em } } else { chapter-gap }
  let chapter = bridge.top-level(class)
  let chapter-of(e) = {
    let n = counter(heading).at(e.location)
    n.slice(0, calc.min(n.len(), chapter))
  }
  let between = if gap != none { (a, b) => if chapter-of(a) != chapter-of(b) { gap } }
  compose(o, class, list, key, gap: between)
}

#let lof = list-of.with(target: figure.where(kind: image), key: "figures")
#let lot = list-of.with(target: figure.where(kind: table), key: "tables")
#let lol = list-of.with(target: figure.where(kind: raw), key: "listings")
