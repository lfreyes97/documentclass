#import "../lib.typ": article

#show: article.with(
  title: "Artículo Científico",
  author: "Investigador Demo",
  abstract: [
    Este es un resumen del artículo. La clase `article` soporta resúmenes en línea y diseño en columnas.
  ],
  cols: 2,
)

= Introducción
La clase `article` está diseñada para documentos cortos, papers y artículos académicos.

== Metodología
Utiliza la jerarquía de secciones estándar (1., 1.1, 1.1.1).
