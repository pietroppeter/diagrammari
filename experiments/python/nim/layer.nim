## The personal layer, applied to Pele's SVG without a browser.
##
## A proof of concept for diagrammari: the same geometry as the browser editor
## (claude-artifacts `personal-diagrams/`), done on the SVG text so that Python (or a nimib page
## at build time) can export the personalized diagram. Flowcharts only, like the editor.
##
## A layer is JSON:
##   {"theme": "isotype", "arrows": "pele" | "straight" | "elbow" | "curve",
##    "nodes": {"<mermaid id>": {"dx": 0, "dy": 0, "fill": "#c8402b"}},
##    "edges": {"<pele edge id>": {"route": "auto" | ..., "c1": [dx, dy], "c2": [dx, dy]}}}

import std/[xmlparser, xmltree, json, strutils, strtabs, math, tables, sequtils, parseutils]

type
  P = tuple[x, y: float]
  Shape = enum shRect, shCircle, shDiam
  Node = object
    id: string
    g: XmlNode
    cx, cy, w, h: float      # Pele's centre and size
    x, y: float              # after the layer
    shape: Shape
    moved: bool
  Edge = object
    id, src, dst: string
    path: XmlNode
    d0: string
    markers: seq[(XmlNode, bool)]   # (marker, at the end?)
    label: XmlNode
    labelC: P
    hasLabel: bool

func `+`(a, b: P): P = (a.x + b.x, a.y + b.y)
func `-`(a, b: P): P = (a.x - b.x, a.y - b.y)
func `*`(a: P, k: float): P = (a.x * k, a.y * k)
func norm(a: P): float = (let l = hypot(a.x, a.y); if l == 0: 1.0 else: l)
func unit(a: P): P = a * (1 / norm(a))
func f(n: float): string =
  let r = round(n * 100) / 100
  result = if r == r.trunc: $int(r) else: formatFloat(r, ffDecimal, 2).strip(leading = false, chars = {'0'})

func nums(s: string): seq[float] =
  ## The numbers in an attribute (`translate(1,2)`, a path's `d`, polygon points); no regex, so
  ## the library needs no libpcre.
  var i = 0
  while i < s.len:
    if s[i] in {'0'..'9', '.'} or (s[i] == '-' and i + 1 < s.len and s[i+1] in {'0'..'9', '.'}):
      var v: float
      let n = parseFloat(s, v, i)
      if n > 0: (result.add v; i += n; continue)
    inc i

proc walk(n: XmlNode, visit: proc (e: XmlNode)) =
  if n.kind != xnElement: return
  visit(n)
  for c in n: walk(c, visit)

func attr(n: XmlNode, k: string): string =
  if n.attrs == nil: "" else: n.attrs.getOrDefault(k)

func hasClass(n: XmlNode, c: string): bool = c in n.attr("class").splitWhitespace

proc sizeOf(n: XmlNode): (float, float) =
  ## Width and height of a node from its first shape (Pele draws centred on the group origin).
  for c in n:
    if c.kind != xnElement or c.tag == "text" or c.hasClass("pele-label"): continue
    case c.tag
    of "rect": return (c.attr("width").parseFloat, c.attr("height").parseFloat)
    of "circle": (let r = c.attr("r").parseFloat; return (2*r, 2*r))
    of "ellipse": return (2*c.attr("rx").parseFloat, 2*c.attr("ry").parseFloat)
    of "polygon", "path":
      let v = nums(if c.tag == "polygon": c.attr("points") else: c.attr("d"))
      var xs, ys: seq[float]
      for i in countup(0, v.len - 2, 2): (xs.add v[i]; ys.add v[i+1])
      if xs.len > 0: return (max(xs) - min(xs), max(ys) - min(ys))
    else: discard
  (0.0, 0.0)

proc boundary(n: Node, t: P): P =
  let d = t - (n.x, n.y)
  let hw = n.w / 2
  let hh = n.h / 2
  if d.x == 0 and d.y == 0: return (n.x, n.y)
  let s = case n.shape
    of shCircle: hw / norm(d)
    of shDiam: 1 / (abs(d.x) / hw + abs(d.y) / hh)
    of shRect: min((if d.x != 0: hw / abs(d.x) else: Inf), (if d.y != 0: hh / abs(d.y) else: Inf))
  (n.x, n.y) + d * s

