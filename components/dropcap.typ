// Letra capital, traída de Instatypst (src/dropcaps.typ). El texto del párrafo
// rodea la inicial, que mide `height` líneas; ver `dropcap` al final.
#import "fonts.typ" as fonts-mod

#let _partibles = (strong, emph, underline, stroke, overline, highlight, smallcaps)
#let _espacio = [ ].func()

#let _unir(hijos) = if hijos.len() == 0 { [] } else { hijos.join() }

#let _con-etiqueta((primero, segundo), etiqueta) = {
  if etiqueta == none {
    (primero, segundo)
  } else if segundo != none {
    (primero, [#segundo#etiqueta])
  } else if primero != none {
    ([#primero#etiqueta], segundo)
  } else {
    (none, none)
  }
}

#let _a-texto(c) = {
  if c == none {
    ""
  } else if type(c) == str {
    c
  } else if c.has("text") {
    _a-texto(c.text)
  } else if c.has("child") {
    _a-texto(c.child)
  } else if c.has("children") {
    c.children.map(_a-texto).join()
  } else if c.func() in _partibles {
    _a-texto(c.body)
  } else if c.func() == smartquote {
    if c.double { "\"" } else { "'"}
  } else if c.func() == space {
    " "
  } else {
    ""
  }
}

#let _puntos(c) = {
  if c == none {
    0
  } else if type(c) == str {
    c.split(" ").len() - 1
  } else if c.has("text") {
    _puntos(c.text)
  } else if c.has("child") {
    _puntos(c.child)
  } else if c.has("children") {
    c.children.map(_puntos).sum(default: 0)
  } else if c.func() in _partibles {
    _puntos(c.body)
  } else if c.func() in (_espacio, linebreak, parbreak) {
    1
  } else {
    0
  }
}

#let _dividir(c, indice) = {
  if c == none {
    return (none, none, none)
  }
  if indice > _puntos(c) {
    return (c, none, none)
  }
  if indice < 0 {
    return _dividir(c, calc.max(0, _puntos(c) + indice + 1))
  }

  if type(c) == str {
    let palabras = c.split(" ")
    return (palabras.slice(0, indice).join(" "), palabras.slice(indice).join(" "), " ")
  }

  if c.has("text") {
    let (text: texto, ..campos) = c.fields()
    let etiqueta = if c.has("label") { c.label } else { none }
    let reconstruye(it) = if it != none { c.func()(..campos, it) }
    let (a, b, sep) = _dividir(texto, indice)
    return (.._con-etiqueta((reconstruye(a), reconstruye(b)), etiqueta), sep)
  }

  if c.func() in _partibles {
    let (body: texto, ..campos) = c.fields()
    let etiqueta = if c.has("label") { c.label } else { none }
    let reconstruye(it) = if it != none { c.func()(..campos, it) }
    let (a, b, sep) = _dividir(texto, indice)
    return (.._con-etiqueta((reconstruye(a), reconstruye(b)), etiqueta), sep)
  }

  if c.has("child") {
    let (child: hijo, styles: estilos, ..campos) = c.fields()
    let etiqueta = if c.has("label") { c.label } else { none }
    let reconstruye(it) = if it != none { c.func()(it, estilos) }
    let (a, b, sep) = _dividir(hijo, indice)
    return (.._con-etiqueta((reconstruye(a), reconstruye(b)), etiqueta), sep)
  }

  if c.has("children") {
    let primero = ()
    let segundo = ()
    let sep = none
    let sub = indice
    for (i, hijo) in c.children.enumerate() {
      let puntos-hijo = _puntos(hijo)
      if sub <= puntos-hijo {
        if hijo.func() not in (_espacio, linebreak, parbreak) {
          let (ha, hb, hsep) = _dividir(hijo, sub)
          primero.push(ha)
          segundo.push(hb)
          sep = hsep
        } else {
          sep = hijo
        }
        segundo += c.children.slice(i + 1)
        break
      }
      sub -= puntos-hijo
      primero.push(hijo)
    }
    return (_unir(primero), _unir(segundo), sep)
  }

  if indice == 0 { (none, c, none) } else { (c, none, none) }
}

#let _antes = regex("[" + "\"'" + "\u{00A0}\u{2000}-\u{200F}\u{2028}-\u{202F}\u{205F}-\u{3000}" + "\u{00AB}\u{00BF}\u{00A1}\u{201C}\u{2018}(\[\{" + "]+")
#let _despues = regex("[" + ".\"'" + ",;:!?\u{00BB}\u{201D}\u{2019})\]\}" + "\u{0300}-\u{036F}" + "]+")

