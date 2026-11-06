// article: clase explícita, estilo compact y estilo por rol
#import "../lib.typ": article, tocs
#show: article.with(title: "Artículo", author: "A")
#tocs.toc(class: "article", style: "compact", depth: 3, levels: (section: (text: (fill: blue))))
= Uno
== Sub uno
=== Subsub
== Sub dos
= Dos
