// Bloque común de título y `titlepage` en las clases: auto o true (la portada de la clase), none o false
// (sin portada) o contenido (una propia). Por defecto, un ensayo con portada; `--input class=…` prueba las
// demás (structure.py compila book, report y article, y book sin portada y con una propia)
#import "../lib.typ": *

#let class = sys.inputs.at("class", default: "essay")
#let tp = sys.inputs.at("titlepage", default: "auto")
#let tp = if tp == "auto" { auto } else if tp == "none" { none } else { align(center + horizon)[PORTADA-PROPIA] }
#let data = (title: "TituloComun", subtitle: "SubtituloComun", author: "AutorComun", publisher: "EditorialComun")

#show: if class == "essay" { essay.with(..data, titlepage: if tp == auto { true } else { tp }) } else if (
  class == "book"
) { book.with(..data, titlepage: tp) } else if class == "report" { report.with(..data, titlepage: tp) } else {
  article.with(..data)
}

= Primera sección
#lorem(40)
