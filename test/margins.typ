// Márgenes y `facing-pages`: resolución de `margin` (components/margins.typ) y su efecto
// en cada clase.
#import "../lib.typ": article, book, report
#import "../components/margins.typ": resolve

#let defaults = (
  facing: (inside: 2.5cm, outside: 1.5cm, y: 2cm),
  single: (x: 2cm, y: 2cm),
)

// auto: los de la clase, según facing-pages
#assert.eq(resolve(auto, true, defaults), defaults.facing)
#assert.eq(resolve(auto, false, defaults), defaults.single)
// Una longitud vale tal cual
#assert.eq(resolve(3cm, true, defaults), 3cm)
// Lo no indicado en un eje conserva el valor por defecto del otro
#assert.eq(resolve((y: 3cm), true, defaults), (inside: 2.5cm, outside: 1.5cm, y: 3cm))
#assert.eq(resolve((x: 1cm), false, defaults), (x: 1cm, y: 2cm))
#assert.eq(resolve((outside: 3cm), true, defaults), (outside: 3cm, y: 2cm))
#assert.eq(resolve((left: 1cm, right: 2cm, top: 1cm, bottom: 1cm), false, defaults), (left: 1cm, right: 2cm, top: 1cm, bottom: 1cm))

// El margen resuelto llega a la página de cada clase
#let probe = context {
  let m = page.margin
  [#type(m) #if type(m) == dictionary { m.keys().sorted().join(",") }]
}
#show: book.with(margin: (inside: 3cm, outside: 2cm), facing-pages: true)
#probe
