// Cabeceras y pies (`page-style`): resolución y validación de components/pagestyle.typ, y
// un libro con estilo propio.
#import "../lib.typ": *
#import "../components/pagestyle.typ": classic, names, resolve

// Todos los preajustes se resuelven con cabecera y pie (o none) y sus claves son válidas
#for name in names { assert(resolve(name) != none, message: name) }
#assert.eq(names, ("classic", "modern", "elegant", "plain", "folio-outer", "running-outer", "running-segment"))
#assert.eq(resolve("plain").header, none)

// none desactiva; un nombre o `auto`-preset da el preajuste
#assert.eq(resolve(none), none)
#assert.eq(resolve("classic").header.rule, classic.header.rule)
// Los espacios del usuario sustituyen a los del preajuste; rule, text y when se combinan
#let custom = resolve((header: (center: "X", text: (style: "italic"))))
#assert.eq(custom.header.keys().contains("odd"), false)
#assert.eq(custom.header.center, "X")
#assert.eq(custom.header.rule, classic.header.rule)
#assert.eq(custom.header.text, (size: 9pt, weight: "regular", style: "italic"))
// Sin espacios propios se conserva todo lo del preajuste
#assert.eq(resolve((header: (rule: none))).header.odd, classic.header.odd)
#assert.eq(resolve((footer: none)).footer, none)

#show: book.with(
  title: "Libro",
  author: "A",
  facing-pages: true,
  page-style: (
    header: (
      odd: (left: ctx => ctx.section, right: ctx => ctx.chapter),
      even: (left: ctx => ctx.part, right: ctx => ctx.author),
      rule: 0.4pt,
    ),
    footer: (left: ctx => ctx.folio, right: ctx => ctx.title, rule: 0.4pt),
  ),
)
#show: mainmatter
= Parte uno
== Primer capítulo
=== Una sección
#lorem(300)
=== Otra sección
#lorem(300)
== Segundo capítulo
#lorem(200)
