
#import "config.typ": *

/// #internal[(mostly for internal use)]
/// Calculates positions for notes.
///
/// Return type is of the form `(<index/id>: offset)`
/// -> dictionary
#let _calculate-offsets(
  /// Of the form
  /// ```typc
  /// (
  ///   height: length, // total page height
  ///   top: length,    // top margin
  ///   bottom: length, // bottom margin
  /// )
  /// ```
  /// -> dictionary
  page,
  /// Of the form `(<index/id>: item)` where items have the form
  /// ```typc
  /// (
  ///   natural: length,    // initial vertical position of item, relative to page
  ///   height: length,     // vertical space needed for item
  ///   clearance: length,  // vertical padding required.
  ///                       // may be collapsed at top & bottom of page, and above separators
  ///   shift: bool | "ignore" | "avoid", // whether the item may be moved about. `auto` = move only if neccessary
  ///   keep-order: bool,   // if false, may be reordered. if true, order relative to other `false` items is kept
  /// )
  /// ```
  /// -> dictionary
  items,
  /// -> length
  clearance,
) = {
  // sorting
  let ignore = ()
  let reorderable = ()
  let nonreorderable = ()
  for (key, item) in items.pairs() {
    if item.shift == "ignore" {
      ignore.push(key)
    } else if item.keep-order == false {
      reorderable.push((key, item.natural))
    } else {
      nonreorderable.push((key, item.natural))
    }
  }
  reorderable = reorderable.sorted(key: ((_, pos)) => pos)

  let positions = ()

  let index_r = 0
  let index_n = 0
  while index_r < reorderable.len() and index_n < nonreorderable.len() {
    if reorderable.at(index_r).at(1) <= nonreorderable.at(index_n).at(1) {
      positions.push(reorderable.at(index_r))
      index_r += 1
    } else {
      positions.push(nonreorderable.at(index_n))
      index_n += 1
    }
  }
  while index_n < nonreorderable.len() {
    positions.push(nonreorderable.at(index_n))
    index_n += 1
  }
  while index_r < reorderable.len() {
    positions.push(reorderable.at(index_r))
    index_r += 1
  }

  // shift down
  let cur = page.top
  let empty = 0pt
  let prev-shift-avoid = false
  let positions_d = ()
  for (key, position) in positions {
    let fault = cur - position
    if cur <= position {
      positions_d.push((key, position))
      if items.at(key).shift == false {
        empty = 0pt
      } else {
        empty += position - cur
      }
      cur = position + items.at(key).height + clearance
    } else if items.at(key).shift == "avoid" {
      if fault <= empty {
        if prev-shift-avoid {
          positions_d.push((key, cur))
          cur = cur + items.at(key).height + clearance
        } else {
          // can stay
          positions_d.push((key, position))
          empty -= fault // ?
          cur = position + items.at(key).height + clearance
        }
      } else {
        if prev-shift-avoid {
          positions_d.push((key, cur))
          cur = cur + items.at(key).height + clearance
        } else {
          positions_d.push((key, position + fault - empty))
          cur = position + fault - empty + items.at(key).height + clearance
          empty = 0pt
        }
      }
    } else if items.at(key).shift == false {
      // check if we can swap with previous
      if (
        positions_d.len() > 0
          and fault > empty
          and items.at(positions_d.last().at(0)).shift != false
          and ((not items.at(key).keep-order) or (not items.at(positions_d.last().at(0)).keep-order))
      ) {
        let (prev, _) = positions_d.pop()
        cur -= items.at(prev).height
        positions_d.push((key, position))
        empty = 0pt
        let new_x = calc.max(position + items.at(key).height + clearance, cur)
        cur = new_x
        positions_d.push((prev, cur))
        cur = cur + items.at(prev).height + clearance
      } else {
        positions_d.push((key, position))
        empty = 0pt
        cur = calc.max(position + items.at(key).height + clearance, cur)
      }
    } else {
      positions_d.push((key, cur))
      empty += 0pt
      // empty = 0pt
      cur = cur + items.at(key).height + clearance
    }
    prev-shift-avoid = items.at(key).shift == "avoid"
  }

  let positions = ()

  let max = if page.height == auto {
    if positions_d.len() > 0 {
      let (key, position) = positions_d.at(-1)
      position + items.at(key).height
    } else { 0pt }
  } else {
    page.height - page.bottom
  }
  for (key, position) in positions_d.rev() {
    if max > position + items.at(key).height {
      positions.push((key, position))
      max = position - clearance
    } else if items.at(key).shift == false {
      positions.push((key, position))
      max = calc.min(position - clearance, max)
    } else {
      positions.push((key, max - items.at(key).height))
      max = max - items.at(key).height - clearance
    }
  }

  let result = (:)
  for (key, position) in positions {
    result.insert(key, position - items.at(key).natural)
  }
  for key in ignore {
    result.insert(key, 0pt)
  }
  result
}


