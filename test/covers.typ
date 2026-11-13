// Portada y contraportada de book (`cover`): contenido, par ya armado, función de estilo (como las de
// coverbook) y diccionario. structure.py comprueba que la primera página es la portada y la última la
// contraportada
#import "../lib.typ": *
#import "../components/covers.typ": normalize, resolve

// Función de estilo como las de coverbook: recibe los datos del libro y el lado
#let fake-cover(data, side: "front", color: none) = page(numbering: none, align(center + horizon)[
  #upper(side)-#(data.title)-#data.at("isbn", default: "sin-isbn")-#color
])
#let book-data = (title: "T", subtitle: none, author: "A", publisher: none)

// Contenido: solo portada; par: las dos; función: las dos, con los datos y las opciones
#assert.eq(resolve([P], book-data), ([P], none))
#assert.eq(resolve(([P], [C]), book-data), ([P], [C]))
#assert.eq(resolve((front: [P], back: [C]), book-data), ([P], [C]))
#let (front, back) = resolve((front: fake-cover, data: (isbn: "978"), options: (color: "rojo")), book-data)
#assert.eq(front, fake-cover((title: "T", author: "A", isbn: "978"), side: "front", color: "rojo"))
#assert.eq(back, fake-cover((title: "T", author: "A", isbn: "978"), side: "back", color: "rojo"))
// `back: none` quita la contraportada de una función
#assert.eq(resolve((front: fake-cover, back: none), book-data).last(), none)
#assert.eq(normalize(none).front, none)

#show: book.with(
  title: "LibroConCubierta",
  author: "A",
  cover: (front: fake-cover, data: (isbn: "978-1"), options: (color: "azul")),
)
#show: mainmatter
= Parte
== Capítulo
#lorem(50)
