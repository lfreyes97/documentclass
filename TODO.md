# TODO

Estado al 2026-11-13. Lo ya hecho está en `HECHO.md`.
Meta: madurez del paquete antes de congelar la API. No hay libros cerrados, así que
los cambios incompatibles salen baratos ahora.

## Prioridad 1: plantillas de debates

Hoy los debates (`Presup/bahnsen-debate/Bahnsen-DebateSproul.typ`, unas 2.000 líneas) usan `book` y todo se
resuelve a mano. Lo que ese libro hace, y lo que le falta:

- Los turnos son `*Sproul:*` escritos a mano: 120 etiquetas (Sproul 44, Bahnsen 38, Dewitt 16, el resto "Hombre
  no identificado", "Miembro del público"…). Entre ellas hay dos que no son oradores (`*Sola Scriptura:*`,
  `*Revelación mediata / inmediata:*`), así que nada distingue un turno de otra etiqueta en negrita. No hay
  estilo ni orden común.
- Las divisiones del debate (`= Presentaciones iniciales`, `= Período de preguntas`) son partes de `book`, con
  página de parte y capítulos "CAPÍTULO N" que en un debate de 80 páginas sobran. Las reacciones del público van
  como texto entre paréntesis.
- Los datos del debate (rival, serie original, grabación, transcripción) viven en la portada de `coverbook`
  (`bahnsen-cover`), no en la clase.

Una clase `debate` con plantillas (formatos de debate: dos oradores con moderador, mesa redonda, entrevista) y,
por dentro, estas piezas:

- [x] **Diseño y fixture.** Extraer un fragmento del libro actual (30–50 turnos, con una interrupción, una
      reacción del público y una pregunta) como demo y prueba, antes de escribir la clase.
- [x] **Turnos como elemento.** `#turn[Sproul][...]` (o `#speaker`), con los oradores declarados en la clase:
      `speakers: (bahnsen: (name:, short:, role:), ...)`. Estilo uniforme del nombre, turno que continúa tras una
      interrupción sin repetir la etiqueta, y oradores no identificados o del público como casos propios.
- [x] **Estructura del debate.** Segmentos con nombre (presentación, réplica, contrainterrogatorio, preguntas del
      público, conclusión), cada uno con su orador y su tiempo, y encabezados ligeros: sin página de parte ni
      apertura de capítulo (un `heading-style` propio). Hecho: `segment`, las plantillas `two-speakers`, `panel` e
      `interview` y su validación. `heading-style` propio: la clase `debate` tiene el rol `segment` (entre `section` y `subsection`) en los tres
      temas. `#segment()` sin tipo abre el siguiente de `program` (por defecto el de la
      plantilla, con los oradores en el orden de `speakers`; los tiempos se dan en `program`).
- [x] **Marcas de la transcripción.** Reacciones del público, `[inaudible]`, interrupciones, códigos de tiempo
      opcionales (`#at("12:30")`) y notas del traductor distintas de las notas del editor.
      Hecho: `crowd`, `inaudible`, `at` y `tnote`, con `marks:` para quitarlas o mostrar los tiempos; una
      interrupción es un `turn` con `cont: true`, sin marca propia.
- [x] **Datos del debate en la clase:** proposición o tema, oradores, moderador, lugar, fecha, título y serie
      originales, y una portadilla "A frente a B". Depende del bloque común de título.
      Hecho: `venue`, `original: (title:, series:, recording:, transcript:)`, el moderador (`moderator: true`) y
      `titlepage: true` para la portadilla; la cabecera es propia de `debate` hasta que exista el bloque común.
- [x] **Cabecera con el segmento actual o el orador:** `page-style` necesita `speaker` y `segment` en `ctx`.
      Hecho: `ctx.segment`, `ctx.speaker` y `ctx.speakers` (los que hablan en la página) y la variante
      `running-segment`, que es la de `debate` por defecto.
