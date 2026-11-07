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

Chosen: C ABI + ctypes for 0.1. Measured on 7 Nov 2026, with both built from the same Nim code
(page: https://pietroppeter.github.io/claude-artifacts/nim-python-bridges/), the two reasons
above hold for nimpy too: it is compiled in, so it adds no run-time dependency, and one module
loads in Python 3.9 to 3.14. Speed is the same (0.8 ms a diagram, under 0.1 µs a call). What
is left for the C ABI: a language-neutral library, the GIL released during a draw, and a
wrapper already written. What is left for nimpy: argument errors are Python exceptions, where a
ctypes mistake segfaults, and Python objects cross without JSON. nimpy is the choice if the
Python API grows into many fine-grained calls (builders); a nimpy module can live beside the C
ABI in the same wheel.

### Build: nimlang's hatch hook, wheels cross-built on one Linux machine

`nimlang` (Pietro's PyPI package: the Nim compiler in a wheel, C through `zig cc` from
`ziglang`) is a build requirement, and its hatch hook builds the library
(`[tool.hatch.build.hooks.nimlang] extensions = ["src/mari/native.nim"]`, a module that includes
the C ABI). Checked: `uv build` with `NIMLANG_TARGET` made the five platform wheels
(manylinux_2_17 x86-64 and aarch64, macOS arm64 and x86-64, win_amd64, about 1.2 MB each) on one
Linux machine, with no Nim or C compiler installed. The Linux x86-64 wheel ran on Python 3.10
and 3.14. This replaces the custom hook and cibuildwheel: one Linux job builds, a matrix on
Linux, macOS and Windows installs each wheel and runs the shared examples, and nothing goes to
PyPI (trusted publishing, `v*` tag) until it is green. The sdist builds wherever nimlang has a
wheel; elsewhere nimlang uses `nim` on the PATH. nimlang pins Nim (2.2.6), so a Nim bump is a
nimlang bump.

Two fixes came out of the check, both in `experiments/python/nim/`: compile-time paths are
joined with `"/"` (cross-compiling for Windows, `/` gave `\` on a Linux path), and QuickJS
calls take a lock and update the stack top, so drawing from Python threads works.

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
- Wheels on musl and Windows arm64 are not in the first set (nimlang knows their tags; not
  tried); the sdist covers them with Nim on the PATH.
- A ctypes API can crash Python on a bug in the library. The ABI is three functions, with
  `try` around everything on the Nim side and strings freed by the library that allocated them.

## Open Questions

- Decided 7 Nov 2026: `pietroppeter/diagrammari-py` for now (Pietro creates it); it may move to
  nimib-land with diagrammari after Pietro talks with Hugo.
- Docs: Python docs in diagrammari's pages (diagrammari-py only releases), or in diagrammari-py?
  To decide once the repository exists.

## Decision: two repositories, with a contract

First degree (the explainer's "case 2") said one repository, because two copies drift. On
appeal, judged with agents doing the work, the ruling is two repositories: agents make keeping
two places in step cheap, while one repository makes parallel threads collide (as on
BACKLOG.md on 7 Nov 2026), mixes two toolchains in one AGENTS.md, and puts a 15-minute wheel
matrix on every Nim PR. It holds only with:

1. diagrammari owns everything that must match: the Nim library, the C ABI
   (`src/mari/capi.nim`), Pele, QuickJS, the layer engine, the editor's JavaScript, and the specs
   with their examples;
2. diagrammari-py owns the Python side (pyproject, Python API, widget wrapper, wheels, notebook
   docs), pins diagrammari to a tag, and runs the shared examples against the pin in CI;
3. a routine opens the bump PR in diagrammari-py when diagrammari tags a release; nothing goes to
   PyPI until it is green.