#let _overflow-eps = 0.5pt

/// #internal[(mostly for internal use)]
/// Places the items of one page and one side. When `carry` is true, the notes that do not fit
/// (the last ones, in page order) are taken off the page and listed in `carried`.
///
/// `items` is an array of the items described in @_calculate-offsets; items that carry a `body`
/// are notes and may be carried, the others (wide blocks) stay. The result is
/// `(offsets: (<index>: offset), carried: (<index>, …))`, with `carried` in page order.
/// -> dictionary
#let _fit-page(page, items, clearance, carry) = {
  let active = range(items.len())
  let carried = ()
  let offsets = (:)
  while true {
    let dict = active.map(k => (str(k), items.at(k))).to-dict()
    offsets = _calculate-offsets(page, dict, clearance)
    if not carry { break }
    let movable = active.filter(k => items.at(k).shift not in (false, "ignore") and items.at(k).at("body", default: none) != none)
    let above = movable.filter(k => items.at(k).natural + offsets.at(str(k)) < page.top - _overflow-eps)
    if above.len() == 0 { break }
    // The note furthest down the page goes first; carried-in notes (natural at the top) go last
    let last = movable.sorted(key: k => (items.at(k).natural, k)).last()
    active = active.filter(k => k != last)
    carried.push(last)
  }
  (offsets: offsets, carried: carried.rev())
}

/// #internal[(mostly for internal use)]
/// Lays out the notes of pages `1` to `upto`, carrying the ones that do not fit to the next page.
/// `regs` has the form `(left: (<page>: items), right: (<page>: items))`. In a book the outer
/// column alternates sides, so a note carried from the right column goes to the left one.
/// The last page does not carry (there is no page to carry to): `last` is its number.
///
/// Returns `(<page>: (left: (items:, offsets:, carried:), right: …))`. Items carried into a page come
/// first, with `carried: true` and `natural` at the top margin.
/// -> dictionary
#let _carry-layout(regs, page, clearance, book, upto, last, carry) = {
  let result = (:)
  let incoming = (left: (), right: ())
  for p in range(1, upto + 1) {
    let this = (:)
    let next = (left: (), right: ())
    for side in ("left", "right") {
      let own = regs.at(side).at(str(p), default: ())
      let carried-in = incoming.at(side).map(it => (..it, natural: page.top, shift: true, keep-order: true, carried: true))
      let items = carried-in + own.map(it => (..it, carried: false))
      let fit = _fit-page(page, items, clearance, carry and p < last)
      this.insert(side, (items: items, offsets: fit.offsets, carried: fit.carried))
      let target = if book { if side == "left" { "right" } else { "left" } } else { side }
      for k in fit.carried { next.insert(target, next.at(target) + (items.at(k),)) }
    }
    result.insert(str(p), this)
    incoming = next
  }
  result
}