proc ports(a, b: Node): (bool, float, P, P) =
  let d: P = (b.x - a.x, b.y - a.y)
  if abs(d.x) >= abs(d.y):
    let s = (if d.x < 0: -1.0 else: 1.0)
    (true, s, (a.x + s*a.w/2, a.y), (b.x - s*b.w/2, b.y))
  else:
    let s = (if d.y < 0: -1.0 else: 1.0)
    (false, s, (a.x, a.y + s*a.h/2), (b.x, b.y - s*b.h/2))

func cubic(p0, c1, c2, p1: P, t: float): P =
  let u = 1 - t
  p0*(u*u*u) + c1*(3*u*u*t) + c2*(3*u*t*t) + p1*(t*t*t)

func tri(tip, dir: P): string =
  let u = unit(dir)
  let n: P = (-u.y, u.x)
  let b = tip - u*8
  "M" & f(tip.x) & "," & f(tip.y) & "L" & f(b.x + n.x*3.36) & "," & f(b.y + n.y*3.36) &
    "L" & f(b.x - n.x*3.36) & "," & f(b.y - n.y*3.36) & "Z"

func num(j: JsonNode, k: string): float =
  if j != nil and j.hasKey(k) and j[k].kind in {JInt, JFloat}: j[k].getFloat else: 0.0

proc setAttr(n: XmlNode, k, v: string) =
  if n.attrs == nil: n.attrs = newStringTable()
  n.attrs[k] = v

