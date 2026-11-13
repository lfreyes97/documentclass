# Hecho

Lo que ya salió de `TODO.md`, con el commit de cada cosa. Sirve de base para el changelog.
Estado al 2026-11-13.

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

## Líneas numeradas

- `line-numbers` en `book`, `report`, `article` y `essay` (`components/lines.typ`, `test/line_numbers.typ`): usa `par.line` de
  Typst, reinicia por página, se puede mostrar cada N líneas y no numera títulos, notas al pie, pies de figura,
  portadas ni bloques de título.

## Depuración: `debug` y `verify`

- `debug` (`false`, `true` o un diccionario `verify`/`lines`/`frame`) en `book`, `report`, `article` y `essay`
  (`components/debug.typ`, `test/verify_off.typ`, `test/verify_on.typ`). Reúne `line-numbers` y el `debug-frame` de `essay`.
- `#verify[…]`: marca lo pendiente de comprobar. Invisible para el lector; deja un dato consultable con su página
  (`typst eval 'query(<dc-verify>).map(it => it.value)' --in …`) y, con `verify` encendido, sale resaltado.
  `#verify-list()` lista los pendientes. Sustituye a los `[VERIFICAR …]` escritos a mano.

## Clase `debate` (`b8db407`…`859cc65`)

- `debate` es una clase propia para transcripciones: debate, mesa redonda o entrevista (`classes/debate.typ`,
  `components/debates.typ`; demos `demo_debate`, `demo_debate_panel`, `demo_debate_interview`,
  `test/debate_program.typ`).
- Oradores declarados (`speakers`) y `#turn("clave")` en estilo `classic` (rótulo en línea) o `modern` (en su línea),
  con `cont: true` para un turno que sigue y `label:` para quien no está declarado.
- Plantillas `two-speakers`, `panel` e `interview`: fijan los segmentos admitidos y cuántos oradores y moderadores
  lleva el formato. `#segment` (título ligero, rol `segment` en `heading-style`) con orador y tiempo, y `program`:
  `#segment()` abre el siguiente del programa de la plantilla.
- Marcas de la transcripción (`crowd`, `inaudible`, `at`, `tnote`) y `marks:` para quitarlas o mostrar los tiempos.
- Datos del debate (`venue`, `original`, moderador) y portadilla «A frente a B» con `titlepage: true`; `cover` y
  `back-cover` de coverbook, como en `book`.
- Cabecera `running-segment` (oradores de la página y segmento): `ctx.segment`, `ctx.speaker` y `ctx.speakers` en
  `page-style`.
- `turn(id:)` y `cite-turn("id")` dan «Bahnsen, Pág. 3, l. 16», calculado al compilar con las marcas `<dc-line>` de
  `lines.setup(track: true)`.
- `speakers-index()` y `glossary(…)` con `gloss("clave")[…]`.
- Saltos de página con `breaks` ("turn", "segment", "section", none; por plantilla) y `start` en `heading-style`:
  los turnos de intercambio van de corrido y los discursos abren página.
- Estilo de títulos (`heading-style`) para `debate`: roles `section`, `segment`, `subsection`… en los tres temas.
- Libro de Bahnsen migrado a una copia con la clase (`Presup/bahnsen-debate/Bahnsen-DebateSproul-debate.typ`, 118
  turnos, 4 segmentos, glosario de 12 entradas): no falta ningún texto respecto al original.

## Citas, epígrafes y adornos (`6ec0709`, `d244d34`, `948320f`, `f5e28be`)

- `quote-style` (`components/quotes.typ`) en las cinco clases: tema o diccionario por rol (`epigraph`, `blockquote`,
  `verse`), con el mismo mecanismo que `heading-style`. `classic` conserva el aspecto anterior.
- Epígrafe: atribución estructurada (`author`, `work`, `article`, `year`, `note`), `epigraphs` (varios seguidos),
  `epigraph-page` y, en `essay`, el estilo del epígrafe que se armaba a mano (78 %, justificado). `align-to` pasó a
  `align`.
- `blockquote(attribution:, marks:)` y `quote(block: true)` con su estilo; las citas en línea (`#quote`) anidan las
  comillas del idioma (es, en, pt, fr, de, it).
- `ornament` (`components/ornaments.typ`): asterismo, florón, filete con rombo, puntos y rombo, dibujados con trazos;
  su nombre vale en `part-ornament` y en la clave `ornament` de `heading-style`.

## Pruebas

- Las referencias de `test/reference/` dejaron de versionarse (`9e58dae`): se crean con `python3 test/structure.py
  --update` y, si faltan, `structure.py` salta la comparación.

## Ronda de API, estilos e imprenta (2026-11-13)

Cambios incompatibles marcados con **(!)**; todos fallan con un mensaje que dice la forma nueva, salvo donde se
indica.

