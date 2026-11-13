
#import "config.typ": *
#import "notes.typ": note

/// Adds lines to the page background showing the various vertical and horizontal boundaries used by glosa.
///
/// To be used in a show-rule:
/// ```typ
/// #show: glosa.show-frame
/// ```
/// -> content
#let show-frame(
  /// Stroke for the lines.
  ///
  /// ```typ
  /// #show: glosa.show-frame.with(stroke: 2pt + red)
  /// ```
  /// -> color
  stroke: 0.5pt + luma(90%),
  /// Set to false to hide the header line
  /// -> bool
  header: true,
  /// Set to false to hide the footer line
  /// -> bool
  footer: true,
  /// -> content
  body,
) = {
  set page(
    background: context {
      let leftm = get-left()
      let rightm = get-right()

      let topm = _config.get().top
      let ascent = page.header-ascent.ratio * topm + page.header-ascent.length
      place(top, dy: topm, line(length: 100%, stroke: stroke))
      if header {
        place(top, dy: topm - ascent, line(length: 100%, stroke: stroke))
      }

      let bottomm = _config.get().bottom
      let descent = page.footer-descent.ratio * bottomm + page.footer-descent.length
      place(bottom, dy: -bottomm, line(length: 100%, stroke: stroke))
      if footer {
        place(bottom, dy: -bottomm + descent, line(length: 100%, stroke: stroke))
      }

      place(left, dx: leftm.far, rect(width: leftm.width, height: 100%, stroke: (x: stroke)))
      place(left, dx: leftm.far + leftm.width + leftm.sep, line(length: 100%, stroke: stroke, angle: 90deg))

      place(right, dx: -rightm.far, rect(width: rightm.width, height: 100%, stroke: (x: stroke)))
      place(right, dx: -rightm.far - rightm.width - rightm.sep, line(length: 100%, stroke: stroke, angle: 90deg))
    },
  )

  body
}


/// Creates a block that extends into the outside/right margin.
///
/// Note: This does not handle page-breaks sensibly.
/// If ```typc config.book = false```, this is not a problem, as then the margins on all pages are the same.
/// However, when using alternating page margins, a multi-page `wideblock` will not work properly.
/// To be able to set this appendix in a many-page wideblock, this code was used:
/// ```typ
/// #show: glosa.setup.with(..config, book: false)
/// #wideblock(side: "inner")[...]
/// ```
///
/// #compat((
///   "0.1.5": (
///     [`reverse` and `double` have been replaced with @wideblock.side.
///      #ergo[use \````typc side: "inner"```\` instead of \````typc reverse: true```\`]
///      #ergo[use \````typc side: "both"```\` instead of \````typc double: true```\`]],
///   ),
/// ))
/// -> content
#let wideblock(
  /// Which side to extend into.
  /// ```typc auto``` defaults to ```typc "outer"```.
  /// In non-book documents, ```typc "outer"```/```typc "inner"``` are equivalent to ```typc "right"```/```typc "left"``` respectively.
  /// -> auto | "outer" | "inner" | "left" | "right" | "both"
  side: auto,
  /// -> content
  body,
) = (
  context {
    // Without margin columns there is nothing to extend into
    if _config.get().mode == "footnote" { return block(width: 100%, body) }

    let left-margin = get-left()
    let right-margin = get-right()

    let side = if side == "outer" or side == auto {
      if _config.get().book and calc.even(here().page()) { "left" } else { "right" }
    } else if side == "inner" {
      if _config.get().book and calc.even(here().page()) { "right" } else { "left" }
    } else { side }

    assert(
      side == "left" or side == "right" or side == "both",
      message: "side must be auto, both, left, right, outer, or inner.",
    )

    let left = if side == "both" or side == "left" {
      left-margin.width + left-margin.sep
    } else {
      0pt
    }
    let right = if side == "both" or side == "right" {
      right-margin.width + right-margin.sep
    } else {
      0pt
    }

    let position = here().position().y
    let page_num = str(here().page())
    let pagewidth = if page.flipped { page.height } else { page.width }
    let linewidth = (
      pagewidth
        - left-margin.far
        - left-margin.width
        - left-margin.sep
        - right-margin.far
        - right-margin.width
        - right-margin.sep
    )
    let height = measure(width: linewidth + left + right, body).height

    if left != 0pt {
      _note_extends_left.update(old => {
        let oldpage = old.at(page_num, default: ())
        oldpage.push((natural: position, height: height, shift: false, keep-order: false))
        old.insert(page_num, oldpage)
        old
      })
    }

    if right != 0pt {
      _note_extends_right.update(old => {
        let oldpage = old.at(page_num, default: ())
        oldpage.push((natural: position, height: height, shift: false, keep-order: false))
        old.insert(page_num, oldpage)
        old
      })
    }

    pad(left: -left, right: -right, body)
  }
)