#let _inicial(c) = {
  if c == none {
    return (none, none)
  }
  if type(c) == str {
    if c == "" {
      return (none, c)
    }
    return (c.clusters().at(0), c.clusters().slice(1).join())
  }
  if c.has("text") {
    let (text: texto, ..campos) = c.fields()
    let reconstruye(it) = if it != none { c.func()(..campos, it) }
    let (letra, resto) = _inicial(texto)
    return (letra, reconstruye(resto))
  }
  if c.func() in _partibles {
    let (body: texto, ..campos) = c.fields()
    let reconstruye(it) = if it != none { c.func()(..campos, it) }
    let (letra, resto) = _inicial(texto)
    return (letra, reconstruye(resto))
  }
  if c.has("child") {
    let (child: hijo, styles: estilos, ..campos) = c.fields()
    let reconstruye(it) = if it != none { c.func()(it, estilos) }
    let (letra, resto) = _inicial(hijo)
    return (letra, reconstruye(resto))
  }
  if c.has("children") {
    let pos = c.children.position(h => h.func() not in (_espacio, parbreak))
    if pos == none {
      return (none, c)
    }
    let (letra, resto) = _inicial(c.children.at(pos))
    let cola = c.children.slice(pos + 1)
    return (letra, _unir((resto,) + cola))
  }
  return (c, none)
}

#let _extraer(cuerpo) = {
  let (letra, resto) = _inicial(cuerpo)
  if letra == none {
    return (none, cuerpo)
  }
  let cadena = _a-texto(letra)
  if cadena != "" {
    while _antes in cadena.last() {
      let (sig, nuevo-resto) = _inicial(resto)
      if sig == none { break }
      letra += sig
      resto = nuevo-resto
      cadena = _a-texto(sig)
    }
    let (sig, nuevo-resto) = _inicial(resto)
    while _a-texto(sig) != "" and _despues in _a-texto(sig).first() {
      letra += sig
      resto = nuevo-resto
      (sig, nuevo-resto) = _inicial(resto)
    }
  }
  (letra, resto)
}

#let _en-linea(elem) = elem != none and measure(h(0.1pt) + elem).width > measure(elem).width

#let _dimensionado(alto, letra, ..args) = context {
  let nombrados = args.named()
  if "size" in nombrados {
    text(..args, letra)
  } else {
    let base = 10pt
    let m = measure(text(..nombrados, size: base, letra)).height
    let factor = if m > 0pt { alto / m } else { 1 }
    text(..nombrados, size: base * factor, letra)
  }
}

#let _resolver-alto(alto) = if type(alto) == int { measure([x\ ] * alto).height } else { alto.to-absolute() }

#let capitular(
  cuerpo,
  letra: none,
  alto: 2,
  justificar: auto,
  hueco: 0.08em,
  sangria: 0pt,
  profundidad: 0,
  transformar: none,
  ..args-texto,
) = layout(reg => {
  let args = args-texto
  if alto != auto {
    if "top-edge" not in args.named() {
      args = arguments(..args, top-edge: "bounds")
    }
    if "bottom-edge" not in args.named() {
      args = arguments(..args, bottom-edge: "bounds")
    }
  }

  let (inicial, resto) = if letra != none {
    (letra, cuerpo)
  } else {
    let (l, r) = _extraer(cuerpo)
    assert(l != none, message: "el cuerpo no contiene ninguna letra inicial")
    (l, r)
  }

  if transformar != none {
    inicial = context transformar(inicial)
  }

  let alto-letra = if alto == auto {
    measure(text(..args.named(), inicial)).height
  } else {
    _resolver-alto(alto)
  }
  let prof = _resolver-alto(profundidad)

  let caja-letra = box(height: alto-letra + prof, _dimensionado(alto-letra, inicial, ..args))
  let ancho-letra = measure(caja-letra).width

  let justificar = if justificar == auto { par.justify } else { justificar }

  let acotado = box.with(width: reg.width - ancho-letra - hueco)

  let i = 1
  let posicion-top = 0pt
  let altura-previa = 0pt
  let (primera, segunda, sep) = while true {
    let (a, b, _) = _dividir(resto, i)
    let a = {
      set par(hanging-indent: sangria, justify: justificar)
      a
    }
    let altura = measure(acotado(a)).height
    let (_, nueva, _) = _dividir(a, -1)
    posicion-top = calc.max(
      posicion-top,
      altura - measure(nueva).height - par.leading.to-absolute(),
    )

    if posicion-top >= alto-letra + prof - 1e-6pt and altura > altura-previa {
      _dividir(resto, i - 1)
      break
    }

    if b == none {
      (a, none, none)
      break
    }

    i += 1
    altura-previa = altura
  }

  set par(justify: justificar)

  let hay-salto = type(sep) == content and sep.func() in (linebreak, parbreak)
  if not hay-salto {
    let s = _dividir(primera, -1).at(2)
    hay-salto = type(s) == content and s.func() in (linebreak, parbreak)
  }

  let ultimo-de-primera = _dividir(primera, -1).at(1)
  let primero-de-segunda = if segunda == none { none } else { _dividir(segunda, 1).at(0) }

  let envuelve(body-content) = if _en-linea(ultimo-de-primera) {
    box(body-content) + linebreak()
  } else {
    block(body-content)
  }

  envuelve(grid(
    column-gutter: hueco,
    columns: (ancho-letra, 1fr),
    caja-letra,
    {
      set par(hanging-indent: sangria)
      primera
      if not hay-salto and _en-linea(ultimo-de-primera) and _en-linea(primero-de-segunda) {
        linebreak(justify: justificar)
      }
    },
  ))

  if type(sep) == content and sep.func() in (linebreak, parbreak) { sep }

  segunda
})

