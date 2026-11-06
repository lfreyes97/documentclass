// Marcadores para el documento y recolección de las entradas del índice
#import "bridge.typ"

// --- Marcadores ---

// Título corto para el índice, como `\section[corto]{largo}`:
//   == Un título muy largo que no cabe en una línea #short[Título corto]
// Es invisible en el título; también sirve en el pie de una figura.
#let short(body) = metadata((tocs-short: body))

// Deja fuera del índice el heading que lo contiene: `== Notas #omit()`.
// Equivale a `#heading(outlined: false)[…]` pero se escribe con `=`.
#let omit() = metadata((tocs-omit: true))

// Entrada manual, como `\addcontentsline`: aparece en el índice con la página
// donde se coloca. `role` es el rol de la clase ("chapter", "section"…) o se
// da `level` directamente.
#let add-entry(role: "chapter", level: auto, number: none, body) = [#metadata((
    tocs-entry: (role: role, level: level, number: number, body: body),
  ))<tocs-entry>]

// Busca el valor de un marcador dentro de un contenido
#let find-marker(it, key) = {
  if type(it) != content { return none }
  if it.func() == metadata {
    let value = it.value
    return if type(value) == dictionary and key in value { value.at(key) }
  }
  if it.has("children") {
    for child in it.children {
      let found = find-marker(child, key)
      if found != none { return found }
    }
  } else if it.has("body") {
    return find-marker(it.body, key)
  } else if it.has("child") {
    return find-marker(it.child, key)
  }
  none
}

// --- Entradas ---
//
// Cada entrada es un diccionario que reciben los estilos y la función `format`:
//   kind      "heading" | "manual" | "figure"
//   level     nivel del heading
//   role      "part", "chapter", "section"… según la clase
//   rank      -1 para partes; 0 para la primera división; 1, 2… debajo
//   number    número como contenido (I, 3, 3.1, A), o none si no lo muestra
//   body      título (el corto si lo hay)
//   page      folio con la numeración de su página, o none
//   location  destino del enlace
//   element   el heading, la figura o el metadata
//   matter    "front" | "main" | "back" en book; none en otras clases
//   appendix  si está dentro de `#show: appendix`

#let rank(class, level, role) = if role == "part" { -1 } else { level - bridge.top-level(class) }

// Requiere `context`
#let from-heading(el, class) = {
  if find-marker(el.body, "tocs-omit") != none { return none }
  let loc = el.location()
  let short = find-marker(el.body, "tocs-short")
  let role = bridge.role-of(class, el.level)
  (
    kind: "heading",
    level: el.level,
    role: role,
    rank: rank(class, el.level, role),
    // prefix() evalúa la numeración en la posición del heading, como lo
    // necesita la cuenta continua de capítulos de book
    number: if bridge.numbered(el) { outline.entry(el.level, el).prefix() },
    body: if short != none { short } else { el.body },
    page: bridge.page-label(loc),
    location: loc,
    element: el,
    matter: bridge.matter.at(loc),
    appendix: bridge.appendix.at(loc) == true,
  )
}

#let from-manual(el, class) = {
  let data = el.value.tocs-entry
  let level = if data.level == auto { bridge.level-of(class, data.role) } else { data.level }
  let role = bridge.role-of(class, level)
  let loc = el.location()
  (
    kind: "manual",
    level: level,
    role: role,
    rank: rank(class, level, role),
    number: data.number,
    body: data.body,
    page: bridge.page-label(loc),
    location: loc,
    element: el,
    matter: bridge.matter.at(loc),
    appendix: bridge.appendix.at(loc) == true,
  )
}

// Figura con su número solo (2.1) o con el suplemento (Figura 2.1)
#let from-figure(el, supplement: false) = {
  if el.caption == none { return none }
  let loc = el.location()
  let prefix = if el.numbering != none { outline.entry(1, el).prefix() }
  // El prefijo de una figura es [suplemento, espacio, número]
  let number = if supplement or prefix == none or not prefix.has("children") { prefix } else {
    prefix.children.last()
  }
  let short = find-marker(el.caption.body, "tocs-short")
  (
    kind: "figure",
    level: 1,
    role: "figure",
    rank: 0,
    number: number,
    body: if short != none { short } else { el.caption.body },
    page: bridge.page-label(loc),
    location: loc,
    element: el,
    matter: bridge.matter.at(loc),
    appendix: bridge.appendix.at(loc) == true,
  )
}

// Encabezados y entradas manuales que `target` selecciona, en orden
#let collect(target, class) = {
  query(target)
    .map(el => if el.func() == heading { from-heading(el, class) } else { from-manual(el, class) })
    .filter(e => e != none)
}

// Selector de todo lo que puede ir al índice, por nivel
#let toc-selector(levels) = {
  let headings = levels.map(l => heading.where(level: l, outlined: true))
  headings.fold(selector(<tocs-entry>), (acc, s) => acc.or(s))
}
