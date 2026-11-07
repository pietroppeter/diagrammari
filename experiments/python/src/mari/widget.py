"""The editor as an anywidget: one ES module that works in Jupyter (Lab, Notebook, VS Code,
Colab) and in marimo (`mo.ui.anywidget`)."""
from pathlib import Path
import anywidget, traitlets

_here = Path(__file__).parent


def esm() -> str:
    # Pele's browser bundle (an IIFE that defines `pele`) in front of the widget module.
    return (_here / "pele.global.js").read_text(encoding="utf-8") + "\n" + (_here / "widget.js").read_text(encoding="utf-8")


class Editor(anywidget.AnyWidget):
    _esm = esm()
    source = traitlets.Unicode("").tag(sync=True)
    layer = traitlets.Dict().tag(sync=True)
    svg = traitlets.Unicode("").tag(sync=True)  # what the browser shows, for comparison

    def diagram(self):
        from . import Diagram
        return Diagram(self.source, dict(self.layer))
