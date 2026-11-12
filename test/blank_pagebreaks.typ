// Los saltos a página impar del usuario también dejan en blanco sin cabecera ni folio
#import "../lib.typ": *

#show: book.with(title: "Saltos propios", author: "A")
#show: main

= Parte
== Capítulo uno
Texto del capítulo uno, con bastante contenido para llenar un poco la página y que tenga cabecera.

#pagebreak(to: "odd")
Texto tras un salto propio: la página anterior queda en blanco, sin cabecera ni folio.

#pagebreak()
#pagebreak()
Dos saltos seguidos dejan una página en blanco intencional.
