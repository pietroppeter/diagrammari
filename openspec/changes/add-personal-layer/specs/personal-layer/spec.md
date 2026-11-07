## ADDED Requirements

### Requirement: A layer apart from the text
A `Layer` SHALL hold a theme name, a default arrow style (`asPele`, `asStraight`, `asElbow`,
`asCurve`), node adjustments keyed by Mermaid id (`dx`, `dy`, `fill`) and edge adjustments keyed
by Pele's edge id (`route`: auto, straight, elbow, curve or bezier; `c1`, `c2`: Bézier handles as
offsets from the start and the end). `parseLayer` SHALL read the JSON the editors write, and `$`
SHALL write it back with only what is set.

```nim
let l = parseLayer("""{"theme": "isotype", "nodes": {"ship": {"dy": 120}},
  "edges": {"L_review_draft_0": {"route": "bezier", "c1": [0, -90], "c2": [0, -90]}}}""")
echo l.theme, " ", l.nodes["ship"].dy, " ", l.edges["L_review_draft_0"].route
echo l
```

```text
isotype 120.0 bezier
{"theme":"isotype","nodes":{"ship":{"dy":120.0}},"edges":{"L_review_draft_0":{"route":"bezier","c1":[0.0,-90.0],"c2":[0.0,-90.0]}}}
```

### Requirement: The layer applied at build time
`toSvg(d, layer)` SHALL draw `d` with Pele and then apply the layer to Pele's SVG: each node
moved by its offset and filled; each edge drawn by its route, or by the default arrow style, or,
when an end moved and the style is `pele`, as a curve; markers and edge labels following their
edge; the viewBox grown to show everything. An empty layer SHALL give Pele's SVG unchanged.

```nim
let d = diagram("flowchart LR\n  a[Start] --> b[End]")
let s = d.toSvg(parseLayer("""{"nodes": {"b": {"dx": 40, "dy": 80}}}"""))
echo "translate(" in s.svg, " ", s.svg.count("pele-edge\""), " ", s.height > d.toSvg.height
echo d.toSvg(Layer()).svg == d.toSvg.svg
```

```text
true 1 true
true
```

#### Scenario: Not a flowchart
- **WHEN** the diagram is not a flowchart
- **THEN** only the theme applies, and offsets and routes are kept in the layer but not drawn

### Requirement: Ids and orphans
`ids(d)` SHALL list the node ids and the edge ids of a flowchart, in Pele's order; `orphans(d,
layer)` SHALL list the ids in the layer that `d` no longer has, so an editor can show them.

```nim
let d = diagram("flowchart LR\n  a --> b\n  b --> c")
echo d.ids.nodes, " ", d.ids.edges
echo d.orphans(parseLayer("""{"nodes": {"x": {"dx": 8}, "a": {"dy": 8}}}"""))
```

```text
@["a", "b", "c"] @["L_a_b_0", "L_b_c_0"]
@["x"]
```
