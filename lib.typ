#import "classes/book.typ": abstract, appendix, back, book, dedication, end-appendix, front, main
#import "components/matter.typ"
#import "classes/article.typ": article
#import "classes/report.typ": report
#import "classes/essay.typ": essay
#import "components/glosa/glosa.typ"
#import "components/glosa/glosa.typ": note, notefigure, wideblock
#import "components/tocs/tocs.typ"
#import "components/dropcap.typ" as dropcap-mod
#import "components/environments.typ": blockquote, epigraph, verse
#import "components/titlepage.typ": colophon, half-title
#import "components/headings.typ": blank-page, part

// Índices: los nombres de LaTeX, con la API de `tocs` (opciones, presets y estilos
// por nivel). `tocs.setup` fija opciones para todo el documento.
#let tableofcontents = tocs.toc
#let minitoc = tocs.partial
#let listoffigures = tocs.lof
#let listoftables = tocs.lot
#let listoflistings = tocs.lol
#let dropcap = dropcap-mod.dropcap
#let ornate-dropcap = dropcap-mod.ornate-dropcap
#let ornate-initial = dropcap-mod.ornate-initial