### API

- **Superficie pública explícita (!)** (`a0ce290`): `lib.typ` exporta solo lo documentado. Las partes del libro
  se llaman como en LaTeX, `frontmatter`, `mainmatter` y `backmatter`; `front`, `main` y `back` siguen como alias
  obsoletos (chocan con nombres propios al importar con `*`) hasta congelar la API. Desaparecen de la superficie
  los módulos internos `matter` y `dropcap-mod` (sin mensaje: Typst dice «unknown variable»).
- **Tabla «Public API» y «States» en el README, y README reordenado** (`03223dd`): estado de cada nombre (estable,
  en desarrollo, avanzado, obsoleto), las opciones de `essay` en lista agrupada, un solo apartado de pruebas.
- **Bloque común de título y `titlepage` único (!)** (`eae73dc`): las cuatro clases tienen `title`, `subtitle`,
  `author`, `date` y `publisher` (`essay` ganó `subtitle` y `publisher`; `article`, `publisher`). `titlepage` es
  `auto`/`true` (la de la clase), `none`/`false` (ninguna, nuevo en `book` y `report`) o contenido;
  `custom-titlepage` falla con mensaje. `test/titlepages.typ`.
- **Portada como diccionario (!)** (`5a01109`): `cover: (front:, back:, data:, options:)`, o un par
  `(portada, contraportada)` como el de `cover-pages` de coverbook (`components/covers.typ`). `back-cover`,
  `cover-data` y `cover-options` fallan con mensaje. Cierra también «Cubierta trasera» (Imprenta): una portada
  dada como contenido ya puede llevar contraportada. `test/covers.typ`.
- **`equation-numbering` en `article` y `essay`** (`6daea71`, `a9d9883`): `(1)`, `(2)`… en todo el documento,
  como sus figuras. Apagado por defecto.
- **Validación uniforme (!)** (`26daae1`): toda opción de tipo diccionario falla con las claves válidas.
  `essay`: `inner`/`outer` pasan a `note-columns: (inner:, outer:)`, que se combina clave a clave con los valores
  de `essay` (antes una columna parcial caía a los 5 mm de glosa) y se valida; `book` valida `minitoc` al
  empezar; los estilos de texto y bloque de `essay` fallan aunque no se usen. `structure.py` compila una lista de
  opciones mal escritas y comprueba cada mensaje.
- **Estados con prefijo `dc-` (!)** (`2166ce6`): `matter-section` y `appendix-mode` son `dc-matter` y
  `dc-appendix`; las claves que lee `tocs` quedan documentadas como contrato (README, «States», y
  `components/tocs/bridge.typ`). Solo afecta a código ajeno que leyera esos estados por su clave.

### Estilos de títulos, cabeceras y pies

- **Títulos huérfanos** (`2ffc449`): un título de sección ya no se queda solo al pie de una página o columna en
  `book`, `article` y `report` (bloque `sticky` con el mismo espaciado de párrafo). Cambia el aspecto: en `book`
  el párrafo que sigue a un título de sección ya no lleva sangría (como en `report`, `article` y LaTeX); junto a
  un índice o una figura el espacio puede variar unos puntos. `debate` conserva lo suyo. Se descartó un
  `\needspace` medido (mantenía la sangría) porque no convergía con muchos títulos seguidos.
  `test/orphan_headings.typ` (book, article a dos columnas, report).
- **`heading-style`: títulos en línea y función** (`132af32`): `run-in: true` y `run-in-sep` (el `\paragraph`
  de LaTeX), y `format: ctx => contenido` (o el rol como función) para lo que no cubra el diccionario; ninguno se
  hereda. Sin cambios en documentos existentes. `test/openings.typ`.
- **`page-style`** (`f34b727`): un `book` con `use-parts: false` no mostraba ninguna cabecera (solo una parte
  empezaba el documento); ahora la primera parte o capítulo lo empieza y el verso lleva el título del libro.
  `article` usa `"plain"` por defecto, como `report` (el folio se mueve 0.2 pt). `test/pagestyle_noparts.typ`.
- **Versalitas de `elegant`** (`32fe379`): documentado que dependen de la fuente (`smcp`); Typst no las
  sintetiza y no hay forma de detectarlo para avisar.

### Revisión de `essay`

- **`inner`/`outer` → `note-columns`** (`26daae1`), ver Validación.
- **Notas al pie con `notes: "footnote"`** (`9fdc9f5`): `@nota` da el número de la nota al pie, que cuenta
  también las corrientes. `test/essay_footnotes.typ`.
- **`verify` estricto** (`b6ac6c0`): `debug: (verify: "error")` resalta las marcas y hace fallar la compilación
  mientras quede alguna, con su página y su nota.
