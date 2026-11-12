# Document Class for Typst

A robust, LaTeX-inspired document class package for Typst, providing `book`, `report`, and `article` classes with advanced features like H4 numbering, configurable layout, and book-specific components.

## Features

- **Standard Classes**:
  - `book`: Supports Parts, Chapters, Frontmatter/Mainmatter/Backmatter, and Appendices.
  - `report`: Supports Chapters and Abstracts. Ideal for theses and technical reports.
  - `article`: Supports Sections, Multi-column layout, and Inline Abstracts.
  - `essay`: Margin notes and figures, the title with its section outline in the margin, and a running header. Built on glosa, a margin-note engine derived from [marginalia](https://github.com/nleanba/typst-marginalia).
- **Advanced Numbering**: Correct handling of H4 (subsections) numbering (`1.1.1`) and Appendix lettering (`A.1`). Cross-references (`@label`) work for parts, chapters, sections, figures and equations.
- **Languages**: Labels ("Chapter", "Contents"...) follow `lang` (es, en, pt, fr, de, it) and can be overridden.
- **Book Components**:
  - `dedication()`, `epigraph()`, `blockquote()`, `verse()`
  - Enhanced Titlepage (Subtitle, Publisher, Logo)
  - `half-title()`, `colophon()`
- **Layout Control**: Configurable margins, paper size (`a4`, `a5`, etc.), and font sizes.
- **Microtypography**: Smart header suppression on empty pages or before Parts.
- **Tables of contents**: one API (`tocs`) behind `tableofcontents`, `minitoc`, `listoffigures`, `listoftables` and `listoflistings`: presets, per-level styles, partial tables and lists of figures, tables and listings.

## Installation

Clone the repository into Typst's local package directory, so any document can import it as `@local/documentclass`:

```bash
# Linux; on macOS use ~/Library/Application Support/typst/packages/local
git clone https://github.com/lfreyes97/documentclass.git \
  ~/.local/share/typst/packages/local/documentclass/0.1.0
```

```typst
#import "@local/documentclass:0.1.0": *
```

You can also clone it anywhere next to your project and import `lib.typ` by its relative path.

## Usage

### Book Class

```typst
#import "lib.typ": *

#show: book.with(
  title: "My Book Title",
  subtitle: "A Great Subtitle",
  author: "Author Name",
  date: "2026",
  publisher: "My Press",
  paper: "a5",
  font-size: 11pt,
  fonts: (body: ("EB Garamond", "Libertinus Serif")),
)

#show: front
#dedication[To the reader.]
#tableofcontents()

#show: main
= Chapter One
#epigraph[A quote][Author]

Content goes here...

#show: back
#show: appendix
== Appendix A
```

### Report Class

```typst
#import "lib.typ": report, abstract

#show: report.with(
  title: "Technical Report",
  author: "Engineer",
  abstract: [
    This is the abstract, appearing on its own page.
  ]
)

= Introduction
This is the first chapter.
```

### Article Class

```typst
#import "lib.typ": article

#show: article.with(
  title: "Scientific Article",
  author: "Researcher",
  cols: 2, // Two-column layout
  abstract: [
    Abstract text appearing before the columns start.
  ]
)

= Introduction
Section 1 starts here.
```

### Essay Class

```typst
#import "lib.typ": essay, note, notefigure, wideblock

#show: essay.with(
  author: "Author Name",
  fonts: (body: "EB Garamond"),
  outer: (far: 16mm, width: 45mm, sep: 8mm), // margin-note column
  facing-pages: true,                        // alternate inner/outer
)

= The Essay Title
== First Section <sec-first>
Text with a margin note#note[Note text.]<n-first>.

As @sec-first and @n-first show... // "section I", "note 1"
```

The level-1 heading is the essay title: it goes to the page header with its number, and its section outline goes to the margin. Level-2 headings are the sections, numbered `I.`, `II.`… Margin notes are numbered `1, 2, 3…` through the whole essay and footnotes switch to `*, †, ‡`.

`note-size` and `note-numbering` set the notes for the whole document, so files that `#include` content only need `#import "lib.typ": note`. Other options: `inner`/`outer` (each `(far, width, sep)`), `top`, `bottom`, `facing-pages`, `font-size`, `chapter-number-style`, `chapter-title-style`, `section-numbering`, `title-in-header`, `titlepage` and `debug-frame` (draws the margin columns). The engine itself is available as the `glosa` module (`glosa.header`, `glosa.notecounter`, `glosa.show-frame`…).

For complete examples, check the `demos/` directory:
- [demos/demo_book.typ](demos/demo_book.typ)
- [demos/demo_article.typ](demos/demo_article.typ)
- [demos/demo_report.typ](demos/demo_report.typ)

## Configuration

All classes accept the following common parameters:
- `title`, `author`, `date`
- `paper`: Paper size (e.g., "a4", "us-letter").
- `font-size`: Base font size (10pt, 11pt, 12pt).
- `fonts`: Font families by role (see [Fonts](#fonts)).
- `lang`: Document language; it also picks the labels (see [Languages](#languages)).
- `labels`: Labels that replace the translated ones.
- `microtype`: Justification and no-break-space adjustments (see [Microtypography](#microtypography)).
- `margin`: Page margins: `auto` (the class default), a length, or a dictionary. With `facing-pages: true` (the default in `book`; `false` in `report` and `article`, like LaTeX's `twoside`) the horizontal margins are `inside` and `outside`, which alternate on each page, e.g. `margin: (inside: 3cm, outside: 2cm, y: 2cm)`; with `false` they are `x`, or `left` and `right`. Keys you leave out keep the class default, and a key of the wrong kind for `facing-pages` fails with a message.

### Specific Parameters
- **Book**: `part-ornament`, `logo`, `custom-titlepage`, `equation-numbering`, `use-parts`, `cover` (see [Covers](#covers)), and `minitoc` (`true`, or a dictionary of `tocs.partial` options; see [Tables of contents](#tables-of-contents-tocs)).
- **Article**: `cols` (column count), `abstract`.
- **Report**: `abstract`, `logo`, `custom-titlepage`, `equation-numbering`.
- **Essay**: see [Essay Class](#essay-class).

With `use-parts: false`, `=` is a chapter and `==` a section; parts are created with `#part[Title]`. `tableofcontents(depth: 2)` still counts from the chapter. `facing-pages` (on by default in `book`) lays the front out as a printed book: after the cover the title page starts on a recto, and the contents and the rest of the front matter do too, so the versos are blank and carry no header or folio (cover, blank, title, blank, contents). `facing-pages: false` removes those versos, for a PDF read on screen. In `book`, any blank page left by a page break (the verso before a part or chapter, or your own `#pagebreak(to: "odd")`) gets no header or folio. `#blank-page()` inserts an intentionally blank page the same way.

`page-style` sets the running header and the footer (LaTeX's fancyhdr). The presets are `"classic"`, `"plain"` (folio only), `"outer"` (folio at the outer edge beside the running title, folio at the foot of chapter openings), `"minimal"` (a small grey folio at the outer foot), `"modern"` and `"elegant"`; the last two go with the `tocs` styles of the same name (`demos/demo_pagestyle.typ` makes one PDF per preset with `--input style=…`). `book` uses `"classic"` (the part on versos, the chapter on rectos, a grey rule, the folio centred in the footer; none of it on opening pages, blank pages or before the first part) `"plain"` in `report` and `none` in `article` (Typst's own folio). It also takes a dictionary that changes the preset, or `none`:

```typst
#show: book.with(page-style: (
  header: (
    odd: (left: ctx => ctx.section, right: ctx => ctx.chapter),
    even: (left: ctx => ctx.part, right: ctx => ctx.author),
    rule: 0.4pt,
  ),
  footer: (left: ctx => ctx.folio, right: ctx => ctx.title),
))
```

`header` and `footer` each take `left`, `center`, `right` (content or `ctx => content`), `odd`/`even` for rectos and versos (used with `facing-pages: true`; otherwise every page is `odd`), `rule`, `text` and `when` (`ctx => bool`). Spaces you give replace the preset's; `rule`, `text` and `when` merge with them. `ctx` has `part`, `chapter`, `section` (the title in force on the page, like `\markboth`), `folio`, `page`, `title`, `author`, `started`, `opening`, `blank`, `numbered` and `matter`. Unknown keys fail with the list of valid ones.

`logo`, `part-ornament` and `custom-titlepage` take content, not file paths. Typst resolves paths relative to the file that reads them, so a path string would point inside the package:

```typst
#show: book.with(
  logo: image("escudo.png", width: 30%),
  part-ornament: image("ornament.svg", width: 80%),
  custom-titlepage: include "my-titlepage.typ",
)
```

### Drop caps

`dropcap` sets the first letter of a paragraph, with any surrounding punctuation, `height` lines tall, and the text flows around it. It uses the `initials` font role unless you pass `font`; any other `text` argument (`fill`, `weight`…) styles the letter.

```typst
#dropcap[Once upon a time…]
#dropcap(height: 3, fill: maroon)[«Quoted» openings keep the quotes with the letter.]
#ornate-dropcap(style: "rubricated")[Illuminated initial in two inks…]
```

`ornate-dropcap` uses the illuminated initials of [EB Garamond Initials](https://github.com/georgd/EB-Garamond-Initials) (SIL OFL 1.1, see `components/assets/eb-initials/COPYING`) in three styles: `"plain"`, `"inverted"` and `"rubricated"`, with `frame` and `wear` (printing wear, 0–1). Letters outside the set (accented letters, Ñ) fall back to `dropcap`. `ornate-initial("Q")` gives the letter alone.

### Covers

`book` places a cover before the title page and a back cover at the end. It is compatible with coverbook, a separate cover package, but any content works:

```typst
// A coverbook style function: the class calls it with title, subtitle, author
// and publisher, plus `cover-data`, and adds the back cover automatically
#show: book.with(
  title: "Essays", author: "Author Name",
  cover: minimal-cover,
  cover-data: (isbn: "978-1-000-00000-0", back-text: [...]),
  cover-options: (trim: "6x9"),
)

// Or covers already built, e.g. with coverbook's cover-pages
#let (front-cover, back-cover) = cover-pages(minimal-cover, data)
#show: book.with(cover: front-cover, back-cover: back-cover)
```

`back-cover: none` leaves the back cover out.

### Numbering and cross-references

Headings use Typst's own numbering, so `@label` works everywhere:

```typst
== Neutrality <neutral>
As shown in @neutral...   // "Chapter 1" / "Capítulo 1"
```

- **Book**: parts are numbered `I, II…`; chapters (`==`) are numbered `1, 2…` and keep counting across parts; sections are `1.1` and `1.1.1`. Front matter and back matter headings are not numbered. After `#show: appendix`, chapters are `A, B…` and sections `A.1`. `#show: end-appendix` turns numbering off again for what follows, such as a glossary.
- **Report**: chapters `1`, sections `1.1`, subsections `1.1.1`.
- **Article**: sections `1.`, `1.1`, `1.1.1`.

In `book` and `report`, figures and tables are numbered within the chapter (`2.3`, `A.1`). Set `equation-numbering: true` to number display equations the same way, as `(2.1)`. In `article` they are numbered through the whole document.

`#heading(numbering: none)[...]` gives an unnumbered heading in any class. `#bibliography("refs.bib")` and `#outline()` produce unnumbered headings; in `book` they sit at chapter level, not as a part.

### Tables of contents (tocs)

The LaTeX names are the `tocs` functions: `tableofcontents` is `tocs.toc`, `minitoc` is `tocs.partial`, `listoffigures` is `tocs.lof`, `listoftables` is `tocs.lot` and `listoflistings` is `tocs.lol`. They all take the same options and read the class on their own: parts and chapters in `book`, chapters in `report`, sections in `article` and `essay`; chapter and appendix numbers; each entry's folio in the numbering of its page (`iii`, `7`); the `toc` and `minitoc` font roles; and the translated labels, including `labels` overrides.

`depth` counts the levels *under the parts*: `depth: 1` lists parts and chapters, `depth: 2` adds sections, `depth: 3` subsections. Parts always appear unless `parts: false`.

In `book`, `minitoc: true` puts a table of the part's chapters on each part page, without numbers and with dot leaders. Pass a dictionary of `tocs.partial` options to change it, for example `minitoc: (depth: 2, size: 1em)`. A `levels` entry replaces the default one, so repeat `number: false` if you still want chapters without numbers.

```typst
#show: front
#tableofcontents(style: "elegant", depth: 2) // "classic", "modern", "elegant" or "compact"
#listoffigures()                            // also listoftables() and listoflistings()

#show: main
= Foundations
== A chapter title too long for the table #tocs.short[Short title]
#minitoc()                            // sections of this chapter
=== Working notes #tocs.omit()        // left out of the table
```

- `tableofcontents` takes `style`, `depth`, `parts`, `matter` (e.g. `("main", "back")`), `title`, `title-level`, `outlined`, `fill`, `font`, `size`, `columns`, `column-gutter`, `gutter`, `class` and `target`.
- `levels` styles each role (`part`, `chapter`, `section`, `subsection`, `subsubsection`, `figure`): `text`, `number-text`, `page-text`, `smallcaps`, `upper`, `indent`, `number-width`, `number-format`, `number-break`, `label`, `appendix-label`, `fill`, `number` (`false` hides the number and label), `page`, `gutter`, `above`, `below`, `align`, `stroke`, `run-in`, `separator`, and `format: (entry, style) => content` to replace the whole layout.

  ```typst
  #tableofcontents(levels: (
    part: (align: center, smallcaps: true, page: false),
    section: (fill: repeat(gap: 0.6em)[·], text: (style: "italic")),
  ))
  ```

- `#show: tocs.setup.with(...)` sets options for every table that follows. Presets are dictionaries (`tocs.presets`), and `tocs.merge` derives new ones from them.
- `minitoc(scope: "part")` or `scope: "chapter"` lists the divisions inside the current part or chapter. `tocs.list-of(target: figure.where(kind: "diagram"), key: "figures")` lists any figure kind, and `supplement: true` shows "Figure 2.1".
- `#tocs.add-entry(role: "section")[...]` adds an entry with the folio where it is placed, like `\addcontentsline`.

The module also works without a class, through `#import "@local/documentclass:0.1.0": tocs`. The options of the old `tableofcontents` (`h1-font`, `chapter-label`, `nest-indent`, `chapter-gap`…) are now `levels` entries, and an old option gives an error that says what to write instead. `demos/demo_tocs.typ` shows a full book.

### Languages

`lang` sets the hyphenation and the class labels: part, chapter, appendix, section, contents, abstract, figures, tables, and in `essay` also note, page and of (the header's "Page 3 of 12"), plus the month names of the date. Spanish, English, Portuguese, French, German and Italian are included; any other language falls back to English. To change a label, pass `labels`:

```typst
#show: book.with(
  lang: "en",
  labels: (chapter: "Lesson", contents: "Table of Contents"),
)
```

An unknown label name is an error.

### Fonts

All classes take a `fonts` dictionary. Give only the roles you want to change; every role you leave out takes its font from its parent:

| Role | Used for | Inherits from |
|------|----------|---------------|
| `body` | Body text | — (`"Libertinus Serif"`) |
| `heading` | All heading levels | `body` |
| `h1`, `h2`, `h3`, `h4` | One heading level | `heading` |
| `title` | Title page, half-title, article title block | `heading` |
| `header` | Running header (book) | `body` |
| `toc` | `tableofcontents` | `body` |
| `minitoc` | `minitoc`, including the automatic one in book parts | `toc` |
| `note` | Margin notes (essay) | `body` |
| `initials` | `dropcap` | `body` |
| `mono` | Code (`raw`) | — (`"DejaVu Sans Mono"`) |

```typst
#show: book.with(
  fonts: (
    body: "EB Garamond",
    heading: "Libertinus Sans", // h1–h4 and title
    h1: "Cinzel",               // parts only
    mono: "Fira Code",
  ),
)
```

Each value can be a family name or a fallback list, such as `("EB Garamond", "Libertinus Serif")`. The defaults ship with Typst, and other families must be installed on your system. An unknown role is an error.

`tableofcontents`, `minitoc` and `dropcap` still take their own `font` argument, which overrides the role for that call.

### Microtypography

All four classes apply a few adjustments to justified text, on by default. `microtype: false` turns them off (Typst's own behavior) and a dictionary changes any of them:

```typst
#show: book.with(
  microtype: (
    spacing: (min: 90%, max: 120%),            // word space Typst may shrink or stretch
    tracking: (min: -0.012em, max: 0.012em),   // letter spacing Typst may adjust
    hyphenation: 130%,                         // cost of a hyphen (100% = Typst's default)
    glue: true,                                // no-break spaces, see below
  ),
)
```

- **`spacing` and `tracking`** are Typst's `par.justification-limits`. With room to adjust both, Typst spreads the correction over many lines instead of loading it on the worst ones. `±0.012em` is about 0.13pt per letter at 11pt, below what the eye picks up.
- **`hyphenation`** raises the cost of hyphenating (Typst's `text.costs`), so words break less often.
- **`glue`** puts a no-break space after short abbreviations before a number (`p. 12`, `Col. 2:3`), titles (`Dr. Bahnsen`), initials (`L. F. Reyes`), numbered books (`1 Corintios`) and `n.º`, so a reference never splits across lines. It also keeps a dash (`—`) with the word before it, so it never starts a line.

On a 39-page Spanish book (EB Garamond, A5) these defaults cut hyphenated lines from 8.1% to 3.4% and the spread of word spaces by about a quarter, and no abbreviation, title or dash was left at a line break. A document that already looked right can re-flow, so recheck page breaks after updating. Hanging punctuation (`overhang`) is already on in Typst.

## Tests

`test/` holds documents that exercise each feature (fonts, numbering and cross-references, the essay class, microtypography). `test/microtype.typ` also checks the no-break rules with `assert`. Compile them from the repository root:

```bash
for f in test/*.typ; do typst compile --root . "$f" /tmp/out.pdf; done
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
