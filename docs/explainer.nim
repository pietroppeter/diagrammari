## The explainer, docs/explainer/index.html: a living document. It starts from zero (one arrow
## written as text) and goes from the simplest to the most complex: Mermaid text, Pele,
## diagrammari's verbs, the history and craft of diagrams, and at the end how it is all built.
## Kept up to date as diagrammari changes.
import std/[os, strutils, strformat, times]
import nimib
import mari, mari/nimib
import tavola

let docs = currentSourcePath().parentDir
nbInit
nb.doc.filename = docs / "explainer" / "index.html"
nb.useTavola(titolo = "Explainer", tavola = "1", scala = "living document", homeHref = "../",
             title = "mari explainer: diagrams from text, drawn by Pele",
             description = "From one arrow written as text to every kind of diagram: Mermaid, Pele, diagrammari's verbs, the history and craft of diagrams, and how it is all built.")

func esc(s: string): string = s.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"))

proc textAndDrawing(source: string, caption = "") =
  ## Mermaid text on the left, Pele's drawing of it on the right.
  let d = diagram(source)
  nbBeside:
    nbRawHtml: "<pre><code class=\"nohighlight\">" & esc(d.source) & "</code></pre>"
    nbDiagram d, caption = caption

nbRawHtml: """<p class="kicker">Explainer · living document</p>
<h1>Diagrams from text, drawn by Pele</h1>
<p class="lede">It starts from one arrow written as text, and goes one step at a time: what
Mermaid is, what Pele changes, how diagrammari writes diagrams in Nim, where each kind of diagram
comes from, and, at the very end, how every piece is built.</p>"""

nbIndice("Indice delle tavole")

# ------------------------------------------------------------------------------- from zero
nbText: """
## A diagram is text

A diagram is usually drawn: boxes placed by hand in Visio, draw.io or on a whiteboard. That is
fine until it has to change. There is another road: write what the diagram *says*, and let a
program decide where things go. Here is the smallest diagram there is, an arrow from `a` to `b`:
"""

textAndDrawing """
  flowchart LR
    a --> b"""

nbText: """
The first line names the kind of diagram (`flowchart`) and the direction (`LR`, left to right).
Each line after it says one thing. One more line gives a box a label and a shape, one more adds
an arrow with words on it:
"""

textAndDrawing """
  flowchart LR
    a[Mermaid text] --> b([SVG])
    a -. a README .-> c(GitHub draws it)"""

nbText: """
This language is **Mermaid**. [Knut Sveidqvist](https://en.wikipedia.org/wiki/Mermaid_(software))
started it in 2014, after losing a Visio file, as a JavaScript library that turns such text into a
picture in the browser. It won the JS Open Source Award in 2019 for "the most exciting use of
technology", and since 2022 GitHub draws a fenced ```` ```mermaid ```` block in any Markdown file,
so the text lives next to the code it describes and changes in the same commit.

The idea is older than Mermaid. Brian Kernighan's *pic* (1982) described pictures for the troff
typesetter in a little language; AT&T's [Graphviz](https://graphviz.org) (1991) drew graphs from
the *dot* language; PlantUML (2009) did UML from text. Mermaid's contribution was a friendly
syntax, many kinds of diagram and a home in the browser and in Markdown.

## Four kinds, side by side

The first word picks the kind. These are the four that diagrammari has Nim verbs for, each as
small as it can be: a flowchart, a sequence diagram (who says what to whom, time running down), a
pie chart and a timeline. Mermaid has more than thirty kinds; they all work the same way.
"""

nbBeside:
  nbCell:
    nbRawHtml: "<pre><code class=\"nohighlight\">flowchart TD\n  ask{Ready?} -->|yes| go\n  ask -->|no| wait</code></pre>"
    nbDiagram "flowchart TD\n  ask{Ready?} -->|yes| go\n  ask -->|no| wait"
  nbCell:
    nbRawHtml: "<pre><code class=\"nohighlight\">sequenceDiagram\n  Ada->>Bob: hello\n  Bob-->>Ada: hi</code></pre>"
    nbDiagram "sequenceDiagram\n  Ada->>Bob: hello\n  Bob-->>Ada: hi"
  nbCell:
    nbRawHtml: "<pre><code class=\"nohighlight\">pie\n  \"Nim\" : 3\n  \"Other\" : 1</code></pre>"
    nbDiagram "pie\n  \"Nim\" : 3\n  \"Other\" : 1"
  nbCell:
    nbRawHtml: "<pre><code class=\"nohighlight\">timeline\n  2014 : Mermaid\n  2026 : Pele</code></pre>"
    nbDiagram "timeline\n  2014 : Mermaid\n  2026 : Pele"

# ---------------------------------------------------------------------------------------- Pele
let tStart = epochTime()
for k in 1 .. 50:
  discard diagram(&"sequenceDiagram\n  a->>b: message {k}\n  b-->>a: reply").toSvg
let msPerDiagram = (epochTime() - tStart) * 1000 / 50

