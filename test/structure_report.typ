// Estructura de report con un tema y doble cara (structure.py lo comprueba y guarda su referencia): `modern`
// pone en la cabecera, en mayúsculas, el título del documento en los versos y el capítulo en los rectos, y
// ninguna en las aperturas; los capítulos abren página nueva
#import "../lib.typ": *
#show: report.with(title: "InformeEstructura", author: "A", style: "modern", facing-pages: true)

= CapituloUno
#lorem(1500)
== SeccionUnoA
#lorem(600)
= CapituloDos
#lorem(300)
== SeccionDosA
#lorem(300)
