// `ornament`: los cinco adornos dibujados, contenido propio, y su uso en `part-ornament` y en `heading-style`
#import "../lib.typ": book, ornament

#show: book.with(
  title: "Adornos", paper: "a5", facing-pages: false, part-ornament: "fleuron",
  heading-style: (chapter: (ornament: "rule")),
)

= Primera parte
== Capítulo uno
Un párrafo antes del separador. #lorem(20)

#ornament("asterism")

#lorem(15)

#ornament("fleuron")
#ornament("rule")
#ornament("dots")
#ornament("diamond")
#ornament[❦]
#ornament("rule", width: 9em, size: 1.4em, fill: maroon, above: 2em)

#lorem(15)
