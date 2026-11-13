# TODO

Estado al 2026-11-12. Lo ya hecho está en `HECHO.md`.
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
      exista (ver «API»).

## API

Inconsistencias medidas sobre las firmas de `book`, `report`, `article` y `essay`.

- [ ] **Superficie pública explícita.** `lib.typ` hoy expone los módulos `matter`, `toc`, `tocs` y `glosa`, y
      nombres genéricos (`main`, `front`, `back`, `note`, `part`, `verify` y, de `debate`, `at`, `turn`,
      `segment`, `crowd`, `gloss`) que chocan con `import "lib.typ": *`. Exportar solo lo documentado.
- [ ] **Tabla "API estable / interna"** en el README, y reordenarlo: la sección de `essay` es un solo párrafo
      de opciones.
- [ ] **Bloque común de título** en las cuatro clases: `title`, `subtitle`, `author`, `date`, `publisher`. Hoy
      falta `subtitle` en `essay` y `publisher` en `article` y `essay`. Resuelve también que en
      `notes: "footnote"` el título de `essay` salga donde esté el `= …`, y debe preceder a los debates.
- [ ] **Familias de opciones como diccionario**, como ya son `fonts`, `microtype` y `minitoc`: falta el grupo de
      portada (`cover`, `back-cover`, `cover-data`, `cover-options`).
- [ ] **`essay.titlepage` vs `custom-titlepage`** (`book`, `report`): mismo concepto, dos nombres. Unificar.
- [ ] **`equation-numbering`** está solo en `book` y `report`. Decidir si va en `article` y `essay`.
- [ ] **Validación uniforme.** Toda opción de tipo diccionario falla con un mensaje que lista las claves válidas,
      como ya hacen `fonts`, `labels`, `microtype`, `margin`, `page-style`, `heading-style`, `line-numbers` y `debug`.
- [ ] **Estados con clave de texto** (`matter-section`, `appendix-mode`, `dc-*`) que `tocs` lee por nombre
      (`components/tocs/bridge.typ`): documentarlos como contrato o reducirlos.

## Estilos de títulos, cabeceras y pies

- [ ] **Títulos huérfanos:** `run-heading` no devuelve un bloque, así que un título de `book`, `report` o `article`
      puede quedar solo al final de la página. En `debate` los segmentos ya van en un bloque `sticky`; falta el
      código común (`components/headings.typ`).

- [ ] **`heading-style`:** títulos en línea con el párrafo (`run-in`, el `\paragraph` de LaTeX) y una función
      `ctx => contenido` para lo que no cubra el diccionario.
- [ ] **`page-style`:** decidir el valor por defecto de `article` (hoy ninguno), y revisar que `classic` no
      muestre cabecera con `use-parts: false` y sin `#part` (no hay primer nivel de parte; es lo que ya hacía `book`).
- [ ] Las versalitas de `elegant` dependen de la fuente: la Libertinus que Typst incluye las tiene, la que instala
      `instatypst` en esta máquina no. Documentarlo o avisar.

## Revisión de `essay`

El ensayo real ya está revisado y migrado (ver `HECHO.md`). Queda la clase:

- [ ] **Integrar `essay` al sistema común:** `page-style` (hoy usa `glosa.header`), `heading-style`
      (`chapter-number-style`, `chapter-title-style`, `section-numbering`) y `margin` en lugar de `top`,
      `bottom`, `inner` y `outer`; y notas al margen en `book`, `report` y `article` (hoy solo `essay`).
- [ ] Renombrar `inner` y `outer` (columnas de notas) a algo como `notes`, para no confundirlos con márgenes.
- [ ] Decidir si el ancho por defecto de la columna interior baja a 0, y si `top` y `header-ascent` por defecto
      son más compactos cuando `chapter-numbering` es `none`.
- [ ] **Desborde de notas:** una consulta (`<glosa-overflow>`) y una marca en `debug-frame` para las páginas que
      aún desbordan. Hoy solo se detecta el desborde por arriba: no se mueve una nota que choca con un bloque
      ancho (`wideblock`), y la última página no puede pasar notas.
- [ ] **`notes: "footnote"`:** los `@ref` a una nota imprimen el número de la nota, que puede no coincidir con el
      de la nota al pie si hay notas al pie corrientes mezcladas.
- [ ] **`verify`:** valorar un modo estricto (`debug: (verify: "error")`) para que la compilación final falle si
      queda alguna marca.
- [ ] El tiempo de compilación del ensayo pasó de 2.5 s a 5.7 s con `carry`: ver si se puede bajar.

### Restos de la migración del índice

- [ ] `Presup/_duplicados/debate_bahnsen_sproul.typ` (copia) sigue con el API antiguo y ya no compila.
- [ ] `chapter-label` de Warfield y Propaganda quedó como `label: "chapter"`; mirar a ojo que el aspecto es el
      deseado. Los índices extra de `Bahnsen-DebateSproul.typ` (`depth: 4`) también.

## Pruebas

- [ ] **Pruebas de `debate`:** sus demos solo comprueban que compilen. Faltan aserciones sobre turnos, `program`,
      `cite-turn` y el índice de oradores. Las referencias de `test/reference/` ya no se versionan, así que el CI
      no compara texto ni posición de líneas de ningún documento.

- [ ] Aserciones sobre las entradas del índice que aparecen a cada `depth` (hoy solo se comprobó a mano), en
      `test/structure.py`.
- [ ] Fixtures de estructura para `report` y `article` con `page-style` y `heading-style` (hoy solo `book` tiene
      fixture), y para `essay` con notas al margen desbordadas.
- [ ] Fixtures con las fuentes que no incluye Typst (`dropcaps`, `fonts_roles` salen con fallback).
- [ ] **README:** enlaza a `demos/`, pero `typst.toml` los excluye del paquete publicado.

## Clases y revisión pendiente

- [ ] **Microtipografía:** solo se midió en `book`. Revisar `report`, `article` (con `cols: 2`, columnas
      estrechas) y `essay` (notas al margen).
- [ ] **`tocs`:** solo se sabe que compila; probarlo a fondo.
- [ ] **Etiquetas traducidas** en pt, fr, de e it: no se verificó que estén bien.
- [ ] **Letras capitales:** no se examinaron por dentro (`glosa` sí, con el reparto de notas).

## Imprenta

- [ ] **Número par de páginas.** Opción para rellenar al final hasta un total par (o múltiplo de 4), que es lo
      que pide una imprenta. Hoy *Siempre Listos* sale con 321.
- [ ] **Cubierta trasera.** Una portada pasada como contenido (p. ej. `book-cover(front: ...)`) no genera
      contraportada; `back-cover` solo se rellena si `cover` es función.
- [ ] **`#dedication`** va en recto, pero un `= Dedicatoria` suelto usa salto simple. Decidir si el front matter
      debe tratarlo igual.

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
      empiezan en `†`.
