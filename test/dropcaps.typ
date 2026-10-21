// Letras capitales: normal, con puntuación inicial, ornamentadas y con el rol `initials`
#import "../lib.typ": *

#show: book.with(title: "Capitulares", fonts: (body: "EB Garamond", initials: "DM Serif Display"))
#show: main
== Capitulares

#dropcap[Este párrafo empieza con una letra capital de dos líneas. #lorem(60)]

#dropcap(height: 3, fill: red)[«Una cita» abre este párrafo con comillas. #lorem(60)]

#ornate-dropcap[Ornamentada en una tinta. #lorem(70)]

#ornate-dropcap(style: "rubricated")[Rubricada: ornamento en tinta, letra en rojo. #lorem(70)]

#ornate-dropcap(style: "inverted", frame: false)[Invertida y sin marco. #lorem(70)]

#ornate-dropcap[Ñandú: la Ñ no está en el juego y cae a la capital normal. #lorem(40)]

#ornate-initial("Q", size: 4em)
