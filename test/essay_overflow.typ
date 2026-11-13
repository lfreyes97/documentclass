// Notas al margen que no caben: con `overflow: "carry"` pasan a la página siguiente, salvo en la última,
// que no tiene a dónde; lo que aún desborda queda en `query(<glosa-overflow>)` y `debug-frame` lo marca en
// rojo. `--input overflow=none` lo prueba sin desborde (structure.py compila las dos)
#import "../lib.typ": essay, note, wideblock

#let overflow = sys.inputs.at("overflow", default: "carry")
#show: essay.with(author: "Autor", overflow: overflow, debug: (frame: true))

= Notas que no caben
== Primera página
#for i in range(9) [Texto#note(lorem(45)) y más texto. ]

#pagebreak()
== Última página
Pocas líneas y muchas notas largas, que no tienen página siguiente:
#for i in range(9) [nota#note(lorem(45)) ]

#context {
  let marks = query(<glosa-overflow>)
  let pages = marks.map(m => m.location().page()).dedup()
  // La última página siempre desborda; con "none" también la primera, cuyas notas no pasan
  assert(counter(page).final().first() in pages, message: "la última página no marca su desborde: " + repr(pages))
  if overflow == "none" { assert(1 in pages, message: "sin desborde, la primera página debía marcarse: " + repr(pages)) }
  if overflow == "carry" { assert(1 not in pages, message: "con carry, la primera página no desborda: " + repr(pages)) }
  assert(marks.all(m => m.value.side in ("left", "right") and m.value.notes > 0))
}
