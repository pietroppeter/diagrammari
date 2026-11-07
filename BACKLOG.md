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
- **A personal layer** (M). Pietro's ask: hand adjustments on top of standard Mermaid, kept
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

## Docs

- **A gallery** (M). Every Pele type, with the person who invented it and a link, growing the
  explainer's history into its own page.
- **API reference** (S). `nim doc` for `src/mari.nim`, published with the pages.
