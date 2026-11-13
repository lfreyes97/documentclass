// `notes: "footnote"`: sin columnas, las notas al margen pasan a pie de página en una sola serie,
// una figura al margen es una figura normal y un bloque ancho, un bloque normal
#import "../lib.typ": essay, note, notefigure, wideblock
#show: essay.with(author: "Autor", notes: "footnote", date: datetime(year: 2026, month: 1, day: 5))

= Título del ensayo
== Primera sección
Antes, una nota al pie corriente#footnote[La primera de la serie.]: la nota al margen que sigue es la segunda.
Texto con una nota#note[Primera nota, que va al pie.]<primera>. Otra#footnote[Una nota al pie corriente.] más.
Y una remisión a @primera, que es la nota al pie 2 (structure.py lo comprueba).

#notefigure(rect(width: 100%, height: 2cm), caption: [Una figura al margen que ahora es normal.])
#wideblock[Un bloque ancho que ahora es un bloque normal.]

#pagebreak()
Segunda página con otra nota#note[Segunda nota.].
