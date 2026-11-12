// Microtipografía: reglas de no ruptura, validación de opciones y efecto en un libro
#import "../components/microtype.typ": defaults, glue, nbsp, resolve

#let n = nbsp
#assert.eq(glue("cf. Col. 2:3"), "cf. Col." + n + "2:3")
#assert.eq(glue("(1 Cor. 1:20)"), "(1" + n + "Cor." + n + "1:20)")
#assert.eq(glue("1 Pedro 3:15"), "1" + n + "Pedro 3:15")
#assert.eq(glue("el Dr. Bahnsen"), "el Dr." + n + "Bahnsen")
#assert.eq(glue("por L. F. Reyes"), "por L." + n + "F." + n + "Reyes")
#assert.eq(glue("pp. 12-15 y n.º 5"), "pp." + n + "12-15 y n.º" + n + "5")
// Lo que no es abreviatura queda intacto
#assert.eq(glue("Fin de la frase. Otra frase 12 veces"), "Fin de la frase. Otra frase 12 veces")
#assert.eq(glue("uno 2 tres"), "uno 2 tres")

#assert.eq(resolve(true), defaults)
#assert.eq(resolve(false), none)
#assert.eq(resolve((hyphenation: 150%)).hyphenation, 150%)
#assert.eq(resolve((hyphenation: 150%)).glue, true)

OK