/// This generates a @wideblock and divides its arguments into three boxes sized to match the margin setup.
/// -> content
#let header(
  /// Will be used to ```typc set``` the text style.
  /// -> dictionary
  text-style: (:),
  /// Up to three positional arguments.
  /// They are interpreted as `⟨outer⟩`, `⟨center⟩⟨outer⟩`, or `⟨inner⟩⟨center⟩⟨outer⟩`,
  /// depending on how many there are.
  ..args,
  /// This is ignored if there are positional parameters or if @glosa-setup.book is ```typc false```.
  ///
  /// Otherwise, it is interpreted as `(⟨outer⟩, ⟨center⟩, ⟨inner⟩)` on even pages.
  /// -> array
  even: (),
  /// This is ignored if there are positional parameters.
  ///
  /// Otherwise, it is interpreted as `(⟨inner⟩, ⟨center⟩, ⟨outer⟩)` on odd pages or, if @glosa-setup.book is ```typc false```, on all pages.
  /// -> array
  odd: (),
) = context {
  let leftm = get-left()
  let rightm = get-right()
  let is-odd = not _config.get().book or calc.odd(here().page())

  set text(..text-style)

  let pos = args.pos()
  if pos.len() > 0 {
    // if args.named().len() > 0 { panic("cannot have named and positional arguments") }
    if pos.len() == 1 {
      pos = (none, none, ..pos)
    } else if pos.len() == 2 {
      pos = (none, ..pos)
    }
    let (inner, center, outer) = pos
    wideblock(
      side: "both",
      {
        box(width: leftm.width, if is-odd { inner } else { outer })
        h(leftm.sep)
        box(width: 1fr, center)
        h(rightm.sep)
        box(width: rightm.width, if is-odd { outer } else { inner })
      },
    )
  } else {
    wideblock(
      side: "both",
      {
        box(
          width: leftm.width,
          if is-odd {
            odd.at(0, default: none)
          } else {
            even.at(0, default: none)
          },
        )
        h(leftm.sep)
        box(
          width: 1fr,
          if is-odd {
            odd.at(1, default: none)
          } else {
            even.at(1, default: none)
          },
        )
        h(rightm.sep)
        box(
          width: rightm.width,
          if is-odd {
            odd.at(2, default: none)
          } else {
            even.at(2, default: none)
          },
        )
      },
    )
  }
}

