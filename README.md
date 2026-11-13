# Document Class for Typst

LaTeX-style document classes for Typst: `book`, `report`, `article`, `essay` (with margin notes) and `debate` (transcribed debates), with role-based fonts, translated labels, shared themes for headings, running heads and tables of contents, and the components of a printed book.

## Features

- **Classes**:
  - `book`: parts, chapters, front matter, main matter, back matter and appendices; covers and a title page.
  - `report`: chapters and an abstract page, for theses and technical reports.
  - `article`: sections, a title block over the text, an inline abstract and several columns.
  - `essay`: margin notes and figures, the title with its section outline in the margin, and a running header. Built on glosa, a margin-note engine derived from [marginalia](https://github.com/nleanba/typst-marginalia).
  - `debate`: speakers, turns, segments and transcript marks for debates, interviews and panels (in development).
- **Numbering and cross-references**: `@label` works for parts, chapters, sections, figures and equations; appendices are lettered (`A.1`).
- **Themes**: `style: "classic"`, `"modern"` or `"elegant"` sets headings (`heading-style`), running heads and footers (`page-style`) and the tables of contents at once; each can be changed key by key.
- **Languages**: labels ("Chapter", "Contents"…) follow `lang` (es, en, pt, fr, de, it) and can be overridden.
- **Book components**: `dedication`, `epigraph`, `blockquote`, `verse`, `half-title`, `colophon`, drop caps, covers.
- **Layout**: one `margin` option with `facing-pages` (LaTeX's `twoside`), paper size and font size.
- **Microtypography**: justification limits, fewer hyphens and no-break spaces after abbreviations, on by default.
- **Tables of contents**: one API (`tocs`) behind `tableofcontents`, `minitoc`, `listoffigures`, `listoftables` and `listoflistings`.
- **Review aids**: numbered lines to quote by page and line, and `#verify[…]` marks for what is still to check.

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

## Public API

`lib.typ` exports only the names below, so `import "@local/documentclass:0.1.0": *` brings nothing else into your document. The API is not frozen yet: a "stable" name keeps its meaning, but an option can still change before 1.0, and every change is listed in `HECHO.md`.

| Names | What they are | Status |
|-------|---------------|--------|
| `book`, `report`, `article`, `essay` | The classes, used as `#show: book.with(...)` | stable |
| `debate` | The debate class | in development |
| `frontmatter`, `mainmatter`, `backmatter`, `appendix`, `end-appendix` | The divisions of a book, as in LaTeX | stable |
| `part`, `blank-page`, `dedication`, `abstract`, `half-title`, `colophon` | Special headings and pages | stable |
| `epigraph`, `blockquote`, `verse` | Text environments | stable; their options will grow with the quotation styles |
| `dropcap`, `ornate-dropcap`, `ornate-initial` | Drop caps | stable |
| `tableofcontents`, `minitoc`, `listoffigures`, `listoftables`, `listoflistings`, `tocs` | Tables of contents and the `tocs` module behind them | stable |
| `note`, `notefigure`, `wideblock` | Margin notes, margin figures and wide blocks (`essay`) | stable |
| `verify`, `verify-list` | Review marks | stable |
| `turn`, `segment`, `crowd`, `inaudible`, `at`, `tnote`, `cite-turn`, `speakers-index`, `glossary`, `gloss` | Debate transcripts (`debate`) | in development |
| `glosa` | The margin-note engine behind `essay` | advanced: may change |
| `front`, `main`, `back` | Old names of `frontmatter`, `mainmatter` and `backmatter` | deprecated: they clash with a document's own names under `import *` and will be removed before 1.0 |

Everything else, the files under `components/` and `classes/`, is internal and can change without notice.

### States

The classes keep a few values in Typst states, which `tocs` reads by their key without importing the class (so it also works in a document without one). The keys are a contract, and every class state has the prefix `dc-`:

| Key | Value | Set by |
|-----|-------|--------|
| `dc-use-parts` | `true` or `false` | `book` (its presence marks a book) |
| `dc-matter` | `"front"`, `"main"` or `"back"` | `frontmatter`, `mainmatter`, `backmatter` |
| `dc-appendix` | `true` after `#show: appendix` | `appendix`, `end-appendix` |
| `dc-fonts` | The fonts resolved by role | every class |
| `dc-labels` | The `labels` overrides | every class |

The other `dc-` states (`dc-debug`, `dc-facing-pages`, `dc-debate-…`) and those of glosa (`_glosa_…`) and `tocs` (`tocs-config`) are internal.

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

#show: frontmatter
#dedication[To the reader.]
#tableofcontents()

#show: mainmatter
= Part One
== Chapter One
#epigraph[A quote][Author]

Content goes here...

#show: backmatter
#show: appendix
== Appendix A
```

### Report Class

```typst
#import "lib.typ": report

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
  note-columns: (outer: (width: 50mm)), // a wider margin-note column
  facing-pages: true,                   // alternate inner and outer columns
)

= The Essay Title
== First Section <sec-first>
Text with a margin note#note[Note text.]<n-first>.

As @sec-first and @n-first show... // "section I", "note 1"
```

The level-1 heading is the essay title: it goes to the page header with its number, and its section outline goes to the margin. Level-2 headings are the sections, numbered `I.`, `II.`… Margin notes are numbered `1, 2, 3…` through the whole essay and footnotes switch to `†, ‡, §`. `note-size` and `note-numbering` set the notes for the whole document, so files that `#include` content only need `#import "lib.typ": note`.

Its own options:

- **Notes**
  - `notes`: `"margin"` (the default) keeps the margin columns; `"footnote"` drops them: margin notes become footnotes in a single numeric series, margin figures plain figures, wide blocks plain blocks, and the page margins come from `margin`, e.g. `margin: (inside: 34mm, outside: 28mm)`, for reading on a small screen or printing in A5.
  - `note-columns`: the margin-note columns, `inner` and `outer`, each with `far` (page edge to column), `width` (the column) and `sep` (column to text). Keys you leave out keep the defaults, `(inner: (far: 16mm, width: 15mm, sep: 8mm), outer: (far: 16mm, width: 45mm, sep: 8mm))`. With `facing-pages: true` inner and outer alternate.
  - `note-size`, `note-numbering`, `clearance` (the least space between two notes, 12 pt).
  - `overflow`: `"carry"` (the default) moves the notes that do not fit the margin column of their page to the top of the column on the next page, marked with a small arrow in the gutter beside the note; `"none"` leaves them pushed up past the top margin. `overflow-mark`: `auto` for the arrow, `none`, or any content. Notes that still do not fit (on the last page, which has no next page; with `"none"`; or over a wide block) leave a `<glosa-overflow>` mark per column, `(side:, notes:)`: `typst query essay.typ "<glosa-overflow>"` lists them with their page, and `debug: (frame: true)` paints those columns red with the number of notes.
  - `footnote-counter`: `"page"` (the default) restarts the footnote symbols on every page, like LaTeX's `perpage`; `"document"` keeps counting. `footnote-symbols`: the marks, `("†", "‡", "§", "‖", "¶")` by default and then repeated (an asterisk as a superscript shrinks to a dot, so it is not in the set).
- **Title and header**
  - `title`, `subtitle`, `author`, `publisher` and `titlepage` (`none` by default; `auto` or `true` for a title page with them; or your own content). See [Configuration](#configuration).
  - `date`: content or a `datetime` for the header; `none`, the default, shows no date, so the PDF does not change when you recompile another day; `datetime.today()` shows today's.
  - `page-counter`: where "Page 3 of 12" goes: `"footer"` at the outer edge (the default), `"header"` in the inner column, or `none`.
  - `title-in-header`, `chapter-numbering` (`none` by default: the essay title carries no numeral; `"1"` shows it, for several chapters), `chapter-number-style`, `chapter-title-style`, `section-numbering`, `section-block-style`, `header-ascent`.
- **Page**: `paper`, `top`, `bottom`, `facing-pages`, `font-size`, `text-fill`, `equation-numbering`, and `debug-frame` (draws the margin columns, as `debug: (frame: true)`).

The engine itself is available as the `glosa` module (`glosa.header`, `glosa.notecounter`, `glosa.show-frame`…).

### Debate Class

`debate` is in development: `demos/demo_debate.typ` (two speakers and a moderator), `demos/demo_debate_panel.typ` and `demos/demo_debate_interview.typ` show it, and `classes/debate.typ` documents each option.

### Examples

The demos are in the repository, not in the published package (`typst.toml` leaves `demos/` and `test/` out):

- [demo_book.typ](https://github.com/lfreyes97/documentclass/blob/main/demos/demo_book.typ), with `--input style=modern` or `elegant`
- [demo_report.typ](https://github.com/lfreyes97/documentclass/blob/main/demos/demo_report.typ) and [demo_article.typ](https://github.com/lfreyes97/documentclass/blob/main/demos/demo_article.typ)
- [demo_pagestyle.typ](https://github.com/lfreyes97/documentclass/blob/main/demos/demo_pagestyle.typ) (one PDF per `page-style`) and [demo_tocs.typ](https://github.com/lfreyes97/documentclass/blob/main/demos/demo_tocs.typ)
- [demo_debate.typ](https://github.com/lfreyes97/documentclass/blob/main/demos/demo_debate.typ)

## Configuration

All classes accept the following common parameters:
- `title`, `subtitle`, `author`, `date`, `publisher`: the title block, the same in every class. `book` and `report` show it on their title page, `article` in the title block over the text, and `essay` on its title page; `title` and `author` also go to the PDF metadata.
- `titlepage` (`book`, `report`, `essay`): `auto` or `true` for the class's title page, `none` or `false` for none, or your own content (`titlepage: include "my-titlepage.typ"`). `book` and `report` have one by default, `essay` does not; `article` sets its title block over the text instead.
- `paper`: Paper size (e.g., "a4", "us-letter").
- `font-size`: Base font size (10pt, 11pt, 12pt).
- `fonts`: Font families by role (see [Fonts](#fonts)).
- `lang`: Document language; it also picks the labels (see [Languages](#languages)).
- `labels`: Labels that replace the translated ones.
- `microtype`: Justification and no-break-space adjustments (see [Microtypography](#microtypography)).
- `margin`: Page margins: `auto` (the class default), a length, or a dictionary. With `facing-pages: true` (the default in `book`; `false` in `report` and `article`, like LaTeX's `twoside`) the horizontal margins are `inside` and `outside`, which alternate on each page, e.g. `margin: (inside: 3cm, outside: 2cm, y: 2cm)`; with `false` they are `x`, or `left` and `right`. Keys you leave out keep the class default, and a key of the wrong kind for `facing-pages` fails with a message.
- `equation-numbering`: `true` numbers display equations (see [Numbering](#numbering-and-cross-references)).
- `line-numbers`: Numbered lines, to quote by page and line or to review with someone (`book`, `report`, `article`, `essay`). `false` by default; `true` numbers every line of the body text, restarting on each page; a dictionary changes it: `line-numbers: (every: 5, scope: "document", size: 7pt, fill: gray, clearance: 8pt, side: start)`. Headings, footnotes, figure captions, title blocks, title pages and margin notes are not numbered.
- `debug`: Debugging aids, invisible to the reader: `false` by default, `true` turns on all of them, or a dictionary picks: `debug: (verify: true, lines: true, frame: true)`. `verify` shows the `#verify[…]` marks, `lines` numbers the lines (as `line-numbers: true`) and `frame` draws the margins and columns (`essay`). `#verify[check the page]` marks something pending: it prints nothing, but leaves a queryable record with its page whether or not `debug` is on (`typst eval 'query(<dc-verify>).map(it => it.value)' --in essay.typ`), and with `verify` on it is highlighted. `#verify-list()` lists the pending ones. For the final build, `debug: (verify: "error")` also shows them and makes the compilation fail while any is left, with its page and note.

Every option that takes a dictionary (`fonts`, `labels`, `microtype`, `margin`, `page-style`, `heading-style`, `line-numbers`, `debug`, `cover`, `minitoc`, `note-columns`) fails on an unknown key with a message that lists the valid ones, and an option that was renamed fails with a message that gives its new form.

### Specific Parameters
- **Book**: `part-ornament`, `logo`, `use-parts`, `cover` (see [Covers](#covers)), and `minitoc` (`true`, or a dictionary of `tocs.partial` options; see [Tables of contents](#tables-of-contents-tocs)).
- **Report**: `abstract`, `abstract-title`, `logo`.
- **Article**: `cols` (column count), `abstract`, `abstract-title`.
- **Essay**: see [Essay Class](#essay-class).

With `use-parts: false`, `=` is a chapter and `==` a section; parts are created with `#part[Title]`. `tableofcontents(depth: 2)` still counts from the chapter. `facing-pages` (on by default in `book`) lays the front out as a printed book: after the cover the title page starts on a recto, and the contents and the rest of the front matter do too, so the versos are blank and carry no header or folio (cover, blank, title, blank, contents). `facing-pages: false` removes those versos, for a PDF read on screen. In `book`, any blank page left by a page break (the verso before a part or chapter, or your own `#pagebreak(to: "odd")`) gets no header or folio. `#blank-page()` inserts an intentionally blank page the same way.

`style` picks a theme (`"classic"`, `"modern"` or `"elegant"`) for headings, running heads and footers, and the `tocs` contents at once: `book(style: "modern")`. `heading-style`, `page-style` and a later `tocs.setup` replace it for one part, so `book(style: "modern", page-style: "plain")` is all modern with a plain footer. Without `style`, each part keeps its class default (`report` and `article` use `"plain"` for `page-style`). Passing a page-style variant where a theme is expected fails with a message that says so.

Small caps (`"elegant"` headings and running heads, and any `title-smallcaps: true`) use the font's own small caps (the OpenType `smcp` feature): Typst does not synthesize them. The Libertinus Serif that ships with Typst has them, but another build of the same family may not (the copy some systems install lacks them), and then the text comes out in lowercase. Check one page, or pick a font that has them, such as EB Garamond.

`heading-style` sets how every heading level looks in `book`, `report` and `article` (LaTeX's fncychap and titlesec): `"classic"` (the "CHAPTER N" label over a centred title, small-caps sections), `"modern"` (left-aligned, a small grey label, a short rule) and `"elegant"` (italic label, small-caps title), the same names as the `tocs` and `page-style` presets. A dictionary changes the preset. Each level is addressed by its role (`part`, `chapter`, `section`, `subsection`, `subsubsection`, `paragraph`) or by its level, `h1`…`h6`, which is the role that level has in the class (in `book`, `h1` is `part` and `h3` is `section`):

```typst
#show: book.with(heading-style: (
  preset: "modern",
  chapter: (align: center, rule: none, title-text: (size: 2.4em)),
  h3: (title-smallcaps: true, title-text: (size: 1em)), // sections in small caps at body size
  subsection: (title-smallcaps: false),
))
```

`part` and `chapter` are openings. They take `start` and `end` (`"odd"`, `"page"`, `"facing"` or `none`), `above`, `below`, `align`, `label` (`"chapter"`, content or `none`), `label-text`, `label-upper`, `number-format` (`n => content`, `none` hides the number), `gap`, `title-text`, `title-upper`, `title-smallcaps`, `rule` and `ornament`; their `front`, `back` and, in `chapter`, `appendix` variants change only what they set. The other roles take `above`, `below`, `align`, `number-format`, `number-text`, `number-sep`, `title-text`, `title-upper` and `title-smallcaps`; each inherits from the one above it what it does not set, and `section` from the body text. `scale` (1 by default) enlarges every heading size by how far it stands above the body text, so `heading-style: (scale: 1.5)` turns 1.8em into 2.2em and 1.2em into 1.3em while a title at 1em stays at body size. Unknown keys fail with the list of valid ones. The roles depend on the class: `book` has all six, `report` starts at `chapter` (its `h1`) and `article` at `section` (its `h1`); a role the class lacks, like `part` in `report`, fails with a message. In `report` and `article` the `classic` sizes are those of an 11 pt body (24 pt chapters, 16 pt sections) written in `em`, so they follow the body size if you change `font-size`. A section role with `run-in: true` puts the heading in line with the paragraph that follows, like LaTeX's `\paragraph` (`run-in-sep`, `h(1em)` by default, separates them: `run-in-sep: [. ]` gives "Title. Text…"). Any role also takes `format: ctx => content`, which draws the whole heading, for what the keys do not cover; a role can be that function directly. `ctx` has `heading` (the element), `body` (with `title-upper` and `title-smallcaps` applied), `number` (formatted with `number-format`, or `none`), `label` (an opening's "Chapter", or `none`), `role` and `style` (every key of the role). The page breaks and the `above` and `below` spacing still apply; in an opening, `format` replaces the label, rule and ornament too. Neither `run-in` nor `format` is inherited by the roles below.

```typst
#show: book.with(heading-style: (
  subsubsection: (run-in: true, run-in-sep: [. ]),
  paragraph: ctx => [#emph(ctx.body) —],
))
```

A section heading (`section` and below) is kept with the paragraph that follows it: it never stays alone at the foot of a page or column. The paragraph after it is not indented, as after a heading in LaTeX.

`page-style` sets the running header and the footer (LaTeX's fancyhdr). The presets are `"classic"`, `"plain"` (folio only), `"running-outer"` (folio at the outer edge beside the running title, folio at the foot of chapter openings), `"folio-outer"` (a small grey folio at the outer foot), `"modern"` and `"elegant"`; `classic`, `modern` and `elegant` are themes shared with `heading-style` and `tocs`, while `plain`, `folio-outer` and `running-outer` are variants that exist only in `page-style` (`demos/demo_pagestyle.typ` makes one PDF per name with `--input style=…`). `book` uses `"classic"` (the part on versos, the chapter on rectos, a grey rule, the folio centred in the footer; none of it on opening pages, blank pages or before the first part or chapter) and `"plain"` in `report` and `article`. A `book` without parts (`use-parts: false`) gets its running heads from the first chapter on: the chapter on rectos and, with no part, the book title on versos. It also takes a dictionary that changes the preset, or `none`:

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

`logo`, `part-ornament` and `titlepage` take content, not file paths. Typst resolves paths relative to the file that reads them, so a path string would point inside the package:

```typst
#show: book.with(
  logo: image("escudo.png", width: 30%),
  part-ornament: image("ornament.svg", width: 80%),
  titlepage: include "my-titlepage.typ",
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

`book` places a cover before the title page and a back cover at the end, both from `cover`. It is compatible with coverbook, a separate cover package, but any content works:

```typst
// A coverbook style function: the class calls it with title, subtitle, author
// and publisher, plus `data`, once for the front and once for the back
#show: book.with(
  title: "Essays", author: "Author Name",
  cover: (
    front: minimal-cover,
    data: (isbn: "978-1-000-00000-0", back-text: [...]),
    options: (trim: "6x9"),
  ),
)

// Or both covers already built, e.g. with coverbook's cover-pages
#show: book.with(cover: cover-pages(minimal-cover, data))
// Or each one as content
#show: book.with(cover: (front: image("front.pdf"), back: image("back.pdf")))
```

`cover` takes `none` (the default), content (a front cover alone), a pair `(front, back)`, a style function (`cover: minimal-cover`, both covers) or a dictionary with `front` (content or a style function), `back` (`auto`, the function's back cover; `none`; or content), `data` and `options`. A front cover given as content gets no back cover unless you pass `back`. The old `back-cover`, `cover-data` and `cover-options` are now `back`, `data` and `options`, and fail with a message that says so.

### Numbering and cross-references

Headings use Typst's own numbering, so `@label` works everywhere:

```typst
== Neutrality <neutral>
As shown in @neutral...   // "Chapter 1" / "Capítulo 1"
```

- **Book**: parts are numbered `I, II…`; chapters (`==`) are numbered `1, 2…` and keep counting across parts; sections are `1.1` and `1.1.1`. Front matter and back matter headings are not numbered. After `#show: appendix`, chapters are `A, B…` and sections `A.1`. `#show: end-appendix` turns numbering off again for what follows, such as a glossary.
- **Report**: chapters `1`, sections `1.1`, subsections `1.1.1`.
- **Article**: sections `1.`, `1.1`, `1.1.1`.

In `book` and `report`, figures and tables are numbered within the chapter (`2.3`, `A.1`). Set `equation-numbering: true` to number display equations the same way, as `(2.1)`. In `article` and `essay` figures, tables and, with `equation-numbering: true`, equations are numbered through the whole document: `(1)`, `(2)`…

`#heading(numbering: none)[...]` gives an unnumbered heading in any class. `#bibliography("refs.bib")` and `#outline()` produce unnumbered headings; in `book` they sit at chapter level, not as a part.

### Tables of contents (tocs)

The LaTeX names are the `tocs` functions: `tableofcontents` is `tocs.toc`, `minitoc` is `tocs.partial`, `listoffigures` is `tocs.lof`, `listoftables` is `tocs.lot` and `listoflistings` is `tocs.lol`. They all take the same options and read the class on their own: parts and chapters in `book`, chapters in `report`, sections in `article` and `essay`; chapter and appendix numbers; each entry's folio in the numbering of its page (`iii`, `7`); the `toc` and `minitoc` font roles; and the translated labels, including `labels` overrides.

`depth` counts the levels *under the parts*: `depth: 1` lists parts and chapters, `depth: 2` adds sections, `depth: 3` subsections. Parts always appear unless `parts: false`.

In `book`, `minitoc: true` puts a table of the part's chapters on each part page, without numbers and with dot leaders. Pass a dictionary of `tocs.partial` options to change it, for example `minitoc: (depth: 2, size: 1em)`. A `levels` entry replaces the default one, so repeat `number: false` if you still want chapters without numbers.

```typst
#show: frontmatter
#tableofcontents(style: "elegant", depth: 2) // "classic", "modern", "elegant" or "compact"
#listoffigures()                            // also listoftables() and listoflistings()

#show: mainmatter
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

The module also works without a class, through `#import "@local/documentclass:0.1.0": tocs`. The options of the old `tableofcontents` (`h1-font`, `chapter-label`, `nest-indent`, `chapter-gap`…) are now `levels` entries, and an old option gives an error that says what to write instead. `demos/demo_tocs.typ` (in the repository) shows a full book.

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

All the classes apply a few adjustments to justified text, on by default. `microtype: false` turns them off (Typst's own behavior) and a dictionary changes any of them:

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

```bash
python3 test/structure.py
```

`test/` holds documents that exercise each feature, many with `assert`s of their own (`test/microtype.typ` checks the no-break rules, `test/openings.typ` the heading styles). The script compiles every file in `test/` and `demos/` and checks the PDFs: no page with only a folio, folios in order, no overlapping text lines, the `classic` running heads and blank pages of `test/structure_book.typ`, that misspelt options fail with a useful message, and, when `test/reference/` exists, the text and line positions of a few files against it. The references are not versioned (they depend on the machine): create them with `--update` before a change to compare against it, and run `--update` again after an intended change; `--no-reference` skips that comparison and `-k name` for one file. It needs `typst` and `pdftotext` (poppler-utils), and compiles with `--ignore-system-fonts` so the result does not depend on installed fonts. CI runs it with Typst 0.15.1 (`.github/workflows/test.yml`).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
