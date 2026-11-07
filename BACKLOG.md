# Backlog

Ideas for diagrammari. A loose list, not a roadmap: nothing here is committed. When an idea is
picked up it becomes an OpenSpec change (`/opsx:propose`) and is marked *in progress* here with
the change name; when the change is archived, its entry is removed and a line goes to
[CHANGELOG.md](CHANGELOG.md).

Rough size: S (hours), M (a day or two), L (more).

## Builders

- **State diagrams** (M). `stateDiagram`: states, transitions, nested states (a body, as
  subgraphs), `[*]`, choice and fork, notes.
- **Class and ER diagrams** (M). `classDiagram` with members from Nim types (a macro over a
  `type` section?), `erDiagram` with cardinalities as an enum.
- **Gantt** (M). Tasks with `times.DateTime` and `Duration`, dependencies by id, sections.
- **Mind map and tree** (S). From nested Nim data (`seq` of nodes, or a JSON tree).
- **Sankey and other charts** (S). `sankey` from a `seq` of (source, target, value);
  `xychart`, `radar`, `treemap` from Nim arrays. Overlaps with tabelline's data: maybe a
  `TableData` overload.
- **Flowchart from Nim** (L). Draw a proc's control flow, or a module's imports, from the AST.

## Rendering

- **Text measurement in Node** (M). Pele in Node measures with Arial's widths. Pass a measurer
  for the page's font (widths from the font file, read once in Node), so any font fits at build
  time.
- **Zoom for static diagrams** (S). Pele's `enableZoom` on an inline SVG, opt-in, with the bundle.
- **Lighter client pages** (S). Load only the diagram types a page uses (`pele/core` +
  `pele/diagrams/<type>` ESM builds) instead of the whole bundle.
- **Mermaid as a fallback renderer** (M). `renderer = mermaidJs` for what Pele does not do (HTML
  labels, plugins), client mode only.
- **A personal layer** (M). *Proposed: `add-personal-layer`.* Pietro's ask: hand adjustments on top of standard Mermaid, kept
  apart from the text. A JSON layer keyed by Mermaid node ids and Pele edge ids (`L_a_b_0`):
  a theme, dx/dy offsets of nodes, edge routing (pele, straight, elbow, curve) and Bézier
  handles, applied after Pele to its SVG (`g.pele-node[data-id]`, `g.pele-edge[data-id]`). A
  browser proof of concept exists (claude-artifacts PR #8, `personal-diagrams/`); here it would
  be a Nim value passed to `toSvg`/`nbDiagram` and applied at build time.
- **Math in labels** (M). A MathJax resolver at build time, for `$$...$$` labels.

## nimib and the ecosystem

- **Move nbDiagram to nimibex** (M). Once the API settles, `nimibex/diagrams` with Pele as the
  default renderer, as the State of NimibLand report suggested; diagrammari stays the library.
- **nimibook and nimiSlides** (S). Check diagrams in their themes; nimibook issue #88 asks for
  Mermaid.
- **Fenced blocks in nbText** (S). Draw ```` ```mermaid ```` blocks found in Markdown text.

## Python, Jupyter and marimo

Pietro's ask (7 Nov 2026): diagrammari from Python with `uv add`, in Jupyter and marimo, with an
editor that gives back the layer and an export of the personalized SVG. A proof of concept of all
of it is in `experiments/python/`.

- **The Python package** (M). *Proposed: `add-python-package`.* `uv add diagrammari`,
  `import mari`: the Nim library in a `py3-none-<platform>` wheel, loaded with ctypes; Node from
  `diagrammari[node]`; wheels by cibuildwheel.
- **The editor in Jupyter, marimo and a browser tab** (M). *Proposed: `add-notebook-editor`.*
  One anywidget module; `mo.ui.anywidget` in marimo; `edit_in_browser()` from a script.
- **Pele in QuickJS** (M). Compile QuickJS (quickjs-ng, MIT, C) into the Nim library and run Pele
  there instead of Node: no Node for nimib pages or Python, a wheel of about 5 MB instead of a
  200 MB Node, and under 1 ms a diagram. Checked through the `quickjs` PyPI package: the same SVG
  as Node, byte for byte, for four diagram types. Not yet compiled from Nim (the sandbox did not
  allow building C cloned from GitHub). Would also make `rmAuto` always static.
- **One layer engine** (M). The geometry is written twice today (JavaScript in the editor, Nim in
  `layer.nim`). Write it once in Nim and compile it to JavaScript for the editor (`nim js`), so
  the editor and the export cannot disagree.
- **The editor in nimib pages** (S). The same module in client mode: a page in "edit" mode
  (`nimib --edit`?) shows the editor and writes the layer next to the notebook as JSON.
- **Layers in a file** (S). Keep a layer next to its text (`flow.mmd` + `flow.layer.json`) or in
  Mermaid frontmatter under a `mari:` key that Mermaid ignores; `mari` reads both.
- **Python builders** (M). If wanted: a few Python helpers that write Mermaid, or the Nim
  builders through nimpy. Mermaid text (an f-string) is enough to start.
- **A cell magic** (S). `%%mari` in Jupyter (IPython) to draw a cell of Mermaid with a layer by
  name; marimo would take `mo.mermaid`-like `mari.mermaid(text)`.
- **PNG and PDF export** (S). From the SVG with resvg (`resvg-py`) or the browser; for slides
  and papers.
- **Pyodide and JupyterLite** (L). The editor already runs in the browser; the export needs the
  Nim library compiled to WebAssembly (emscripten, and Pele in the page's own JavaScript).
- **conda-forge** (S). A feedstock once the PyPI wheels are stable.

## Docs

- **A gallery** (M). Every Pele type, with the person who invented it and a link, growing the
  explainer's history into its own page.
- **API reference** (S). `nim doc` for `src/mari.nim`, published with the pages.