- **Desborde de notas** (`c3a6b1b`): cada columna cuyas notas aún no caben (en la última página, con `overflow:
  "none"` o sobre un bloque ancho) deja una marca `<glosa-overflow>` `(side:, notes:)`, y `debug-frame` la pinta
  de rojo. `test/essay_overflow.typ`, con y sin `carry`. Mover la nota que choca con un bloque ancho sigue en el
  TODO.

### Pruebas

- **Índice a cada `depth`** (`af07593`): `test/tocs_depth.typ` (1, 2, 3 y 2 sin partes) y su comprobación.
- **Fixtures de estructura de `report` y `article`** (`af07593`): `test/structure_report.typ` (`modern`, doble
  cara) y `test/structure_article.typ` (`page-style` y `heading-style` propios), con sus cabeceras comprobadas y
  referencia local. El de `essay` con notas desbordadas es `test/essay_overflow.typ` (`c3a6b1b`).
- **Enlaces a `demos/`** (`03223dd`): el README los enlaza en GitHub, porque `typst.toml` los deja fuera del
  paquete.

### Clases

- **Microtipografía en `report`, `article` y `essay`** (`81a29dc`, `e84481a`). Medida con un texto en español (12 párrafos,
  Libertinus), sin y con `microtype`: `report` 0 % de líneas con guion en los dos casos y la dispersión del
  espacio entre palabras de 0.45 a 0.26 pt; `article` a dos columnas, 13 % de guiones en los dos casos (en
  columnas estrechas el coste no los reduce) y dispersión de 1.04 a 0.84 pt; `essay`, de 0 a 12.5 % de guiones
  y una línea más por párrafo (las uniones de `glue`, «Greg L. Bahnsen», «p. 12», cuestan cortes en su columna
  de 102 mm) a cambio de una dispersión de 0.67 a 0.39 pt; `book`, de 6.2 a 0 % y de 0.78 a 0.68 pt. Se encontró
  un error de `glue` que afectaba a todas las clases: la raya de apertura de un inciso («texto —inciso») podía
  acabar línea y el inciso no podía empezarla. Corregido: la raya pegada a una palabra se une a ella, la de
  apertura a la palabra que sigue y la exenta («Réplica — Bahnsen») al espacio de antes, como hasta ahora;
  `test/microtype.typ` lo comprueba en columnas estrechas.

Los demos de `debate` se compararon con los del commit de partida (`9e58dae`): mismo texto y mismas páginas;
solo cambia un píxel de suavizado en algunas rayas.

### Imprenta

- **Número de páginas para la imprenta** (`9d0143d`): `book(page-multiple: 4)` añade páginas en blanco, sin
  cabecera ni folio, antes de la contraportada hasta que el total del PDF, cubiertas incluidas, sea múltiplo
  de 4 (o de lo que se pida). `test/page_multiple.typ`.
- **Cubierta trasera** (`5a01109`): ver Portada como diccionario.
- **`= Dedicatoria` en recto** (`72d339e`): un título de nivel parte en el front matter de un libro con partes
  abre en recto con `facing-pages`, como `#dedication`, el índice y los capítulos del front matter de un libro
  sin partes. Cambia el aspecto: `demo_book` ganó dos versos en blanco.

### Decisiones de esta ronda

- `frontmatter`/`mainmatter`/`backmatter` como nombres canónicos; los cortos quedan como alias obsoletos, no se
  quitan todavía, para no romper los libros reales al actualizar.
- `note`, `part` y `verify` se quedan con su nombre: son específicos y están documentados.
- `titlepage` (no `custom-titlepage`) es el nombre común; `article` no tiene portada, su bloque de título va sobre
  el texto.
- `equation-numbering` sí en `article` y `essay`, apagado por defecto.
- Los estados se renombraron a `dc-` en lugar de reducirse: los lee `tocs` sin la clase.
- `article` usa `page-style: "plain"`.
- El párrafo tras un título de sección no se sangra en `book` (consecuencia de usar el `sticky` de Typst, que no
  oscila); los capítulos siguen igual.
- `essay`: se mantienen los valores por defecto de la columna interior (15 mm) y de `top` y `header-ascent`
  aunque `chapter-numbering` sea `none`. Cambiarlos ensancharía el texto de todo ensayo ya revisado; quien no use
  la columna interior pone `note-columns: (inner: (width: 0mm))`.
- `page-multiple` cuenta todas las páginas del PDF, cubiertas incluidas, y solo existe en `book`.

## Decisiones tomadas

- `tocs` canónico, `margin` único con `facing-pages`, `report` con `plain`, `style` como tema común, `overflow:
  "carry"` por defecto.
- `debate` es una clase propia, no un modo de `book`; con `breaks: "turn"` solo los discursos abren página por turno.
- La versión (`0.1.0`) no es urgente: es de desarrollo, se sube cuando convenga.
