// Configuración tipográfica compartida por las clases (parámetro `fonts`).
//
// Cada rol omitido (o con valor none) hereda la fuente de su rol padre:
//   body ─┬─ heading ─┬─ h1, h2, h3, h4
//         │           └─ title (portada, half-title, titleblock)
//         ├─ header (cabecera de página)
//         ├─ toc (índice) ── minitoc
//         ├─ note (notas al margen, clase essay)
//         └─ initials (letra capital)
//   mono (bloques de código, independiente)
//
// El orden importa: cada padre aparece antes que sus hijos.
#let roles = (
  body: none,
  heading: "body",
  h1: "heading",
  h2: "heading",
  h3: "heading",
  h4: "heading",
  title: "heading",
  header: "body",
  toc: "body",
  minitoc: "toc",
  note: "body",
  initials: "body",
  mono: none,
)

// Fuentes incluidas con Typst, disponibles sin instalar nada
#let defaults = (
  body: "Libertinus Serif",
  mono: "DejaVu Sans Mono",
)

// Completa un diccionario parcial de fuentes con la herencia de `roles`
#let resolve(fonts) = {
  assert(
    type(fonts) == dictionary,
    message: "fonts debe ser un diccionario, p. ej. `fonts: (body: \"EB Garamond\")`",
  )
  for key in fonts.keys() {
    assert(
      key in roles,
      message: "fonts: rol desconocido «" + key + "». Roles válidos: " + roles.keys().join(", "),
    )
  }
  let given = defaults + fonts.pairs().filter(((_, font)) => font != none).to-dict()
  let resolved = (:)
  for (role, parent) in roles {
    resolved.insert(role, given.at(role, default: if parent != none { resolved.at(parent) }))
  }
  resolved
}

// Fuentes resueltas del documento, para los componentes que el usuario llama
// directamente (tableofcontents, minitoc, dropcap, half-title). Requiere `context`.
#let current = state("dc-fonts", resolve((:)))

// Compone `body` con la fuente del rol indicado, o con `font` si se da una
#let use(role, body, font: none) = context {
  set text(font: if font != none { font } else { current.get().at(role) })
  body
}
