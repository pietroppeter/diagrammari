## ADDED Requirements

### Requirement: Installed with uv
`uv add diagrammari` SHALL install a wheel with the Nim library compiled in on Linux (x86-64,
arm64), macOS (arm64, x86-64) and Windows (x86-64), with no compiler; elsewhere the sdist SHALL
build with Nim on the PATH. The import name SHALL be `mari`. The wheel SHALL not depend on the
Python version (`py3-none-<platform>`).

```python
import mari
print(mari.pele_version())
```

```text
1.13.0
```

### Requirement: A diagram in Python
`mari.Diagram(source, layer=None)` SHALL give `.svg` (Pele's SVG with the layer applied),
`.save(path)` and `.ids()`; Jupyter and marimo SHALL show it as SVG. `mari.DiagramError` SHALL
carry Pele's `code`, `line`, `column` and `snippet`.

```python
d = mari.Diagram("flowchart LR\n  a[Start] --> b[End]", {"nodes": {"b": {"dy": 80}}})
print(d.svg.startswith("<svg"), d.ids())
try:
    mari.Diagram("flowchart LR\n  a --> [").svg
except mari.DiagramError as e:
    print(e.code, e.line, e.column)
```

```text
True {'nodes': ['a', 'b'], 'edges': ['L_a_b_0']}
syntax 2 8
```

### Requirement: No Node needed
The package SHALL run Pele in QuickJS compiled into the library, and give the same SVG as Pele
in Node. `mari.engine()` SHALL say which engine runs.

```python
print(mari.engine())
```

```text
quickjs
```

#### Scenario: Node on request
- **WHEN** `MARI_ENGINE=node` is set
- **THEN** Pele runs in Node from `$MARI_NODE`, the `nodejs-wheel-binaries` wheel (`diagrammari[node]`) or `node` on the PATH, in that order, and drawing raises `DiagramError` with code `no-node` when none is there
