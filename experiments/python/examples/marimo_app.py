import marimo

app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    import mari

    src = """flowchart LR
      idea[Idea] --> draft(Draft)
      draft --> review{Review?}
      review -->|yes| ship((Ship))
      review -.->|no| draft"""
    d = mari.Diagram(src)
    editor = mo.ui.anywidget(d.edit())
    editor
    return editor, mari, mo, src


@app.cell
def _(editor, mari, mo, src):
    # Runs again on every edit: the layer as JSON, and the SVG drawn headless by Nim.
    layer = editor.value["layer"]
    mari.Diagram(src, layer).save("from_marimo.svg")
    mo.vstack([mo.md("**layer**"), mo.json(layer), mo.md("**exported by Nim**"), mari.Diagram(src, layer)])
    return


if __name__ == "__main__":
    app.run()
