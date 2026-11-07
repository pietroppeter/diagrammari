## Flowcharts: nodes with shapes, links between them, subgraphs, classes and styles.
##
## ```nim
## let f = flowchart(LR)
##   .node("text", "Mermaid text")
##   .node("svg", "SVG", round)
##   .link("text", "svg", "Pele")
## echo f
## ```
##
## or, with the block macro of `diagrammari`, one verb per line:
##
## ```nim
## let f = flowchart(LR):
##   node "text", "Mermaid text"
##   "text" --> "svg"
## ```

import std/strutils
import core

type
  Direction* = enum
    ## Where the flow goes: top to bottom (`TB`, or `TD`), bottom to top, left to right, right to left.
    TB, TD, BT, LR, RL

  Shape* = enum
    ## Node shapes, as in Mermaid's classic syntax.
    rect, round, stadium, subroutine, cylinder, circle, asymmetric, rhombus, hexagon,
    parallelogram, parallelogramAlt, trapezoid, trapezoidAlt, doubleCircle

  Link* = enum
    ## How a link is drawn: the Mermaid operator is the enum's string.
    arrow = "-->", line = "---", dotted = "-.->", dottedLine = "-.-", thick = "==>",
    thickLine = "===", circleEnd = "--o", crossEnd = "--x", invisible = "~~~"

  Flowchart* = object
    direction*: Direction
    title*: string
    lines: seq[string]
    depth: int

func initFlowchart*(direction = TB, title = ""): Flowchart =
  ## An empty flowchart going in `direction`, with an optional title.
  Flowchart(direction: direction, title: title)

func indent(f: Flowchart): string = "  ".repeat(f.depth + 1)

func shaped(id, label: string, shape: Shape): string =
  let q = quoted(label)
  let (a, b) = case shape
    of rect: ("[", "]")
    of round: ("(", ")")
    of stadium: ("([", "])")
    of subroutine: ("[[", "]]")
    of cylinder: ("[(", ")]")
    of circle: ("((", "))")
    of asymmetric: (">", "]")
    of rhombus: ("{", "}")
    of hexagon: ("{{", "}}")
    of parallelogram: ("[/", "/]")
    of parallelogramAlt: ("[\\", "\\]")
    of trapezoid: ("[/", "\\]")
    of trapezoidAlt: ("[\\", "/]")
    of doubleCircle: ("(((", ")))")
  id & a & q & b

proc node*(f: sink Flowchart, id: string, label = "", shape = rect,
           classes: openArray[string] = []): Flowchart =
  ## A node `id`, drawn as `shape` with `label` (the id when empty), in the given classes
  ## (see `classDef`). Ids are letters, digits and `_`.
  checkId(id)
  result = f
  var s = result.indent & shaped(id, if label.len > 0: label else: id, shape)
  if classes.len > 0: s.add ":::" & classes.join(",")
  result.lines.add s

proc link*(f: sink Flowchart, a, b: string, label = "", kind = arrow): Flowchart =
  ## A link from node `a` to node `b`, with an optional label. Nodes not declared with
  ## `node` are drawn as rectangles labelled with their id.
  checkId(a)
  checkId(b)
  result = f
  var s = result.indent & a & " " & $kind
  if label.len > 0: s.add "|" & quoted(label) & "|"
  result.lines.add s & " " & b

proc link*(f: sink Flowchart, a: string, b: openArray[string], label = "",
           kind = arrow): Flowchart =
  ## Links from `a` to each of `b`, in order.
  result = f
  for x in b: result = result.link(a, x, label, kind)

proc chain*(f: sink Flowchart, ids: openArray[string], kind = arrow): Flowchart =
  ## Links between consecutive nodes: `chain ["a", "b", "c"]` is a → b → c.
  result = f
  for k in 1 ..< ids.len: result = result.link(ids[k - 1], ids[k], kind = kind)

proc subgraph*(f: sink Flowchart, id: string, title = "", direction = ""): Flowchart =
  ## Opens a subgraph: what follows is inside it until `endBlock`. In the block macro,
  ## `subgraph "id", "Title": body` opens and closes it around `body`.
  checkId(id)
  result = f
  result.lines.add result.indent & "subgraph " & id &
    (if title.len > 0: "[" & quoted(title) & "]" else: "")
  inc result.depth
  if direction.len > 0: result.lines.add result.indent & "direction " & direction

proc endBlock*(f: sink Flowchart): Flowchart =
  ## Closes the innermost open subgraph.
  result = f
  if result.depth == 0: raise newException(ValueError, "endBlock without an open subgraph")
  dec result.depth
  result.lines.add result.indent & "end"

proc classDef*(f: sink Flowchart, name, css: string): Flowchart =
  ## A class of nodes, styled with CSS-like `css` (`fill:#f9f,stroke:#333`).
  ## Colours set this way are fixed: they do not follow the theme.
  checkId(name)
  result = f
  result.lines.add result.indent & "classDef " & name & " " & css

proc style*(f: sink Flowchart, id, css: string): Flowchart =
  ## A style for one node.
  checkId(id)
  result = f
  result.lines.add result.indent & "style " & id & " " & css

proc href*(f: sink Flowchart, id, url: string, tooltip = ""): Flowchart =
  ## Makes node `id` a link to `url`.
  checkId(id)
  result = f
  result.lines.add result.indent & "click " & id & " href " & quoted(url) &
    (if tooltip.len > 0: " " & quoted(tooltip) else: "")

proc raw*(f: sink Flowchart, line: string): Flowchart =
  ## A line of Mermaid as it is, for what the builder does not cover yet.
  result = f
  result.lines.add result.indent & line

func toDiagram*(f: Flowchart): Diagram =
  var s = ""
  if f.title.len > 0: s.add "---\ntitle: " & f.title & "\n---\n"
  s.add "flowchart " & $f.direction
  for l in f.lines: s.add "\n" & l
  for k in countdown(f.depth - 1, 0): s.add "\n" & "  ".repeat(k + 1) & "end"
  Diagram(kind: dkFlowchart, source: s)

func `$`*(f: Flowchart): string = f.toDiagram.source