- [x] **Líneas numeradas para citar** ("Bahnsen, p. 12, l. 4"): ya existe `line-numbers`; falta fijar cómo se
      cita y que el número de línea sea estable.
      Hecho: `turn(id:)` y `cite-turn("id")` dan «Bahnsen, Pág. 3, l. 16», calculado al compilar (la línea sale de
      las marcas `<dc-line>` que deja `lines.setup(track: true)`, porque `counter(par.line)` siempre vale 0). La cita
      impresa solo vale para una edición: cambiar papel, márgenes o fuente mueve las líneas.
- [x] **Índice de oradores** y **glosario** (el libro actual ya termina con `= Glosario`, hoy a mano).
      Hecho: `speakers-index()` (páginas por orador, con tramos) y `glossary(entradas)` con `gloss("clave")[…]` para
      marcar los términos y sus páginas; orden alfabético sin tildes por defecto.
      Saltos de página: `breaks` ("turn", "segment", "section", none; por plantilla, hoy "turn" en las tres) y
      `start` en `heading-style`. En los segmentos de intercambio (introducción, preguntas, contrainterrogatorio, ronda, tema)
      los turnos van de corrido; solo los discursos (apertura, réplica, conclusión) abren página.
- [ ] **Texto paralelo** original y traducción en dos columnas (opcional; hay un proyecto `translation-harness`
      en `Proyectos`).
- [ ] Diseñarla sobre el sistema común de temas (`style`), cabeceras, aperturas y el bloque común de título, no
      como una copia de `book`.

## Prioridad 2: citas, epígrafes y adornos

Hoy hay `epigraph`, `blockquote` y `verse` (`components/environments.typ`), sin estilos ni integración con los
temas, y el `part-ornament` es contenido suelto. Nada de esto sigue `style`.

- [ ] **Estilos de cita con los temas** (`classic`, `modern`, `elegant`): un parámetro como `quote-style` o que
      cuelguen de `style`, para `epigraph`, `blockquote` y `verse`, con el mismo mecanismo de preajuste y
      diccionario que `heading-style`.
- [ ] **Epígrafe como componente global**, en todas las clases: posición (apertura de capítulo, inicio de sección,
      página propia del libro), formato de la atribución (— Autor, *Obra*, año), alineación con la columna en
      `essay`, varios epígrafes seguidos. El de `essay` que hoy se arma a mano (bloque al 78 %, cursiva de
      9.5 pt, atribución a la derecha) sería su `classic`.
- [ ] **Cita larga** (`blockquote`): sangría, filete lateral, comillas, atribución con fuente; integrar con el
      `quote` nativo de Typst (`show quote.where(block: true)`).
- [ ] **Comillas anidadas** en español: la cita interna con “…” dentro de «…» sin escribirla a mano.
- [ ] **Adornos:** separadores de sección (`#ornament()`: asterismo ⁂, florón ❦, filete con glifo central),
      remate de capítulo, presets para `part-ornament`, y su relación con la clave `ornament` de `heading-style`.
- [ ] Revisar cómo se llevan con las capitulares (`dropcap`, `ornate-dropcap`), que ya existen.

## API

La ronda de API está en `HECHO.md`. Queda:

- [ ] **`debate` y las piezas comunes nuevas.** `debate` sigue con `cover`, `back-cover`, `cover-data` y
      `cover-options` sueltos (`book` ya usa `cover: (front:, back:, data:, options:)`, en
      `components/covers.typ`) y con su propio `titlepage: true/false` (las demás clases usan
      `titlepage-mod.choose`). No se tocó porque `debate` quedaba fuera de esta ronda: pasarla a las dos
      piezas al trabajar la clase.
- [ ] **Título de `essay` con `notes: "footnote"`.** Sigue saliendo donde esté el `= …`: en el ensayo el título
      es su heading de nivel 1, no `title`. Decidir si `title` pone un bloque de título al principio, como en
      `article`; cambia cómo se escribe un ensayo, así que no se hizo sin decidirlo.

## Revisión de `essay`

