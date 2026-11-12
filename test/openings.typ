// Aperturas de parte y capítulo (`heading-style`): resolución y validación de
// components/openings.typ, y un libro con estilo propio.
#import "../lib.typ": *
#import "../components/openings.typ": leaf, names, resolve, roles, run-leaf

#assert.eq(names, ("classic", "modern", "elegant"))
#for name in names {
  let style = resolve(name)
  assert.eq(style.keys(), roles + ("scale",))
  // Cada variante se resuelve con todas las claves
  for (role, variants) in (part: (none, "front", "back"), chapter: (none, "front", "back", "appendix")) {
    for variant in variants { assert(leaf(style, role, variant).keys().contains("start"), message: name) }
  }
}

// Cascada: cada título de sección hereda del anterior solo lo que no fija
#let cascade = resolve((section: (title-smallcaps: true, title-text: (size: 1em)), subsection: (title-text: (weight: "bold"))))
#assert.eq(run-leaf(cascade, "section").title-text, (size: 1em, weight: 400, tracking: 0.03em))
#assert.eq(run-leaf(cascade, "subsection").title-text.weight, "bold")
#assert.eq(run-leaf(cascade, "subsection").title-text.size, 1.05em) // lo fija classic
#assert.eq(run-leaf(cascade, "subsection").title-smallcaps, false) // lo fija classic
#assert.eq(run-leaf(resolve((subsection: (title-smallcaps: true))), "paragraph").title-smallcaps, true)
// `h3` es el alias de section en book (nivel 3); h1 es part
#assert.eq(leaf(resolve((h1: (label: none))), "part", none).label, none)
#assert.eq(run-leaf(resolve((h3: (above: 9em))), "section").above, 9em)
#assert.eq(run-leaf(resolve((h4: (above: 8em))), "subsection").above, 8em)

#let near(a, b) = calc.abs((a - b) / 1em) < 0.0001
// `scale` agranda lo que sobresale del cuerpo: 1.8em → 2.2em y 1.2em → 1.3em con 1.5; 1em no cambia
#let big = resolve((scale: 1.5))
#assert(near(leaf(big, "chapter", none).title-text.size, 2.2em))
#assert(near(run-leaf(big, "section").title-text.size, 1.3em))
#assert(near(run-leaf(big, "subsubsection").title-text.size, 1em))
#assert(near(leaf(big, "chapter", none).label-text.size, 1.15em))
#assert(near(leaf(resolve((scale: 150%)), "chapter", none).title-text.size, 2.2em))
#assert.eq(leaf(resolve((scale: 1)), "chapter", none).title-text.size, 1.8em)

// Las claves del rol valen para todas las variantes; las de una variante, solo para ella
#let custom = resolve((chapter: (align: left, front: (above: 1em))))
#assert.eq(leaf(custom, "chapter", none).align, left)
#assert.eq(leaf(custom, "chapter", "back").align, left)
#assert.eq(leaf(custom, "chapter", "front").above, 1em)
#assert.eq(leaf(custom, "chapter", none).above, 4em)
// Los diccionarios de texto se combinan con los del preajuste
#assert.eq(leaf(resolve((chapter: (title-text: (size: 2em)))), "chapter", none).title-text, (size: 2em, weight: 500, tracking: 0.05em))
// Una variante con `back` sin etiqueta ni número
#assert.eq(leaf(resolve("classic"), "chapter", "back").label, none)
#assert.eq(leaf(resolve("classic"), "chapter", "back").number-format, none)

#show: book.with(
  title: "Libro",
  heading-style: (
    preset: "modern",
    part: (label-text: (fill: red)),
    chapter: (align: center, rule: none, label: none, number-format: n => [Cap. #n]),
  ),
)
#show: main
= Parte
== Un capítulo
#lorem(40)
