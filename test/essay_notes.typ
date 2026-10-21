// Clase essay en inglés: notas, remisiones, fecha y cabecera
#import "../lib.typ": essay, note, notefigure, wideblock

#show: essay.with(
  author: "A. Writer",
  date: datetime(year: 2026, month: 9, day: 22),
  lang: "en",
  fonts: (note: "DejaVu Sans Mono"),
)

= The Essay
== First <s1>
Text with a note#note[A margin note.]<n1> and a footnote#footnote[Foot.].
#notefigure(rect(width: 100%, height: 1cm), caption: [Margin figure])
#lorem(500)
== Second
See @s1 and @n1. #lorem(200)
