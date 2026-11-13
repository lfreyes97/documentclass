// Puente con documentclass. Los estados de Typst se identifican por su clave,
// así que tocs lee los de la clase sin importarla: funciona igual en un
// documento que no la use, donde estos estados quedan en su valor inicial.
//
//   dc-use-parts    solo book lo fija (true o false): delata la clase book
//   dc-matter       "front" | "main" | "back" en book
//   dc-appendix     true tras `#show: appendix`
//   dc-fonts        fuentes resueltas por rol (toc, minitoc…)
//   dc-labels       etiquetas que el documento sobrescribe con `labels`
//
// Son un contrato: el README los documenta («States»), y cambiar una clave o un valor rompe tocs
// usado sin la clase y cualquier código ajeno que los lea. Todos los estados de la clase llevan el
// prefijo `dc-`; los de glosa, `_glosa_`, y los de tocs, `tocs-`.

#let use-parts = state("dc-use-parts", none)
#let matter = state("dc-matter", none)
#let appendix = state("dc-appendix", false)
#let fonts = state("dc-fonts", none)
#let labels = state("dc-labels", (:))

// Nivel de heading de cada rol, por clase. El rango (rank) de un rol es su
// distancia al primer rol después de las partes: 0 para capítulos en book y
// report, para secciones en article y essay.
#let classes = (
  book: (part: 1, chapter: 2, section: 3, subsection: 4, subsubsection: 5),
  report: (chapter: 1, section: 2, subsection: 3, subsubsection: 4),
  article: (section: 1, subsection: 2, subsubsection: 3, paragraph: 4),
  // El nivel 1 del ensayo es su título, que no va al índice
  essay: (section: 2, subsection: 3, subsubsection: 4, paragraph: 5),
)

// Clase del documento (requiere `context`). Sin documentclass se usa article:
// el nivel 1 es la primera división.
#let detect() = {
  if use-parts.final() != none { return "book" }
  if fonts.final() == none { return "article" }
  let top = query(heading.where(level: 1))
  if top.len() > 0 and top.all(h => not h.outlined) { "essay" } else { "report" }
}

#let resolve-class(class) = {
  let class = if class == auto { detect() } else { class }
  assert(
    class in classes,
    message: "tocs: clase desconocida «" + str(class) + "». Clases válidas: " + classes.keys().join(", "),
  )
  class
}

// Nivel del primer rol que no es parte
#let top-level(class) = classes.at(class).pairs().find(((role, _)) => role != "part").last()
#let part-level(class) = classes.at(class).at("part", default: none)

#let role-of(class, level) = {
  let found = classes.at(class).pairs().find(((_, l)) => l == level)
  if found != none { found.first() } else { "level-" + str(level) }
}

#let level-of(class, role) = {
  let roles = classes.at(class)
  assert(role in roles, message: "tocs: la clase " + class + " no tiene el rol «" + role + "». Roles: " + roles.keys().join(", "))
  roles.at(role)
}

// Si el heading muestra su número. Tras `end-appendix()` el back matter de
// book conserva la numeración de apéndice pero no la muestra.
#let numbered(el) = {
  let loc = el.location()
  el.numbering != none and (matter.at(loc) != "back" or appendix.at(loc) == true)
}

// Folio de una posición con la numeración vigente allí: romanos en el front
// matter, arábigos después, o lo que el documento haya fijado.
#let page-label(loc) = {
  let pattern = loc.page-numbering()
  // Sin numeración de página, arábigos, como `outline()`
  numbering(if pattern == none { "1" } else { pattern }, ..counter(page).at(loc))
}

// Fuente de un rol de documentclass, o none si el documento no la usa
#let font(role) = {
  let resolved = fonts.get()
  if resolved != none { resolved.at(role, default: none) }
}