nbText: &"""
## Pele: who draws the text

Text needs a program to become a picture. Every drawing on this page was made by
[Pele](https://pele.run), a renderer for Mermaid text written from scratch by
[kepano](https://stephango.com) (Steph Ango, the CEO of Obsidian), released in October 2026 under
the MIT license. It reads Mermaid 12.1 syntax, every built-in kind, and draws SVG with its own
layout. On 22 October 2026 [Obsidian 1.15](https://obsidian.md/changelog/2026-10-22-desktop-v1.15.0)
switched to it: "Obsidian no longer includes Mermaid".

What makes it different, and why it suits Nim and nimib:

- **Small, with no dependencies.** The whole of Pele {peleVersion} is one file of
  {peleBundle.len div 1000} kB, 275 kB gzipped, with all 33 kinds.
- **A plain function.** `render(text)` turns a string into an SVG string, with no browser
  needed. It runs in Node too, so a page can be drawn *when it is built* and carry no JavaScript
  at all. Mermaid needs a browser for that.
- **Fast.** While this page was built, Pele drew a small sequence diagram in
  {msPerDiagram:.2f} ms on average (in Node, through diagrammari, counting the round trip).
- **Colours are CSS variables.** Colours and fonts are `--pele-*` variables, so the same SVG
  follows the page, light or dark, without being drawn again.
- **Responsive.** Given a narrow width, a wide flowchart is laid out again top to bottom instead
  of shrinking to unreadable.
- **Careful with untrusted text.** Labels are SVG text, never HTML; links and styles are
  filtered; sizes are limited.

It is not a drop-in copy. The layout is its own, so a diagram looks different than in Mermaid;
Mermaid's themes do not apply; HTML labels and JavaScript `click` callbacks are not supported.
And it is young: a dozen releases in its first two weeks. diagrammari pins one release
(`peleVersion`) and moves to the next on purpose. How Pele works inside is at the end, under
[How it is built](#how-it-is-built).
"""

# ------------------------------------------------------------------------- diagrammari steps
nbText: """
## diagrammari, step by step

diagrammari brings this to Nim. It does not draw anything itself: that is Pele's job. It gives
Nim three things, met here in this order: a value for a diagram, verbs that write correct Mermaid,
and ways to show the drawing.

### A diagram value

`diagram` is a proc: it takes Mermaid text and returns a `Diagram`. `echo` prints the text back,
and `kind` comes from the first word. The indentation that all lines share is removed, so the text
can be indented with the code around it.
"""

nbCode:
  let first = diagram """
    flowchart LR
      a --> b"""
  echo first.kind
  echo first

nbText: """
Any of Pele's 33 kinds works this way, also the ones that have no Nim verbs yet:
"""

nbCode:
  let map = diagram """
    mindmap
      root((diagrammari))
        text
        verbs
        Pele"""
nbDiagram map

nbText: """
### Verbs are procs

For four kinds there are Nim verbs. They are plain procs: `initFlowchart` makes an empty
flowchart, and each verb (`node`, `link`, ...) takes a flowchart and returns a new one with one
more line, so they chain. `echo` shows the Mermaid they wrote.
"""

nbCode:
  let f = initFlowchart(LR)
    .node("a", "Mermaid text")
    .node("b", "SVG", round)
    .link("a", "b", "Pele")
  echo f
nbDiagram f

nbText: """
What the verbs add over writing the text yourself: ids are checked (a typo like `"my node"` is an
error in Nim, not a strange drawing), labels are quoted (a `"` or a new line in a label cannot
break the text), and shapes and arrows are Nim enums (`round`, `dotted`), so the compiler knows
them.
"""

nbCode:
  let q = initFlowchart().node("say", "she said \"go\"\nand left")
  echo q
  try:
    discard initFlowchart().node("my node")
  except ValueError as e:
    echo e.msg

nbText: """
### The block is a macro

Repeating the flowchart on every line gets long. `flowchart(LR): body` is a **macro**: it makes
`initFlowchart(LR)` and reads each line of the body as a verb applied to it. The same flowchart
as above:
"""

nbCode:
  let g = flowchart(LR):
    node "a", "Mermaid text"
    node "b", "SVG", round
    link "a", "b", "Pele"
  echo $g == $f

nbText: """
This is what the macro does to each line of the body, and nothing more:

| written in the body | what it stands for |
|---|---|
| `node "a", "Start"` | `it = node(it, "a", "Start")` |
| `"a" --> "b"` | `it = link(it, "a", "b", kind = arrow)` |
| `"a" --> "b" --> "c"` | two links, `a` to `b` and `b` to `c` |
| `subgraph "s", "Title":` and a body | `it = subgraph(it, "s", "Title")`, the body, `it = endBlock(it)` |
| `for`, `if`, `when`, `while`, `block` | the same rules inside their bodies |
| `echo`, `discard`, `let` and any other statement | left as it is |

The other link operators work like `-->`: `---`, `-.->`, `-.-`, `==>`, `===` and `~~~`.

Exactly four macros exist, one per kind with verbs: `flowchart`, `sequence`, `pie` and
`timeline`, each with a body. Called without a body, each is the same as its `init` proc. Every
verb is a proc; `diagram` is a proc; `nbDiagram` (below) is a template. When a Mermaid keyword is
also a Nim keyword, the verb has another name: `end` is `endBlock`, `else` is `orElse`, `and` is
`also`.

Because the body is Nim, a loop can make the nodes:
"""

