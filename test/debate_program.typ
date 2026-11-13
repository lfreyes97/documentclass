// `#segment()` abre los segmentos del programa de la plantilla, con el orador en el orden de `speakers`
#import "../lib.typ": debate, segment, turn

#show: debate.with(
  template: "two-speakers",
  title: "Programa por defecto",
  speakers: (
    uno: (name: "Uno", short: "Uno"),
    dos: (name: "Dos", short: "Dos"),
    mod: (name: "Moderador", short: "Mod", moderator: true),
  ),
)

#segment()
#turn("mod")[Abre el moderador.]
#segment()
#turn("uno")[Presenta Uno.]
#segment()
#turn("dos")[Presenta Dos.]
// Un segmento con tipo no gasta uno del programa; lo dado con nombre sustituye al del programa
#segment("cross", speaker: "dos")
#segment(time: duration(minutes: 10))
#turn("uno")[Replica Uno.]
#segment()
#turn("dos")[Replica Dos.]
#segment()
#segment()
#segment()