/// Builds an auto-generated mini table of contents for the current chapter: the headings
/// of `sublevel` that fall between `loc` (typically a chapter heading's location) and either
/// the next heading of `level`, or the end of the document. Uses ```typ #outline()```, so
/// entries get the usual dotted leader and page number.
///
/// Caution: an entry's size depends on the final page numbers of the headings it lists. In a
/// document that also uses the margin-note placement algorithm, if this ends up as one of
/// *several* fixed-size notes competing for the same margin space (e.g. one per chapter in a
/// long, note-heavy document), that page-number dependency can feed back into the placement
/// algorithm and prevent the layout from converging. A single mini-outline placed once (e.g.
/// at the document's title, listing its top-level sections) is much less prone to this than
/// one placed at every chapter.
///
/// `loc` must be resolved with ```typ #context here()``` *before* this ends up nested inside
/// something that measures its content first, such as @note, e.g. inside a `place-note`-based
/// function: ```typ #measure()``` lays out its argument in an isolated pass in which `here()`
/// no longer reflects the real position in the document, which silently changes the query
/// result and can make the whole page fail to converge. @chapter resolves `loc` up front for
/// exactly this reason.
///
/// -> content
#let chapter-outline(
  /// Location to start looking after, typically a chapter heading's ```typ context here()```
  /// (not ```typ it.location()```: see @chapter).
  /// -> location
  loc,
  /// Level of the enclosing chapter heading.
  /// -> int
  level: 1,
  /// Level of the headings to list.
  /// -> int
  sublevel: 2,
  /// Passed through to the underlying ```typ #outline()```.
  /// -> arguments
  ..args,
) = context {
  let next = query(heading.where(level: level).after(loc))
  let end = if next.len() > 0 { next.first().location() } else { none }
  let target = if end != none {
    heading.where(level: sublevel).after(loc).before(end, inclusive: false)
  } else {
    heading.where(level: sublevel).after(loc)
  }
  outline(title: none, target: target, indent: 0pt, ..args)
}

/// Show-rule handler for chapter headings: renders a large chapter number and drops
/// @chapter-outline into the margin, echoing classic book chapter openers.
///
/// Use as
/// ```typ
/// #show heading.where(level: 1): glosa.chapter
/// ```
/// Combine with ```typ #set heading(numbering: "I.")``` (or similar) to get the big
/// numeral; without numbering, only the mini-outline is placed in the margin.
///
/// Note: apply this show-rule only where the chapter treatment should start (e.g. after
/// a manually-styled title heading), since it replaces the default rendering of every
/// heading it matches from that point on.
/// -> content
#let chapter(
  it,
  /// Style for the big numeral.
  /// -> dictionary
  number-style: (size: 40pt, weight: "black"),
  /// Style for the chapter title.
  /// -> dictionary
  title-style: (size: 1.4em, weight: "black"),
  /// Passed to the ```typ #block()``` wrapping the title.
  /// -> dictionary
  block-style: (above: 30pt, below: 14pt),
  /// Style for @chapter-outline's entries.
  /// -> dictionary
  outline-style: (size: 7.5pt),
  /// Stroke for the rule separating the margin column. ```typc none``` to disable.
  /// -> stroke | none
  rule: 0.6pt + luma(40%),
  /// Level of headings to list in the mini-outline. ```typc none``` to disable.
  /// -> none | int
  sublevel: 2,
  /// Passed to the underlying @note. ```typc false``` makes other notes avoid this block,
  /// but in an already note-dense document, adding several fixed, avoided blocks can make
  /// the placement algorithm take many iterations to settle (Typst may warn that the
  /// document "did not converge"). ```typc "ignore"``` is instant and always stable, at the
  /// cost of no longer reserving space against nearby notes.
  /// -> bool | "ignore" | "avoid"
  shift: false,
  /// Whether to render the title inline in the body. Set to ```typc false``` when the
  /// heading's content is being shown elsewhere instead (e.g. pulled into the page header
  /// via a query on ```typ heading.where(level: ..)```), so only the margin note (numeral
  /// and/or @chapter-outline) is emitted here.
  /// -> bool
  show-title: true,
  /// Whether to render the numeral in the margin note. Set to ```typc false``` when it's
  /// being shown elsewhere instead (e.g. beside the title in @title-header), so the margin
  /// note only carries @chapter-outline.
  /// -> bool
  show-number: true,
) = {
  if show-title {
    block(..block-style, breakable: false, text(..title-style, it.body))
  }
  context {
    let loc = here()
    let number = if show-number and it.numbering != none {
      counter(heading).display(it.numbering)
    } else { none }
    if number != none or sublevel != none {
      note(
        shift: shift,
        numbering: none,
        // Tamaño base de glosa, no el de note-defaults: el índice fija su propio tamaño
        // y este solo decide la línea base con que se alinea la nota
        text-style: (size: 9.35pt),
        block-style: (
          stroke: if rule != none { (left: rule) } else { none },
          inset: (left: 1em),
          width: 100%,
        ),
      )[
        #if number != none [
          #text(..number-style, number)
          #v(0.6em)
        ]
        #if sublevel != none {
          set text(..outline-style)
          set par(leading: 0.55em)
          chapter-outline(loc, level: it.level, sublevel: sublevel)
        }
      ]
    }
  }
}