nbCode:
  let steps = ["read Pele", "write verbs", "write specs", "show Pietro"]
  let plan = flowchart(LR):
    for k, s in steps:
      node "s" & $k, s, (if k == steps.high: stadium else: rect)
      if k > 0: link "s" & $(k - 1), "s" & $k
nbDiagram plan

nbText: """
### The other three kinds

The same way: a sequence diagram with alternatives (`alt`, then `orElse` for Mermaid's
`else`), then a pie chart and a timeline side by side.
"""

var nimLines = 0
for file in walkDirRec(docs.parentDir / "src"):
  if file.endsWith(".nim"): nimLines += readFile(file).countLines

nbCode:
  let call = sequence:
    participant "you", "You"
    participant "pele", "Pele"
    message "you", "pele", "some text"
    alt "it reads":
      message "pele", "you", "a drawing", reply
    orElse "it does not":
      message "pele", "you", "where it failed", reply
nbDiagram call

nbBeside:
  nbCell:
    nbCode:
      let lines = pie("Lines of code",
                      showData = true):
        slice "Pele (TypeScript)", 52973
        slice "mari (Nim)", float(nimLines)
    nbDiagram lines, caption = "mari's lines are counted when the page is built."
  nbCell:
    nbCode:
      let years = timeline("Diagrams as text"):
        period "1982", "pic"
        period "1991", "Graphviz"
        period "2014", "Mermaid"
        period "2026", "Pele"
    nbDiagram years

nbText: """
### Drawing it

`toSvg` draws a diagram with Pele and returns the SVG, with its size. A text Pele cannot read
raises `DiagramError`, which says where:
"""

nbCode:
  let svg = first.toSvg
  echo svg.width, " × ", svg.height, " px, ", svg.svg.len, " characters of SVG"
  try:
    discard diagram("flowchart LR\n  a --> [oops").toSvg
  except DiagramError as e:
    echo e.code, " at line ", e.line, ", column ", e.column
    echo e.snippet

nbText: """
`toHtml` puts the drawing in a page, in one of three modes. `rmStatic` draws when the page is
built (needs Node): the page carries only SVG, no JavaScript; this page is drawn this way.
`rmClient` puts the text and Pele in the page, and the reader's browser draws it at the width of
the screen. `rmAuto`, the default, is static when Node is there and client otherwise.

A static drawing has one width. So, given `narrow`, diagrammari draws a second, narrow version and
the page shows it on small screens: open this page on a phone and the left-to-right flowcharts
turn top to bottom. `save` writes a diagram to a `.svg`, `.md` or `.html` file.

### Colours are CSS

A `Theme` is Pele's `--pele-*` variables as a Nim value, and `css` writes them as a CSS rule.
This site uses `tavolaTheme`: India ink on drawing paper, a technical blue, red pencil.
"""

nbCode:
  echo tavolaTheme.css(".mari")

nbText: """
### In nimib

`import mari/nimib` adds the template `nbDiagram`, which takes a diagram or Mermaid text, an
optional caption, and `showSource` for a fold with the Mermaid text under the drawing.
`nb.useDiagrams(mode = rmClient)` sets the mode for the whole page. With `nbInitMd` (a README made
by a notebook), `nbDiagram` writes a ```` ```mermaid ```` block, and GitHub draws it.
"""

# ------------------------------------------------------------------------------------- history
nbText: """
## The art of diagrams: where each kind comes from

Mermaid's kinds look like a modern list, but almost every one was invented by a person, for a
problem, long before software. Here they are in order, each drawn by Pele (open "Mermaid text"
under a drawing to read it). First the whole story, as four timelines:
"""

let charts = timeline("Charts of data"):
  period "1765", "Priestley: A Chart of Biography"
  period "1786", "Playfair: line and bar charts"
  period "1801", "Playfair: the pie chart"
  period "1858", "Nightingale: the rose diagram"
  period "1869", "Minard: Napoleon's march"
let work = timeline("Logic and work"):
  period "1768", "Euler: circles for logic"
  period "1880", "Venn: diagrams of propositions"
  period "1896", "Adamiecki: the harmonogram"
  period "1898", "Sankey: a steam engine"
  period "1921", "the Gilbreths: process charts"
let computing = timeline("Computing"):
  period "1947", "Goldstine and von Neumann: flow diagrams"
  period "1974", "Wirth: syntax diagrams"
  period "1976", "Chen: entity-relationship"
  period "1981", "Sugiyama: layered drawing"
  period "1987", "Harel: statecharts"
let textual = timeline("Text to diagrams"):
  period "1982", "Kernighan: pic"
  period "1991", "Graphviz: dot"
  period "2009", "PlantUML"
  period "2014", "Mermaid"
  period "2026", "Pele"