// ─────────────────────────────────────────────────────────────
//  capitular-ornamentada — capitular iluminada de EB Garamond Initials
//
//  Glifos SVG de georgd/EB-Garamond-Initials (OFL-1.1, ver
//  src/assets/eb-initials/COPYING), basados en las capitulares de
//  *De Peste Commentarius* (1589). Dos capas por letra, mismo viewBox
//  0 0 1000 1000, superpuestas sin traducir nada:
//    F1 -> ornamento de fondo (florituras)  -> color `ornamento:`
//    F2 -> la letra en primer plano         -> color `fill:`
//
//  Mismos parámetros que capitular() (alto, hueco, sangria, justificar,
//  profundidad, letra…), así que se puede cambiar una por otra.
//  El repo de origen NO trae G ni T: esas dos se generaron aparte desde
//  la fuente EB Garamond con el ornamento de C/I (ver
//  scripts/generar-G-T.py). Las acentuadas (Á, É, Ñ…) no
//  existen: caen al capitular() de siempre con los mismos argumentos.
//  La puntuación inicial («, ¿, …) cuelga en el margen a tamaño de
//  texto en vez de agrandarse con la letra. `hueco` por defecto es más
//  ancho que en capitular() porque el cuadro del ornamento llega al borde.
// ─────────────────────────────────────────────────────────────
#let _iniciales = (
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
  "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
)
#let _iniciales-especiales = ("Ä": "Adieresis", "Ö": "Odieresis", "Ü": "Udieresis")

#let _archivo-inicial(c) = {
  let c = upper(c)
  if c in _iniciales { c } else { _iniciales-especiales.at(c, default: none) }
}

// Estilos de grabado (imitan capitulares de imprenta de los ss. XVI–XVII):
//   "una-tinta"  -> ornamento y letra en la misma tinta, sobre el papel
//   "invertida"  -> bloque de tinta con ornamento y letra calados (criblé):
//                   el calado es transparente, deja ver el papel de la página
//   "rubricada"  -> ornamento en tinta, letra en rojo (impresión a dos tintas)
// `marco: true` agrega el doble filete del taco de madera. `desgaste:`
// (0–1) simula la impresión: bordes irregulares y huecos donde no cubrió
// la tinta; cada letra usa su propia semilla, así no se gastan igual.
// Con desgaste > 0 Typst rasteriza el filtro (deja de ser vectorial).
#let _estilos = ("una-tinta", "invertida", "rubricada")
#let _tinta = rgb("#1c1712")
#let _rubrica = rgb("#a3271f")

// Colores (ornamento, letra) ya resueltos según el estilo.
#let _colores-inicial(estilo, tinta, fill, ornamento) = {
  assert(estilo in _estilos, message: "estilo desconocido \"" + estilo + "\" — disponibles: " + _estilos.join(", "))
  let tinta = if tinta == none { _tinta } else { tinta }
  let (orn, ltr) = if estilo == "rubricada" {
    (tinta, _rubrica)
  } else {
    (tinta, tinta)
  }
  (
    if ornamento == none { orn } else { ornamento },
    if fill == none { ltr } else { fill },
  )
}

