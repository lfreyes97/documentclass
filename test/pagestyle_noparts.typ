// `classic` en un libro sin partes (`use-parts: false`): el capítulo empieza el documento, así que
// lleva cabecera; en el verso, sin parte, el título del libro (structure.py lo comprueba)
#import "../lib.typ": *
#show: book.with(title: "LibroSinPartes", use-parts: false)
#show: front
#tableofcontents()
#show: main
= CapituloUno
#lorem(700)
= CapituloDos
#lorem(700)
