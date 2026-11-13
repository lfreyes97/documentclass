// `line-numbers`: líneas numeradas por página, de 5 en 5, sin numerar títulos, notas al pie ni portada
#import "../lib.typ": essay, note
#show: essay.with(
  author: "Autor", date: datetime(year: 2026, month: 1, day: 5), top: 32mm, bottom: 16mm,
  outer: (far: 16mm, width: 45mm, sep: 8mm), inner: (far: 16mm, width: 0mm, sep: 8mm),
  line-numbers: (every: 5),
)

= Título del ensayo
== Primera sección
#lorem(120)#note[Una nota al margen, sin numerar sus líneas.] #lorem(120)#footnote[Una nota al pie.]