nbBeside:
  for t in [charts, work, computing, textual]: nbDiagram t

nbText: """
### Timelines, 1765

[Joseph Priestley](https://en.wikipedia.org/wiki/A_Chart_of_Biography), the chemist who isolated
oxygen, drew *A Chart of Biography* in 1765: about two thousand lives as lines along a scale of
years, so that who lived at the same time as whom could be *seen*. *A New Chart of History*
(1769) did the same for empires and went through fifteen editions by 1816. Every timeline above,
and every Gantt chart below, keeps his idea: time runs along one axis, at a constant scale.

### Pie charts, 1801

[William Playfair](https://en.wikipedia.org/wiki/Pie_chart), a Scottish engineer and
pamphleteer, invented the line chart and the bar chart in *The Commercial and Political Atlas*
of 1786, and then, in his *Statistical Breviary* (1801), the pie chart, to show the parts of the
Turkish Empire. [Florence Nightingale's](https://en.wikipedia.org/wiki/Pie_chart#Polar_area_diagram)
rose diagram (1858) was a relative: months as wedges, deaths from preventable disease in blue,
large enough that politicians could not look away.
"""

nbDiagram """
  pie showData
    title Deaths in the Crimean War, Jan 1855 (Nightingale's figures)
    "Preventable disease" : 2761
    "Wounds" : 83
    "Other causes" : 324""", showSource = true,
  caption = "<b>Tavola 2.</b> Nightingale's worst month as a pie. She chose wedges by month instead: the pie hides time."

nbText: """
### Venn diagrams, 1768 and 1880

[Leonhard Euler](https://en.wikipedia.org/wiki/Venn_diagram) explained syllogisms with circles in
his *Letters to a German Princess* (1768). [John Venn](https://en.wikipedia.org/wiki/Venn_diagram)
made the method systematic in 1880, *On the Diagrammatic and Mechanical Representation of
Propositions and Reasonings*: every possible overlap is drawn, and shading says which are empty.
He called them "Eulerian circles"; the name Venn diagram came later.
"""

nbDiagram """
  venn-beta
    title What a good diagram is
    set Correct
    set Clear
    set Short
    union Correct,Clear["useful"]
    union Clear,Short["glanceable"]
    union Correct,Clear,Short["the one to draw"]""", showSource = true,
  caption = "<b>Tavola 3.</b> A Venn diagram (Pele's <code>venn-beta</code>)."

nbText: """
### Gantt charts, 1896

The Polish engineer [Karol Adamiecki](https://en.wikipedia.org/wiki/Gantt_chart) drew his
*harmonogram* in 1896 to plan the work of a steel mill, but published it only decades later, in
Polish; [Henry Gantt](https://en.wikipedia.org/wiki/Gantt_chart) drew similar charts around
1910–1915 in the United States, and his name stayed. Tasks are bars on Priestley's time axis.
"""

nbDiagram """
  gantt
    title Building diagrammari
    dateFormat YYYY-MM-DD
    section Day one
      Read Pele           :done, read, 2026-11-07, 1d
      Builders and specs  :done, build, after read, 1d
    section Next
      More builders       :more, after build, 5d
      Build-time mode in nimibex :after more, 3d""", showSource = true,
  caption = "<b>Tavola 4.</b> A Gantt chart, with Mermaid's dependencies (<code>after read</code>)."

nbText: """
### Sankey diagrams, 1898

Captain [Matthew Sankey](https://en.wikipedia.org/wiki/Sankey_diagram) drew the energy of a steam
engine in 1898 as a stream that splits, each branch as wide as the energy it carries, so the
losses could be seen at a glance. Thirty years earlier Charles Joseph Minard had used the same
device on a map, for the soldiers of Napoleon's Russian campaign (1869), the drawing Edward Tufte
calls perhaps the best statistical graphic ever drawn.
"""

nbDiagram """
  sankey
    Coal,Steam,100
    Steam,Engine work,9
    Steam,Exhaust,62
    Steam,Condenser,22
    Steam,Radiation,7""", showSource = true,
  caption = "<b>Tavola 5.</b> In the spirit of Sankey's steam engine (the numbers are illustrative): most of the coal goes out of the exhaust."

nbText: """
### Flowcharts, 1921

In 1921 [Frank and Lillian Gilbreth](https://en.wikipedia.org/wiki/Flow_process_chart)
presented *Process Charts: First Steps in Finding the One Best Way* to the American Society of
Mechanical Engineers: a way to draw work as a sequence of operations, transports, inspections,
delays and storages, each with its own symbol, so that wasted steps could be seen and removed.
In 1947 [Herman Goldstine and John von Neumann](https://en.wikipedia.org/wiki/Flowchart) used
*flow diagrams* to plan programs for the first stored-program computers; in the 1960s ANSI
standardised the symbols (the rhombus for a decision, the parallelogram for input), and ISO
adopted them in 1970. Kaoru Ishikawa later counted the flowchart among the seven basic tools of
quality control.
"""

