## Why

The personal layer is made by hand, so it needs a place to make it: drag a box, bend an arrow,
and get the JSON back. Pietro wants that in Jupyter and in marimo, and in a plain browser tab
from a script. From the thread "Plan diagrammari for Python, Jupyter and marimo"; it needs
`add-personal-layer` and `add-python-package`. The proof of concept is in
`experiments/python/src/mari/widget.js`, checked in marimo 0.25.2 and JupyterLab 4.6.6. The PR
that builds it is still to be opened.

## What Changes

- One editor, an ES module with Pele's bundle in front, written for anywidget's interface
  (`render({model, el})`, traits `source`, `layer`, `svg`):
  - drag boxes (4 px snap), click an arrow to pick its route (auto, straight, elbow, curve,
    bezier), drag Bézier handles, pick a fill, a theme and the default arrow style, clear;
  - the layer goes back to Python on every change; a change of `source` or `layer` from Python
    redraws.
- `Diagram.edit()` gives the widget (`mari.Editor`, an `anywidget.AnyWidget`); in Jupyter it
  shows as it is, in marimo wrapped in `mo.ui.anywidget`, so a cell that reads `editor.value`
  runs again on every edit (the export cell of the proof of concept).
- `Diagram.edit_in_browser()` serves the same module on 127.0.0.1 with a stand-in model, opens
  a tab, and returns the layer when Done is pressed: for scripts, the terminal and any editor.
- The editor shows orphans: ids in the layer that the text no longer has.
- The nimib client mode can use the same module later (BACKLOG), so there is one editor.

## Differences from Mermaid and Pele

- Mermaid and Pele have no editor: Pele has `mount` (draw in the page) and `enableZoom`. The
  editor is diagrammari's, over Pele's SVG.

## Capabilities

### New Capabilities
- `notebook-editor`: the widget, its traits, the browser tab, and where it is checked to work.

## Impact

`python/src/mari/widget.js`, `widget.py`, `browser.py`; `anywidget` as the extra
`diagrammari[widget]`; a docs page with a recording of the editor. No change to the Nim API.
