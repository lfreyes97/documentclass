// Márgenes compartidos por las clases (parámetro `margin`), junto con `facing-pages`
// (el `twoside` de LaTeX).
//
//   margin: auto                                  los de la clase
//   margin: 2cm                                   el mismo en los cuatro lados
//   margin: (inside: 3cm, outside: 2cm, y: 2cm)   con facing-pages: true
//   margin: (x: 2.5cm, y: 2cm)                    con facing-pages: false
//
// Con `facing-pages: true` el margen horizontal es `inside` y `outside`, que alternan
// con cada página; con `false` es `x`, o `left` y `right`. Lo que no se indica queda en el
// valor por defecto de la clase: `(y: 3cm)` solo cambia el vertical.

#let horizontal = ("x", "left", "right", "inside", "outside")
#let vertical = ("y", "top", "bottom")
#let facing-keys = ("inside", "outside")
#let single-keys = ("left", "right")

// Márgenes por defecto de una clase: `facing` (doble cara) y `single` (una cara)
#let resolve(margin, facing-pages, defaults) = {
  let base = if facing-pages { defaults.facing } else { defaults.single }
  if margin == auto { return base }
  if type(margin) == length or type(margin) == relative { return margin }
  assert(
    type(margin) == dictionary,
    message: "margin debe ser auto, una longitud o un diccionario, p. ej. `margin: (x: 2cm, y: 2.5cm)`",
  )
  let valid = horizontal + vertical + ("rest",)
  for key in margin.keys() {
    assert(
      key in valid,
      message: "margin: clave desconocida «" + key + "». Claves válidas: " + valid.join(", "),
    )
  }
  let wrong = if facing-pages { single-keys } else { facing-keys }
  for key in wrong {
    assert(
      key not in margin,
      message: "margin: «"
        + key
        + "» no se usa con `facing-pages: "
        + repr(facing-pages)
        + "`; usa "
        + if facing-pages { "`inside` y `outside`" } else { "`x`, o `left` y `right`" },
    )
  }
  // Lo que el usuario fija en un eje sustituye a los valores por defecto de ese eje
  let merged = (:)
  if not margin.keys().any(k => k in horizontal + ("rest",)) {
    for (key, value) in base { if key in horizontal { merged.insert(key, value) } }
  }
  if not margin.keys().any(k => k in vertical + ("rest",)) {
    for (key, value) in base { if key in vertical { merged.insert(key, value) } }
  }
  merged + margin
}
