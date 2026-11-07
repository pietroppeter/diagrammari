"""diagrammari for Python (proof of concept).

    import mari
    d = mari.Diagram("flowchart LR\\n  a --> b")
    d                      # shows the SVG in Jupyter and marimo
    w = d.edit()           # editor widget (anywidget): drag boxes, shape arrows
    d.layer = w.layer      # the personal layer, plain JSON
    d.save("a.svg")        # Mermaid + layer -> personalized SVG, drawn headless by Nim + Pele

The drawing is done by a Nim library (libmari, loaded with ctypes) that runs Pele in QuickJS,
compiled in (or in Node, with MARI_ENGINE=node).
"""
from __future__ import annotations

import ctypes, json, os, sys
from pathlib import Path

__all__ = ["Diagram", "DiagramError", "draw", "pele_version", "engine"]
_here = Path(__file__).parent
_libname = {"win32": "mari.dll", "darwin": "libmari.dylib"}.get(sys.platform, "libmari.so")


def _load():
    if "MARI_NODE" not in os.environ:
        try:  # the Node of the nodejs-wheel-binaries wheel (pip install diagrammari[node])
            import nodejs_wheel
            node = Path(nodejs_wheel.__file__).parent / "bin" / ("node.exe" if os.name == "nt" else "node")
            if node.exists():
                os.environ["MARI_NODE"] = str(node)
        except ImportError:
            pass
    lib = ctypes.CDLL(str(_here / "_lib" / _libname))
    lib.mari_draw.argtypes = [ctypes.c_char_p]
    lib.mari_draw.restype = ctypes.c_void_p
    lib.mari_free.argtypes = [ctypes.c_void_p]
    lib.mari_pele_version.restype = ctypes.c_char_p
    lib.mari_engine.restype = ctypes.c_char_p
    return lib


_lib = _load()


class DiagramError(ValueError):
    """Pele could not draw the text: `code` (syntax, semantic, ...), `line`, `column`, `snippet`."""

    def __init__(self, a: dict):
        self.code, self.line, self.column, self.snippet = a.get("code"), a.get("line"), a.get("column"), a.get("snippet", "")
        super().__init__(f"{a.get('code')}: {a.get('message')}" + (f"\n{self.snippet}" if self.snippet else ""))


def draw(source: str, layer: dict | None = None, **options) -> dict:
    """Mermaid text (and a personal layer) to Pele's SVG, with the ids the layer can use."""
    req = json.dumps({"source": source, "layer": layer or {}, "options": options}).encode()
    p = _lib.mari_draw(req)
    try:
        answer = json.loads(ctypes.string_at(p).decode())
    finally:
        _lib.mari_free(p)
    if not answer.get("ok"):
        raise DiagramError(answer)
    return answer


def pele_version() -> str:
    return _lib.mari_pele_version().decode()


def engine() -> str:
    """Where Pele runs: "quickjs" (compiled into the library) or "node" (MARI_ENGINE=node)."""
    return _lib.mari_engine().decode()


class Diagram:
    """Standard Mermaid text plus a personal layer (theme, offsets, arrow routes, fills)."""

    def __init__(self, source: str, layer: dict | None = None):
        self.source = source
        self.layer = layer or {}

    @property
    def svg(self) -> str:
        return draw(self.source, self.layer)["svg"]

    def ids(self) -> dict:
        """The node and edge ids the layer can refer to."""
        return draw(self.source)["ids"]

    def save(self, path: str | os.PathLike) -> Path:
        p = Path(path)
        p.write_text(self.svg, encoding="utf-8")
        return p

    def _repr_svg_(self):  # Jupyter
        return self.svg

    def _mime_(self):  # marimo
        return "image/svg+xml", self.svg

    def edit(self):
        """An editor widget for Jupyter and marimo; its `layer` follows your edits."""
        from .widget import Editor
        w = Editor(source=self.source, layer=self.layer)

        def follow(change):
            self.layer = change["new"]
        w.observe(follow, names="layer")
        return w

    def edit_in_browser(self, timeout: float | None = None) -> dict:
        """Open the editor in a local browser tab; returns the layer when you press Done."""
        from .browser import edit
        self.layer = edit(self.source, self.layer, timeout=timeout)
        return self.layer

    def __repr__(self):
        return f"Diagram({self.source!r}, layer={self.layer!r})"
