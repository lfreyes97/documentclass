// Ensayo sin `date`: la cabecera no lleva fecha (y el PDF no cambia al recompilar otro día)
#import "../lib.typ": essay, note
#show: essay.with(author: "Autor Demo", top: 32mm, bottom: 16mm, note-columns: (outer: (width: 45mm)))

= Título
== Sección
Primera página con una nota#note[Nota al margen.].

#pagebreak()
Segunda página, con cabecera corrida.
