// Parámetro `style` de las clases: un tema que fija títulos, cabeceras y pies, e índice
#import "../lib.typ": *
#import "../components/themes.typ": check, pick, themes

#assert.eq(themes, ("classic", "modern", "elegant"))
#assert.eq(check(auto), auto)
#assert.eq(check("modern"), "modern")
// Lo propio gana al tema, y el tema a lo de la clase
#assert.eq(pick("plain", "modern", "classic"), "plain")
#assert.eq(pick(auto, "modern", "classic"), "modern")
#assert.eq(pick(auto, auto, "classic"), "classic")
#assert.eq(pick(none, "modern", "classic"), none)

#show: book.with(title: "Tema", style: "elegant", page-style: "plain")
#show: front
#tableofcontents()
#show: main
= Parte
== Capítulo
#lorem(80)
