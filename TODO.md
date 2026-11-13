# TODO

Estado al 2026-11-12. Lo ya hecho está en `HECHO.md`.
Meta: madurez del paquete antes de congelar la API. No hay libros cerrados, así que
los cambios incompatibles salen baratos ahora.

## API

Inconsistencias medidas sobre las firmas de `book`, `report`, `article` y `essay`.

- [ ] **Familias de opciones como diccionario**, como ya son `fonts`, `microtype` y `minitoc`: falta el grupo
      de portada (`cover`, `back-cover`, `cover-data`, `cover-options`).
- [ ] **Bloque común de título** en las cuatro clases: `title`, `subtitle`, `author`, `date`, `publisher`.
      Hoy falta `subtitle` en `essay` y `publisher` en `article` y `essay`. Lo exclusivo de una clase
      se documenta como tal.
- [ ] **`essay.titlepage` vs `custom-titlepage`** (`book`, `report`): mismo concepto, dos nombres.
      Unificar (no revisé cómo funciona el de `essay`).
- [ ] **`equation-numbering`** está solo en `book` y `report`. Decidir si va en `article` y `essay`.
- [ ] **Superficie pública explícita.** `lib.typ` hoy expone los módulos `matter`, `toc`, `tocs` y
      `glosa`, y nombres genéricos (`main`, `front`, `back`, `note`, `part`) que chocan con
      `import "lib.typ": *`. Exportar solo lo documentado.
- [ ] **Tabla "API estable / interna"** en el README.
- [ ] **Validación uniforme.** Toda opción de tipo diccionario falla con un mensaje que lista las
      claves válidas, como ya hacen `fonts`, `labels`, `microtype`, `margin`, `page-style` y `heading-style`.
- [ ] **Estados con clave de texto** (`matter-section`, `appendix-mode`, `dc-*`) que `tocs` lee por
      nombre (`components/tocs/bridge.typ`): documentarlos como contrato o reducirlos.

### Restos de la migración del índice

- [ ] `Presup/_duplicados/debate_bahnsen_sproul.typ` (copia) sigue con el API antiguo y ya no compila.
- [ ] `chapter-label` de Warfield y Propaganda quedó como `label: "chapter"`; mirar a ojo que el
      aspecto es el deseado. Los índices extra de `Bahnsen-DebateSproul.typ` (`depth: 4`) también.

## Estilos de títulos, cabeceras y pies

- [ ] **`heading-style`:** títulos en línea con el párrafo (`run-in`, el `\paragraph` de LaTeX) y una
      función `ctx => contenido` para lo que no cubra el diccionario.
- [ ] **`page-style`:** decidir el valor por defecto de `article` (hoy ninguno), y revisar que
      `classic` no muestre cabecera con `use-parts: false` y sin `#part` (no hay primer nivel de
      parte; es lo que ya hacía `book`).
- [ ] Las versalitas de `elegant` dependen de la fuente: la Libertinus que Typst incluye las tiene, la
      que instala `instatypst` en esta máquina no. Documentarlo o avisar.

## Revisión de `essay`

El ensayo real ya está revisado (ver `HECHO.md`). Queda la clase:

- [ ] **Integrar `essay` al sistema común.** Evaluar qué de `essay` y de `glosa` puede pasar al paquete
      y qué aporta al sistema global:
  - notas al margen en `book`, `report` y `article` (hoy solo `essay`);
  - `page-style` en `essay` (usa `glosa.header`, con su propia cabecera);
  - `heading-style` en `essay` (`chapter-number-style`, `chapter-title-style`, `section-numbering`);
  - `margin` en lugar de `top`, `bottom`, `inner` y `outer`.
- [ ] Renombrar `inner` y `outer` (columnas de notas) a algo como `notes`, para no confundirlos
      con márgenes.