nbCode:
  let gilbreth = flowchart(TD, title = "One best way to mail a letter"):
    node "write", "Write the letter", round
    node "check", "Is it right?", rhombus
    node "walk", "Walk to the post box", asymmetric
    node "wait", "Wait for collection", stadium
    "write" --> "check"
    link "check", "write", "no"
    link "check", "walk", "yes"
    "walk" --> "wait"
nbDiagram gilbreth, caption = "<b>Tavola 6.</b> An operation, an inspection, a transport and a delay: the Gilbreths' symbols, approximately, in Mermaid's shapes."

nbText: """
### Railroad diagrams, 1974

[Niklaus Wirth](https://en.wikipedia.org/wiki/Syntax_diagram) drew the grammar of Pascal as
*syntax diagrams* in the *Pascal User Manual and Report* (1974): to read a rule, follow the track
like a train, and every path is a valid sentence. They became *railroad diagrams*, still the
clearest way to show a grammar. Pele reads them in EBNF, ABNF or PEG.
"""

nbDiagram """
  railroad-ebnf-beta
    title "A Nim identifier (ASCII)"
    identifier = letter , { [ "_" ] , ( letter | digit ) } ;
    letter = "a" | "..." | "z" | "A" | "..." | "Z" ;
    digit = "0" | "..." | "9" ;""", showSource = true,
  caption = "<b>Tavola 7.</b> A railroad diagram: an underscore may appear, but never two in a row, nor at the end."

nbText: """
### Entity-relationship diagrams, 1976

[Peter Chen's](https://en.wikipedia.org/wiki/Entity%E2%80%93relationship_model) paper *The
Entity-Relationship Model: Toward a Unified View of Data* (ACM TODS, March 1976) gave databases a
picture: things (entities), how they relate, and how many of each. The "crow's foot" ends that
Mermaid draws come from a later variant of the notation.
"""

nbDiagram """
  erDiagram
    DIAGRAM ||--|{ NODE : has
    DIAGRAM ||--o{ EDGE : has
    NODE ||--o{ EDGE : "starts or ends"
  """, showSource = true,
  caption = "<b>Tavola 8.</b> An ER diagram of a diagram."

nbText: """
### Layered graph drawing, 1981

None of this would draw itself without an algorithm for *where things go*. In 1981 Kozo
Sugiyama, Shojiro Tagawa and Mitsuhiko Toda published
[*Methods for Visual Understanding of Hierarchical System Structures*](https://en.wikipedia.org/wiki/Layered_graph_drawing)
(IEEE Transactions on Systems, Man, and Cybernetics), the scheme almost every flowchart tool
still follows. Gansner, Koutsofios, North and Vo refined it in *A Technique for Drawing Directed
Graphs* (1993), the paper behind Graphviz's dot; Pele's layout is a descendant (more at the end).
"""

let scheme = flowchart(LR, title = "The Sugiyama scheme"):
  node "cycles", "1. break cycles"
  node "ranks", "2. put nodes on ranks"
  node "order", "3. order ranks to cross less"
  node "place", "4. place nodes and route lines"
  "cycles" --> "ranks" --> "order" --> "place"
nbDiagram scheme

nbText: """
### Statecharts, 1987

State machines were drawn as circles and arrows since the 1950s, and became unreadable as soon as
a system had more than a few states. [David Harel's](https://en.wikipedia.org/wiki/State_diagram)
*Statecharts: A Visual Formalism for Complex Systems* (1987) added depth (states inside states),
concurrency and history, and was taken into UML. Mermaid's `stateDiagram` keeps his nested states.
"""

nbDiagram """
  stateDiagram-v2
    [*] --> Text
    Text --> Drawn : toSvg
    Text --> Error : syntax error
    Error --> Text : fix the line
    state Drawn {
      [*] --> Wide
      Wide --> Narrow : below 640 px
      Narrow --> Wide
    }
    Drawn --> [*]""", showSource = true,
  caption = "<b>Tavola 9.</b> A statechart, with a state inside a state."

nbText: """
### Sequence diagrams, 1993

Telecom engineers needed to agree on who sends what to whom, in which order, before anything was
built. The [message sequence chart](https://en.wikipedia.org/wiki/Message_sequence_chart) standard
(ITU-T Z.120, first released in March 1993) made the drawing exact: one vertical line per
participant, time running down, messages as arrows. UML's sequence diagrams (1997) and Mermaid's
come from it.
"""

nbCode:
  let phoneCall = sequence:
    participant "a", "Caller"
    participant "x", "Exchange"
    participant "b", "Callee"
    message "a", "x", "off hook"
    message "x", "a", "dial tone", reply
    message "a", "x", "digits"
    message "x", "b", "ring"
    message "b", "x", "answer", reply
    message "x", "a", "connected", reply
nbDiagram phoneCall, caption = "<b>Tavola 10.</b> A telephone call, the kind of exchange message sequence charts were made for."

