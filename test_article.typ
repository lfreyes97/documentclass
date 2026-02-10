#import "lib.typ": article

#show: article.with(
  title: "Artículo de Prueba",
  subtitle: "Evaluación de la clase article",
  author: "Autor de Prueba",
  date: "Febrero 2026",
  abstract: [
    Este es el resumen del artículo. Debería aparecer centrado y con un ancho menor que el texto principal, justo después del título y antes del contenido en columnas (si las hubiera).
  ],
  cols: 2,
)

= Introducción
Este texto debería estar en dos columnas. La clase article no tiene capítulos, por lo que H1 es una sección numerada como "1. Título".

== Metodología
H2 es una subsección numerada como "1.1 Título".

=== Detalles
H3 es una subsubsección "1.1.1 Título".

= Resultados
Una nueva sección principal ("2. Resultados").
