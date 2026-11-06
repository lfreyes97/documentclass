// Composición de las entradas
#import "i18n.typ"

// Requiere `context` (las etiquetas dependen del idioma)
#let label-of(entry, style) = {
  let label = if style.appendix-label and entry.appendix and entry.rank == 0 { "appendix" } else { style.label }
  if label == none { none } else if type(label) == str { i18n.get(label) } else if type(label) == function {
    label(entry)
  } else { label }
}

#let number-of(entry, style) = {
  if entry.number == none { return none }
  let number = if style.number-format != none { (style.number-format)(entry.number) } else { entry.number }
  let label = label-of(entry, style)
  let number = if label != none [#label~#number] else { number }
  if style.upper { number = upper(number) }
  if style.smallcaps { number = smallcaps(number) }
  text(..style.number-text, number)
}

#let title-of(entry, style) = {
  let body = entry.body
  if style.upper { body = upper(body) }
  if style.smallcaps { body = smallcaps(body) }
  body
}

#let page-of(entry, style) = if style.page and entry.page != none { text(..style.page-text, entry.page) }

// Una entrada en su propio bloque: sangría francesa para los títulos largos,
// relleno hasta el folio y el folio en una columna derecha (`gutter`) que el
// texto no invade.
#let line(entry, style) = {
  if style.format != none { return (style.format)(entry, style) }
  set text(..style.text)
  context {
    let number = number-of(entry, style)
    let page = page-of(entry, style)
    let (lead, hang) = if number == none { (none, 0pt) } else if style.number-break {
      ([#number#linebreak()], 0pt)
    } else if style.number-width == auto {
      let lead = [#number#h(style.number-gap)]
      (lead, measure(lead).width)
    } else {
      // Un número con etiqueta («Apéndice A») puede no caber en el ancho fijo
      let width = calc.max(style.number-width.to-absolute(), measure(number).width + style.number-gap.to-absolute())
      (box(width: width, number), width)
    }
    let tail = if page != none {
      let fill = if style.fill != none { box(width: 1fr, style.fill) } else { h(1fr) }
      // Caja de ancho cero: el folio cae en la columna `gutter`, fuera del texto
      [#h(0.35em)#fill#h(0.35em)#box(width: 0pt, box(width: style.gutter, align(right, page)))]
    }
    block(
      width: 100%,
      above: style.above,
      below: style.below,
      inset: (left: style.indent, right: if page != none { style.gutter } else { 0pt }, bottom: if style.stroke != none { 0.35em } else { 0pt }),
      stroke: style.stroke,
      align(style.align, par(
        hanging-indent: hang,
        first-line-indent: 0pt,
        justify: false,
        link(entry.location, [#lead#title-of(entry, style)#tail]),
      )),
    )
  }
}

// Entradas run-in seguidas, en un solo párrafo: «1.1 Título 3 · 1.2 Otro 5»
#let run-in(group) = {
  let (first, style) = group.first()
  let items = group.map(((entry, style)) => {
    let number = number-of(entry, style)
    let page = page-of(entry, style)
    text(..style.text, link(entry.location, [#if number != none [#number~]#title-of(entry, style)#if page != none [~#page]]))
  })
  block(
    width: 100%,
    above: style.above,
    below: style.below,
    inset: (left: style.indent, right: style.gutter),
    par(first-line-indent: 0pt, justify: false, items.join(style.separator)),
  )
}

// Compone una lista de pares (entrada, estilo). `gap(prev, next)` devuelve un
// espacio extra entre dos entradas, o none.
#let entries(pairs, gap: none) = {
  let out = ()
  let group = ()
  let prev = none
  for (entry, style) in pairs {
    if style.run-in {
      group.push((entry, style))
      prev = entry
      continue
    }
    if group.len() > 0 {
      out.push(run-in(group))
      group = ()
    }
    if gap != none and prev != none {
      let space = gap(prev, entry)
      if space != none { out.push(v(space, weak: true)) }
    }
    out.push(line(entry, style))
    prev = entry
  }
  if group.len() > 0 { out.push(run-in(group)) }
  out.join()
}

// Título de un índice: un heading de la clase (sin número y, por defecto,
// fuera del propio índice) o un bloque con el estilo `title` del preset
#let title(body, level: none, outlined: false, style: (:)) = {
  if body == none { return }
  if level != none {
    heading(level: level, numbering: none, outlined: outlined, bookmarked: true, body)
  } else {
    let body = if style.at("upper", default: false) { upper(body) } else { body }
    let body = if style.at("smallcaps", default: false) { smallcaps(body) } else { body }
    block(width: 100%, below: 1.6em, align(style.at("align", default: left), text(..style.at("text", default: (:)), body)))
  }
}