/// A ```typc heading(numbering: ..)``` pattern interpreted against only the heading's own
/// counter segment, ignoring any unused ancestor levels.
///
/// Needed whenever a level never gets its own heading but a deeper level does — the most
/// common case being @chapter set up on a lone, unnumbered level-1 document title (see
/// @title-header), with real, numbered sections starting at level 2: plain
/// ```typc heading(numbering: "I.")``` numbers using the *entire* counter vector up to the
/// heading's level, so the never-incremented level 1 shows up as a spurious leading "N."
/// (roman numeral zero) before the real number. This strips everything but the heading's own
/// segment.
///
/// Use as
/// ```typ
/// #show heading.where(level: 2): set heading(numbering: glosa.level-numbering("I."))
/// ```
/// -> function
#let level-numbering(
  /// -> string
  pattern,
) = (..n) => numbering(pattern, n.pos().last())

/// Page-header content that shows the document's title — its first heading of `level` —
/// right-aligned against the margin column, on the page where that heading lands, together
/// with its @chapter numeral (if the heading has a ```typc numbering```) separated by the
/// same rule @chapter uses. Calls `fallback` (with no arguments) on every other page. Meant
/// to be used directly as ```typ #set page(header: ..)```:
/// ```typ
/// #set page(header: glosa.title-header(
///   fallback: () => if here().page() > 1 { glosa.header(..) },
/// ))
/// ```
///
/// Pair with @chapter (```typc show-title: false, show-number: false```) on the same heading
/// so its title and numeral aren't *also* rendered inline in the body — only its mini-outline
/// is, in the margin:
/// ```typ
/// #show heading.where(level: 1): set heading(outlined: false, numbering: "1")
/// #show heading.where(level: 1): glosa.chapter.with(show-title: false, show-number: false)
/// ```
/// (The ```typc outlined: false``` needs its own rule — it has to take effect *before* the
/// heading is constructed, so it can't be folded into @chapter's show-rule handler.)
///
/// Requires context.
/// -> content
#let title-header(
  /// Level of the title heading to look for.
  /// -> int
  level: 1,
  /// Style for the title text.
  /// -> dictionary
  style: (size: 1.3em, weight: "black"),
  /// Style for the numeral — matched to @chapter's own default.
  /// -> dictionary
  number-style: (size: 40pt, weight: "black"),
  /// Stroke for the rule separating title and numeral. ```typc none``` to disable.
  /// -> stroke | none
  rule: 0.6pt + luma(40%),
  /// Called with no arguments on every page that isn't the title heading's own page.
  /// ```typc none``` shows nothing there.
  /// -> none | function
  fallback: none,
) = context {
  let titles = query(heading.where(level: level))
  if titles.len() > 0 and titles.first().location().page() == here().page() {
    let it = titles.first()
    let number = if it.numbering != none {
      numbering(it.numbering, ..counter(heading).at(it.location()))
    } else { none }
    header(
      align(right + horizon, text(..style, it.body)),
      if number != none {
        box(
          width: 100%,
          inset: (left: 1em),
          stroke: if rule != none { (left: rule) } else { none },
          align(horizon, text(..number-style, number)),
        )
      },
    )
  } else if fallback != none {
    fallback()
  }
}

