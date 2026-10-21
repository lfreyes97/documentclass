# Document Class for Typst

A robust, LaTeX-inspired document class package for Typst, providing `book`, `report`, and `article` classes with advanced features like H4 numbering, configurable layout, and book-specific components.

## Features

- **Standard Classes**:
  - `book`: Supports Parts, Chapters, Frontmatter/Mainmatter/Backmatter, and Appendices.
  - `report`: Supports Chapters and Abstracts. Ideal for theses and technical reports.
  - `article`: Supports Sections, Multi-column layout, and Inline Abstracts.
- **Advanced Numbering**: Correct handling of H4 (subsections) numbering (`1.1.1`) and Appendix lettering (`A.1`).
- **Book Components**:
  - `dedication()`, `epigraph()`, `blockquote()`, `verse()`
  - Enhanced Titlepage (Subtitle, Publisher, Logo)
  - `half-title()`, `colophon()`
- **Layout Control**: Configurable margins, paper size (`a4`, `a5`, etc.), and font sizes.
- **Microtypography**: Smart header suppression on empty pages or before Parts.

## Installation

Clone this repository into your project or add it as a local package:

```bash
git clone https://github.com/your-username/documentclass.git
```

Then import it in your Typst file:

```typst
#import "documentclass/lib.typ": *
```

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
= Appendix A
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
- `margin-inside`, `margin-outside`, `margin-y`: Page margins.

### Specific Parameters
- **Book**: `part-ornament`, `minitoc`, `logo`, `custom-titlepage`.
- **Article**: `cols` (column count), `abstract`.
- **Report**: `abstract`, `logo`, `custom-titlepage`.

`logo`, `part-ornament` and `custom-titlepage` take content, not file paths. Typst resolves paths relative to the file that reads them, so a path string would point inside the package:

```typst
#show: book.with(
  logo: image("escudo.png", width: 30%),
  part-ornament: image("ornament.svg", width: 80%),
  custom-titlepage: include "my-titlepage.typ",
)
```

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
