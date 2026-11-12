# TODO

Estado al 2026-11-12, tras los commits `ea6d924` (márgenes), `45a3bd9`, `643fa19` y `3c198b8`
(`page-style`).
Meta: madurez del paquete antes de congelar la API. No hay libros cerrados, así que
los cambios incompatibles salen baratos ahora.

## Decisiones abiertas

- [x] **Márgenes.** Decidido: un único `margin` (`auto`, longitud o diccionario) y
      `facing-pages` como el `twoside` de LaTeX. Ver "Estabilizar la API".
- [x] **Índice.** Decidido: la API de `tocs` es la canónica. `tableofcontents`,
      `minitoc`, `listoffigures` y `listoftables` se conservan como nombres (son los de
      LaTeX y los que usan los libros) pero pasan a ser `tocs`. Plan en "Estabilizar la API".
- [x] **`report` y `page-style`.** Decidido: `report` usa `page-style: "plain"` (solo el
      folio) y el estilo de párrafo y las marcas de `layout.setup`, como `book`. Sus títulos
      van en bloque para que el primer párrafo no se sangre. Cambia respecto a antes: los
      párrafos llevan sangría y el interlineado es el de `book`.

## Estabilizar la API

Inconsistencias medidas sobre las firmas de `book`, `report`, `article` y `essay`.

- [x] **Márgenes unificados.** `margin` y `facing-pages` en `book`, `report` y `article`
      (`components/margins.typ`, `test/margins.typ`). Con `facing-pages: true` el margen es
      `inside`/`outside`; con `false`, `x` o `left`/`right`; lo no indicado conserva el valor
      de la clase y una clave del tipo equivocado falla con mensaje. `facing-pages` es `true`
      en `book` y `false` en `report` y `article` (`report` pasa de márgenes alternos a
      simétricos). En `essay`, `book` se renombró a `facing-pages`.
  - **Falta:** en `essay`, renombrar `inner` y `outer` (columnas de notas) a algo como
    `notes`. En `report` y `article`, `facing-pages` cambia los márgenes y, si se activa
    `page-style`, alterna cabeceras y pies (`odd`/`even`).
- [ ] **Familias de opciones como diccionario**, como ya son `fonts`, `microtype` y
      ahora `minitoc`: falta el grupo de portada (`cover`, `back-cover`, `cover-data`,
      `cover-options`).
- [ ] **Bloque común de título** en las cuatro clases: `title`, `subtitle`, `author`,
      `date`, `publisher`. Hoy falta `subtitle` en `essay` y `publisher` en `article` y
      `essay`. Lo exclusivo de una clase se documenta como tal.
- [ ] **`essay.titlepage` vs `custom-titlepage`** (`book`, `report`): mismo concepto,
      dos nombres. Unificar (no revisé cómo funciona el de `essay`).
- [ ] **`essay.book`** (booleano que alterna columnas de notas): nombre poco claro y
      distinto de `facing-pages`. Renombrar.
- [ ] **`equation-numbering`** está solo en `book` y `report`. Decidir si va en
      `article` y `essay`.