- [ ] Decidir si el ancho por defecto de la columna interior baja a 0, y si `top` y `header-ascent`
      por defecto son más compactos cuando `chapter-numbering` es `none` (el título ya no lleva un
      numeral de 60 pt, y 32 mm + 11 pt de margen superior sobra).
- [ ] **Desborde de notas:** una consulta (`typst query … '<glosa-overflow>'`) y una marca en `debug-frame`
      para las páginas que aún desbordan. Hoy solo se detecta el desborde por arriba: no se mueve una
      nota que choca con un bloque ancho (`wideblock`), y la última página no puede pasar notas.
- [ ] **`notes: "footnote"`:** en este modo el título del ensayo se imprime en el cuerpo, donde esté el `= …`, así que si
      va después de un bloque de autor se ve al revés; resolverlo con el bloque común de título. Los `@ref` a una nota
      imprimen el número de la nota, que puede no coincidir con el de la nota al pie si hay notas al pie corrientes.
- [ ] El tiempo de compilación del ensayo pasó de 2.5 s a 5.7 s con `carry`: ver si se puede bajar.

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
      aperturas de capítulo y sobre el bloque común de título, no como una copia de `book`.
      Una demo con un extracto del libro actual haría de prueba.

## Pruebas, CI y versión

- [ ] Aserciones sobre las entradas del índice que aparecen a cada `depth` (hoy solo se comprobó
      a mano), en `test/structure.py`.
- [ ] Fixtures de estructura para `report` y `article` con `page-style` y `heading-style` (hoy solo
      `book` tiene fixture), y para `essay` con notas al margen desbordadas.
- [ ] Fixtures con las fuentes que no incluye Typst (`dropcaps`, `fonts_roles` salen con fallback).
- [ ] El CI (`.github/workflows/test.yml`) no se ha visto correr en GitHub; las referencias pueden
      diferir si la versión de `pdftotext` del runner da otro texto.
- [ ] **Changelog** y **etiquetas de versión** (sin urgencia: es una versión de desarrollo, se sube
      cuando convenga; subir obliga a renombrar el enlace simbólico `@local/documentclass:0.1.0` o a
      cambiar los imports). `HECHO.md` es la base. Cambios incompatibles desde `0.1.0`: `logo`,
      `part-ornament` y `custom-titlepage` ahora son contenido; `fonts` sustituyó a las fuentes
      sueltas; `microtype` y `facing-pages` cambian la maquetación por defecto; `margin-inside`,
      `margin-outside`, `margin-x` y `margin-y` son `margin`; `book` en `essay` es `facing-pages`;
      `outer`/`minimal` de `page-style` son `running-outer`/`folio-outer`; `heading-style` sustituye
      a `h1-size`…; el `date` de `essay` es `none`; las notas al pie de `essay` empiezan en `†`.
- [ ] **README:** enlaza a `demos/`, pero `typst.toml` los excluye del paquete publicado.

## Clases y revisión pendiente

- [ ] **Microtipografía:** solo se midió en `book`. Revisar `report`, `article` (con
      `cols: 2`, columnas estrechas) y `essay` (notas al margen).
- [ ] **`tocs`:** solo se sabe que compila; probarlo a fondo.
- [ ] **Etiquetas traducidas** en pt, fr, de e it: no se verificó que estén bien.
- [ ] **Letras capitales:** no se examinaron por dentro (`glosa` sí, con el reparto de notas).

## Imprenta

- [ ] **Cubierta trasera.** Una portada pasada como contenido (p. ej. `book-cover(front:
      ...)`) no genera contraportada; `back-cover` solo se rellena si `cover` es función.
- [ ] **Número par de páginas.** Opción para rellenar al final hasta un total par (o
      múltiplo de 4), que es lo que pide una imprenta. Hoy *Siempre Listos* sale con 321.
- [ ] **`#dedication`** va en recto, pero un `= Dedicatoria` suelto usa salto simple.
      Decidir si el front matter debe tratarlo igual.
