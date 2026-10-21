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
    note: "nota",
    page: "Pág.",
    of: "de",
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
    note: "note",
    page: "Page",
    of: "of",
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
    note: "nota",
    page: "Pág.",
    of: "de",
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
    note: "note",
    page: "Page",
    of: "sur",
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
    note: "Anmerkung",
    page: "Seite",
    of: "von",
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
    note: "nota",
    page: "Pag.",
    of: "di",
  ),
)

// Nombres de los meses y orden de la fecha, por idioma
#let months = (
  es: ("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"),
  en: ("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"),
  pt: ("janeiro", "fevereiro", "março", "abril", "maio", "junho", "julho", "agosto", "setembro", "outubro", "novembro", "dezembro"),
  fr: ("janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"),
  de: ("Januar", "Februar", "März", "April", "Mai", "Juni", "Juli", "August", "September", "Oktober", "November", "Dezember"),
  it: ("gennaio", "febbraio", "marzo", "aprile", "maggio", "giugno", "luglio", "agosto", "settembre", "ottobre", "novembre", "dicembre"),
)

// Fecha en el idioma del texto: «22 de septiembre de 2026», «September 22, 2026»...
// `datetime.display()` no traduce los meses.
#let date(d) = context {
  let lang = if text.lang in months { text.lang } else { "en" }
  let (day, month, year) = (d.day(), months.at(lang).at(d.month() - 1), d.year())
  if lang in ("es", "pt") [#day de #month de #year]
  else if lang == "en" [#month #day, #year]
  else if lang == "de" [#day. #month #year]
  else [#day #month #year]
}

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
