// `verify[…]`: invisible para el lector (off: debug false). Deja un dato consultable en los dos casos
#import "../lib.typ": article, verify, verify-list
#show: article.with(title: "Verificar", author: "A", debug: false)

= Texto
Una afirmación dudosa#verify[comprobar la cifra, ≈29] en el cuerpo. Otra línea con relleno para tener varias.
#lorem(30)#footnote[Una fuente#verify[buscar la página].]

#verify-list()