nbText: """
### Mind maps and the Ishikawa diagram

Trees of ideas are as old as logic: [Porphyry](https://en.wikipedia.org/wiki/Mind_map) drew
categories as a tree in the 3rd century, and Tony Buzan named the *mind map* in his BBC series
*Use Your Head* (1974). In the 1960s, at the Kawasaki shipyards,
[Kaoru Ishikawa](https://en.wikipedia.org/wiki/Ishikawa_diagram) popularised the cause-and-effect
diagram that looks like a fish: the problem at the head, families of causes as bones.
"""

nbDiagram """
  ishikawa-beta
    Unreadable diagram
    Layout
      Lines cross
      Too wide for a phone
    Labels
      Too long
      Font not measured
    Content
      Too many nodes
      Two ideas in one drawing""", showSource = true,
  caption = "<b>Tavola 11.</b> An Ishikawa diagram (Pele's <code>ishikawa-beta</code>) of a bad diagram."

nbText: """
### And the rest

Pele draws more than a history can hold: Georg von Mayr's star plot of 1877 (`radar-beta`), Ben
Shneiderman's [treemaps](https://en.wikipedia.org/wiki/Treemapping) of the early 1990s
(`treemap-beta`), Toyota's [kanban](https://en.wikipedia.org/wiki/Kanban) boards from the late
1940s (`kanban`), Simon Wardley's [maps](https://en.wikipedia.org/wiki/Wardley_map) (2005,
`wardley-beta`), Dave Snowden's [Cynefin](https://en.wikipedia.org/wiki/Cynefin_framework) (1999,
`cynefin-beta`), git graphs, C4 architecture diagrams, packets, quadrant charts and user journeys.
In diagrammari they all work as text, through `diagram`, before they get verbs.

## On the craft

Four readings for whoever wants to draw better diagrams, not only more of them.

- **Why diagrams work.** Jill Larkin and Herbert Simon,
  [*Why a Diagram is (Sometimes) Worth Ten Thousand Words*](https://mechanism.ucsd.edu/bill/teaching/F12/cs200/Readings/larkin.whyadiagramissometimesworth.1987.pdf)
  (Cognitive Science, 1987). A diagram and a text can hold the same information; the diagram wins
  when it puts together what the reader needs together, so less searching and less remembering.
  The word *sometimes* in the title is the lesson: a diagram that does not group things well is
  just a harder text.
- **What the eye can compare.** Jacques Bertin's
  [*Sémiologie graphique*](https://en.wikipedia.org/wiki/Jacques_Bertin) (1967) lists the
  *visual variables* (position, size, shape, value, colour, orientation, texture) and what each
  can say: position orders, colour separates, size compares. Use one variable for one meaning.
- **Less ink.** Edward Tufte's
  [*The Visual Display of Quantitative Information*](https://en.wikipedia.org/wiki/Edward_Tufte)
  (1983) asks for every mark to carry information (the *data-ink ratio*) and coined *chartjunk*
  for the rest. Pele's plain style, with colour only where the source asks for it, agrees.
- **Topology over geography.** [Harry Beck's](https://en.wikipedia.org/wiki/Tube_map) London
  Underground diagram (designed 1931, published 1933) threw away true distances and kept only
  what a traveller needs: order of stations, lines, changes, all at 45 and 90 degrees. Every
  flowchart is a Beck map: what matters is what connects to what, and the layout is free to
  make that clear.

## Differences from Mermaid, and what is next

- **Pele, not mermaid.js.** The text is Mermaid's; the drawing is Pele's. Diagrams look different
  from GitHub's rendering of the same text; some features (HTML labels, `click` callbacks,
  Mermaid themes) do not exist.
- **Verbs for four kinds.** Flowchart, sequence, pie and timeline today; the others as text.
  Next candidates are in the backlog: state, class, ER, Gantt, mind map, Sankey.
- **Node at build time.** Static drawing needs Node 20 or later. Without it, diagrams are drawn
  in the browser.
- **Fonts.** In Node, Pele measures with Arial's widths: use Arimo, Arial or Helvetica for
  diagrams drawn at build time, or draw in the browser.

The [specs](../specs/) say exactly how diagrammari behaves, with examples that ran when that page
was built.
"""

# ------------------------------------------------------------------------- how it is built
var fileLines: seq[(string, int)]
for file in walkDirRec(docs.parentDir / "src"):
  if file.endsWith(".nim"):
    fileLines.add (file.relativePath(docs.parentDir), readFile(file).countLines)
var lineTable = "| file | lines | what it holds |\n|---|---:|---|\n"
const holds = {"src/mari/core.nim": "the `Diagram` value, kinds, ids and quoting",
  "src/mari/flowchart.nim": "flowchart verbs", "src/mari/sequence.nim": "sequence verbs",
  "src/mari/pie.nim": "pie verbs", "src/mari/timeline.nim": "timeline verbs",
  "src/mari.nim": "the four macros", "src/mari/pele.nim": "Pele and the Node process",
  "src/mari/render_html.nim": "modes, figures, pages, files",
  "src/mari/theme.nim": "themes as CSS", "src/mari/nimib.nim": "the nimib block"}
for (path, what) in holds:
  for (f, n) in fileLines:
    if f == path: lineTable.add &"| `{f[4..^1]}` | {n} | {what} |\n"

