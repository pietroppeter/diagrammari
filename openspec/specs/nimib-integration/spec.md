# nimib-integration Specification

## Purpose
diagrammari in nimib notebooks.

## Requirements

### Requirement: A diagram block
`import mari/nimib` SHALL add `nbDiagram d` (a diagram or Mermaid text, with an optional
HTML `caption` and `showSource` to add the Mermaid text in a fold), a block that keeps the HTML
and the Mermaid text, so the diagram renders with nimib's HTML backend (`nbInit`) and its
Markdown backend (`nbInitMd`), where it becomes a ```mermaid block that GitHub draws. The core of
diagrammari SHALL NOT depend on nimib.

#### Scenario: A README from a notebook
- **WHEN** a notebook made with `nbInitMd` calls `nbDiagram f`
- **THEN** the Markdown file holds the Mermaid text of `f` in a ```mermaid block

### Requirement: How a page draws
`nb.useDiagrams(mode, cdn, narrow, fontFamily)` SHALL set how the page's diagrams are drawn; the
default SHALL be `rmAuto`. In client mode the first diagram of the page SHALL bring
`peleScript`, and the others SHALL not.

#### Scenario: A page without JavaScript
- **WHEN** a page uses `rmStatic`
- **THEN** it has no script from diagrammari, and every diagram is an inline SVG
