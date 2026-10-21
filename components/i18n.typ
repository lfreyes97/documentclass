// Etiquetas de la clase según el idioma del texto (`lang`).
// Un idioma sin traducción usa el inglés.
#let translations = (
  es: (
    part: "Parte",
    chapter: "Capítulo",
    appendix: "Apéndice",
    section: "Sección",
    contents: "Contenido",
    abstract: "Resumen",
    figures: "Lista de Figuras",
    tables: "Lista de Tablas",
  ),
  en: (
    part: "Part",
    chapter: "Chapter",
    appendix: "Appendix",
    section: "Section",
    contents: "Contents",
    abstract: "Abstract",
    figures: "List of Figures",
    tables: "List of Tables",
  ),
  pt: (
    part: "Parte",
    chapter: "Capítulo",
    appendix: "Apêndice",
    section: "Seção",
    contents: "Sumário",
    abstract: "Resumo",
    figures: "Lista de Figuras",
    tables: "Lista de Tabelas",
  ),
  fr: (
    part: "Partie",
    chapter: "Chapitre",
    appendix: "Annexe",
    section: "Section",
    contents: "Table des matières",
    abstract: "Résumé",
    figures: "Table des figures",
    tables: "Liste des tableaux",
  ),
  de: (
    part: "Teil",
    chapter: "Kapitel",
    appendix: "Anhang",
    section: "Abschnitt",
    contents: "Inhaltsverzeichnis",
    abstract: "Zusammenfassung",
    figures: "Abbildungsverzeichnis",
    tables: "Tabellenverzeichnis",
  ),
  it: (
    part: "Parte",
    chapter: "Capitolo",
    appendix: "Appendice",
    section: "Sezione",
    contents: "Indice",
    abstract: "Sommario",
    figures: "Elenco delle figure",
    tables: "Elenco delle tabelle",
  ),
)

// Etiquetas que el documento sobrescribe con el parámetro `labels` de la clase
#let overrides = state("dc-labels", (:))

#let check(labels) = {
  assert(
    type(labels) == dictionary,
    message: "labels debe ser un diccionario, p. ej. `labels: (chapter: \"Lección\")`",
  )
  let known = translations.en.keys()
  for key in labels.keys() {
    assert(
      key in known,
      message: "labels: etiqueta desconocida «" + key + "». Etiquetas válidas: " + known.join(", "),
    )
  }
}

// Etiqueta como texto plano (requiere `context`)
#let get(key) = {
  let base = translations.at(text.lang, default: translations.en)
  overrides.get().at(key, default: base.at(key))
}

// Etiqueta en el idioma del texto donde se coloca
#let term(key) = context get(key)

// Título por defecto (`auto`) de un componente: la etiqueta traducida
#let title-or(title, key) = if title == auto { term(key) } else { title }
