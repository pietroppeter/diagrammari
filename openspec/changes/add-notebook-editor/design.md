## Context

What does a Python library need to offer an interactive editor in Jupyter and in marimo? Notes
from the proof of concept (`experiments/python/`, 7 Nov 2026), so the next person does not have
to find out again.

## Decisions

### anywidget, one module for both

- **ipywidgets** (8.1.9) is the Jupyter widget protocol: a Python model and a JavaScript view
  that keep traits in sync over the kernel's comm channel. Writing one used to mean a JupyterLab
  extension with a build step and a cookiecutter.
- **anywidget** (0.11.0) is a thin layer over it: the view is one ES module given as a string or
  a file (`_esm`, optional `_css`), loaded by the front end at run time. No extension, no build.
  The same widget runs in JupyterLab, Notebook 7, VS Code, Colab, and in marimo.
- **marimo** (0.25.2) is reactive: a cell reruns when a value it reads changes. It has its own
  UI elements (`mo.ui.*`) and runs any anywidget through `mo.ui.anywidget(widget)`: its `.value`
  is the dict of synced traits, and reading it makes the cell rerun on each change. That is all
  the "marimo integration" there is to write.

Chosen: an anywidget. ipywidgets alone would mean a JupyterLab extension, and marimo would not
take it; a marimo-only plugin would leave Jupyter out.

### Traits

`source` (str, Python to browser), `layer` (dict, both ways), `svg` (str, browser to Python: what
the editor shows, handy to compare with the export). The layer is saved on pointer up, not on
each move, so the kernel sees one change per drag.

### Pele in the module

The module is Pele's browser bundle (about 730 kB, an IIFE that defines `pele`) followed by the
editor. Read from the package at import, sent once per widget. Lighter loads (Pele's per-type
ESM builds) are the BACKLOG item "Lighter client pages", and apply here too.

### Gotchas found

- marimo renders each anywidget inside a shadow root: styles appended to `document.head` do not
  apply. The style goes inside `el` (or in `_css`, which anywidget scopes).
- Pages may match `g.pele-node` twice (the editor and an exported SVG in another cell); tests
  select inside `.mari-w`.
- Pointer events on thin arrows: a wide transparent `path.hit` over each edge, as in the browser
  proof of concept.

### A browser tab without a notebook

`edit_in_browser` runs `http.server` on 127.0.0.1 (a free port), serves a page that imports the
same module with a stand-in model (`get`, `set`, `on`, `save_changes`), and blocks until the
page posts the layer. No new dependency; works from a script or the REPL.

## Risks / Trade-offs

- Fonts: the editor measures labels with the browser's fonts, the export with Arial's widths
  (see the Python design). The export is the truth; the editor shows a warning when the theme's
  font is not loaded.
- Pyodide and JupyterLite: the widget would work (it is all in the browser), but the export needs
  the Nim library compiled for WebAssembly. BACKLOG.

## Open Questions

- Should the editor also edit the text (a source pane), or stay a layer editor next to the
  notebook's own cell? The proof of concept edits the layer only.
