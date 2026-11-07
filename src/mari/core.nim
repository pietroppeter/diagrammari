## The diagram value: Mermaid text and the kind of diagram it is.
##
## Every diagram, whether written as Mermaid text or built with the typed builders
## (`flowchart`, `sequence`, `pie`, `timeline`), ends up as a `Diagram`: the Mermaid source that
## Pele (or Mermaid, or GitHub) renders. `echo d` prints that source.

import std/[strutils, hashes]

type
  DiagramKind* = enum
    ## The diagram types Pele 1.13 knows, named as Pele names them (`DiagramType` in Pele).
    dkUnknown = "unknown"
    dkFlowchart = "flowchart", dkSequence = "sequence", dkClass = "class", dkState = "state",
    dkEr = "er", dkPie = "pie", dkGantt = "gantt", dkGitGraph = "gitGraph", dkMindmap = "mindmap",
    dkTimeline = "timeline", dkJourney = "journey", dkXychart = "xychart",
    dkQuadrant = "quadrantChart", dkRequirement = "requirement", dkC4 = "c4", dkSankey = "sankey",
    dkBlock = "block", dkPacket = "packet", dkKanban = "kanban", dkArchitecture = "architecture",
    dkRadar = "radar", dkTreemap = "treemap", dkInfo = "info", dkAgentflow = "agentflow",
    dkUsecase = "usecase", dkRailroad = "railroad", dkTreeView = "treeView", dkVenn = "venn",
    dkCynefin = "cynefin", dkWardley = "wardley", dkSwimlane = "swimlane",
    dkIshikawa = "ishikawa", dkEventModeling = "eventmodeling"

  Diagram* = object
    ## Mermaid text, with the kind detected from its first keyword.
    kind*: DiagramKind
    source*: string

  DiagramError* = object of CatchableError
    ## A diagram that cannot be drawn. `code` is Pele's error code (`syntax`, `semantic`,
    ## `limit`, `unsupported-diagram`) or `no-node` when the build-time renderer is missing;
    ## `line` and `column` start at 1 (0 when unknown) and `snippet` marks the place.
    code*: string
    line*, column*: int
    snippet*: string

const keywords: seq[(string, DiagramKind)] = @[
  # longest first where one keyword starts another
  ("flowchart-elk", dkFlowchart), ("flowchart", dkFlowchart), ("graph", dkFlowchart),
  ("sequenceDiagram", dkSequence), ("classDiagram", dkClass), ("stateDiagram", dkState),
  ("erDiagram", dkEr), ("pie", dkPie), ("gantt", dkGantt), ("gitGraph", dkGitGraph),
  ("mindmap", dkMindmap), ("timeline", dkTimeline), ("journey", dkJourney),
  ("xychart", dkXychart), ("quadrantChart", dkQuadrant), ("requirementDiagram", dkRequirement),
  ("C4Context", dkC4), ("C4Container", dkC4), ("C4Component", dkC4), ("C4Dynamic", dkC4),
  ("C4Deployment", dkC4), ("sankey", dkSankey), ("block", dkBlock), ("packet", dkPacket),
  ("kanban", dkKanban), ("architecture", dkArchitecture), ("radar", dkRadar),
  ("treemap", dkTreemap), ("info", dkInfo), ("agentflow", dkAgentflow), ("usecase", dkUsecase),
  ("railroad", dkRailroad), ("treeView", dkTreeView), ("venn", dkVenn), ("cynefin", dkCynefin),
  ("wardley", dkWardley), ("swimlane", dkSwimlane), ("ishikawa", dkIshikawa),
  ("eventmodeling", dkEventModeling)]

func firstLine(source: string): string =
  ## The first line that says what the diagram is: after frontmatter (`---` ... `---`),
  ## `%%` comments and directives, and blank lines.
  var inFront = false
  var seen = false
  for raw in source.splitLines:
    let l = raw.strip
    if not seen and l == "---":
      inFront = true
      seen = true
      continue
    if inFront:
      if l == "---": inFront = false
      continue
    if l.len == 0 or l.startsWith("%%"): continue
    return l

func detectKind*(source: string): DiagramKind =
  ## The kind of a Mermaid text, from its first keyword; `dkUnknown` when none matches.
  let l = firstLine(source)
  for (kw, kind) in keywords:
    if l.startsWith(kw):
      let rest = l[kw.len .. ^1]
      if rest.len == 0 or rest[0] in {' ', '\t', '-', ';'}: return kind
  dkUnknown

func diagram*(source: string): Diagram =
  ## A diagram from Mermaid text. Leading indentation common to all lines is removed, so a
  ## triple-quoted string can be indented with the code around it.
  var common = high(int)
  for l in source.splitLines:
    if l.strip.len > 0: common = min(common, l.len - l.strip(trailing = false).len)
  if common == high(int): common = 0
  var lines: seq[string]
  for l in source.splitLines: lines.add (if l.len >= common: l[common .. ^1] else: l.strip)
  let text = lines.join("\n").strip(leading = false)
  Diagram(kind: detectKind(text), source: text.strip(trailing = false, chars = {'\n'}))

func mermaid*(source: string): Diagram =
  ## Another name for `diagram`, for code that reads better with it.
  diagram(source)

func toDiagram*(d: Diagram): Diagram = d

func `$`*(d: Diagram): string = d.source

func hash*(d: Diagram): Hash = hash(d.source)

func toMarkdown*(d: Diagram): string =
  ## A fenced ```mermaid block: GitHub, GitLab, Obsidian and most Markdown viewers draw it.
  "```mermaid\n" & d.source & "\n```"

# ---------------------------------------------------------------------- helpers for the builders

func validId*(id: string): bool =
  ## A node or participant id the builders accept: letters, digits and `_`, not starting with
  ## a digit, and not `end` (which closes a block in Mermaid).
  id.len > 0 and id[0] in IdentStartChars and id.allCharsInSet(IdentChars) and
    id.toLowerAscii != "end"

proc checkId*(id: string) =
  if not validId(id):
    raise newException(ValueError, "not a valid diagram id: \"" & id &
      "\" (use letters, digits and _, not starting with a digit, not \"end\")")

func quoted*(label: string): string =
  ## A label in double quotes, with `"` written as Mermaid's `#quot;` and new lines as `<br>`.
  "\"" & label.multiReplace(("\"", "#quot;"), ("\n", "<br>")) & "\""

func plainText*(text: string): string =
  ## Text that runs to the end of a line (sequence messages, notes, timeline events), with the
  ## characters that would end it written as entities.
  text.multiReplace(("#", "#35;"), (";", "#59;"), (":", "#58;"), ("\n", "<br>"))

func number*(x: float): string =
  ## A number as Mermaid reads it: `386`, not `386.0`.
  result = $x
  if result.endsWith(".0"): result.setLen(result.len - 2)
