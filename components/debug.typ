// Ayudas de depuración (parámetro `debug`) y marcas de revisión (`verify`). Todo es invisible para el
// lector salvo con la depuración activa.
//
//   debug: false                         sin ayudas (por defecto)
//   debug: true                          todas
//   debug: (verify: true, lines: false)  las que indiques; las que no, apagadas
//
// Claves:
//   verify   Resalta las marcas `verify[…]`, que si no son invisibles
//   lines    Numera las líneas del cuerpo (como `line-numbers: true`)
//   frame    Dibuja los límites de márgenes y columnas (`essay`)
//
// `verify[…]` marca algo pendiente de comprobar: no imprime nada, pero deja un dato consultable
// desde la línea de comandos, con su página, aunque la depuración esté apagada:
//
//   typst eval 'query(<dc-verify>).map(it => (page: it.location().page(), text: it.value.text))' --in ensayo.typ

#import "tocs/bridge.typ"

#let keys = ("verify", "lines", "frame")
#let state-debug = state("dc-debug", (verify: false, lines: false, frame: false))

#let resolve(options) = {
  assert(
    options == true or options == false or options == none or type(options) == dictionary,
    message: "debug debe ser true, false o un diccionario, p. ej. `debug: (verify: true)`",
  )
  if options == true { return keys.map(k => (k, true)).to-dict() }
  let out = keys.map(k => (k, false)).to-dict()
  if type(options) == dictionary {
    for (key, value) in options {
      assert(key in keys, message: "debug: clave desconocida «" + key + "». Claves válidas: " + keys.join(", "))
      assert(type(value) == bool, message: "debug: «" + key + "» debe ser true o false")
      out.insert(key, value)
    }
  }
  out
}

// Fija las ayudas para el documento. `options` ya resuelto con `resolve`
#let setup(options, body) = {
  state-debug.update(options)
  body
}

// El texto de un contenido, para el dato consultable
#let plain(it) = {
  if type(it) == str { it } else if it == [] { "" } else if it.has("text") { it.text } else if (
    it.func() == [ ].func()
  ) { " " } else if it.has("children") { it.children.map(plain).join() } else if it.has("body") {
    plain(it.body)
  } else { "" }
}

/// Marca algo pendiente de comprobar. No se imprime; con `debug: (verify: true)` sale resaltado.
#let verify(body, kind: "VERIFICAR") = context {
  // La página no se guarda en el valor: dentro de una nota al margen movida por `carry`, `here()` cambia entre
  // pasadas y el documento no converge. La da `item.location().page()`
  [#metadata((text: plain(body), kind: kind))<dc-verify>]
  if state-debug.get().verify {
    // La marca no deja hueco en el texto final; en depuración se separa de la palabra anterior
    h(0.3em, weak: true)
    highlight(fill: rgb("#ffe58a"), extent: 1pt, [#text(size: 0.8em, weight: "bold", kind)~#body])
  }
}

/// Lista las marcas `verify` del documento con su página (solo con `debug: (verify: true)`)
#let verify-list(title: [Pendientes de verificar]) = context {
  if not state-debug.get().verify { return }
  let items = query(<dc-verify>)
  block(breakable: false)[
    #set par.line(numbering: none)
    #text(weight: "bold", title) (#items.len())
    #if items.len() > 0 {
      for item in items [
        - #link(item.location(), [pág. #bridge.page-label(item.location())]): #if item.value.text == "" [_(sin nota)_] else [#item.value.text]
      ]
    } else [ Ninguno.]
  ]
}
