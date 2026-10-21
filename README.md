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
  book: true,                                // alternate inner/outer
)

= The Essay Title
== First Section <sec-first>
Text with a margin note#note[Note text.]<n-first>.

As @sec-first and @n-first show... // "section I", "note 1"
```

The level-1 heading is the essay title: it goes to the page header with its number, and its section outline goes to the margin. Level-2 headings are the sections, numbered `I.`, `II.`… Margin notes are numbered `1, 2, 3…` through the whole essay and footnotes switch to `*, †, ‡`.

`note-size` and `note-numbering` set the notes for the whole document, so files that `#include` content only need `#import "lib.typ": note`. Other options: `inner`/`outer` (each `(far, width, sep)`), `top`, `bottom`, `book`, `font-size`, `chapter-number-style`, `chapter-title-style`, `section-numbering`, `title-in-header`, `titlepage` and `debug-frame` (draws the margin columns). The engine itself is available as the `glosa` module (`glosa.header`, `glosa.notecounter`, `glosa.show-frame`…).

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
- `margin-inside`, `margin-outside`, `margin-y`: Page margins.

### Specific Parameters
- **Book**: `part-ornament`, `minitoc`, `logo`, `custom-titlepage`, `equation-numbering`.
- **Article**: `cols` (column count), `abstract`.
- **Report**: `abstract`, `logo`, `custom-titlepage`, `equation-numbering`.
- **Essay**: see [Essay Class](#essay-class).

`logo`, `part-ornament` and `custom-titlepage` take content, not file paths. Typst resolves paths relative to the file that reads them, so a path string would point inside the package:

```typst
#show: book.with(
  logo: image("escudo.png", width: 30%),
  part-ornament: image("ornament.svg", width: 80%),
  custom-titlepage: include "my-titlepage.typ",
)
```

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

`#listoffigures()` and `#listoftables()` list figures and tables with their numbers and pages.

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

## Tests

`test/` holds documents that exercise each feature (fonts, numbering and cross-references, the essay class). Compile them from the repository root:

```bash
for f in test/*.typ; do typst compile --root . "$f" /tmp/out.pdf; done
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
