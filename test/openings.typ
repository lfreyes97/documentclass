// Aperturas de parte y capítulo (`heading-style`): resolución y validación de
// components/openings.typ, y un libro con estilo propio.
#import "../lib.typ": *
#import "../components/openings.typ": leaf, names, resolve

#assert.eq(names, ("classic", "modern", "elegant"))
#for name in names {
  let style = resolve(name)
  assert.eq(style.keys(), ("part", "chapter"))
  // Cada variante se resuelve con todas las claves
  for (role, variants) in (part: (none, "front", "back"), chapter: (none, "front", "back", "appendix")) {
    for variant in variants { assert(leaf(style, role, variant).keys().contains("start"), message: name) }
  }
}

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
