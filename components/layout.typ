#import "headings.typ": chapter-counter, matter-state, part-counter

#let setup(
  title: none,
  author: none,
  header-font: ("Akshar", "Arial Narrow"),
  body,
) = {
  // Headers y Footers (la geometría de página se configura en book.typ)
  set page(
    // Cabecera Dinámica (Running Header)
    header: context {
      // 1. Obtener número de página actual (absoluto, para comparar con location().page())
      let abs-page = here().page()
      // Número de página del contador (puede diferir si se reinicia el contador)
      let page-num = counter(page).at(here()).first()

      // 2. Consultas globales de headings
      let all-h1 = query(heading.where(level: 1))
      let all-h2 = query(heading.where(level: 2))

      // 3. SUPRESIÓN FRONTMATTER: Si estamos antes del primer H1 (parte), suprimir
      // Detectamos frontmatter sin usar state para evitar layout thrashing
      if all-h1.len() == 0 or abs-page < all-h1.first().location().page() {
        return none
      }

      // 3b. SUPRESIÓN: Si hay un H1 o H2 en ESTA página, no mostrar cabecera
      let h1-on-page = all-h1.filter(h => h.location().page() == abs-page)
      let h2-on-page = all-h2.filter(h => h.location().page() == abs-page)
      if h1-on-page.len() > 0 or h2-on-page.len() > 0 {
        return none
      }

      // 3c. SUPRESIÓN DE PÁGINAS EN BLANCO: Si esta es una página PAR
      // y la página siguiente tiene un heading, suprimir (es una página en blanco antes del título)
      let h1-on-next = all-h1.filter(h => h.location().page() == abs-page + 1)
      let h2-on-next = all-h2.filter(h => h.location().page() == abs-page + 1)
      if calc.even(abs-page) and (h1-on-next.len() > 0 or h2-on-next.len() > 0) {
        return none
      }

      // 4. Encontrar el H1 (Parte) más reciente ANTES de esta página
      let h1-before = all-h1.filter(h => h.location().page() < abs-page)
      let current-h1 = if h1-before.len() > 0 {
        h1-before.last()
      } else {
        none
      }

      // 5. Encontrar el H2 (Capítulo) más reciente ANTES de esta página
      let h2-before = all-h2.filter(h => h.location().page() < abs-page)
      let current-h2 = if h2-before.len() > 0 {
        h2-before.last()
      } else {
        none
      }

      // 5. Validar que el H2 pertenezca al H1 actual
      // (El H2 debe aparecer después del H1 en el documento)
      let valid-h2 = if current-h2 != none and current-h1 != none {
        (
          (current-h2.location().page() > current-h1.location().page())
            or (
              current-h2.location().page() == current-h1.location().page()
                and current-h2.location().position().y > current-h1.location().position().y
            )
        )
      } else if current-h2 != none {
        true // Si no hay H1, el H2 es válido
      } else {
        false
      }

      // 6. Contenido de la Cabecera
      set text(font: header-font, size: 9pt, weight: "regular")

      // 7. Contenido dependiente de par/impar
      if calc.odd(page-num) {
        // Página IMPAR (Derecha): Título del Capítulo (H2)
        let header-content = if valid-h2 {
          current-h2.body
        } else if current-h1 != none {
          current-h1.body // Fallback al título de la parte
        } else {
          title // Fallback al título del libro
        }
        align(right)[#emph(header-content)]
      } else {
        // Página PAR (Izquierda): Título de la Parte (H1) o Libro
        let header-content = if current-h1 != none {
          current-h1.body
        } else {
          title
        }
        align(left)[#emph(header-content)]
      }

      v(-0.5em)
      line(length: 100%, stroke: 0.5pt + gray)
    },

    // Pie de página
    footer: context {
      let page-num = counter(page).at(here()).first()
      import "headings.typ": matter-state
      let state-val = matter-state.at(here())
      let pattern = if state-val == "front" { "i" } else { "1" }

      align(center)[
        #set text(size: 10pt)
        #std.numbering(pattern, page-num)
      ]
    },
  )

  // Configuración de párrafos
  set par(
    leading: 0.7em,
    spacing: 1.35em,
    justify: true,
    linebreaks: "optimized",
    first-line-indent: 1.5em,
  )

  show heading: it => {
    it
    par(first-line-indent: 0pt)
  }

  body
}