- [x] **Un solo índice: `tocs` canónico.** Hecho:
  - `tableofcontents`, `minitoc`, `listoffigures`, `listoftables` y `listoflistings` son
    las funciones de `tocs`; se eliminaron `components/toc.typ`, `components/minitoc.typ` y
    las listas de `matter.typ`.
  - `book(minitoc: ...)` acepta `false`, `true` o un diccionario de opciones de
    `tocs.partial`; desaparecieron los cinco `minitoc-*` sueltos. Por defecto: capítulos,
    sin número, en peso normal y con puntos. `tocs` ganó la clave de estilo `number`
    (`false` oculta número y etiqueta).
  - `depth` cuenta los niveles bajo las partes. Un `depth` antiguo con partes equivale a
    ese valor menos 1; sin partes (`use-parts: false`) es igual.
  - Una opción antigua falla con un mensaje que dice su forma nueva (`h1-font`, `h2-font`,
    `h3-font`, `chapter-label`, `nest-indent`, `indent`, `chapter-gap`, `numbering`).
  - Con `facing-pages: false` el título del índice (un encabezado de nivel capítulo) ya no
    fuerza una página impar en el front matter.
  - Migrados y verificados contra sus PDFs anteriores (mismas palabras en el índice):
    `Presup/siempre-listos/main.typ`, `Bahnsen-DebateSproul.typ`, `Defendiendo la fe.typ`,
    `Warfield-Vol1.typ` y `Propaganda/espanol/main.typ` y `main-a5.typ`.
  - **Falta:** `Presup/_duplicados/debate_bahnsen_sproul.typ` (copia) sigue con el API
    antiguo y ya no compila. `chapter-label` de Warfield y Propaganda quedó como
    `label: "chapter"`; mirar a ojo que el aspecto es el deseado. Los índices extra
    de `Bahnsen-DebateSproul.typ` (`depth: 4`) también.
  - Falta una prueba con aserciones sobre las entradas que aparecen a cada `depth` (hoy solo
    se comprobó a mano); entra en el script de estructura de "Pruebas, CI y versión".
- [ ] **Superficie pública explícita.** `lib.typ` hoy expone los módulos `matter`,
      `toc`, `tocs` y `glosa`, y nombres genéricos (`main`, `front`, `back`, `note`,
      `part`) que chocan con `import "lib.typ": *`. Exportar solo lo documentado.
- [ ] **Tabla "API estable / interna"** en el README.
- [ ] **Validación uniforme.** Toda opción de tipo diccionario falla con un mensaje que
      lista las claves válidas, como ya hacen `fonts`, `labels` y `microtype`.
- [ ] **Estados con clave de texto** (`matter-section`, `appendix-mode`, `dc-*`) que
      `tocs` lee por nombre (`components/tocs/bridge.typ`): documentarlos como contrato
      o reducirlos.

## Cabeceras, pies y aperturas de capítulo (equivalentes a fancyhdr y fncychap)

Cabeceras y pies ya se configuran con `page-style` (ver abajo). Las aperturas siguen sin
configuración; conviene diseñarlas antes de congelar la API, porque añaden parámetros nuevos.

- [x] **Aperturas de capítulo y de parte: `heading-style`** en `book` (primera versión,
      `components/openings.typ`, `test/openings.typ`). Preajustes `classic` (idéntico al
      anterior: comprobado píxel a píxel y con las referencias de `test/structure.py`),
      `modern` y `elegant`; diccionario por rol (`part`, `chapter`, `section`, `subsection`,
      `subsubsection`, `paragraph`, con alias `h1`…`h6`). Las aperturas tienen variantes `front`,
      `back` y `appendix`; las secciones heredan del rol anterior y la primera del cuerpo. Las
      claves viejas `h1-size`…`h4-smallcaps` de `headings.setup` desaparecieron. `scale`
      agranda a la vez todos los tamaños según cuánto sobresalen del cuerpo. Los niveles 5 y
      6 de `book` ya no usan el estilo por defecto de Typst, sino los de `heading-style`.
  - `report` y `article` usan `heading-style` con preajustes por clase (`classic` idéntico al
    anterior, comprobado píxel a píxel; `modern` y `elegant` derivados de los de `book`). Sus
    tamaños de `classic` son los de un cuerpo de 11 pt, escritos en `em`, así que ahora siguen
    `font-size`; antes eran en pt.
  - **Falta:** títulos en línea con el párrafo (`run-in`, el `\paragraph` de LaTeX), una función
    `ctx => contenido` para lo que no cubra el diccionario, y la apertura de `essay`
    (queda para su revisión).
  - Las versalitas de `elegant` dependen de la fuente: la Libertinus que Typst incluye las
    tiene, la que instala `instatypst` en esta máquina no.
