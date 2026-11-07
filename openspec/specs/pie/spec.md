# pie Specification

## Purpose
Pie charts built in Nim. After William Playfair, who drew the first ones in his *Statistical
Breviary* (1801).

## Requirements

### Requirement: Slices
`pie(title, showData)` SHALL make an empty pie chart and `slice label, value` add a slice, in
order; `pie(title, [(label, value), ...])` SHALL make one from pairs. `showData` SHALL write each
value next to its label. Values SHALL be written as Mermaid reads them (`386`, not `386.0`) and
SHALL be positive, else `ValueError`.

```nim
let p = pie("What a diagram is made of", showData = true):
  slice "Boxes", 40
  slice "Arrows", 35
  slice "Labels", 24.5
echo p
```

```text
pie showData
  title What a diagram is made of
  "Boxes" : 40
  "Arrows" : 35
  "Labels" : 24.5
```
