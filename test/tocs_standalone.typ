// Sin documentclass: clase article por defecto, `format` propio y título corto
#import "../lib.typ": tocs
#set text(lang: "fr")
#set heading(numbering: "1.1")
#tocs.toc(style: "elegant", levels: (subsection: (format: (e, s) => block[→ #e.body (#e.page)])))
= Premier
== Sous
= Second chapitre au titre long #tocs.short[Deux]
