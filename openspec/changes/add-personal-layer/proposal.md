## Why

Pietro wants his diagrams to stay standard Mermaid and still look like his: a box moved by hand,
an arrow bent the way he means it, a theme. The edits must live apart from the text, so the text
keeps working on GitHub and in Mermaid, and the edits survive when the text changes. This is the
BACKLOG.md entry "A personal layer", with the browser proof of concept in claude-artifacts PR #8
(`personal-diagrams/`). It is also the first step for Python, Jupyter and marimo
(`add-python-package`, `add-notebook-editor`), which edit and export this layer; the thread
"Plan diagrammari for Python, Jupyter and marimo" wrote this proposal. The PR that builds it is
still to be opened.

## What Changes

- A `Layer` value: a theme name, a default arrow style (`pele`, `straight`, `elbow`, `curve`),
  and per-id adjustments. Nodes are keyed by their Mermaid id (`dx`, `dy`, `fill`); edges by
  Pele's edge id, `L_<from>_<to>_<n>` (`route` and, for `bezier`, the handles `c1`, `c2` as
  offsets from the ends).
- `parseLayer` and `$` read and write it as JSON, the format the editors exchange.
- `toSvg(d, layer)` draws with Pele, then applies the layer to Pele's SVG: nodes moved, arrows
  re-routed with their markers and labels, fills set, the viewBox grown to fit. `nbDiagram`
  takes a `layer` too.
- `ids(d)` lists the node and edge ids a layer can use, and `orphans(d, layer)` the ids in a
  layer that the text no longer has.
- Flowcharts first. Other types take the theme only, as in the browser proof of concept.

## Differences from Mermaid and Pele

- Mermaid has no hand layout: positions come from the layout engine only. The layer is
  diagrammari's, and a diagram with a layer looks different in Mermaid or on GitHub (it shows the
  plain layout there, which is the point: nothing breaks).
- Pele's edge ids (`L_a_b_0`) are Pele's naming, the same as Mermaid's `id` for links. If a
  future Pele changes them, layers keyed by edge id need a migration; node ids are Mermaid's own.
- The layer is applied after Pele, to its SVG (`g.pele-node[data-id]`, `g.pele-edge[data-id]`),
  not inside Pele's layout. Moving a box does not move the others.

## Capabilities

### New Capabilities
- `personal-layer`: the layer, its JSON, applying it at build time, ids and orphans.

### Modified Capabilities
- `rendering`: `toSvg` takes an optional layer.
- `nimib-integration`: `nbDiagram` takes an optional layer.

## Impact

New `src/mari/layer.nim` (the proof of concept is `experiments/python/nim/layer.nim`); `pele.nim`
(the Node runner also answers `pele.parse` edges, for the edge ends); `nimib.nim`; the explainer
gets a step with a moved box. The themes of the layer should be `Theme` values (theming spec),
not the proof of concept's table.
