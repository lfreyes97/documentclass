// Mesa redonda con la plantilla `panel`: tres panelistas y una moderadora, estilo `modern` y portadilla.
#import "../lib.typ": at, crowd, debate, segment, speakers-index, turn

#show: debate.with(
  template: "panel",
  title: "El futuro de la edición digital",
  subtitle: "Mesa redonda",
  proposition: [¿Sobrevivirá el libro impreso?],
  venue: "Feria del Libro",
  date: "2026",
  titlepage: true,
  // Los segmentos que abre `#segment()`, con su orador y su tiempo
  program: (
    (kind: "introduction", speaker: "marta", time: duration(minutes: 5)),
    (kind: "round", time: duration(minutes: 30)),
    (kind: "questions"),
    (kind: "closing", speaker: "marta"),
  ),
  turn-style: "modern",
  speakers: (
    ana: (name: "Ana Prieto", short: "Prieto", role: "editora"),
    luis: (name: "Luis Mora", short: "Mora", role: "autor"),
    eva: (name: "Eva Soler", short: "Soler", role: "bibliotecaria"),
    marta: (name: "Marta Vidal", short: "Vidal", role: "moderadora", moderator: true),
  ),
)

#segment()

#turn("marta")[Buenas tardes. Hoy hablamos del libro impreso y de su futuro, con tres personas que lo conocen bien.]

#segment()

#turn("marta")[Empecemos por Ana: ¿el papel tiene los días contados?]
#turn("ana")[
  No lo creo. Cada año se venden más libros impresos de los que se predijo, y las lectoras lo prefieren para
  regalar y para estudiar.
]
#turn("luis")[
  Como autor, lo que me importa es que me lean. #crowd[risas] El soporte es secundario.
]
#turn("eva")[En la biblioteca vemos las dos cosas, y los préstamos digitales no reducen los de papel.]

#segment()

#turn(none, label: "Asistente")[¿Qué pasa con los libros descatalogados?]
#turn("eva")[Ahí lo digital es una salvación: lo que no se reimprime, se escanea.]

#segment()

#turn("marta")[Gracias a todos. Seguiremos esta conversación en la próxima feria.]

#speakers-index()