stopServer()
let tCold = epochTime()
discard first.toSvg
let msCold = (epochTime() - tCold) * 1000
let tWarm = epochTime()
discard first.toSvg
let msWarm = (epochTime() - tWarm) * 1000

nbText: &"""
## How it is built

From scratch, one piece at a time, in the order the pieces depend on each other. diagrammari is
{nimLines} lines of Nim in `src/` and one JavaScript file it does not own (Pele). Each Nim
file holds one idea:

{lineTable}
The whole path, from a line of Nim to a drawing on the page:
"""

let drawPath = sequence(autonumber = true):
  actor "you", "You"
  participant "nim", "Nim, mari"
  participant "node", "Pele in Node"
  message "you", "nim", "verbs, or Mermaid text"
  note "a Diagram: kind and text", rightOf, "nim"
  message "nim", "node", "the text, as one line of JSON", activate = true
  note "started once, reused for every diagram", rightOf, "node"
  alt "it parses":
    message "node", "nim", "SVG", reply, deactivate = true
  orElse "it does not":
    message "node", "nim", "code, line, column", reply
  message "nim", "you", "a figure in the page", reply
nbDiagram drawPath, caption = "<b>Tavola 12.</b> How a diagram is drawn at build time."

nbText: &"""
### 1. A diagram is a string

`core.nim` holds the one value everything else makes: `Diagram`, an object with the Mermaid text
(`source`) and its `kind`. `diagram(text)` removes the indentation common to all lines (so a
triple-quoted string can be indented like the code around it) and finds the kind: it skips
frontmatter (`---` ... `---`), `%%` comments and blank lines, and matches the first word against
a table of Mermaid's keywords (`flowchart`, `graph`, `sequenceDiagram`, `pie`, ...).

The same file has the helpers every verb uses. `checkId` accepts letters, digits and `_`, not a
digit first and never `end` (which would close a block in Mermaid), and raises `ValueError`
otherwise. `quoted` puts a label in double quotes, writing `"` as Mermaid's `#quot;` and a new
line as `<br>`. `plainText` is for text that runs to the end of a line (messages, notes, events),
where `#`, `;` and `:` would end it early, so they become `#35;`, `#59;` and `#58;`.

### 2. A verb adds a line

Each kind with verbs is an object that keeps the Mermaid lines written so far. A flowchart:

```nim
type Flowchart* = object
  direction*: Direction
  title*: string
  lines: seq[string]   # the body, already indented
  depth: int           # how many subgraphs are open
```

A verb checks its ids, writes one line at the current depth, and returns the object.
`subgraph` writes its line and adds one to `depth`; `endBlock` takes one away and writes `end`.
`toDiagram` puts it together: a frontmatter block for the title, the header (`flowchart LR`),
the lines, and an `end` for every subgraph still open. Verbs take the object as `sink`, so a chain
of verbs moves one object along instead of copying it at every step.

Sequence diagrams have blocks with more than one part (`alt` ... `else` ... `end`). In Nim each
part is its own block, so `orElse` comes *after* the `alt` block has closed: it removes the `end`
just written, writes `else` and opens again. It raises `ValueError` if the block before it is not
an `alt`; `also` (for `par`) and `option` (for `critical`) work the same way.

### 3. Four macros, one rewrite

`src/mari.nim` has the four macros, and they share one proc, `rewriteVerbs`, that walks the body
once. The table in [The block is a macro](#the-block-is-a-macro) is the whole of it. What the
compiler sees for a small block:

```nim
# written
let f = flowchart(LR):
  node "a", "Start"
  "a" --> "b" --> "c"

# what the macro makes of it
let f = block:
  var it = initFlowchart(LR)
  it = node(it, "a", "Start")
  it = link(it, "a", "b", kind = arrow)
  it = link(it, "b", "c", kind = arrow)
  it
```

A verb is any call whose name is not `echo`, `discard`, `assert` or `doAssert`. A chain like
`"a" --> "b" --> "c"` arrives as nested infix nodes, `("a" --> "b") --> "c"`, and the macro
unrolls it from the left. One detail: inside a template or a generic proc, Nim hands the macro
not a name but the list of overloads with that name (a *symbol choice*), so the macro reads the
name from the first of them.

### 4. Pele inside a Nim program

Pele is one JavaScript file, `src/mari/vendor/pele.global.js`, copied from the npm package and
pinned by `peleVersion` ("{peleVersion}"). `staticRead` puts it inside the compiled program, so a
program that uses diagrammari needs nothing else from diagrammari at run time, only Node.

The first `toSvg` writes the bundle and a 16-line `runner.cjs` to a temporary folder named after
the version, and starts Node once with them. The runner loads Pele and reads one JSON request per
line on its input (the text and the options), calls `pele.render`, and writes one JSON answer per
line: the SVG and its size, or the error with its code, line, column and snippet, which
`toSvg` raises as `DiagramError`. The process stays alive for every later diagram and is stopped
when the program exits. Why one process: while this page was built, the first diagram (starting
Node) took {int(msCold)} ms, the next one {msWarm:.1f} ms.

Each SVG's ids start with a prefix made from a hash of its text (`idFor`), so two diagrams on one
page never share an id.

### 5. Inside Pele

Every diagram goes through the same steps in Pele:
"""

