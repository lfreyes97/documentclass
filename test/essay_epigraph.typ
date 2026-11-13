// En `essay`, `#epigraph` sale como el epígrafe del ensayo: bloque al 78 %, texto justificado a la izquierda,
// cursiva y atribución estructurada a la derecha
#import "../lib.typ": epigraph, essay
#show: essay.with(author: "Autor Demo", top: 32mm, bottom: 16mm, outer: (far: 16mm, width: 45mm, sep: 8mm))

= Título del ensayo

#epigraph(
  [Moloch aparece como respuesta a una pregunta: ¿quién hace esto? La tierra podría ser hermosa, y todos los hombres felices y sabios. En cambio tenemos cárceles, chimeneas, manicomios.],
  (author: "Scott Alexander", article: "Meditations on Moloch", year: 2014, note: "trad. propia"),
)

== Primera sección
Texto de la sección. #lorem(40)