// Los <path> de una capa, recoloreados. `color=` además de `fill=`: G y T
// engruesan el trazo con stroke="currentColor", que toma ese valor.
#let _paths(capa, nombre, color) = (
  read("assets/eb-initials/" + capa + "/" + nombre + ".svg")
    .find(regex("(?s)<path.*</svg>"))
    .replace("</svg>", "")
    .replace("<path", "<path fill='" + color + "' color='" + color + "'")
)

#let _filtro-desgaste(k, semilla) = {
  let k = calc.clamp(k, 0, 1)
  ("<filter id='desgaste' x='-5%' y='-5%' width='110%' height='110%'>" +
  "<feTurbulence type='fractalNoise' baseFrequency='0.05' numOctaves='3' seed='" + str(semilla) + "' result='r'/>" +
  "<feDisplacementMap in='SourceGraphic' in2='r' scale='" + str(5 * k) + "' xChannelSelector='R' yChannelSelector='G' result='d'/>" +
  "<feTurbulence type='fractalNoise' baseFrequency='0.022' numOctaves='3' seed='" + str(semilla + 7) + "' result='n'/>" +
  "<feColorMatrix in='n' type='matrix' values='0 0 0 0 0  0 0 0 0 0  0 0 0 0 0  -14 0 0 0 " + str(9.6 + (1 - k) * 4) + "' result='mask'/>" +
  "<feComposite in='d' in2='mask' operator='in'/></filter>")
}

// Solo la letra iluminada, sin párrafo: útil para portadas o composiciones
// a mano. Devuelve none si la letra no existe en el set.
#let inicial-ornamentada(
  c,
  size: 3em,
  estilo: "una-tinta",
  marco: true,
  desgaste: 0,
  tinta: none,
  fill: none,
  ornamento: none,
) = {
  let nombre = _archivo-inicial(c)
  if nombre == none { return none }
  let (orn, ltr) = _colores-inicial(estilo, tinta, fill, ornamento)
  let orn = orn.to-hex()
  let ltr = ltr.to-hex()

  let cuerpo = if estilo == "invertida" {
    // Bloque de tinta con el ornamento y la letra recortados por máscara.
    let borde = if marco { -30 } else { 0 }
    let lado = 1000 - 2 * borde
    // La región de la máscara tiene que coincidir exacto con el bloque: con
    // una región más grande, el renderizador de Typst desplaza el resultado
    // (rsvg lo dibuja bien; es cosa de Typst).
    let caja = "x='" + str(borde) + "' y='" + str(borde) + "' width='" + str(lado) + "' height='" + str(lado) + "'"
    ("<mask id='calado' maskUnits='userSpaceOnUse' " + caja + "><rect " + caja + " fill='white'/>" +
    _paths("F1", nombre, "black") + _paths("F2", nombre, "black") + "</mask>" +
    "<rect " + caja + " fill='" + orn + "' mask='url(#calado)'/>")
  } else {
    _paths("F1", nombre, orn) + _paths("F2", nombre, ltr)
  }
  if marco {
    cuerpo += "<rect x='-30' y='-30' width='1060' height='1060' fill='none' stroke='" + orn + "' stroke-width='14'/>"
    cuerpo += "<rect x='-55' y='-55' width='1110' height='1110' fill='none' stroke='" + orn + "' stroke-width='5'/>"
  }
  let vb = if marco { "-70 -70 1140 1140" } else { "0 0 1000 1000" }
  let filtro = if desgaste > 0 { _filtro-desgaste(desgaste, c.to-unicode()) } else { "" }
  let g = if desgaste > 0 { "<g filter='url(#desgaste)'>" } else { "<g>" }
  let svg = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='" + vb + "'>" + filtro + g + cuerpo + "</g></svg>"
  image(bytes(svg), format: "svg", width: size, height: size)
}

