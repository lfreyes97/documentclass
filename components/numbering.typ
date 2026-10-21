// Numeración de figuras y ecuaciones relativa al capítulo: 2.3, A.1, o solo 3
// fuera de un capítulo numerado. `level` es el nivel de heading del capítulo
// (2 en book, 1 en report). Typst evalúa las funciones de numeración en la
// posición del elemento numerado, también cuando se lo referencia.
#let in-chapter(level, ..nums) = {
  let n = str(nums.pos().last())
  let chapters = query(heading.where(level: level).before(here()))
  if chapters.len() == 0 or chapters.last().numbering == none {
    return n
  }
  let chapter = chapters.last()
  numbering(chapter.numbering, ..counter(heading).at(chapter.location())) + "." + n
}

#let equation-in-chapter(level, ..nums) = "(" + in-chapter(level, ..nums) + ")"

// Reinicia figuras y ecuaciones; se coloca en cada capítulo numerado
#let reset-in-chapter() = {
  for kind in (image, table, raw) {
    counter(figure.where(kind: kind)).update(0)
  }
  counter(math.equation).update(0)
}
