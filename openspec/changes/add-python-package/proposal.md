## Why

Pietro wants diagrammari in Python: `uv add diagrammari`, then Mermaid text in, a personalized
SVG out, from a script, Jupyter or marimo. It is also a way to learn what it takes to ship a Nim
library to Python. From the thread "Plan diagrammari for Python, Jupyter and marimo"; it needs
`add-personal-layer`, and `add-notebook-editor` builds on it. A proof of concept is in
`experiments/python/`. The PR that builds it is still to be opened.

## What Changes

- A Python distribution `diagrammari` on PyPI, imported as `mari` like the Nim package, with the
  Nim library inside (compiled with `--app:lib`, a C ABI, loaded with `ctypes`).
- `mari.Diagram(source, layer=None)`: `.svg`, `.save(path)`, `.ids()`; shown as SVG in Jupyter
  (`_repr_svg_`) and marimo (`_mime_`). `mari.draw(source, layer, **options)` for the answer as a
  dict. `mari.DiagramError` with Pele's code, line, column and snippet.
- Layers are plain dicts (the JSON of `add-personal-layer`): load, save and diff them as files.
- Pele runs in QuickJS compiled into the library, so nothing else is installed (checked in the
  proof of concept: same SVG as Node). `MARI_ENGINE=node` runs it in Node instead: `$MARI_NODE`,
  the extra `diagrammari[node]` (`nodejs-wheel-binaries`), or `node` on the PATH.
- Wheels for Linux (x86-64, arm64), macOS (arm64, x86-64) and Windows, built by cibuildwheel in
  GitHub Actions with Nim installed, published with PyPI trusted publishing on a tag. An sdist
  that builds with Nim on the PATH.
- Builders stay Nim-only for now: in Python, Mermaid text is the API (an f-string is a builder).

## Differences from Mermaid and Pele

- None in the text: the package draws what Pele draws. Pele's Python story today is none (it is
  an npm package); this package is Pele plus the layer, callable from Python.
- Options are Pele's, in snake_case (`font_family`, `max_width`), as Python expects.

## Capabilities

### New Capabilities
- `python`: the package, its API, how it finds Node, and how it is built and published.

## Impact

A `python/` folder at the repository root (pyproject, hatchling build hook, `src/mari`), a C ABI
module `src/mari/capi.nim` beside the Nim library, a `wheels.yml` workflow, a page in the docs.
The core stays standard library only; nothing changes for Nim users.
