// Temas de las clases (parámetro `style`): una familia visual que comparten los títulos
// (`heading-style`), las cabeceras y pies (`page-style`) y el índice (`tocs`). Cada parte
// tiene además sus propios nombres, que no son temas:
//   page-style  variantes de cabecera y pie: plain, folio-outer, running-outer
//   tocs        compact

#let themes = ("classic", "modern", "elegant")
#let page-variants = ("plain", "folio-outer", "running-outer")

// Pista para un nombre de preajuste que no es de `target` ("heading-style", "tocs"…)
#let hint(name) = if name in page-variants {
  " «" + name + "» es una variante de `page-style`, no un tema; los temas son " + themes.join(", ") + "."
} else { "" }

// `style` de una clase: auto o un tema
#let check(style) = {
  assert(
    style == auto or style in themes,
    message: "style: «"
      + repr(style)
      + "» no es un tema."
      + if type(style) == str and hint(style) != "" { hint(style) } else { " Temas: " + themes.join(", ") + "." },
  )
  style
}

// Valor de una parte: el propio, o el del tema, o el de la clase si no hay tema
#let pick(own, style, fallback) = if own != auto { own } else if style != auto { style } else { fallback }
