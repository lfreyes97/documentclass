#import "matter.typ": *
#let default(body) = {
  set page(
    footer: context [
      #set align(center)
      #set text(size: 10pt)
      #line(length: 100%, stroke: 0.5pt)
      #v(0.5em)
      #counter(page).display("1")
    ]
  )
  body
}
