// Estructura de article con `page-style` y `heading-style` propios (structure.py lo comprueba y guarda su
// referencia): la cabecera lleva la sección vigente, salvo en la primera página, y las secciones van en
// versalitas con el preajuste `elegant`
#import "../lib.typ": *
#show: article.with(
  title: "ArticuloEstructura",
  author: "A",
  heading-style: (preset: "elegant", section: (title-smallcaps: false)),
  page-style: (
    preset: "classic",
    header: (when: ctx => ctx.page > 1, right: ctx => ctx.section),
  ),
)

= SeccionUno
#lorem(500)
== SubseccionUnoA
#lorem(300)
= SeccionDos
#lorem(600)