- [x] **Cabeceras y pies: `page-style`** (primera versión, `components/pagestyle.typ`,
      `test/pagestyle.typ`). Preajuste `"classic"` (lo que hacía `book`, con páginas idénticas
      a las de antes), diccionario `header`/`footer` con `left`/`center`/`right`, `odd`/`even`,
      `rule`, `text` y `when`, y funciones `ctx => contenido` con `part`, `chapter`, `section`,
      `folio`, `title`, `author`… `book` usa `classic`; `report` y `article` aceptan
      `page-style`; en `report` es `"plain"` y en `article` `none`. `layout.setup` quedó solo con el
      estilo de párrafo y las marcas de salto.
  - Preajustes: `classic`, `modern` y `elegant` (temas, compartidos con `heading-style` y `tocs`) y las
    variantes `plain`, `folio-outer` y `running-outer`, solo de `page-style`. El parámetro `style`
    de las clases aplica un tema a las tres partes (`components/themes.typ`, `test/themes.typ`);
    `demos/demo_pagestyle.typ`). Las
    aperturas y el formato del folio no necesitaron claves propias: salen de `ctx.opening` y
    de las funciones de cada espacio.
  - **Falta:** probar `page-style` en `essay` (usa el motor de `glosa`, con su propia
    cabecera) y decidir el valor por defecto de `article`.
  - Con `use-parts: false` y sin `#part`, `classic` no muestra cabecera (no hay primer nivel
    de parte); es lo que ya hacía `book`. Revisar si debe mostrarla.

## Revisión de `essay`

- [ ] **Revisar `essay` como clase.** Se hará más adelante, con cambios propios del
      usuario. Objetivo: evaluar qué de `essay` y de `glosa` puede integrarse al paquete
      común (notas al margen en otras clases, cabecera con el título del ensayo, aperturas
      con índice de secciones en el margen, `chapter-number-style`/`chapter-title-style`) y
      qué aporta al sistema global (`page-style`, bloque común de título, aperturas).
      Quedan pendientes aquí: renombrar `inner`/`outer` a `notes`, `titlepage`,
      `subtitle`/`publisher`, `page-style` y la revisión a tamaño real.

## Clase para debates

Hoy los debates (`Presup/bahnsen-debate/Bahnsen-DebateSproul.typ`, unas 2.000 líneas) usan
`book` y todo se resuelve a mano. Lo que ese libro hace, y lo que le falta:

- Los turnos son `*Sproul:*` escritos a mano: 120 etiquetas (Sproul 44, Bahnsen 38,
  Dewitt 16, el resto "Hombre no identificado", "Miembro del público"…). Entre ellas hay dos
  que no son oradores (`*Sola Scriptura:*`, `*Revelación mediata / inmediata:*`), así que
  nada distingue un turno de otra etiqueta en negrita. No hay estilo ni orden común.
- Las divisiones del debate (`= Presentaciones iniciales`, `= Período de preguntas`) son
  partes de `book`, con página de parte y capítulos "CAPÍTULO N" que en un debate de 80
  páginas sobran. Las reacciones del público van como texto entre paréntesis.
- Los datos del debate (rival, serie original, grabación, transcripción) viven en la
  portada de `coverbook` (`bahnsen-cover`), no en la clase.

Ideas, sin decidir:

- [ ] **Turnos como elemento.** `#turn[Sproul][...]` (o `#speaker`), con los oradores
      declarados en la clase: `speakers: (bahnsen: (name:, short:, role:), ...)`. Estilo
      uniforme del nombre, turno que continúa tras una interrupción sin repetir la etiqueta,
      y oradores no identificados o del público como casos propios.
- [ ] **Estructura del debate.** Segmentos con nombre (presentación, réplica, contrainterrogatorio,
      preguntas del público, conclusión), cada uno con su orador y su tiempo, y encabezados
      ligeros: sin página de parte ni apertura de capítulo.
