// Adornos: separadores de sección, remates de capítulo y el adorno de las partes (`part-ornament`) y de
// `heading-style` (clave `ornament`). Se dibujan con trazos y formas, no con glifos, así que no dependen de que la
// fuente del cuerpo los tenga.
//
//   #ornament("asterism")            ⁂ tres asteriscos en triángulo
//   #ornament("fleuron")             una flor de cuatro pétalos
//   #ornament("rule")                un filete con un rombo en el centro
//   #ornament("dots")                tres puntos
//   #ornament("diamond")             un rombo
//   #ornament[❦]                     cualquier contenido, centrado
//   #ornament("rule", width: 8em, fill: gray, above: 2em)

#let kinds = ("asterism", "fleuron", "rule", "dots", "diamond")

// Un asterisco de seis brazos
#let asterisk(size, stroke) = box(width: size, height: size, {
  for angle in (0deg, 60deg, 120deg) {
    place(center + horizon, rotate(angle, line(length: size, stroke: stroke)))
  }
})

#let diamond(size, fill) = box(width: size, height: size, rotate(45deg, rect(width: size * 0.7, height: size * 0.7, fill: fill, stroke: none)))

// Una flor de cuatro pétalos: cuatro círculos que se cruzan y un punto en el centro
#let flower(size, fill) = {
  let petal = size * 0.3
  box(width: size, height: size, {
    for (dx, dy) in ((1, 0), (-1, 0), (0, 1), (0, -1)) {
      place(center + horizon, dx: dx * petal, dy: dy * petal, circle(radius: petal, stroke: 0.06em + fill))
    }
    place(center + horizon, circle(radius: size * 0.1, fill: fill, stroke: none))
  })
}

/// Un adorno. `kind` es el nombre de uno (ver arriba) o cualquier contenido, que se centra tal cual.
///
/// - size: Tamaño de las figuras (1em, el del texto)
/// - fill: Color; por defecto, el del texto
/// - width: Ancho del filete de `"rule"`
/// - above, below: Espacio antes y después
#let ornament(kind, size: 1em, fill: auto, width: 6em, above: 1.2em, below: 1.2em) = context {
  let color = if fill == auto { text.fill } else { fill }
  let stroke = 0.06em + color
  let shape = if type(kind) != str { kind } else {
    assert(kind in kinds, message: "ornament: «" + kind + "» no es un adorno. Adornos: " + kinds.join(", ") + "; o pasa contenido, p. ej. `#ornament[❦]`")
    if kind == "asterism" {
      let star = asterisk(size * 0.8, stroke)
      stack(dir: ttb, spacing: size * 0.1, star, stack(dir: ltr, spacing: size * 0.4, star, star))
    } else if kind == "fleuron" {
      flower(size * 1.4, color)
    } else if kind == "rule" {
      block(width: width, grid(
        columns: (1fr, auto, 1fr),
        column-gutter: size * 0.6,
        align: horizon,
        line(length: 100%, stroke: stroke), diamond(size * 0.7, color), line(length: 100%, stroke: stroke),
      ))
    } else if kind == "dots" {
      stack(dir: ltr, spacing: size * 0.5, ..range(3).map(_ => circle(radius: size * 0.13, fill: color, stroke: none)))
    } else {
      diamond(size * 0.8, color)
    }
  }
  v(above)
  align(center, shape)
  v(below)
}

// Un valor de `part-ornament` u `ornament` (heading-style): el nombre de un adorno se dibuja sin espacios propios
// (el título ya deja los suyos); lo demás (contenido, none, auto) pasa tal cual
#let resolve(value) = if type(value) == str { ornament(value, above: 0pt, below: 0pt) } else { value }
