#import "../lib.typ": report

#show: report.with(
  title: "Reporte Técnico",
  subtitle: "Evaluación de la clase report",
  author: "Ingeniero de Prueba",
  date: "2026",
  publisher: "Tech Corp",
  abstract: [
    Este es el resumen del reporte. Debería aparecer en su propia página, centrada verticalmente, después de la portada y antes del primer capítulo.
  ],
)

= Introducción
Este es el primer capítulo. En la clase report, H1 es "Capítulo 1". Debe comenzar en una página nueva.

== Antecedentes
H2 es una sección dentro del capítulo, numerada como "1.1".

=== Estado del Arte
H3 es una subsección "1.1.1".

= Análisis
Segundo capítulo ("Capítulo 2"). Comienza en página nueva.