#let capitular-ornamentada(
  cuerpo,
  alto: 3,
  hueco: 0.3em,
  estilo: "una-tinta",
  marco: true,
  desgaste: 0,
  tinta: none,
  fill: none,
  ornamento: none,
  ..args,
) = context {
  // Color de la letra resuelto: lo usan también la puntuación colgada y
  // el fallback a capitular() (acentuadas), para que no desentonen.
  let (_, color-letra) = _colores-inicial(estilo, tinta, fill, ornamento)
  let (l, resto) = _extraer(cuerpo)
  let cs = _a-texto(l).clusters()
  let i = cs.position(c => c.match(regex("\\p{L}")) != none)
  // Solo se separa el caso "puntuación + una letra" («T, ¿A, "E…);
  // cualquier otra forma rara cae a capitular() tal cual.
  if i == none or i != cs.len() - 1 {
    return capitular(cuerpo, alto: alto, hueco: hueco, fill: color-letra, ..args)
  }
  let letra = cs.at(i)
  let ilum = inicial-ornamentada(
    letra, size: _resolver-alto(alto), estilo: estilo, marco: marco, desgaste: desgaste,
    tinta: tinta, fill: fill, ornamento: ornamento,
  )
  let inicial = if ilum == none { letra } else { ilum }
  // Puntuación inicial colgada en el margen, a tamaño de texto: no
  // crece con la capitular (un « gigante al lado de la letra se ve mal).
  if i > 0 {
    let pre = text(size: text.size, fill: color-letra, cs.slice(0, i).join())
    inicial = box({
      place(top + left, dx: -measure(pre).width - 0.1em, pre)
      inicial
    })
  }
  capitular(resto, letra: inicial, alto: alto, hueco: hueco, fill: color-letra, ..args)
}

// ─────────────────────────────────────────────────────────────
//  API pública de documentclass
// ─────────────────────────────────────────────────────────────

#let _styles = (plain: "una-tinta", inverted: "invertida", rubricated: "rubricada")

#let _style(style) = {
  assert(
    style in _styles,
    message: "dropcap: estilo desconocido «" + style + "». Estilos: " + _styles.keys().join(", "),
  )
  _styles.at(style)
}

/// Letra capital: la primera letra de `body` (con la puntuación que la rodea)
/// ocupa `height` líneas y el texto la rodea. Sin `font`, usa el rol `initials`.
///
/// - initial: letra a usar en lugar de la primera de `body`
/// - height: líneas que ocupa (int) o una longitud; auto = tamaño natural
/// - gap: espacio entre la letra y el texto
/// - hanging-indent: sangría de las líneas junto a la letra
/// - depth: líneas que la letra baja por debajo de su base
/// - transform: función aplicada a la letra, p. ej. `upper`
/// - ..text-args: argumentos de `text` para la letra (font, fill, weight…)
#let dropcap(
  body,
  initial: none,
  height: 2,
  justify: auto,
  gap: 0.08em,
  hanging-indent: 0pt,
  depth: 0,
  transform: none,
  ..text-args,
) = context {
  let named = (font: fonts-mod.current.get().initials, ..text-args.named())
  capitular(
    body,
    letra: initial,
    alto: height,
    justificar: justify,
    hueco: gap,
    sangria: hanging-indent,
    profundidad: depth,
    transformar: transform,
    ..named,
  )
}

/// Inicial iluminada de EB Garamond Initials (A–Z, Ä, Ö, Ü), sola.
/// Devuelve none si la letra no existe en el juego.
///
/// - style: "plain" (una tinta), "inverted" (bloque de tinta con la letra
///   calada) o "rubricated" (ornamento en tinta, letra en rojo)
/// - frame: doble filete del taco de madera
/// - wear: desgaste de impresión, de 0 a 1 (con > 0 la imagen se rasteriza)
/// - ink, fill, ornament: tinta general, color de la letra y del ornamento
#let ornate-initial(
  letter,
  size: 3em,
  style: "plain",
  frame: true,
  wear: 0,
  ink: none,
  fill: none,
  ornament: none,
) = inicial-ornamentada(
  letter,
  size: size,
  estilo: _style(style),
  marco: frame,
  desgaste: wear,
  tinta: ink,
  fill: fill,
  ornamento: ornament,
)

/// Letra capital iluminada: como `dropcap`, con la inicial de `ornate-initial`.
/// Las letras que no están en el juego (acentuadas, Ñ…) usan `dropcap`.
#let ornate-dropcap(
  body,
  height: 3,
  gap: 0.3em,
  style: "plain",
  frame: true,
  wear: 0,
  ink: none,
  fill: none,
  ornament: none,
  justify: auto,
  hanging-indent: 0pt,
  depth: 0,
  ..text-args,
) = capitular-ornamentada(
  body,
  alto: height,
  hueco: gap,
  estilo: _style(style),
  marco: frame,
  desgaste: wear,
  tinta: ink,
  fill: fill,
  ornamento: ornament,
  justificar: justify,
  sangria: hanging-indent,
  profundidad: depth,
  ..text-args,
)
