## Context

diagrammari is a Nim library around Pele, a JavaScript renderer. To use it from Python, three
things have to cross: the Nim code (Mermaid text, the layer, the Node runner), Pele itself, and
something to run Pele in. What was checked, and how, is in `experiments/python/README.md`; the
versions below are those of 7 Nov 2026.

## Goals / Non-Goals

**Goals:** `uv add diagrammari` on the usual platforms with no compiler; the same SVG as the Nim
library; a small surface that a notebook can show.

**Non-Goals:** Python builders (later, if wanted); Pyodide and JupyterLite (see BACKLOG); a
Python reimplementation of anything Pele or the Nim library does.

## Decisions

### Nim to Python: a C ABI and ctypes, not nimpy

Three ways were looked at.

- **nimpy** (yglukhov/nimpy, active, Python 3.14 supported since June 2026): Nim procs become a
  Python extension module; nimpy finds libpython at run time, so one binary serves several
  Python versions. Good when the API is many small calls with Python objects.
- **nimporter** (1.1.0, last release 2021, last commit 2023): compiles Nim on import or into
  wheels. Not maintained: not a base for a package.
- **C ABI + ctypes**: `{.exportc, dynlib, cdecl.}` procs in a shared library, loaded with
  `ctypes.CDLL`. No dependency at all; the wheel is `py3-none-<platform>`, one per platform for
  every Python 3. The API is JSON in, JSON out, which fits: a diagram is a string, a layer is
  JSON, the answer is an SVG.

Chosen: C ABI + ctypes, for zero dependencies and one wheel per platform. The call is one per
diagram, so JSON costs nothing that matters. nimpy stays the choice if the Python API grows into
many fine-grained calls (builders).

### Build: hatchling with a hook, cibuildwheel in CI

`uv build` uses a hatchling build hook that runs `nim c --app:lib` and marks the wheel as
platform-specific (checked in the proof of concept). In CI, cibuildwheel (4.3.5) builds the
platform wheels: Nim installed in `before-all` (choosenim or the nightlies, as
`tools/setup.sh` does), auditwheel/delocate fix the tags. Since the wheel does not depend on the
Python version, `CIBW_BUILD` can be one CPython per platform. Publishing with PyPI trusted
publishing from a `v*` tag.

### Running Pele: QuickJS compiled in, Node as an option

- **Node from PyPI** (`nodejs-wheel-binaries` 24.x): works, checked with no `node` on the PATH.
  About 200 MB installed: an extra, `diagrammari[node]`, not a dependency.
- **V8 in Python** (`mini-racer` 0.14): Pele runs, 13 ms a diagram, about 80 MB.
- **QuickJS** (`quickjs` on PyPI, 4.8 MB): Pele runs, under 1 ms a diagram once loaded, and the
  SVG is byte-identical to Node's for a flowchart, a sequence, a pie and a class diagram.

- **QuickJS compiled into the Nim library** (quickjs-ng 0.18, MIT, vendored and pinned): Nim's
  `{.compile.}` builds its four C files, a 40-line C shim gives Nim four functions. Checked: the
  same SVG as Node for the four types, 0.7 to 0.8 ms a diagram after a 100 ms load, the library
  grows from 1.1 to 2.4 MB, the wheel is 1.3 MB.

Chosen: QuickJS compiled in, by default; Node behind `MARI_ENGINE=node`, kept while QuickJS is
new. The C ABI is the same for both. The same engine can serve nimib pages (BACKLOG "Pele in
QuickJS for the Nim library").

### Names

Distribution `diagrammari` (free on PyPI), import `mari` (also free), as in Nim. Options in
snake_case. A layer is a dict, not a class, so it round-trips through JSON files and notebook
state without a converter.

## Risks / Trade-offs

- Node's text widths: Pele in Node or QuickJS measures with Arial's widths, the browser with the
  real fonts, so a theme font that is not installed looks different in the editor and in the
  export. Same as for nimib pages; the BACKLOG item "Text measurement in Node" is the fix.
- Wheels on musl and Windows arm64 are not in the first set; the sdist covers them with Nim.
- A ctypes API can crash Python on a bug in the library. The ABI is three functions, with
  `try` around everything on the Nim side and strings freed by the library that allocated them.

## Open Questions

- One repository or two? First-degree verdict (7 Nov 2026, the explainer's "case 2"): this
  repository, because two copies of Pele, QuickJS, the C ABI and the spec would drift.
  `pyproject.toml` goes at the root, so the sdist can include `src/mari`; Python code in
  `python/mari/`; wheels on `py-v*` tags. Pietro has the final word.
