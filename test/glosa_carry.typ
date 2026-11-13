// Reparto de notas al margen con desborde (`overflow: "carry"`): las funciones puras de
// components/glosa/logic.typ, sin compilar ninguna página.
#import "../components/glosa/logic.typ": _carry-layout, _fit-page, _overflowing

#let page = (height: 800pt, top: 100pt, bottom: 50pt)
#let clearance = 10pt
#let note(natural, height) = (natural: natural, height: height, shift: true, keep-order: false, body: [x], raw: [x])

// Caben: no se mueve ninguna
#let fit = _fit-page(page, (note(100pt, 50pt), note(200pt, 50pt)), clearance, true)
#assert.eq(fit.carried, ())

// No caben: tres notas de 300 pt en una columna de 650 pt. Las de más abajo pasan a la página siguiente
#let tall = (note(110pt, 300pt), note(300pt, 300pt), note(700pt, 300pt))
#let kept = _fit-page(page, tall, clearance, false)
#assert.eq(kept.carried, ())
#let fit = _fit-page(page, tall, clearance, true)
#assert.eq(fit.carried, (2,))

// Sin desborde, el reparto sin carry es el de siempre: mismos desplazamientos
#let small = (note(110pt, 50pt), note(130pt, 50pt))
#assert.eq(_fit-page(page, small, clearance, true).offsets, _fit-page(page, small, clearance, false).offsets)

// Entre páginas: lo que sobra de la 1 va a la 2, antes de sus notas propias
#let regs = (left: (:), right: ("1": tall, "2": (note(150pt, 100pt),)))
#let layout = _carry-layout(regs, page, clearance, false, 2, 3, true)
#assert.eq(layout.at("1").right.carried, (2,))
#let second = layout.at("2").right
#assert.eq(second.items.len(), 2) // la que llega y la propia
#assert(second.items.first().carried)
#assert.eq(second.items.first().natural, page.top) // llega arriba del todo
#assert.eq(second.carried, ())

// En un libro, la columna exterior cambia de lado: lo que sale de la derecha entra por la izquierda
#let book = _carry-layout(regs, page, clearance, true, 2, 3, true)
#assert.eq(book.at("2").left.items.len(), 1)
#assert.eq(book.at("2").right.items.len(), 1) // solo la propia

// La última página no pasa nada: no hay a dónde
#let last = _carry-layout(regs, page, clearance, false, 1, 1, true)
#assert.eq(last.at("1").right.carried, ())

// Una nota fija (un bloque ancho, sin `body`) nunca se mueve
#let wide = (natural: 120pt, height: 100pt, shift: false, keep-order: false)
#assert.eq(_fit-page(page, (wide, note(130pt, 200pt)), clearance, true).carried, ())
// … y no se carga aunque sobren notas: solo pasan las notas, no los bloques
#let crowded = (wide,) + tall
#assert(0 not in _fit-page(page, crowded, clearance, true).carried)

// Lo que aún no cabe: sin carry, la nota que sube por encima del margen; con carry, nada (pasó a la siguiente)
#assert.eq(_overflowing(page, tall, _fit-page(page, tall, clearance, false)).len(), 1)
#assert.eq(_overflowing(page, tall, _fit-page(page, tall, clearance, true)), ())
#assert.eq(_overflowing(page, small, _fit-page(page, small, clearance, true)), ())
// Una nota fija a propósito fuera de la columna (el título en la cabecera) no es un desborde
#let header-note = (natural: 20pt, height: 10pt, shift: false, keep-order: false, body: [t])
#assert.eq(_overflowing(page, (header-note,), _fit-page(page, (header-note,), clearance, true)), ())

Reparto de notas con desborde: correcto.
