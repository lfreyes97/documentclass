#let minitoc(
  font: none,
  depth: 2,
  indent: 0pt,
  size: 11pt,
) = {
  context {
    let nexth2 = heading.where(level: 2).after(here())
    let nexth1 = heading.where(level: 1, outlined: true).after(here(), inclusive: false)

    let target-selector = nexth2.before(nexth1)

    if font != none {
      set text(font: font, size: size)
      outline(
        target: target-selector,
        indent: indent,
        depth: depth,
        title: none,
      )
    } else {
      set text(size: size)
      outline(
        target: target-selector,
        indent: indent,
        depth: depth,
        title: none,
      )
    }
  }
}
