
#import "config.typ": *
#import "logic.typ": place-note, _get-near-side

/// The default counter used for the note icons.
///
/// If you use @note-numbering without @note-numbering.repeat, it is recommended you reset this occasionally, e.g. per heading or per page.
/// #example(scale-preview: 100%, ```typc notecounter.update(1)```)
/// -> counter
#let notecounter = counter("glosa-note")

/// Defaults for @note and @notefigure that a document class sets once for the whole
/// document, so a plain ```typ #note[..]``` already has the class's size and numbering.
/// `text-style` and `par-style` are merged between glosa's own defaults and the per-note
/// arguments; `numbering` replaces the default of @note.numbering/@notefigure.numbering when
/// that argument is left at ```typc auto```.
/// -> state
#let note-defaults = state("_glosa_note_defaults", (text-style: (:), par-style: (:), numbering: auto))

/// Icons to use for note markers.
///
/// ```typc ("◆", "●", "■", "▲", "♥", "◇", "○", "□", "△", "♡")```
#let note-markers = ("◆", "●", "■", "▲", "♥", "◇", "○", "□", "△", "♡")
/// Icons to use for note markers, alternating filled/outlined.
///
/// ```typc ("●", "○", "◆", "◇", "■", "□", "▲", "△", "♥", "♡")```
#let note-markers-alternating = ("●", "○", "◆", "◇", "■", "□", "▲", "△", "♥", "♡")

/// Format note marker.
/// -> content
#let note-numbering(
  /// #example(```typ
  /// #for i in array.range(1,15) {
  ///   note-numbering(markers: note-markers, i) }
  ///
  /// #for i in array.range(1,15) {
  ///   note-numbering(markers: note-markers-alternating, i) }
  ///
  /// #for i in array.range(1,15) {
  ///   note-numbering(markers: (), i) }
  /// ```)
  /// -> array
  markers: note-markers-alternating,
  /// Whether to (```typc true```) loop over the icons, or (```typc false```) continue with numbers after icons run out.
  /// #example(```typ
  /// #for i in array.range(1,15) {
  ///   note-numbering(repeat: true, i) }
  ///
  /// #for i in array.range(1,15) {
  ///   note-numbering(repeat: false, i) }
  /// ```)
  /// -> bool
  repeat: true,
  /// Wrap the symbol in a styled text function.
  /// -> function
  style: text.with(weight: 900, font: "Inter", size: 5pt, style: "normal", fill: rgb(54%, 72%, 95%)),
  /// Whether to add a space of 2pt after the symbol.
  /// If ```typc auto```, a space is only added if it is a number (the symbols have ran out).
  /// -> auto | bool
  space: auto,
  ..,
  /// -> int
  i,
) = {
  let index = if repeat and markers.len() > 0 { calc.rem(i - 1, markers.len()) } else { i - 1 }
  let symbol = if index < markers.len() {
    markers.at(index)
    if space == true { h(2pt) }
  } else {
    str(index + 1 - markers.len())
    if space == true or space == auto { h(2pt) }
  }
  style(symbol)
}

