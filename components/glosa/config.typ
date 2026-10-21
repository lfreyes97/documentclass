
///#internal()
#let _fill_config(..config) = {
  let config = config.named()
  // default margins a4 are 2.5 cm
  let inner = config.at("inner", default: (far: 5mm, width: 15mm, sep: 5mm))
  let outer = config.at("outer", default: (far: 5mm, width: 15mm, sep: 5mm))
  return (
    inner: (
      far: inner.at("far", default: 5mm),
      width: inner.at("width", default: 15mm),
      sep: inner.at("sep", default: 5mm),
    ),
    outer: (
      far: outer.at("far", default: 5mm),
      width: outer.at("width", default: 15mm),
      sep: outer.at("sep", default: 5mm),
    ),
    top: config.at("top", default: 2.5cm),
    bottom: config.at("bottom", default: 2.5cm),
    book: config.at("book", default: false),
    clearance: config.at("clearance", default: 12pt),
  )
}

#let _config = state("_glosa_config", _fill_config())

/// Page setup helper
///
/// This will generate a dictionary ```typc ( margin: .. )``` compatible with the passed config.
/// This can then be spread into the page setup like so:
///```typ
/// #set page( ..page-setup(..config) )```
///
/// Takes the same options as @glosa-setup.
/// -> dictionary
#let _page-setup(
  /// Missing entries are filled with package defaults. Note: missing entries are _not_ taken from the current glosa config, as this would require context.
  /// -> dictionary
  ..config,
) = {
  let config = _fill_config(..config)
  if config.book {
    return (
      binding: left,
      margin: (
        inside: config.inner.far + config.inner.width + config.inner.sep,
        outside: config.outer.far + config.outer.width + config.outer.sep,
        top: config.top,
        bottom: config.bottom,
      ),
    )
  } else {
    return (
      binding: left,
      margin: (
        left: config.inner.far + config.inner.width + config.inner.sep,
        right: config.outer.far + config.outer.width + config.outer.sep,
        top: config.top,
        bottom: config.bottom,
      ),
    )
  }
}

/// This will update the glosa config and setup the page with the provided config options.
/// (This means this will insert a pagebreak.)
///
/// Use as
/// ```typ
/// #show: glosa.setup.with(/* options here */)
/// ```
///
/// The default values for the margins have been chosen such that they match the default typst margins for a4. It is strongly recommended to change at least one of either `inner` or `outer` to be wide enough to actually contain text.
///
/// This function also sets up the neccesary show-rule to allow referencing labelled notes.
/// If you also have a custom ```typ #show ref:``` rule, it may be relevant if setup is called before or after that show rule.
///
/// #compat((
///   "0.1.5": (
///     [`numbering` has been replaced with @note.numbering/@notefigure.numbering.
///      #ergo[set \````typc numbering: /**/```\` directly on your notes instead of via @glosa-setup.\ Use ```typ #let note = note.with(numbering: /**/)``` for consistency.]],
///     [`flush-numbers` has been replaced by @note.flush-numbering.
///      #ergo[set \````typc flush-numbering: true```\` directly on your notes instead of via @glosa-setup.\ Use ```typ #let note = note.with(flush-numbering: /**/)``` for consistency.]],
///   ),
///   "0.2.0": (
///     [This function does no longer apply the configuration partially, but will reset all unspecified options to the default.
///      Additionally, it replaces the `page-setup()` function that was needed previously and is no longer called `configure()`],
///   ),
/// ))
#let setup(
  /// Inside/left margins.
  ///     - `far`: Distance between edge of page and margin (note) column.
  ///     - `width`: Width of the margin column.
  ///     - `sep`: Distance between margin column and main text column.
  ///
  /// The page inside/left margin should equal `far` + `width` + `sep`.
  ///
  /// If partial dictionary is given, it will be filled up with defaults.
  /// -> dictionary
  inner: (far: 5mm, width: 15mm, sep: 5mm),
  /// Outside/right margins. Analogous to `inner`.
  /// -> dictionary
  outer: (far: 5mm, width: 15mm, sep: 5mm),
  /// Top margin.
  /// -> length
  top: 2.5cm,
  /// Bottom margin.
  /// -> length
  bottom: 2.5cm,
  ///- If ```typc true```, will use inside/outside margins, alternating on each page.
  ///- If ```typc false```, will use left/right margins with all pages the same.
  /// -> bool
  book: false,
  /// Minimal vertical distance between notes and to wide blocks.
  /// -> length
  clearance: 12pt,
  /// -> content
  body,
) = {}
#let setup(..config, body) = {
  _config.update(_fill_config(..config))
  set page(.._page-setup(..config))
  show ref: it => {
    if (
      it.has("element")
        and it.element != none
        and it.element.has("children")
        and it.element.children.len() > 1
        and it.element.children.first().func() == metadata
    ) {
      if it.element.children.first().value == "_glosa_note" {
        h(0pt, weak: true)
        show link: it => {
          show underline: i => i.body
          it
        }
        let dest = query(selector(<_glosa_note>).after(it.element.location()))
        assert(dest.len() > 0, message: "Could not find referenced note")
        link(dest.first().location(), dest.first().value.anchor)
      } else if it.element.children.first().value == "_glosa_notefigure" {
        let dest = query(selector(<_glosa_notefigure_meta>).after(it.element.location()))
        assert(dest.len() > 0, message: "Could not find referenced notefigure")
        if it.has("form") {
          std.ref(dest.first().value.label, form: it.form, supplement: it.supplement)
        } else {
          std.ref(dest.first().value.label, supplement: it.supplement)
        }
      } else {
        it
      }
    } else {
      it
    }
  }
  body
}

/// // #internal[(mostly for internal use)]
/// Returns a dictionary with the keys `far`, `width`, `sep` containing the respective widths of the
/// left margin on the current page. (On both even and odd pages.)
///
/// Requires context.
/// -> dictionary
#let get-left() = {
  let config = _config.get()
  if not (config.book) or calc.odd(here().page()) {
    return config.inner
  } else {
    return config.outer
  }
}

/// // #internal[(mostly for internal use)]
/// Returns a dictionary with the keys `far`, `width`, `sep` containing the respective widths of the
/// right margin on the current page. (On both even and odd pages.)
///
/// Requires context.
/// -> dictionary
#let get-right() = {
  let config = _config.get()
  if not (config.book) or calc.odd(here().page()) {
    return config.outer
  } else {
    return config.inner
  }
}

#let _note_extends_left = state("_glosa_note_extends_left", (:))
#let _note_extends_right = state("_glosa_note_extends_right", (:))
