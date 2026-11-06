// Etiquetas de tocs, con las mismas claves que documentclass para que el
// parámetro `labels` de la clase también las cambie aquí.
#import "bridge.typ"

#let translations = (
  es: (part: "Parte", chapter: "Capítulo", appendix: "Apéndice", contents: "Contenido", figures: "Lista de Figuras", tables: "Lista de Tablas", listings: "Lista de Códigos", page: "Pág."),
  en: (part: "Part", chapter: "Chapter", appendix: "Appendix", contents: "Contents", figures: "List of Figures", tables: "List of Tables", listings: "List of Listings", page: "Page"),
  pt: (part: "Parte", chapter: "Capítulo", appendix: "Apêndice", contents: "Sumário", figures: "Lista de Figuras", tables: "Lista de Tabelas", listings: "Lista de Códigos", page: "Pág."),
  fr: (part: "Partie", chapter: "Chapitre", appendix: "Annexe", contents: "Table des matières", figures: "Table des figures", tables: "Liste des tableaux", listings: "Liste des codes", page: "Page"),
  de: (part: "Teil", chapter: "Kapitel", appendix: "Anhang", contents: "Inhaltsverzeichnis", figures: "Abbildungsverzeichnis", tables: "Tabellenverzeichnis", listings: "Quelltextverzeichnis", page: "Seite"),
  it: (part: "Parte", chapter: "Capitolo", appendix: "Appendice", contents: "Indice", figures: "Elenco delle figure", tables: "Elenco delle tabelle", listings: "Elenco dei listati", page: "Pag."),
)

// Etiqueta como texto plano (requiere `context`)
#let get(key) = {
  let base = translations.at(text.lang, default: translations.en)
  bridge.labels.get().at(key, default: base.at(key))
}

#let term(key) = context get(key)

#let title-or(title, key) = if title == auto { term(key) } else { title }
