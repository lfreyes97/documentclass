#import "fonts.typ" as fonts-mod

#let minitoc(
  font: none, // none = rol `minitoc` de las fuentes del documento
  depth: 2,
  indent: 0pt,
  size: 0.9em,
) = {
  context {
    let nexth2 = heading.where(level: 2).after(here())
    let nexth1 = heading.where(level: 1, outlined: true).after(here(), inclusive: false)

    let target-selector = nexth2.before(nexth1)

    set text(font: if font != none { font } else { fonts-mod.current.get().minitoc }, size: size)
    outline(
      target: target-selector,
      indent: indent,
      depth: depth,
      title: none,
    )
  }
}
