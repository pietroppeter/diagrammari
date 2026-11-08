## 1. Library

- [ ] 1.1 `src/mari/capi.nim`: `mari_draw`, `mari_free`, `mari_pele_version` over `toSvg(d, layer)` and `ids`
- [ ] 1.2 No run-time library beyond libc (no `std/re`): check with `ldd` / `otool -L`

## 2. Package

- [ ] 2.1 `python/`: pyproject (hatchling with nimlang's hook, extras `node` and `widget`), `src/mari`
- [ ] 2.2 `Diagram`, `draw`, `DiagramError`, `pele_version`; snake_case options
- [ ] 2.3 Tests with pytest, and the Python examples of the specs run by a small runner

## 3. Wheels

- [ ] 3.1 `.github/workflows/wheels.yml`: five wheels built with `NIMLANG_TARGET` on one Linux job, each
  installed and tested on its own OS
- [ ] 3.2 Trusted publishing to TestPyPI on a branch, PyPI on a `v*` tag
- [ ] 3.3 Check `uv add diagrammari` in a new project on Linux, macOS and Windows

## 4. Docs and checks

- [ ] 4.1 A docs page "diagrammari in Python"
- [ ] 4.2 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`
- [ ] 4.3 Rebuild the docs (`nim r -d:release docs/all.nim`)
