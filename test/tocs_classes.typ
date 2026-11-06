// report: detección de clase, `setup`, etiquetas de documentclass, columnas y parcial por rol
#import "../lib.typ": report, tocs
#show: report.with(title: "Informe", author: "A", lang: "en", labels: (contents: "Table of Contents"))
#show: tocs.setup.with(style: "modern", levels: (chapter: (text: (fill: maroon))))
#tocs.toc(depth: 3)
#tocs.toc(title: [Two columns], columns: 2, depth: 1, fill: repeat[.])
= Introduction
== Background
=== Detail
= Results
== Data
#tocs.partial(scope: "chapter")
== More data
