## 1. Editor

- [ ] 1.1 Move `experiments/python/src/mari/widget.js` into the package; style in `_css`
- [ ] 1.2 Orphans shown in the toolbar; a warning when the theme's font is not loaded
- [ ] 1.3 `Editor`, `Diagram.edit()`, `Diagram.edit_in_browser()`

## 2. Checks

- [ ] 2.1 Playwright tests: marimo (`marimo run`), JupyterLab, the browser tab; drag a box, set a route, read the layer in Python
- [ ] 2.2 By hand: Notebook 7, VS Code, Colab
- [ ] 2.3 The export matches the editor's positions (within the snap) for each route

## 3. Docs and checks

- [ ] 3.1 The docs page "diagrammari in Python" gets the editor, with a short recording
- [ ] 3.2 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`
- [ ] 3.3 Rebuild the docs (`nim r -d:release docs/all.nim`)
