## mari, the module of diagrammari: diagrams for Nim, drawn by Pele.
##
## Diagrams are Mermaid text (`diagram"""..."""`) or built in Nim with typed builders for a few
## types (flowcharts, sequence diagrams, pie charts, timelines). Pele (https://pele.run) draws
## them as SVG: at build time, through Node, or in the browser.
##
## ```nim
## import mari
## let f = flowchart(LR):
##   node "text", "Mermaid text"
##   node "svg", "SVG", round
##   link "text", "svg", "Pele"
## echo f                      # the Mermaid text
## f.save "flow.svg"           # drawn by Pele
## ```
##
## Four macros, where plain procs cannot do the job: `flowchart(args): body`,
## `sequence(args): body`, `pie(args): body` and `timeline(args): body` read each line of `body`
## as a verb applied to the diagram, without repeating it. A verb with a body of its own
## (`subgraph "id", "Title": ...`, `loop "label": ...`, `alt`, `orElse`, ...) opens a block,
## and the block is closed after its body. In a flowchart, `"a" --> "b"` is `link "a", "b"`
## (also `---`, `-.->`, `-.-`, `==>`, `===`, `~~~`, and chains `"a" --> "b" --> "c"`).

import std/macros
import mari/[core, flowchart, sequence, pie, timeline, pele, theme, render_html]
export core, flowchart, sequence, pie, timeline, pele, theme, render_html

const linkOps = ["-->", "---", "-.->", "-.-", "==>", "===", "~~~"]
const notVerbs = ["echo", "discard", "doAssert", "assert", "debugEcho"]

func linkKind(op: string): NimNode =
  let name = case op
    of "-->": "arrow"
    of "---": "line"
    of "-.->": "dotted"
    of "-.-": "dottedLine"
    of "==>": "thick"
    of "===": "thickLine"
    else: "invisible"
  ident(name)

func nameOf(n: NimNode): string =
  case n.kind
  of nnkIdent, nnkSym: n.strVal
  of nnkOpenSymChoice, nnkClosedSymChoice: n[0].strVal
  else: ""

proc rewriteVerbs(body, it: NimNode): NimNode =
  ## Each call statement `verb(args)` becomes `it = verb(it, args)`; one with a body of its own
  ## becomes `it = verb(it, args)`, the body, then `it = endBlock(it)`. `for`, `if`, `when` and
  ## `block` bodies are rewritten too; other statements are left as they are.
  case body.kind
  of nnkStmtList:
    result = newStmtList()
    for s in body: result.add rewriteVerbs(s, it)
  of nnkCall, nnkCommand:
    if nameOf(body[0]).len > 0 and nameOf(body[0]) notin notVerbs:
      let hasBody = body.len >= 2 and body[^1].kind == nnkStmtList
      var call = newCall(body[0], it)
      for k in 1 ..< body.len - (if hasBody: 1 else: 0): call.add body[k]
      result = newAssignment(it, call)
      if hasBody:
        result = newStmtList(result, rewriteVerbs(body[^1], it),
                             newAssignment(it, newCall(ident"endBlock", it)))
    else:
      result = body
  of nnkInfix:
    let op = nameOf(body[0])
    if op in linkOps:
      # a --> b --> c: the left side is a chain itself
      var ends = @[body[2]]
      var left = body[1]
      var ops = @[op]
      while left.kind == nnkInfix and nameOf(left[0]) in linkOps:
        ends.insert(left[2], 0)
        ops.insert(nameOf(left[0]), 0)
        left = left[1]
      ends.insert(left, 0)
      result = newStmtList()
      for k in 0 ..< ops.len:
        result.add newAssignment(it, newCall(ident"link", it, ends[k], ends[k + 1],
          newNimNode(nnkExprEqExpr).add(ident"kind", linkKind(ops[k]))))
    else:
      result = body
  of nnkForStmt, nnkWhileStmt, nnkBlockStmt:
    result = body.copyNimTree
    result[^1] = rewriteVerbs(body[^1], it)
  of nnkIfStmt, nnkWhenStmt:
    result = body.copyNimTree
    for k in 0 ..< result.len: result[k][^1] = rewriteVerbs(body[k][^1], it)
  else:
    result = body

proc builder(init: NimNode, args: NimNode): NimNode =
  let hasBody = args.len >= 1 and args[^1].kind == nnkStmtList
  var create = newCall(init)
  for k in 0 ..< args.len - (if hasBody: 1 else: 0): create.add args[k]
  if not hasBody: return create
  let it = genSym(nskVar, "diagram")
  newBlockStmt(newStmtList(newVarStmt(it, create), rewriteVerbs(args[^1], it), it))

macro flowchart*(args: varargs[untyped]): untyped =
  ## `flowchart(LR, title = "...")` is an empty flowchart (see `initFlowchart`); with a body, the
  ## flowchart changed by the verbs in it, one per line: `node "a", "Start"` stands for
  ## `f = f.node("a", "Start")`, and `"a" --> "b"` for `f = f.link("a", "b")`.
  builder(bindSym"initFlowchart", args)

macro sequence*(args: varargs[untyped]): untyped =
  ## `sequence(title = "...")` is an empty sequence diagram (see `initSequence`); with a body,
  ## the diagram changed by the verbs in it, one per line.
  builder(bindSym"initSequence", args)

macro pie*(args: varargs[untyped]): untyped =
  ## `pie("Title")` is an empty pie chart (see `initPie`); with a body, one `slice` per line.
  builder(bindSym("initPie", brOpen), args)

macro timeline*(args: varargs[untyped]): untyped =
  ## `timeline("Title")` is an empty timeline (see `initTimeline`); with a body, one `period`
  ## or `section` per line.
  builder(bindSym"initTimeline", args)
