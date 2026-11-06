#import "classes/book.typ": abstract, appendix, back, book, dedication, end-appendix, front, main
#import "components/matter.typ"
#import "classes/article.typ": article
#import "classes/report.typ": report
#import "classes/essay.typ": essay
#import "components/glosa/glosa.typ"
#import "components/glosa/glosa.typ": note, notefigure, wideblock
#import "components/toc.typ"
#import "components/minitoc.typ"
#import "components/tocs/tocs.typ"
#import "components/dropcap.typ" as dropcap-mod
#import "components/environments.typ": blockquote, epigraph, verse
#import "components/titlepage.typ": colophon, half-title
#import "components/headings.typ": blank-page, part

#let tableofcontents = toc.custom
#let minitoc = minitoc.minitoc
#let dropcap = dropcap-mod.dropcap
#let ornate-dropcap = dropcap-mod.ornate-dropcap
#let ornate-initial = dropcap-mod.ornate-initial
#let listoffigures = matter.list-of-figures
#let listoftables = matter.list-of-tables
