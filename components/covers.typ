// Portada y contraportada de book (parámetro `cover`), compatibles con coverbook.
//
//   cover: none                                 sin portada
//   cover: [contenido]                          una portada ya armada, sin contraportada
//   cover: (portada, contraportada)             las dos ya armadas, p. ej. de `cover-pages`
//   cover: minimal-cover                        una función de estilo: hace las dos
//   cover: (front: …, back: …, data: …, options: …)
//
// Claves del diccionario:
//   front    Contenido o una función de estilo de coverbook (`minimal-cover`…), que se llama con el
//            título, el subtítulo, el autor y la editorial del libro más `data`, y `side: "front"`
//   back     auto (la de `front` si es una función; si no, ninguna), none o contenido
//   data     Datos extra para la función: isbn, back-text, volume…
//   options  Opciones de la función: trim, spine, colores…

#let keys = ("front", "back", "data", "options")

// Las opciones sueltas de antes son ahora claves de `cover`
#let check-old(back-cover, cover-data, cover-options) = {
  let old = (back-cover: (back-cover, auto, "back"), cover-data: (cover-data, (:), "data"), cover-options: (
    cover-options,
    (:),
    "options",
  ))
  for (name, (value, default, key)) in old {
    if value != default {
      panic("book: " + name + " ahora es la clave `" + key + "` de cover: `cover: (front: …, " + key + ": …)`")
    }
  }
}

// `cover` en forma de diccionario, validado
#let normalize(cover) = {
  if cover == none { return (front: none, back: none, data: (:), options: (:)) }
  if type(cover) == array {
    assert(cover.len() == 2, message: "book: cover como lista debe ser (portada, contraportada)")
    return (front: cover.first(), back: cover.last(), data: (:), options: (:))
  }
  if type(cover) in (content, function) { return (front: cover, back: auto, data: (:), options: (:)) }
  assert(
    type(cover) == dictionary,
    message: "book: cover debe ser none, contenido, una función de portada, (portada, contraportada) o un diccionario",
  )
  for key in cover.keys() {
    assert(key in keys, message: "book: clave desconocida «" + key + "» en cover. Claves válidas: " + keys.join(", "))
  }
  for key in ("data", "options") {
    assert(type(cover.at(key, default: (:))) == dictionary, message: "book: cover." + key + " debe ser un diccionario")
  }
  (front: cover.at("front", default: none), back: cover.at("back", default: auto), data: cover.at("data", default: (:)), options: cover.at("options", default: (:)))
}

// (portada, contraportada) ya armadas. `book` tiene title, subtitle, author y publisher
#let resolve(cover, book) = {
  let c = normalize(cover)
  let data = book.pairs().filter(((_, value)) => value != none).to-dict() + c.data
  let make(side) = (c.front)(data, side: side, ..c.options)
  let front = if type(c.front) == function { make("front") } else { c.front }
  let back = if c.back != auto { c.back } else if type(c.front) == function { make("back") }
  (front, back)
}