- [ ] **Integrar `essay` al sistema común:** `page-style` (hoy usa `glosa.header`), `heading-style`
      (`chapter-number-style`, `chapter-title-style`, `section-numbering`) y `margin` en lugar de `top`,
      `bottom` y `note-columns`; y notas al margen en `book`, `report` y `article` (hoy solo `essay`). No se
      empezó: la cabecera y el título del ensayo son de glosa (título en la cabecera, índice de secciones en
      el margen) y no caben en los preajustes de `page-style` y `heading-style` sin nuevos roles; y las notas
      al margen en las otras clases piden que glosa conviva con sus márgenes y cabeceras. Es una ronda propia.
- [ ] **Notas que chocan con un bloque ancho.** Ya se detectan (`<glosa-overflow>`, marca roja en
      `debug-frame`), pero no se mueven: el reparto (`_fit-page`) solo saca las que desbordan por arriba.
- [ ] El tiempo de compilación del ensayo pasó de 2.5 s a 5.7 s con `carry`: ver si se puede bajar. Pista:
      `_draw-carried` y cada nota rehacen `_carry-layout` desde la página 1 (coste cuadrático en páginas); se
      podría guardar el reparto en un estado. No se midió: el ensayo real está fuera del repositorio.

### Restos de la migración del índice

- [ ] `Presup/_duplicados/debate_bahnsen_sproul.typ` (copia) sigue con el API antiguo y ya no compila.
- [ ] `chapter-label` de Warfield y Propaganda quedó como `label: "chapter"`; mirar a ojo que el aspecto es el
      deseado. Los índices extra de `Bahnsen-DebateSproul.typ` (`depth: 4`) también.
- [ ] Al actualizar los libros reales a esta ronda: `front`/`main`/`back` siguen valiendo (obsoletos),
      pero `custom-titlepage`, `back-cover`, `cover-data`, `cover-options` y el `inner`/`outer` de `essay`
      fallan con un mensaje que dice la forma nueva.

## Pruebas

- [ ] Fixtures con las fuentes que no incluye Typst (`dropcaps`, `fonts_roles` salen con fallback). Pide meter
      las fuentes (OFL) en el repositorio y compilar con `--font-path`, o una referencia que solo se compare en
      la máquina que las tiene.

## Clases y revisión pendiente

- [ ] **`tocs`:** ya se comprueban las entradas a cada `depth` (`test/tocs_depth.typ`); falta lo demás:
      `minitoc` con `scope`, `list-of` con otros tipos de figura, `add-entry`, `short`/`omit` y los estilos.
- [ ] **Etiquetas traducidas** en pt, fr, de e it: no se verificó que estén bien (pide alguien que las lea).
- [ ] **Letras capitales:** no se examinaron por dentro (`glosa` sí, con el reparto de notas).

## Al final

Esto solo tiene sentido cuando la API esté estable; hacerlo antes obliga a repetirlo.

- [ ] **CI:** subir los commits a GitHub y ver correr `.github/workflows/test.yml`, que nunca se ha ejecutado allí.
      Las referencias de `test/reference/` ya no se versionan, así que el CI salta esa comparación.
- [ ] **Changelog** y **etiquetas de versión** (sin urgencia: es una versión de desarrollo, se sube cuando
      convenga; subir obliga a renombrar el enlace simbólico `@local/documentclass:0.1.0` o a cambiar los
      imports). `HECHO.md` es la base. Cambios incompatibles desde `0.1.0`: `logo`, `part-ornament` y
      `custom-titlepage` ahora son contenido; `fonts` sustituyó a las fuentes sueltas; `microtype` y `facing-pages`
      cambian la maquetación por defecto; `margin-inside`, `margin-outside`, `margin-x` y `margin-y` son `margin`;
      `book` en `essay` es `facing-pages`; `outer`/`minimal` de `page-style` son `running-outer`/`folio-outer`;
      `heading-style` sustituye a `h1-size`…; el `date` de `essay` es `none`; las notas al pie de `essay`
      empiezan en `†`; y los de la ronda de API (ver `HECHO.md`, «Ronda de API, estilos e imprenta»).
