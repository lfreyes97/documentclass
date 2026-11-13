// Microtipografía: reglas de no ruptura, validación de opciones y efecto en un libro
#import "../components/microtype.typ": defaults, glue, glue-setup, nbsp, resolve

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

// La raya: la de apertura de un inciso no cierra línea y la de cierre no la abre; con espacio delante, el
// inciso puede empezar línea. Cada ancho fuerza un corte distinto (structure.py comprueba los finales de línea)
#show: glue-setup
#for width in (2cm, 2.2cm, 2.6cm, 3cm) {
  block(width: width, par(justify: false)[RAYA palabras inteligible —la lógica— y fin])
  // La raya exenta, con espacio a los dos lados, tampoco empieza línea
  block(width: width, par(justify: false)[EXENTA palabras largas — exento fin])
}

OK
