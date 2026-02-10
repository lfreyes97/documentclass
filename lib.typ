#import "classes/book.typ": abstract, appendix, back, book, dedication, end-appendix, front, main
#import "classes/article.typ": article
#import "classes/report.typ": report
#import "components/toc.typ"
#import "components/minitoc.typ"
#import "components/dropcap.typ"
#import "components/environments.typ": blockquote, epigraph, verse
#import "components/titlepage.typ": colophon, half-title

#let tableofcontents = toc.custom
#let minitoc = minitoc.minitoc
#let dropcap = dropcap.dropcap