/// #internal[(mostly for internal use)]
/// The page geometry, the total number of pages and the registered notes (requires context).
/// -> dictionary
#let _note-state() = {
  let cfg = _config.get()
  (
    page: (height: if page.flipped { page.width } else { page.height }, bottom: cfg.bottom, top: cfg.top),
    clearance: cfg.clearance,
    book: cfg.book,
    carry: cfg.overflow == "carry",
    mark: cfg.overflow-mark,
    last: calc.max(counter(page).final().first(), 1),
    regs: (left: _note_extends_left.final(), right: _note_extends_right.final()),
  )
}

/// #internal[(mostly for internal use)]
/// Draws on every page the notes carried over from the previous one, each marked with an arrow.
/// Requires context.
/// -> content
#let _draw-carried() = context {
  let st = _note-state()
  if not st.carry { return }
  let n = here().page()
  let layout = _carry-layout(st.regs, st.page, st.clearance, st.book, n, st.last, true).at(str(n))
  let pagewidth = if page.flipped { page.height } else { page.width }
  for side in ("left", "right") {
    let fit = layout.at(side)
    for (index, item) in fit.items.enumerate() {
      if not item.carried or index in fit.carried { continue }
      let column = if side == "left" { get-left() } else { get-right() }
      let x = if side == "left" { column.far } else { pagewidth - column.far - column.width }
      let y = st.page.top + fit.offsets.at(str(index))
      place(top + left, dx: x, dy: y, item.body)
      // The mark sits in the gutter between the column and the text, level with the note's first line,
      // so it never touches the neighbouring notes and the note keeps the height it was laid out with
      if st.mark != none {
        let mark = if st.mark == auto { text(size: 0.85em, fill: luma(35%))[↑] } else { st.mark }
        let width = measure(mark).width
        // The numerals hang out of the left edge of a column, so on the right the mark goes beyond them
        let dx = if side == "left" { x + column.width + 3pt } else { x - width - 11pt }
        place(top + left, dx: dx, dy: y + 0.05em, mark)
      }
    }
  }
}

// Internal use.
// Requires Context.
// -> "left" | "right"
#let _get-near-side() = {
  let anchor = here().position()
  let pagewidth = if page.flipped { page.height } else { page.width }
  let left = get-left()
  let right = get-right()
  if (
    anchor.x - left.far - left.width - left.sep
      < (pagewidth - left.far - left.width - left.sep - right.far - right.width - right.sep) / 2
  ) {
    "left"
  } else {
    "right"
  }
}

// Internal use.
#let place-note(
  /// -> "right" | "left" | "near"
  side: "right",
  dy: 0pt,
  keep-order: false,
  shift: true,
  body,
) = (
  box(
    width: 0pt,
    context {
      assert(side == "left" or side == "right" or side == "near", message: "side must be left or right.")

      let dy = dy.to-absolute()
      let anchor = here().position()
      let pagewidth = if page.flipped { page.height } else { page.width }
      let page_num = str(anchor.page)

      let side = if side == "near" { _get-near-side() } else { side }

      let width = if side == "left" { get-left().width } else { get-right().width }
      let height = measure(body, width: width).height
      let notebox = box(width: width, height: height, body)
      let natural_position = anchor.y + dy

      let extends = if side == "right" { _note_extends_right } else { _note_extends_left }

      let current = extends.get().at(page_num, default: ())
      let index = current.len()

      extends.update(old => {
        let oldpage = old.at(page_num, default: ())
        oldpage.push((natural: natural_position, height: height, shift: shift, keep-order: keep-order, body: notebox, raw: body))
        old.insert(page_num, oldpage)
        old
      })

      let st = _note-state()
      let fit = _carry-layout(st.regs, st.page, st.clearance, st.book, anchor.page, st.last, st.carry).at(page_num).at(side)
      // Notes carried into this page come before this page's own notes
      let id = fit.items.filter(it => it.carried).len() + index

      // Carried out to the next page: that page draws it
      if id in fit.carried { return }
      let vadjust = dy + fit.offsets.at(str(id), default: 0pt)

      let hadjust = if side == "left" { get-left().far - anchor.x } else {
        pagewidth - anchor.x - get-right().far - get-right().width
      }

      place(left, dx: hadjust, dy: vadjust, notebox)
    },
  )
)
