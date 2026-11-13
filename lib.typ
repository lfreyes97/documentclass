// API pública de documentclass: solo lo que documenta el README (tabla «Public API»). Lo demás
// (components/, los módulos `matter` y `dropcap`, los estados) es interno y puede cambiar.

// Clases
#import "classes/book.typ": book
#import "classes/report.typ": report
#import "classes/article.typ": article
#import "classes/essay.typ": essay
#import "classes/debate.typ": debate

// Partes del libro, como en LaTeX (`\frontmatter`…), y páginas especiales
#import "components/matter.typ": abstract, appendix, backmatter, dedication, end-appendix, frontmatter, mainmatter
#import "components/titlepage.typ": colophon, half-title
#import "components/ornaments.typ": ornament
#import "components/headings.typ": blank-page, part

// Entornos, capitulares y marcas de revisión
#import "components/environments.typ": blockquote, epigraph, epigraph-page, epigraphs, verse
#import "components/dropcap.typ": dropcap, ornate-dropcap, ornate-initial
#import "components/debug.typ": verify, verify-list

// Índices: los nombres de LaTeX, con la API de `tocs` (opciones, presets y estilos
// por nivel). `tocs.setup` fija opciones para todo el documento.
#import "components/tocs/tocs.typ"
#let tableofcontents = tocs.toc
#let minitoc = tocs.partial
#let listoffigures = tocs.lof
#let listoftables = tocs.lot
#let listoflistings = tocs.lol

// Ensayo: notas y figuras al margen, y el motor `glosa` para usos avanzados
#import "components/glosa/glosa.typ"
#import "components/glosa/glosa.typ": note, notefigure, wideblock

// Debates
#import "classes/debate.typ": at, cite-turn, crowd, gloss, glossary, inaudible, segment, speakers-index, tnote, turn

// Obsoletos: los nombres cortos de `frontmatter`, `mainmatter` y `backmatter`, que chocan con nombres
// propios del documento al importar con `*`. Se quitarán antes de congelar la API
#let front = frontmatter
#let main = mainmatter
#let back = backmatter
