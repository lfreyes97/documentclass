# TODO

Estado al 2026-11-13. Lo ya hecho está en `HECHO.md`.
Meta: madurez del paquete antes de congelar la API. No hay libros cerrados, así que
los cambios incompatibles salen baratos ahora.

## Prioridad 1: `debate` (lo que queda)

La clase `debate`, el `quote-style`, el epígrafe global, la cita larga con comillas anidadas y los adornos están
hechos (ver `HECHO.md`). Queda, sobre todo, lo que enseñe el uso al maquetar el libro de Bahnsen:

- [ ] **Documentar `debate` en el README:** plantillas (`two-speakers`, `panel`, `interview`), `speakers`, `turn`,
      `segment` y `program`, marcas, `breaks`, `cite-turn`, índice de oradores y glosario, `cover`. Hoy el README
      no la menciona, y `typst.toml` tampoco (descripción y palabras clave).
- [ ] **Probar a fondo `debate`:** `facing-pages: true`, los temas `modern` y `elegant` más allá de la primera
      página, y `tableofcontents` con esta clase (compila, pero no se ha mirado el resultado).
- [ ] **Estilo de turno `elegant`** (el nombre en el margen, como un guion); hoy solo `classic` y `modern`.
- [ ] **Ajustar `exchange-kinds` y `breaks` por plantilla** según el uso: ahora los turnos de introducción,
      preguntas, contrainterrogatorio, ronda y tema van de corrido y los de apertura, réplica y conclusión abren
      página. `closing` sigue el orden de `speakers`; en muchos debates se invierte (hay que dar `program`).
- [ ] **Libro de Bahnsen:** decidir si la copia `Bahnsen-DebateSproul-debate.typ` (clase `debate`, 70 páginas)
      reemplaza al original (`book`, 80). Su lomo quedó en `spine-width(64)`; el original decía 176, sin que se
      sepa por qué. En `Iapocalipsis` el epígrafe de «Moloch…» sigue armado a mano y se puede pasar a `#epigraph`.
- [ ] **`essay` y `epigraph-page`:** `essay` no fija el estado de `facing-pages`, así que la página propia del
      epígrafe saltaría siempre a página impar.
- [ ] **Remate de capítulo automático:** `ornament` se escribe a mano al final del capítulo; no hay clave en
      `heading-style` que lo ponga solo.
- [ ] **Texto paralelo** original y traducción en dos columnas (opcional; hay un proyecto `translation-harness`
      en `Proyectos`).
- [ ] Pasar la cabecera propia de `debate` (título, oradores, portadilla) al **bloque común de título** cuando
      exista (ya existe en las cuatro clases; falta pasar `debate`, ver «API»).

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
- [ ] **Nombres genéricos de `debate` en la superficie pública:** `lib.typ` sigue exportando `at`, `turn`,
      `segment`, `crowd` y `gloss`, que chocan con `import "lib.typ": *` (la exportación del resto ya es explícita).

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
- [ ] **Pruebas de `debate`:** sus demos solo comprueban que compilen. Faltan aserciones sobre turnos, `program`,
      `cite-turn` y el índice de oradores. Las referencias de `test/reference/` no se versionan, así que el CI no
      compara texto ni posición de líneas de ningún documento.

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