- [ ] **Marcas de la transcripción.** Reacciones del público, `[inaudible]`, interrupciones,
      códigos de tiempo opcionales (`#at("12:30")`) y notas del traductor distintas de las
      notas del editor.
- [ ] **Líneas o párrafos numerados** para citar ("Bahnsen, p. 12, l. 4"), opcional
      (`par.line` de Typst).
- [ ] **Datos del debate en la clase:** proposición o tema, oradores, moderador, lugar,
      fecha, título y serie originales, y una portadilla "A frente a B".
- [ ] **Cabecera** con el segmento actual o el orador; **índice de oradores** y
      **glosario** (el libro actual ya termina con `= Glosario`, hoy a mano).
- [ ] **Texto paralelo** original y traducción en dos columnas (opcional; hay un proyecto
      `translation-harness` en `Proyectos`).
- [ ] **Dependencias.** Conviene diseñarla sobre el sistema común de cabeceras, pies y
      aperturas de capítulo y sobre el bloque común de título (secciones de arriba), no
      como una copia de `book`. Una demo con un extracto del libro actual haría de prueba.

## Pruebas, CI y versión

- [x] **Pruebas que verifiquen estructura.** `test/structure.py`: compila todo y revisa
      páginas con solo folio, orden de folios, solape de líneas, cabeceras y páginas en
      blanco de `test/structure_book.typ`, y el texto y la posición de las líneas de seis
      archivos contra `test/reference/`. Comprobado que detecta una cabecera invertida,
      folios en páginas en blanco, líneas solapadas y un cambio de interlineado.
  - **Falta:** aserciones sobre las entradas del índice a cada `depth` (pendiente de `tocs`),
    pruebas de `report` y `article` con `page-style` (hoy solo `book` tiene fixture de
    estructura) y fixtures con las fuentes que no incluye Typst (`dropcaps`, `fonts_roles`
    salen con fallback).
  - No he visto el CI correr: el workflow está sin probar en GitHub, y las referencias pueden
    diferir si la versión de `pdftotext` del runner da otro texto.
- [x] **CI** (`.github/workflows/test.yml`) ejecuta ese script con Typst 0.15.1.
- [ ] **Changelog** y **etiquetas de versión** (sin urgencia: es una versión de desarrollo,
      se sube cuando convenga; subir obliga a renombrar el enlace simbólico
      `@local/documentclass:0.1.0` o a cambiar los imports). Cambios incompatibles desde `0.1.0`:
      `logo`, `part-ornament` y `custom-titlepage` ahora son contenido; `fonts` sustituyó a
      las fuentes sueltas; `microtype` y `facing-pages` cambian la maquetación por defecto.
- [ ] **README:** enlaza a `demos/`, pero `typst.toml` los excluye del paquete publicado.

## Clases y revisión pendiente

- [ ] **Microtipografía:** solo se midió en `book`. Revisar `report`, `article` (con
      `cols: 2`, columnas estrechas) y `essay` (notas al margen).
- [ ] **`essay`:** nunca se vio a tamaño real. En una miniatura el texto parecía llegar
      muy pegado a la columna de notas.
- [ ] **`tocs`:** solo se sabe que compila; probarlo a fondo.
- [ ] **Etiquetas traducidas** en pt, fr, de e it: no se verificó que estén bien.
- [ ] **`glosa` y letras capitales:** no se examinaron por dentro.

## Imprenta

- [ ] **Cubierta trasera.** Una portada pasada como contenido (p. ej. `book-cover(front:
      ...)`) no genera contraportada; `back-cover` solo se rellena si `cover` es función.
- [ ] **Número par de páginas.** Opción para rellenar al final hasta un total par (o
      múltiplo de 4), que es lo que pide una imprenta. Hoy *Siempre Listos* sale con 321.
- [ ] **`#dedication`** va en recto, pero un `= Dedicatoria` suelto usa salto simple.
      Decidir si el front matter debe tratarlo igual.
