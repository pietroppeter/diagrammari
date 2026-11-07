## 1. Model

- [ ] 1.1 `Layer`, `NodeAdjust`, `EdgeAdjust`, `ArrowStyle` in `src/mari/layer.nim`; `parseLayer` and `$`
- [ ] 1.2 Themes by name from `Theme` values (theming spec), with the font Pele measures with

## 2. Apply

- [ ] 2.1 The Node runner answers the edge ends from `pele.parse` with the SVG
- [ ] 2.2 Port `experiments/python/nim/layer.nim` (offsets, fills, routes, markers, labels, viewBox)
- [ ] 2.3 `toSvg(d, layer)`, `ids`, `orphans`; `nbDiagram(..., layer)`
- [ ] 2.4 Tests: an empty layer gives Pele's SVG; each route; a moved node with a labelled edge

## 3. Docs and checks

- [ ] 3.1 A step in the explainer: the same diagram, plain and with a layer
- [ ] 3.2 Run `nim r tests/all.nim` and `nim r tools/specexamples.nim --changes`
- [ ] 3.3 Rebuild the docs (`nim r -d:release docs/all.nim`)