let inside = flowchart(LR, title = "Inside Pele"):
  node "text", "Mermaid text", stadium
  node "pre", "preprocess"
  node "detect", "detect the kind", rhombus
  node "parse", "parse"
  node "model", "model", cylinder
  node "layout", "layout"
  node "svg", "SVG", round
  "text" --> "pre" --> "detect" --> "parse" --> "model" --> "layout" --> "svg"
  link "model", "svg", "again at a new width", dotted
nbDiagram inside

nbText: """
1. **Preprocess**: frontmatter and `%%{init}%%` directives become settings, comments go, line
   breaks are normalised.
2. **Detect** the kind from the first keyword, as `diagram` does in Nim.
3. **Parse** with the kind's own lexer and parser. They are tested against the specs of
   Mermaid's own parsers and with differential fuzzing, which is how Pele can promise the same
   syntax with none of Mermaid's code.
4. **Model**: a plain data structure of what the diagram says (nodes, edges, messages, slices).
   It can be drawn again at another width without parsing again.
5. **Layout**: where things go. Each kind has its own; graphs share a *layered* layout, one rank
   after another, with boxes inside boxes for subgraphs.
6. **SVG**, with every colour a CSS variable and every element a class (`pele-node`,
   `pele-edge`, `pele-label`), so a page can style it.

To size a box, Pele has to know how wide its label is. In a browser it measures with a canvas, in
the page's font. In Node there is no canvas, so it uses a table of Arial's widths. That is why
this site draws its diagrams in [Arimo](https://github.com/googlefonts/arimo), a free font with
exactly Arial's widths: drawn at build time, the labels still fit their boxes.

The layered layout is the hardest part, and the biggest (2,227 lines of TypeScript). It follows
Sugiyama's scheme from the history above: nodes on ranks, each rank ordered to cross as few lines
as possible, then everything placed. The comment at the top of Pele's `layered.ts` lists what it
aims for, most important first. Shortened:

> 1. Lines can be told apart: none touch, run along each other, or cross a node or a label.
> 2. Lines cross as little as the order of the nodes allows.
> 3. An edge takes the shortest and simplest way: straight if it can, else one curve.
> 4. An edge meets the middle of a side.
> 5. The drawing is balanced, and what is alike is drawn alike.
> 6. An edge leaves and reaches a node square to it, and an arrowhead points straight at it.
> 7. Nodes keep the order they were written in, where nothing above says otherwise.
> 8. The drawing stays compact.

Aim 7 is a quiet one with big effects: the order you write things in is a hint the layout
respects, so you can steer a drawing by reordering lines.

### 6. From SVG to a page

`render_html.nim` wraps a drawing in a `<figure class="mari mari-<kind>">`, with its caption.
In static mode, given `narrow`, it asks Pele for the drawing twice, the second time with that
`maxWidth` and another id prefix; if the two are the same (most kinds but flowcharts), it keeps
one. Otherwise the figure holds both, and a CSS container query, which looks at the width of the
figure rather than of the screen, shows the one that fits.

In client mode the figure holds the Mermaid text in a `<pre>` and a one-line script calling
`mariMount`, which hands the text to `pele.mount` in the browser and hides the text once the
drawing is there. `peleScript` is what the page needs once, before the first such figure: Pele
itself (inlined, or from jsDelivr pinned to the same version) and `mariMount`. `rmAuto` is
decided when the figure is made: static if Node can be found (`MARI_NODE`, or `node` on the
path), client otherwise.

### 7. Themes

`theme.nim` is a list of Pele's variables (background, ink, lines, surfaces, accent, critical,
fonts, eight series colours) as a Nim object. `css` writes the ones that are set as a CSS rule
for a selector; `css(light, dark)` adds the dark ones inside a `prefers-color-scheme: dark` media
query. The SVG is never drawn again for a theme: it only reads the variables.

### 8. The nimib block

`nimib.nim` makes `nbDiagram` a nimib block of its own (`newNbBlock(NbDiagram)`) that keeps the
finished HTML and the Mermaid text, so each of nimib's backends picks what it needs: the HTML
backend writes the figure, the Markdown backend writes a ```` ```mermaid ```` fence. The page's
settings (`useDiagrams`) are kept in the document's context. In client mode, when the page is
written, each block looks for the first client block of the page, and only that one brings
`peleScript` with it, so Pele is in the page once however many diagrams there are.

### 9. How it is checked

`tests/all.nim` runs the tests of the verbs, the drawing and the nimib block. Every requirement in
the [specs](../specs/) has an example, a ```` ```nim ```` block and the text it prints;
`tools/specexamples.nim` runs them all and checks the output, and the specs page shows the drawing
each one makes. CI runs both, builds every page (this one included) and publishes the site.
"""
nbSave