/// Create a marginnote.
/// Will adjust it's position downwards to avoid previously placed notes, and upwards to avoid extending past the bottom margin.
///
/// Notes can be attached a label and are referenceable (if @glosa-setup was run).
///
/// #compat((
///   "0.1.5": (
///     [`reverse` has been replaced with @note.side.
///      #ergo[use \````typc side: "inner"```\` instead of \````typc reverse: true```\`]],
///     [`numbered` has been replaced with @note.numbering.
///      #ergo[use \````typc numbering: "none"```\` instead of \````typc numbered: false```\`]],
///   ),
///   "0.2.2": (
///     [`align-baseline` has been replaced with @note.alignment.
///      #ergo[use \````typc alignment: "top"```\` instead of \````typc align-baseline: false```\`]],
///   ),
/// ))
#let note(
  /// Counter to use for this note.
  /// Can be set to ```typc none``` do disable numbering this note.
  ///
  /// Will only be stepped if `numbering` is not ```typc none```.
  /// -> counter | none
  counter: notecounter,
  /// Function or `numbering`-string to generate the note markers from the `notecounter`.
  /// - If ```typc none```, will not step the `counter`.
  /// - Will be ignored if `counter` is ```typc none```.
  ///
  /// Examples:
  /// - ```typc (..i) => super(numbering("1", ..i))``` for superscript numbers
  ///   #note(numbering: (..i) => super(numbering("1", ..i)))[E.g.]
  /// - ```typc (..i) => super(numbering("a", ..i))``` for superscript letters
  ///   #note(numbering: (..i) => super(numbering("a", ..i)))[E.g.]
  /// - ```typc glosa.note-numbering.with(repeat: false, markers: ())``` for small blue numbers
  ///   #note(numbering: glosa.note-numbering.with(repeat: false, markers: ()))[E.g.]
  /// - ```typc auto``` uses @note-defaults, or @note-numbering if it sets none.
  /// -> auto | none | function | string
  numbering: auto,
  /// Used to generate the marker for the anchor (i.e. the one in the surrounding text)
  ///
  /// - If ```typc auto```, will use the given @note.numbering.
  /// - Will be ignored if `counter` is ```typc none```.
  /// -> none | auto | function | string
  anchor-numbering: auto,
  /// Whether to have the anchor link to the note, and vice-versa.
  /// -> bool
  link-anchor: true,
  /// Disallow note markers hanging into the whitespace.
  /// - If ```typc auto```, acts like ```typc false``` if @note.anchor-numbering is ```typc auto```.
  /// -> auto | bool
  flush-numbering: auto,
  /// Which side to place the note.
  /// ```typc auto``` defaults to ```typc "outer"```.
  /// In non-book documents, ```typc "outer"```/```typc "inner"``` are equivalent to ```typc "right"```/```typc "left"``` respectively.
  /// ```typc "near"``` will place the note in the left or right margin, depending which is nearer.
  /// -> auto | "outer" | "inner" | "left" | "right" | "near"
  side: auto,
  /// Vertical alignment of the note.
  /// #let note = note.with(block-style: (outset: (left: 5cm), fill: oklch(70%, 0.1, 120deg, 20%)), shift: "ignore")
  /// - ```typc "bottom"``` aligns the bottom edge of the note with the main text baseline.#note(alignment: "bottom")[Bottom\ ...]
  /// - ```typc "baseline"``` aligns the first baseline of the note with the main text baseline.#note(alignment: "baseline")[Baseline\ ...]
  /// - ```typc "top"``` aligns the top edge of the note with the main text baseline.#note(alignment: "top")[Top\ ...]
  ///
  /// -> "baseline" | "top" | "bottom"
  alignment: "baseline",
  /// Inital vertical offset of the note, relative to the alignment point.
  /// The note may get shifted still to avoid other notes depending on @note.shift.
  /// -> length
  dy: 0pt,
  /// Notes with ```typc keep-order: true``` are not re-ordered relative to one another.
  ///
  /// -> bool
  keep-order: false,
  /// Whether the note may get shifted vertically to avoid other notes.
  /// - ```typc true```: The note may shift to avoid other notes, wide-blocks and the top/bottom margins.
  /// - ```typc false```: The note is placed exactly where it appears, and other notes may shift to avoid it.
  /// - ```typc "avoid"```: The note is only shifted if shifting other notes is not sufficent to avoid a collision.
  ///   E.g. if it would collide with a wideblock or a note with ```typc shift: false```.
  /// - ```typc "ignore"```: Like ```typc false```, but other notes do not try to avoid it.
  /// - ```typc auto```: ```typc true``` if numbered, ```typc "avoid"``` otherwise.
  /// -> bool | auto | "avoid" | "ignore"
  shift: auto,
  /// Will be used to ```typc set``` the text style, on top of
  /// ```typc (size: 9.35pt, style: "normal", weight: "regular")``` and @note-defaults.
  /// -> dictionary
  text-style: (:),
  /// Will be used to ```typc set``` the par style, on top of
  /// ```typc (spacing: 1.2em, leading: 0.5em, hanging-indent: 0pt)``` and @note-defaults.
  /// -> dictionary
  par-style: (:),
  /// Will be passed to the `block` containing the note body.
  /// If this is a function, it will be called with ```typc "left"``` or ```typc "right"``` as its argument, and the result is passed to the `block`.
  /// -> dictionary | function
  block-style: (width: 100%),
  /// -> content
  body,
) = {
  metadata("_glosa_note")

  // `auto` always steps: @note-defaults can change the numbering, not turn it off
  if counter != none and numbering != none { counter.step() }

  context {
    let defaults = note-defaults.get()
    let numbering = if counter == none { none } else if numbering != auto { numbering } else if (
      defaults.numbering != auto
    ) { defaults.numbering } else { note-numbering }
    let flush-numbering = if flush-numbering == auto { anchor-numbering != auto } else { flush-numbering }
    let anchor-numbering = if anchor-numbering == auto { numbering } else { anchor-numbering }

    let shift = if shift == auto { if numbering != none { true } else { "avoid" } } else { shift }

    let text-style = (size: 9.35pt, style: "normal", weight: "regular", ..defaults.text-style, ..text-style)
    let par-style = (spacing: 1.2em, leading: 0.5em, hanging-indent: 0pt, ..defaults.par-style, ..par-style)

    let side = if side == "outer" or side == auto {
      if _config.get().book and calc.even(here().page()) { "left" } else { "right" }
    } else if side == "inner" {
      if _config.get().book and calc.even(here().page()) { "right" } else { "left" }
    } else { side }

    assert(
      side == "left" or side == "right" or side == "near",
      message: "side must be auto, left, right, near, outer, or inner.",
    )
    let body = if numbering != none {
      let number = {
        if link-anchor {
          show link: it => {
            show underline: i => i.body
            it
          }
          link(here(), counter.display(numbering))
        } else {
          counter.display(numbering)
        }
      }
      if flush-numbering {
        box(number)
        h(0pt, weak: true)
        body
      } else {
        body
        let width = measure({
          set text(..text-style)
          set par(..par-style)
          number
        }).width
        if width < 8pt { width = 8pt }
        place(
          top + start,
          {
            h(-width) // HACK: uses `h` instad of `dx` so it works in ltr and rtl contexts
            box(
              width: width,
              {
                h(1fr)
                sym.zws
                number
                h(1fr)
              },
            )
          },
        )
      }
    } else {
      body
    }

    let block-style = if type(block-style) == function {
      block-style(side)
    } else {
      block-style
    }

    let anchor = if anchor-numbering != none and counter != none {
      counter.display(anchor-numbering)
    } else []

    let body = align(
      top,
      block(
        width: 100%,
        ..block-style,
        align(
          start,
          {
            // HACK: inner align ensures text-direction is unaffected by `place(left,..)`
            set text(..text-style)
            set par(..par-style)
            [#metadata((note: true, anchor: anchor))<_glosa_note>#body]
          },
        ),
      ),
    )

    let dy-adjust = if alignment == "baseline" {
      measure(text(..text-style, sym.zws)).height
    } else if alignment == "top" {
      0pt
    } else if alignment == "bottom" {
      let width = if side == "left" {
        get-left().width
      } else {
        get-right().width
      }
      measure(width: width, body).height
    } else {
      panic("Unknown value for alignment")
    }
    let dy = dy - dy-adjust

    h(0pt, weak: true)
    box({
      if anchor-numbering != none {
        if link-anchor {
          show link: it => {
            show underline: i => i.body
            it
          }
          let dest = query(selector(<_glosa_note>).after(here()))
          if dest.len() > 0 {
            link(dest.first().location(), anchor)
          } else {
            anchor
          }
        } else {
          anchor
        }
      }
      place-note(side: side, dy: dy, keep-order: keep-order, shift: shift, body)
    })
  }
}

/// Reference a nearby margin note. Will place the same anchor as that note had.
///
/// Be aware that notes without an anchor (including notefigures) still count for the offset, but the rendered link is empty.
///
/// #example(scale-preview: 100%, ```typ
///   This is a note: #note[Blah Blah]
///
///   This is a link to that note:
///     #glosa.ref(-1)
///
///   This is an unnumbered note:
///     #note(counter: none)[Blah Blah]
///
///   This is a useless link to that note:
///     #glosa.ref(-1)
///   ```)
#let ref(
  /// How many notes away the target note is.
  /// - ```typc -1```: The previous note.
  /// - ```typc 0```: Disallowed
  /// - ```typc 1```: The next note.
  /// -> integer
  offset,
) = context {
  h(0pt, weak: true)
  show link: it => {
    show underline: i => i.body
    it
  }
  assert(offset != 0, message: "glosa.ref offset must not be 0.")
  if offset > 0 {
    let dest = query(selector(<_glosa_note>).after(here()))
    assert(dest.len() > offset, message: "Not enough notes after this to reference")
    link(dest.at(offset - 1).location(), dest.at(offset - 1).value.anchor)
  } else {
    let dest = query(selector(<_glosa_note>).before(here()))
    assert(dest.len() >= -offset, message: "Not enough notes before this to reference")
    link(dest.at(offset).location(), dest.at(offset).value.anchor)
  }
}

