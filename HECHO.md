# Hecho

Lo que ya salió de `TODO.md`, con el commit de cada cosa. Sirve de base para el changelog.
Estado al 2026-11-12.

## Antes de esta ronda

- `tocs` es el índice canónico (`595d4b7`): `tableofcontents`, `minitoc`, `listoffigures`, `listoftables`
  y `listoflistings` son sus funciones; se eliminaron `components/toc.typ`, `components/minitoc.typ` y las
  listas de `matter.typ`.
  - `book(minitoc: ...)` acepta `false`, `true` o un diccionario de opciones de `tocs.partial`; desaparecieron
    los cinco `minitoc-*` sueltos. `tocs` ganó la clave de estilo `number` (`false` oculta número y etiqueta).
  - `depth` cuenta los niveles bajo las partes (un `depth` antiguo con partes equivale a ese valor menos 1).
  - Una opción antigua falla con un mensaje que dice su forma nueva (`h1-font`, `chapter-label`, `nest-indent`…).
  - Con `facing-pages: false` el título del índice ya no fuerza una página impar en el front matter.
  - Migrados y verificados contra sus PDFs anteriores: `Presup/siempre-listos/main.typ`,
    `Bahnsen-DebateSproul.typ`, `Defendiendo la fe.typ`, `Warfield-Vol1.typ` y `Propaganda/espanol/main.typ`
    y `main-a5.typ`.
- `facing-pages` para el front de un libro impreso (`ea15153`), marca de saltos de página para que los saltos del
  usuario dejen páginas en blanco limpias (`4461dcc`), `microtype` (`7f2778e`) y TOC sin solapes (`e6f7698`).

## Márgenes y doble cara (`ea6d924`)

- Un único `margin` (`auto`, longitud o diccionario con la sintaxis de Typst) y `facing-pages` como el `twoside`
  de LaTeX, en `book`, `report` y `article` (`components/margins.typ`, `test/margins.typ`).
- Con `facing-pages: true` el margen es `inside`/`outside`; con `false`, `x` o `left`/`right`. Lo no indicado
  conserva el valor de la clase y una clave del tipo equivocado falla con mensaje.
- `facing-pages` es `true` en `book` y `false` en `report` y `article`. En `essay`, `book` se renombró a
  `facing-pages`.

## Cabeceras y pies: `page-style` (`45a3bd9`, `643fa19`, `3c198b8`)

- Preajuste `classic` (lo que hacía `book`, páginas idénticas a las de antes), y un diccionario `header`/`footer`
  con `left`/`center`/`right`, `odd`/`even`, `rule`, `text` y `when`, con funciones `ctx => contenido`
  (`part`, `chapter`, `section`, `folio`, `title`, `author`…). `components/pagestyle.typ`, `test/pagestyle.typ`.
- `layout.setup` quedó solo con el estilo de párrafo y las marcas de salto.
- Preajustes: temas `classic`, `modern`, `elegant` y variantes solo de `page-style`: `plain`, `folio-outer` y
  `running-outer` (antes `outer` y `minimal`). `demos/demo_pagestyle.typ`.
- `report` usa `"plain"` y el estilo de párrafo de `book` (`46fb148`); `article`, ninguno.

## Temas: `style` (`c0b1d05`)

- Un parámetro `style` en las clases aplica un tema (`classic`, `modern`, `elegant`) a los títulos, las cabeceras
  y pies, y el índice; `heading-style`, `page-style` y `tocs.setup` lo sustituyen en una sola parte.
- Pasar una variante de `page-style` donde se espera un tema falla con un mensaje que lo dice
  (`components/themes.typ`, `test/themes.typ`).

## Títulos: `heading-style` (`64bccf3`, `1f06806`, `0983956`, `d975ce4`)

- Aperturas de parte y capítulo y títulos de sección con preajustes `classic` (idéntico al anterior: comprobado
  píxel a píxel y con las referencias del script), `modern` y `elegant`. `components/openings.typ`,
  `test/openings.typ`.
- Un diccionario por rol (`part`, `chapter`, `section`, `subsection`, `subsubsection`, `paragraph`) con alias
  `h1`…`h6`; las aperturas tienen variantes `front`, `back` y `appendix`; las secciones heredan del rol anterior
  y la primera del cuerpo; `scale` agranda todos los tamaños según cuánto sobresalen del cuerpo.
- `report` y `article` lo usan con preajustes por clase (`classic` idéntico al anterior). Sus tamaños de `classic`
  son los de un cuerpo de 11 pt, en `em`, así que ahora siguen `font-size`.
- Desaparecieron `h1-size`…`h4-smallcaps` de `headings.setup`; los niveles 5 y 6 de `book` siguen `heading-style`.
- `demo_book.typ` muestra los seis niveles y elige tema con `--input style=…` (`82ba636`).

## Pruebas y CI (`bec5e29`)

- `test/structure.py`: compila `test/` y `demos/` y revisa páginas con solo folio, orden de folios, solape de
  líneas, cabeceras y páginas en blanco de `test/structure_book.typ`, y el texto y la posición de las líneas de
  seis archivos contra `test/reference/`. Comprobado que detecta una cabecera invertida, folios en páginas en
  blanco, líneas solapadas y un cambio de interlineado.
- CI en `.github/workflows/test.yml`, con Typst 0.15.1.

## Ensayo real (Iapocalipsis) y clase `essay`

Revisado con el ensayo real (24 páginas, 142 notas al margen). Los espacios entre texto y columna de notas estaban
bien: no hizo falta tocarlos.

- Título sin numeral por defecto (`chapter-numbering: none`) y contador «Pág. n de N» en el pie exterior
  (`page-counter`), lo que libera la columna interior de 15 mm de la cabecera (`b9902a8`).
- **Desborde de notas** (`overflow: "carry"`, por defecto; `99e0e77`, `44e555a`): las notas que no caben en la
  columna de su página pasan al principio de la siguiente, con una flecha junto a la nota en el canal
  (`overflow-mark`). `glosa` reparte con funciones puras (`_fit-page`, `_carry-layout`, `test/glosa_carry.typ`);
  sin desborde el resultado es idéntico. `setup` pasó a `glosa/setup.typ`.
- Notas al pie con símbolos que reinician en cada página (`footnote-counter: "page"`, `d1b1ea7`) y sin asterisco,
  que como superíndice queda en un punto: `footnote-symbols` empieza en `†` (`ea264db`).
- Modo sin columna `notes: "footnote"`: las notas al margen son notas al pie en una sola serie numérica, las figuras
  al margen figuras normales y los bloques anchos bloques normales; los márgenes salen de `margin`
  (`test/essay_footnotes.typ`). `glosa` ganó la opción `mode`.
- Fecha fija (`913f520`): `date` es `none` por defecto, sin fecha en la cabecera ni en los metadatos del PDF.
  Una `datetime` o un texto la ponen; `datetime.today()` devuelve la de hoy.

## Decisiones tomadas

- `tocs` canónico, `margin` único con `facing-pages`, `report` con `plain`, `style` como tema común, `overflow:
  "carry"` por defecto.
- La versión (`0.1.0`) no es urgente: es de desarrollo, se sube cuando convenga.
