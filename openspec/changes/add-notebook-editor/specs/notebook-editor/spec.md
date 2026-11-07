## ADDED Requirements

### Requirement: One editor for Jupyter and marimo
`Diagram.edit()` SHALL return an anywidget (`mari.Editor`) with the traits `source`, `layer` and
`svg`. It SHALL show the diagram drawn by Pele, let the reader drag boxes, pick an arrow's route,
drag Bézier handles, pick fills, a theme and a default arrow style, and SHALL send the layer back
to Python after each change; the diagram's `layer` SHALL follow it. It SHALL work in JupyterLab
4, Jupyter Notebook 7, VS Code and marimo (through `mo.ui.anywidget`).

```python
d = mari.Diagram("flowchart LR\n  a[Start] --> b[End]")
w = d.edit()
print(type(w).__name__, w.source == d.source, w.layer)
```

```text
Editor True {}
```

#### Scenario: Dragging a box in marimo
- **WHEN** the reader drags box `b` in an editor shown with `mo.ui.anywidget`
- **THEN** `editor.value["layer"]["nodes"]["b"]` has the offset, and the cells that read it run again

#### Scenario: Changing the text from Python
- **WHEN** Python sets `w.source` to a new text
- **THEN** the editor draws the new diagram and keeps the layer, listing the ids it no longer finds

### Requirement: Editing in a browser tab
`Diagram.edit_in_browser(timeout=None)` SHALL serve the editor on 127.0.0.1, open it in the
default browser, and return the layer when the reader presses Done (or the previous layer on
timeout), setting it on the diagram.

#### Scenario: From a script
- **WHEN** a script calls `d.edit_in_browser()` and the reader moves a box and presses Done
- **THEN** the call returns the layer with that box's offset, and `d.save(path)` writes the personalized SVG