/// Creates a figure in the margin.
///
/// Parameters `numbering`, `anchor-numbering`, `flush-numbering`, `side`, `keep-order`, `shift`, `text-style`, `par-style`, and `block-style` work the same as for @note.
///
/// Notefigures can be attached a label and are referenceable (if @glosa-setup was run). Furthermore, the underlying @note can be given a label using the `note-label` parameter.
///
/// #compat((
///   "0.1.5": (
///     [`reverse` has been replaced with @notefigure.side.
///      #ergo[use \````typc side: "inner"```\` instead of \````typc reverse: true```\`]],
///     [`numbered` has been replaced with @notefigure.numbering.
///      #ergo[use \````typc numbering: glosa.note-numbering```\` instead of \````typc numbered: true```\`]],
///   ),
///   "0.2.2": (
///     [@notefigure.dy no longer takes a relative length, instead @notefigure.alignment was added.],
///   ),
///   "0.3.0": (
///     [The `label` argument has been removed.
///      #ergo[Instead of ```typ #notefigure(label: <l>, ..)```, use ```typ #notefigure(..)<l>```.]],
///   )
/// ))
/// -> content
#let notefigure(
  /// Same as @note.numbering, but with different default.
  /// Set this to `glosa.notecounter` (or another counter) to enable numbering this note.
  ///
  /// Will only be stepped if `numbering` is not ```typc none```.
  ///
  /// #example(scale-preview: 100%, dir: ttb, ```typ
  /// Notefigure with marker:
  /// #notefigure(rect(height: 10pt, width: 100%), caption: [...], counter: glosa.notecounter)
  /// ```)
  /// #example(scale-preview: 100%, dir: ttb, ```typ
  /// Using the figure counter for the numbering:
  /// #notefigure(
  ///   rect(height: 10pt, width: 100%), caption: [...],
  ///   counter: counter(figure.where(kind: image)),
  ///   anchor-numbering: (.., i) => super[fig. #numbering("1", i+1)], numbering: none,
  /// )
  /// ```)
  /// -> counter | none
  counter: none,
  /// Same as @note.numbering.
  /// -> auto | none | function | string
  numbering: auto,
  /// Same as @note.anchor-numbering.
  /// -> none | auto | function | string
  anchor-numbering: auto,
  /// Whether to have the anchor link to the note, and vice-versa.
  /// -> bool
  link-anchor: true,
  /// Disallow note markers hanging into the whitespace.
  /// - If ```typc auto```, acts like ```typc false``` if @notefigure.anchor-numbering is ```typc auto```.
  /// -> auto | bool
  flush-numbering: auto,
  /// Which side to place the note.
  /// ```typc auto``` defaults to ```typc "outer"```.
  /// In non-book documents, ```typc "outer"```/```typc "inner"``` are equivalent to ```typc "right"```/```typc "left"``` respectively.
  /// -> auto | "outer" | "inner" | "left" | "right" | "near"
  side: auto,
  /// Vertical alignment of the notefigure.
  /// #let notefigure = notefigure.with(shift: "ignore", show-caption: (number, caption) => block(outset: (left: 5cm), width: 100%, fill: oklch(70%, 0.1, 120deg, 20%), {
  ///   number; caption.supplement; [ ]; caption.counter.display(caption.numbering); caption.separator; caption.body
  /// }))
  /// - ```typc "top"```, ```typc "bottom"``` work the same as @note.alignment.
  /// - ```typc "baseline"``` aligns the first baseline of the _caption_ with the main text baseline.
  ///   #notefigure(rect(width: 100%, height: 2pt, stroke: 0.5pt + gray), alignment: "baseline", caption: [Baseline])
  /// - ```typc "caption-top"``` aligns the top of the caption with the main text baseline.
  ///   #notefigure(rect(width: 100%, height: 2pt, stroke: 0.5pt + gray), alignment: "caption-top", caption: [Caption-top])
  ///
  /// -> "baseline" | "top" | "bottom" | "caption-top"
  alignment: "baseline",
  /// Inital vertical offset of the notefigure, relative to the alignment point.
  ///
  /// The notefigure may get shifted still to avoid other notes depending on ```typc notefigure.shift```.
  /// -> length
  dy: 0pt,
  /// -> bool
  keep-order: false,
  /// -> bool | auto | "avoid" | "ignore"
  shift: auto,
  /// Same as @note.text-style.
  /// -> dictionary
  text-style: (:),
  /// Same as @note.par-style.
  /// -> dictionary
  par-style: (:),
  /// Will be passed to the `block` containing the note body (this contains the entire figure).
  /// If this is a function, it will be called with ```typc "left"``` or ```typc "right"``` as its argument, and the result is passed to the `block`.
  /// -> dictionary | function
  block-style: (width: 100%),
  /// A function with two arguments, the (note-)number and the caption.
  /// Will be called as the caption show rule.
  ///
  /// If @notefigure.numbering is ```typc none```, `number` will be ```typc none```.
  /// -> function
  show-caption: (number, caption) => {
    number
    caption.supplement
    [ ]
    caption.counter.display(caption.numbering)
    caption.separator
    caption.body
  },
  /// Pass-through to ```typ #figure()```, but used to adjust the vertical position.
  /// -> length
  gap: 0.55em,
  /// A label to attach to the note. Referencing this label will repeat the anchor,
  /// so it is only really useful if @notefigure.anchor-numbering is not ```typc none```.
  /// -> none | label
  note-label: none,
  /// The figure content, e.g.~an image. Pass-through to ```typ #figure()```, but used to adjust the vertical position.
  /// -> content
  content,
  /// Pass-through to ```typ #figure()```.
  ///
  /// (E.g. `caption`)
  /// -> arguments
  ..figureargs,
) = {
  [#metadata("_glosa_notefigure")<_glosa_notefigure>]

  if counter != none and numbering != none { counter.step() }

  context {
    let defaults = note-defaults.get()
    let numbering = if counter == none { none } else if numbering != auto { numbering } else if (
      defaults.numbering != auto
    ) { defaults.numbering } else { note-numbering }
    let flush-numbering = if flush-numbering == auto { anchor-numbering != auto } else { flush-numbering }
    let anchor-numbering = if anchor-numbering == auto { numbering } else { anchor-numbering }

    let shift = if shift == auto { if numbering != none { true } else { "avoid" } } else { shift }

    let text-style = (size: 9.35pt, style: "normal", weight: "regular", ..defaults.text-style, ..text-style)
    let par-style = (spacing: 1.2em, leading: 0.5em, hanging-indent: 0pt, ..defaults.par-style, ..par-style)

    let number = if counter != none and numbering != none {
      if link-anchor {
        show link: it => {
          show underline: i => i.body
          it
        }
        link(here(), counter.display(numbering))
      } else {
        counter.display(numbering)
      }
    } else { none }
    let number-width = if numbering != none and not flush-numbering {
      let width = measure({
        set text(..text-style)
        set par(..par-style)
        number
      }).width
      if width < 8pt { 8pt } else { width }
    } else { 0pt }

    set figure.caption(position: bottom)
    show figure.caption: it => {
      set align(left)
      if numbering != none {
        context if flush-numbering {
          show-caption(
            number,
            it,
          )
        } else {
          show-caption(
            place(
              // top + left,
              left,
              dx: -number-width,
              box(
                width: number-width,
                {
                  h(1fr)
                  sym.zws
                  number
                  h(1fr)
                },
              ),
            ),
            it,
          )
        }
      } else {
        context show-caption(none, it)
      }
    }

    let side = if side == "outer" or side == auto {
      if _config.get().book and calc.even(here().page()) { "left" } else { "right" }
    } else if side == "inner" {
      if _config.get().book and calc.even(here().page()) { "right" } else { "left" }
    } else if side == "near" {
      _get-near-side()
    } else {
      side
    }

    let width = if side == "left" {
      get-left().width
    } else {
      get-right().width
    }
    let height = (
      measure(
        width: width,
        {
          set text(..text-style)
          set par(..par-style)
          content
        },
      ).height
        + measure(text(..text-style, v(gap))).height
    )
    let baseline-height = measure(text(..text-style, sym.zws)).height
    let alignment = alignment
    let dy = dy
    if alignment == "baseline" {
      alignment = "top"
      dy = dy - height - baseline-height
    } else if alignment == "caption-top" {
      alignment = "top"
      dy = dy - height
    }

    let index = query(selector(<_glosa_notefigure>).before(here())).len()
    let figure-label = std.label("_glosa_notefigure__" + str(index))

    [#note(
        numbering: none,
        anchor-numbering: anchor-numbering,
        link-anchor: link-anchor,
        counter: counter,
        side: side,
        dy: dy,
        alignment: alignment,
        keep-order: keep-order,
        shift: shift,
        text-style: text-style,
        par-style: par-style,
        block-style: block-style,
        [#figure(
            content,
            gap: gap,
            placement: none,
            ..figureargs,
          )#figure-label],
      )#note-label]
    // for unclear reasons, if this is placed before the note, it becomes part of the content referenced by note-label.
    [#metadata((label: figure-label))<_glosa_notefigure_meta>]
  }
}