proc applyLayer*(svg: string, layer: JsonNode, ends: Table[string, (string, string)]): string =
  ## The SVG with the layer's offsets, fills and arrow routes; the viewBox grows to fit.
  ## `ends` gives each Pele edge id its two Mermaid node ids (from `pele.parse`).
  let root = parseXml(svg)
  let lnodes = layer{"nodes"}
  let ledges = layer{"edges"}
  let arrows = layer{"arrows"}.getStr("pele")
  var nodes: Table[string, Node]
  var edges: seq[Edge]
  var labels: Table[string, XmlNode]
  walk(root) do (e: XmlNode):
    if e.tag == "g" and e.hasClass("pele-node") and e.attr("data-id") != "":
      let v = nums(e.attr("transform"))
      if v.len < 2: return
      let (w, h) = sizeOf(e)
      let cls = e.attr("class")
      let sh = if "circle" in cls or "ellipse" in cls: shCircle
               elif "diam" in cls or "hex" in cls: shDiam else: shRect
      nodes[e.attr("data-id")] = Node(id: e.attr("data-id"), g: e, cx: v[0], cy: v[1], w: w, h: h,
                                      shape: sh)
    elif e.tag == "g" and e.hasClass("pele-edge-label"):
      labels[e.attr("data-id")] = e
    elif e.tag == "g" and e.hasClass("pele-edge") and e.attr("data-id") in ends:
      var ed = Edge(id: e.attr("data-id"))
      (ed.src, ed.dst) = ends[ed.id]
      var ms: seq[XmlNode]
      for c in e:
        if c.kind != xnElement or c.tag != "path": continue
        if c.hasClass("pele-marker"): ms.add c
        elif ed.path == nil: ed.path = c
      if ed.path == nil: return
      ed.d0 = ed.path.attr("d")
      let v = nums(ed.d0)
      let s: P = (v[0], v[1])
      let t: P = (v[^2], v[^1])
      for m in ms:
        let q = nums(m.attr("d"))
        let tip: P = (q[0], q[1])
        ed.markers.add (m, norm(tip - t) <= norm(tip - s))
      edges.add ed
  var pts: seq[P]
  for id, n in nodes.mpairs:
    let o = lnodes{id}
    n.x = n.cx + o.num("dx")
    n.y = n.cy + o.num("dy")
    n.moved = o.num("dx") != 0 or o.num("dy") != 0
    n.g.setAttr("transform", "translate(" & f(n.x) & "," & f(n.y) & ")")
    let fill = o{"fill"}.getStr
    if fill.len > 0:
      for c in n.g:
        if c.kind == xnElement and c.tag != "text" and c.attr("fill") notin ["", "none"]:
          c.setAttr("fill", fill)
    pts.add [(n.x - n.w/2, n.y - n.h/2), (n.x + n.w/2, n.y + n.h/2)]
  for e in edges.mitems:
    if e.id in labels:
      e.label = labels[e.id]
      for c in e.label:
        if c.kind == xnElement and c.tag == "rect":
          e.labelC = (c.attr("x").parseFloat + c.attr("width").parseFloat/2,
                      c.attr("y").parseFloat + c.attr("height").parseFloat/2)
          e.hasLabel = true
    if e.src notin nodes or e.dst notin nodes or e.src == e.dst: continue
    let a0 = nodes[e.src]
    let b0 = nodes[e.dst]
    let o = ledges{e.id}
    let route = o{"route"}.getStr("auto")
    let mode = if route != "auto": route
               elif a0.moved or b0.moved: (if arrows == "pele": "curve" else: arrows)
               else: arrows
    if mode notin ["straight", "elbow", "curve", "bezier"]: continue
    var a, b, c1, c2, mid, dA, dB: P
    let hasS = e.markers.anyIt(not it[1])
    let hasE = e.markers.anyIt(it[1])
    if mode == "straight":
      a = boundary(a0, (b0.x, b0.y)); b = boundary(b0, (a0.x, a0.y))
      dA = a - b; dB = b - a; mid = (a + b) * 0.5
    else:
      let (hz, s, pa, pb) = ports(a0, b0)
      a = pa; b = pb
      if mode == "elbow":
        if hz:
          let mx = (a.x + b.x) / 2
          mid = (mx, (a.y + b.y) / 2); c1 = (mx, a.y); c2 = (mx, b.y)
        else:
          let my = (a.y + b.y) / 2
          mid = ((a.x + b.x) / 2, my); c1 = (a.x, my); c2 = (b.x, my)
      else:
        let k = max(36.0, abs(if hz: b.x - a.x else: b.y - a.y) / 2)
        if hz: (c1 = (a.x + s*k, a.y); c2 = (b.x - s*k, b.y))
        else: (c1 = (a.x, a.y + s*k); c2 = (b.x, b.y - s*k))
        if mode == "bezier":
          if o{"c1"} != nil: c1 = a + (o["c1"][0].getFloat, o["c1"][1].getFloat)
          if o{"c2"} != nil: c2 = b + (o["c2"][0].getFloat, o["c2"][1].getFloat)
        mid = cubic(a, c1, c2, b, 0.5)
        pts.add [cubic(a, c1, c2, b, 0.25), cubic(a, c1, c2, b, 0.75)]
      dA = a - c1; dB = b - c2
    let a2 = if hasS: a - unit(dA)*7 else: a
    let b2 = if hasE: b - unit(dB)*7 else: b
    let d = case mode
      of "straight": "M" & f(a2.x) & "," & f(a2.y) & "L" & f(b2.x) & "," & f(b2.y)
      of "elbow": "M" & f(a2.x) & "," & f(a2.y) & "L" & f(c1.x) & "," & f(c1.y) & "L" & f(c2.x) &
                  "," & f(c2.y) & "L" & f(b2.x) & "," & f(b2.y)
      else: "M" & f(a2.x) & "," & f(a2.y) & "C" & f(c1.x) & "," & f(c1.y) & " " & f(c2.x) & "," &
            f(c2.y) & " " & f(b2.x) & "," & f(b2.y)
    e.path.setAttr("d", d)
    for (m, atEnd) in e.markers: m.setAttr("d", if atEnd: tri(b, dB) else: tri(a, dA))
    if e.hasLabel:
      let t = mid - e.labelC
      e.label.setAttr("transform", "translate(" & f(t.x) & "," & f(t.y) & ")")
      pts.add [(mid.x - 20, mid.y - 12), (mid.x + 20, mid.y + 12)]
  # grow the viewBox to fit what moved
  let vb = nums(root.attr("viewBox"))
  if vb.len == 4:
    var (x1, y1, x2, y2) = (vb[0], vb[1], vb[0] + vb[2], vb[1] + vb[3])
    for p in pts:
      x1 = min(x1, p.x - 12); y1 = min(y1, p.y - 12); x2 = max(x2, p.x + 12); y2 = max(y2, p.y + 12)
    root.setAttr("viewBox", f(x1) & " " & f(y1) & " " & f(x2 - x1) & " " & f(y2 - y1))
    root.setAttr("width", f(x2 - x1)); root.setAttr("height", f(y2 - y1))
  result = $root
