// Microtipografía compartida por las clases (parámetro `microtype`).
//
//   microtype: true                     valores por defecto
//   microtype: false                    sin ajustes: los de Typst
//   microtype: (tracking: (min: -0.02em, max: 0.02em), glue: false)
//
// Tres ajustes, por orden de efecto:
//   spacing, tracking  Holgura que Typst puede usar al justificar: estirar o
//                      encoger el espacio entre palabras y, algo menos, el
//                      interletrado. Reparte el ajuste entre muchas
//                      líneas en vez de cargarlo en las peores.
//   hyphenation        Coste de guionar una palabra (100% = el de Typst).
//                      Subirlo reduce los guiones; con ±0.012em de interletra
//                      el espacio sigue repartido de forma pareja.
//   glue               Espacios de no ruptura tras abreviaturas, tratamientos,
//                      iniciales y libros numerados; la raya de cierre pegada a
//                      la palabra anterior y la de apertura a la siguiente.
//
// `overhang` (puntuación que sobresale del margen) ya viene activado en Typst.

#let defaults = (
  spacing: (min: 90%, max: 120%),
  tracking: (min: -0.012em, max: 0.012em),
  hyphenation: 130%,
  glue: true,
)

// Completa las opciones con los valores por defecto. `false` o `none` las desactiva
#let resolve(options) = {
  if options == false or options == none { return none }
  if options == true { return defaults }
  assert(
    type(options) == dictionary,
    message: "microtype debe ser true, false o un diccionario, p. ej. `microtype: (hyphenation: 150%)`",
  )
  for key in options.keys() {
    assert(
      key in defaults,
      message: "microtype: opción desconocida «" + key + "». Opciones válidas: " + defaults.keys().join(", "),
    )
  }
  for key in ("spacing", "tracking") {
    if key in options {
      let range = options.at(key)
      assert(
        type(range) == dictionary and range.keys().sorted() == ("max", "min"),
        message: "microtype: " + key + " debe ser `(min: ..., max: ...)`",
      )
    }
  }
  defaults + options
}

#let nbsp = "\u{00a0}"

// Cada regla busca un espacio que no debe separar la línea. Típico: «Cor. 1:20»
// no puede quedar con «Cor.» al final de una línea y «1:20» al principio de la
// siguiente. Los patrones consumen texto en vez de usar mirada atrás, que el
// motor de expresiones de Typst no tiene; `glue-space` solo cambia los espacios.
#let glue-rules = (
  // Abreviatura corta y número: p. 12, pp. 3-5, cap. 2, vv. 7, Col. 2:3
  regex("\\b\\p{L}{1,5}\\. [0-9]"),
  // Tratamientos ante un nombre: Dr. Bahnsen, Sra. Pérez
  regex("\\b(?:Dr|Dra|Sr|Sra|Srta|Lic|Ing|Prof|Pbro|Rev|Mons|Fr|St|Mr|Mrs|Ms)\\. \\p{Lu}"),
  // Iniciales: L. F. Reyes
  regex("\\b\\p{Lu}\\. "),
  // Libro numerado: 1 Corintios, 2 Timoteo
  regex("\\b[1-3] \\p{Lu}"),
  // Número ordinal abreviado: n.º 5
  regex("\\b[nN]\\.[º°o] "),
)

#let glue-space(text) = text.replace(" ", nbsp)

/// Aplica las reglas de no ruptura a un texto. Lo usa la regla `show` de `setup`
/// y las pruebas.
#let glue(text) = {
  for rule in glue-rules {
    text = text.replace(rule, match => glue-space(match.text))
  }
  text
}

// Una regla `show` solo vale para el resto de su bloque, así que cada una
// envuelve el contenido en su propio bloque en vez de ir en un bucle.
#let glue-setup(body) = {
  let body = glue-rules.fold(body, (content, rule) => {
    show rule: it => glue-space(it.text)
    content
  })

  // La raya pegada a una palabra no abre línea: se une a ella con un WORD JOINER
  // («la ética— y», «word—word»). Tras ella se puede cortar
  show regex("\\S—"): it => {
    let chars = it.text.clusters()
    [#chars.slice(0, -1).join()#sym.wj#chars.last()]
  }
  // La raya que abre un inciso («texto —inciso— texto») no cierra línea: se une a la
  // palabra que sigue. El corte en el espacio de antes sigue permitido, así que el
  // inciso puede empezar línea, como pide la ortografía
  show regex("\\s—\\p{L}"): it => {
    let chars = it.text.clusters()
    [#chars.slice(0, -1).join()#sym.wj#chars.last()]
  }
  body
}

#let setup(options, body) = {
  let options = resolve(options)
  if options == none { return body }

  set par(justification-limits: (spacing: options.spacing, tracking: options.tracking))
  set text(costs: (hyphenation: options.hyphenation))
  if options.glue { glue-setup(body) } else { body }
}
