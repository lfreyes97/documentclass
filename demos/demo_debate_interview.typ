// Entrevista con la plantilla `interview`: entrevistadora e invitado, sin moderador, formato libre de página.
#import "../lib.typ": at, debate, segment, turn

#show: debate.with(
  template: "interview",
  title: "Conversación sobre tipografía",
  proposition: [Entrevista a Pablo Sanz],
  date: "2026",
  marks: (timecodes: true),
  page-style: "plain",
  speakers: (
    rosa: (name: "Rosa Gil", short: "Gil", role: "entrevistadora"),
    pablo: (name: "Pablo Sanz", short: "Sanz", role: "tipógrafo"),
  ),
)

#segment("introduction")

#turn("rosa")[#at("00:00") Pablo, ¿cómo empezó todo?]
#turn("pablo")[Con un rótulo mal espaciado en una tienda de mi barrio. No pude dejar de verlo.]

#segment("topic", title: "Las fuentes y la lectura", time: duration(minutes: 12))

#turn("rosa")[#at("03:40") ¿Importa la fuente que se elige?]
#turn("pablo")[
  Importa más el espacio que la fuente: el interlineado, los márgenes, el ancho de la columna.

  Una fuente discreta bien compuesta gana a una vistosa mal puesta.
]
#turn("rosa", cont: false)[¿Y en pantalla?]
#turn("pablo")[Lo mismo, pero con menos control, y ahí está el reto.]

#segment("closing")

#turn("rosa")[#at("11:55") Gracias, Pablo.]
