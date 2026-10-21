#import "headings.typ": is-blank-page, matter-state

#let setup(
  title: none,
  author: none,
  header-font: none, // none = hereda del cuerpo
  body,
) = {
  // Headers y Footers (la geometría de página se configura en book.typ)
  set page(
    // Cabecera Dinámica (Running Header)
    header: context {
      // 1. Número de página físico: decide recto/verso y se compara con location().page()
      let abs-page = here().page()

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

      // 3c. SUPRESIÓN EN PÁGINAS SIN NUMERACIÓN O EN BLANCO (reversos antes de parte o capítulo)
      if page.numbering == none or is-blank-page(abs-page) {
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
      set text(font: header-font) if header-font != none
      set text(size: 9pt, weight: "regular")

      // 7. Contenido dependiente de recto (impar) / verso (par)
      if calc.odd(abs-page) {
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
      // Sin folio en páginas sin numeración (portada, dedicatoria), en blanco ni de parte
      let abs-page = here().page()
      let part-on-page = query(heading.where(level: 1)).any(h => (
        h.location().page() == abs-page and matter-state.at(h.location()) != "front"
      ))
      if page.numbering == none or is-blank-page(abs-page) or part-on-page {
        return none
      }
      let page-num = counter(page).at(here()).first()
      let state-val = matter-state.at(here())
      let pattern = if state-val == "front" { "i" } else { "1" }

      align(center)[
        #set text(size: 10pt)
        #std.numbering(pattern, page-num)
      ]
    },
  )

  // Configuración de párrafos: la sangría separa los párrafos, sin espacio extra.
  // Typst no sangra el primer párrafo tras un título o un bloque.
  set par(
    leading: 0.7em,
    spacing: 0.7em,
    justify: true,
    linebreaks: "optimized",
    first-line-indent: 1.5em,
  )

  body
}
