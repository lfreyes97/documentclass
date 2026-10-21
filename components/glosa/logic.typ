
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
        oldpage.push((natural: natural_position, height: height, shift: shift, keep-order: keep-order))
        old.insert(page_num, oldpage)
        old
      })

      let offset_page = (
        height: if page.flipped { page.width } else { page.height },
        bottom: _config.get().bottom,
        top: _config.get().top,
      )
      let offset_items = extends
        .final()
        .at(page_num, default: ())
        .enumerate()
        .map(((key, item)) => (str(key), item))
        .to-dict()
      let offset_clearance = _config.get().clearance
      let offsets = _calculate-offsets(offset_page, offset_items, offset_clearance)

      let vadjust = dy + offsets.at(str(index), default: 0pt)

      let hadjust = if side == "left" { get-left().far - anchor.x } else {
        pagewidth - anchor.x - get-right().far - get-right().width
      }

      place(left, dx: hadjust, dy: vadjust, notebox)
    },
  )
)
