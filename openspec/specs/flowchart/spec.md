# flowchart Specification

## Purpose
Flowcharts built in Nim: nodes with shapes, links, subgraphs, classes. The oldest kind of diagram
here (the Gilbreths' process charts, 1921) and the one Pele lays out with the most care.

## Requirements

### Requirement: A flowchart, verb by verb
`flowchart(direction, title)` SHALL make an empty flowchart going `TB` (or `TD`), `BT`, `LR` or
`RL`. With a body, each line SHALL be a verb applied to it: `node "a", "Label"` stands for
`f = f.node("a", "Label")`. The same verbs SHALL chain: `flowchart(LR).node("a").link("a", "b")`.

```nim
let f = flowchart(LR, title = "From text to picture"):
  node "text", "Mermaid text"
  node "svg", "SVG", round
  link "text", "svg", "Pele"
echo f
```

```text
---
title: From text to picture
---
flowchart LR
  text["Mermaid text"]
  svg("SVG")
  text -->|"Pele"| svg
```

### Requirement: Links as operators
In a flowchart body, `"a" --> "b"` SHALL be `link "a", "b"`, and the other Mermaid links SHALL be
operators too: `---` (line), `-.->` (dotted), `-.-`, `==>` (thick), `===`, `~~~` (invisible). A
chain `"a" --> "b" --> "c"` SHALL be one link per step. Outside a body, `link` takes `kind`
(`arrow`, `line`, `dotted`, `dottedLine`, `thick`, `thickLine`, `circleEnd`, `crossEnd`,
`invisible`).

```nim
let f = flowchart(TD):
  "idea" --> "draft" --> "review"
  "review" -.-> "draft"
  "review" ==> "done"
echo f
```

```text
flowchart TD
  idea --> draft
  draft --> review
  review -.-> draft
  review ==> done
```

### Requirement: Shapes
`node` SHALL take a `Shape`: `rect` (default), `round`, `stadium`, `subroutine`, `cylinder`,
`circle`, `asymmetric`, `rhombus`, `hexagon`, `parallelogram`, `parallelogramAlt`, `trapezoid`,
`trapezoidAlt`, `doubleCircle`, written in Mermaid's classic syntax.

```nim
let f = flowchart(LR):
  node "start", "Start", stadium
  node "ok", "Is it clear?", rhombus
  node "db", "Notes", cylinder
  "start" --> "ok"
  link "ok", "db", "yes"
echo f
```

```text
flowchart LR
  start(["Start"])
  ok{"Is it clear?"}
  db[("Notes")]
  start --> ok
  ok -->|"yes"| db
```

### Requirement: Subgraphs
`subgraph "id", "Title": body` SHALL put the nodes of `body` in a subgraph, drawn as a box
around them; outside a body, `subgraph` opens one and `endBlock` closes it. Subgraphs nest, and
a subgraph left open is closed when the text is written.

```nim
let f = flowchart(LR):
  subgraph "nim", "Nim":
    node "code", "nimib notebook"
  subgraph "js", "Pele, in Node":
    node "svg", "SVG"
  "code" --> "svg"
echo f
```

```text
flowchart LR
  subgraph nim["Nim"]
    code["nimib notebook"]
  end
  subgraph js["Pele, in Node"]
    svg["SVG"]
  end
  code --> svg
```

### Requirement: Classes, styles and links out
`classDef name, css` SHALL define a class, `node(..., classes = ["name"])` SHALL put a node in
it, `style id, css` SHALL style one node, `href id, url` SHALL make a node a link, and `raw line`
SHALL add Mermaid as it is. Colours set this way are fixed: they do not follow the theme.

```nim
let f = flowchart(LR):
  classDef "hot", "fill:#f6d365"
  node "a", "Pele", classes = ["hot"]
  href "a", "https://pele.run"
echo f
```

```text
flowchart LR
  classDef hot fill:#f6d365
  a["Pele"]:::hot
  click a href "https://pele.run"
```
