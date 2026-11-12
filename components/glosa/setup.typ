#import "config.typ": *
#import "logic.typ": _draw-carried

#let setup(..config, body) = {
  _config.update(_fill_config(..config))
  set page(.._page-setup(..config), foreground: _draw-carried())
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
