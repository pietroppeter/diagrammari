## The explainer, docs/explainer/index.html: a living document on Mermaid, Pele, the art of
## diagrams, and diagrammari step by step. Kept up to date as diagrammari changes.
import std/[os, strutils, strformat, times]
import nimib
import mari, mari/nimib
import tavola

let docs = currentSourcePath().parentDir
nbInit
nb.doc.filename = docs / "explainer" / "index.html"
nb.useTavola(titolo = "Explainer", tavola = "1", scala = "living document", homeHref = "../",
             title = "mari explainer: Mermaid, Pele and the art of diagrams",
             description = "Mermaid and Pele, how Pele draws, the history and craft of diagrams, and diagrammari step by step.")

nbRawHtml: """<p class="kicker">Explainer · living document</p>
<h1>Diagrams from text, drawn by Pele</h1>
<p class="lede">What Mermaid is, what Pele changes, how Pele lays out a drawing, where each kind of
diagram comes from (two and a half centuries of people drawing boxes and arrows), and how diagrammari
brings it all to Nim.</p>"""

nbIndice("Indice delle tavole")

# ------------------------------------------------------------------------------------- Mermaid
nbText: """
## Mermaid: diagrams as text

A diagram is usually drawn: boxes placed by hand in Visio, draw.io or on a whiteboard. That is
fine until it has to change. **Mermaid** takes the other road: you write what the diagram *says*,
and a program decides where things go.

```text
flowchart LR
  idea --> draft --> review
  review -. not yet .-> draft
```

[Knut Sveidqvist](https://en.wikipedia.org/wiki/Mermaid_(software)) started Mermaid in 2014,
after losing a Visio file, as a JavaScript library that turns such text into a picture in the
browser. It won the JS Open Source Award in 2019 for "the most exciting use of technology", and
since 2022 GitHub draws a fenced ```` ```mermaid ```` block in any Markdown file, so the text
lives next to the code it describes and changes in the same commit. Today it has more than thirty
diagram types: flowcharts, sequence, class, state and ER diagrams, Gantt charts, pies, mind maps,
timelines, Sankey diagrams, Venn diagrams and more.

The idea is older than Mermaid. Brian Kernighan's *pic* (1982) described pictures for the troff
typesetter in a little language; AT&T's [Graphviz](https://graphviz.org) (1991) drew graphs from
the *dot* language with the layered layout described below; PlantUML (2009) did UML from text.
Mermaid's contribution was a friendly syntax, many types and a home in the browser and in Markdown.
"""

# ---------------------------------------------------------------------------------------- Pele
let tStart = epochTime()
for k in 1 .. 50:
  discard diagram(&"sequenceDiagram\n  a->>b: message {k}\n  b-->>a: reply").toSvg
let msPerDiagram = (epochTime() - tStart) * 1000 / 50

nbText: &"""
## Pele: a new renderer for the same text

[Pele](https://pele.run) is a renderer for Mermaid text written from scratch by
[kepano](https://stephango.com) (Steph Ango, the CEO of Obsidian), released in October 2026 under
the MIT license. It reads Mermaid 12.1 syntax, every built-in diagram type, and draws SVG with its
own layout engine. On 22 October 2026 [Obsidian 1.15](https://obsidian.md/changelog/2026-10-22-desktop-v1.15.0)
switched to it: "Obsidian no longer includes Mermaid".

What makes it different, and why it suits Nim and nimib:

- **Small, with no dependencies.** The whole of Pele {peleVersion} is one file of
  {peleBundle.len div 1000} kB, 275 kB gzipped, with all 33 diagram types.
- **Synchronous, no DOM.** `render(text)` is a plain function from a string to an SVG string.
  It runs in Node as well as in a browser, so a page can be drawn *when it is built* and carry no
  JavaScript at all. Mermaid needs a browser for that.
- **Fast.** While this page was built, Pele drew a small sequence diagram in
  {msPerDiagram:.2f} ms on average (in Node, through diagrammari, counting the round trip).
- **Themed with CSS variables.** Colours and fonts are `--pele-*` variables, so the same SVG
  follows the page, light or dark, without being drawn again.
- **Responsive.** Given a narrow width, a wide flowchart is laid out again top to bottom
  instead of shrinking to unreadable.
- **Careful with untrusted text.** Labels are SVG text, never HTML; links and styles are
  filtered; sizes are limited. kepano cites Mermaid's history of security issues as one reason
  to start again.

It is not a drop-in copy. The layout is its own, so a diagram looks different than in Mermaid;
Mermaid's themes do not apply (colours come from CSS); HTML labels and JavaScript `click`
callbacks are not supported. And it is young: a dozen releases in its first two weeks. diagrammari
pins one release (`peleVersion`) and moves to the next on purpose.
"""

# ------------------------------------------------------------------------------- how Pele draws
nbText: """
## How Pele draws a diagram

Every diagram goes through the same steps. Drawn here with diagrammari, of course:
"""
let inside = flowchart(LR, title = "Inside Pele"):
  node "text", "Mermaid text", stadium
  node "pre", "preprocess"
  node "detect", "detect the type", rhombus
  node "parse", "parse"
  node "model", "model", cylinder
  node "layout", "layout"
  node "svg", "SVG", round
  "text" --> "pre" --> "detect" --> "parse" --> "model" --> "layout" --> "svg"
  link "model", "svg", "again at a new width", dotted
nbDiagram inside

nbText: """
1. **Preprocess**: frontmatter (`---` ... `---`) and `%%{init}%%` directives become settings,
   comments go, line breaks are normalised.
2. **Detect** the type from the first keyword (`flowchart`, `sequenceDiagram`, `pie`, ...).
3. **Parse** with the type's own lexer and parser. They are tested against the specs of
   Mermaid's own parsers and with differential fuzzing, which is how Pele can promise the same
   syntax with none of Mermaid's code.
4. **Model**: a plain data structure of what the diagram says (nodes, edges, messages, slices).
   `parse` returns it; it can be drawn again at another width without parsing again.
5. **Layout**: where things go. Each type has its own; graphs share a *layered* layout, one rank
   after another, with compound boxes for subgraphs.
6. **SVG**, with every colour a CSS variable and every element a class (`pele-node`,
   `pele-edge`, `pele-label`), so a page can style it.

To size a box, Pele has to know how wide its label is. In a browser it measures with a canvas, in
the page's font. In Node there is no canvas, so it uses a table of Arial's widths. That is why
this site draws its diagrams in [Arimo](https://github.com/googlefonts/arimo), a free font with
exactly Arial's widths: drawn at build time, the labels still fit their boxes.

### The layered layout, and what it aims for

The layered layout is the hardest part, and the biggest (2,227 lines of TypeScript). It follows
the scheme of Sugiyama, Tagawa and Toda (below): put nodes on ranks, order each rank to cross as
few lines as possible, then place everything. The comment at the top of Pele's `layered.ts`
lists what it aims for, most important first, and is worth reading as a short essay on drawing
graphs. Shortened:

> 1. Lines can be told apart: none touch, run along each other, or cross a node or a label.
> 2. Lines cross as little as the order of the nodes allows.
> 3. An edge takes the shortest and simplest way: straight if it can, else one curve.
> 4. An edge meets the middle of a side.
> 5. The drawing is balanced, and what is alike is drawn alike.
> 6. An edge leaves and reaches a node square to it, and an arrowhead points straight at it.
> 7. Nodes keep the order they were written in, where nothing above says otherwise.
> 8. The drawing stays compact.

Rule 7 is a quiet one with big effects: the order you write things in is a hint the layout
respects, so you can steer a drawing by reordering lines.
"""

# ------------------------------------------------------------------------------------- history
nbText: """
## The art of diagrams: where each kind comes from

Mermaid's types look like a modern list, but almost every one was invented by a person, for a
problem, long before software. Here they are in order, each drawn again by Pele from Mermaid
text (open "Mermaid text" under a drawing to read it).
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
nbDiagram gilbreth, caption = "<b>Tavola 3.</b> An operation, an inspection, a transport and a delay: the Gilbreths' symbols, approximately, in Mermaid's shapes."

nbText: """
### Gantt charts, 1896

The Polish engineer [Karol Adamiecki](https://en.wikipedia.org/wiki/Gantt_chart) drew his
*harmonogram* in 1896 to plan the work of a steel mill, but published it only decades later, in Polish;
[Henry Gantt](https://en.wikipedia.org/wiki/Gantt_chart) drew similar charts around 1910–1915 in
the United States, and his name stayed. Tasks are bars on Priestley's time axis.
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
  caption = "<b>Tavola 6.</b> A Venn diagram (Pele's <code>venn-beta</code>)."

nbText: """
### Sequence diagrams, 1993

Telecom engineers needed to agree on who sends what to whom, in which order, before anything was
built. The [message sequence chart](https://en.wikipedia.org/wiki/Message_sequence_chart) standard
(ITU-T Z.120, first released in March 1993) made the drawing exact: one vertical line per
participant, time running down, messages as arrows. UML's sequence diagrams (1997) and Mermaid's
come from it.
"""

nbCode:
  let rendering = sequence(autonumber = true):
    actor "you", "You"
    participant "nim", "nimib notebook"
    participant "node", "Pele in Node"
    message "you", "nim", "nbDiagram f"
    message "nim", "node", "Mermaid text, as JSON", activate = true
    note "started once, reused for every diagram", rightOf, "node"
    alt "it parses":
      message "node", "nim", "SVG", reply, deactivate = true
    orElse "it does not":
      message "node", "nim", "code, line, column", reply
    message "nim", "you", "a page with no JavaScript", reply
nbDiagram rendering, caption = "<b>Tavola 7.</b> How diagrammari draws at build time."

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
  caption = "<b>Tavola 8.</b> A railroad diagram: an underscore may appear, but never two in a row, nor at the end."

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
  caption = "<b>Tavola 9.</b> An ER diagram of a diagram."

nbText: """
### Layered graph drawing, 1981

None of this would draw itself without an algorithm for *where things go*. In 1981 Kozo
Sugiyama, Shojiro Tagawa and Mitsuhiko Toda published
[*Methods for Visual Understanding of Hierarchical System Structures*](https://en.wikipedia.org/wiki/Layered_graph_drawing)
(IEEE Transactions on Systems, Man, and Cybernetics), the scheme almost every flowchart tool
still follows. Gansner, Koutsofios, North and Vo refined it in *A Technique for Drawing Directed
Graphs* (1993), the paper behind Graphviz's dot; Pele's `layered.ts` is a descendant.
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
  caption = "<b>Tavola 10.</b> A statechart, with a state inside a state."

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
In diagrammari they all work as text, through `diagram"..."`, before they get a builder.

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

## diagrammari, step by step

diagrammari does not draw anything itself: that is Pele's job, and the layout alone is more code
than diagrammari will ever be. (tabelline, the table library next door, made the other choice and
was written in plain Nim: tables are mostly formatting, diagrams are mostly geometry.) diagrammari
gives Nim three things: a value for a diagram, typed builders that write correct Mermaid, and
ways to show the drawing.

### A diagram is Mermaid text

Any of Pele's 33 types works as text. `echo` prints the text; `kind` comes from its first keyword.
"""

nbCode:
  let d = diagram """
    mindmap
      root((diagrammari))
        text
          Mermaid
          GitHub draws it
        builders
          flowchart
          sequence
          pie
          timeline
        Pele
          at build time
          in the browser"""
  echo d.kind
nbDiagram d

nbText: """
### Builders write the Mermaid for you

For four types there are Nim verbs. Each takes the diagram and returns a new one, so they chain;
inside a `flowchart(...):` block (or `sequence`, `pie`, `timeline`) each line is a verb without
repeating the diagram, and `"a" --> "b"` is a link. Ids are checked, labels are quoted: what comes
out is always valid Mermaid.
"""

nbCode:
  let steps = ["read Pele", "write builders", "write specs", "show Pietro"]
  let plan = flowchart(LR):
    for k, s in steps:
      node "s" & $k, s, (if k == steps.high: stadium else: rect)
      if k > 0: link "s" & $(k - 1), "s" & $k
  echo plan
nbDiagram plan

var nimLines = 0
for f in walkDirRec(docs.parentDir / "src"):
  if f.endsWith(".nim"): nimLines += readFile(f).countLines
nbCode:
  let p = pie("Lines of code", showData = true):
    slice "Pele 1.13 (TypeScript)", 52973
    slice "mari (Nim)", float(nimLines)   # counted when this page was built
nbDiagram p, caption = "Why diagrammari wraps Pele instead of rewriting it."

nbText: """
### Drawn at build time, or in the browser

`toSvg` sends the text to one Node process running the Pele that ships with diagrammari, and gets
back the SVG. A page drawn this way needs no JavaScript: this one has none. `toHtml(d, rmClient)`
instead puts the text in the page with Pele, and the reader's browser draws it, at the width of
the screen, with zoom for large diagrams. `rmAuto`, the default, is static when Node is there.
On this site, static diagrams also carry a second drawing for narrow screens: open this page on a
phone and the flowcharts turn vertical.

A text Pele cannot read raises `DiagramError`, with the place:
"""

nbCode:
  try:
    discard diagram("flowchart LR\n  a --> [oops").toSvg
  except DiagramError as e:
    echo e.code, " at line ", e.line, ", column ", e.column
    echo e.snippet

nbText: """
### Themes are CSS

A `Theme` is the `--pele-*` variables as a Nim value. This site uses `tavolaTheme`: India ink on
drawing paper, a technical blue, red pencil.
"""

nbCode:
  echo tavolaTheme.css(".mari")

nbText: """
### In nimib

`import mari/nimib` adds `nbDiagram`, which takes a diagram or Mermaid text, an optional
caption and `showSource` for the fold with the Mermaid text you have seen above.
`nb.useDiagrams(mode = rmClient)` draws in the browser instead. With `nbInitMd` (a README made by
a notebook), `nbDiagram` writes a ```` ```mermaid ```` block, and GitHub draws it.

## Differences from Mermaid, and what is next

- **Pele, not mermaid.js.** The text is Mermaid's; the drawing is Pele's. Diagrams look different
  from GitHub's rendering of the same text; some features (HTML labels, `click` callbacks,
  Mermaid themes) do not exist.
- **Builders for four types.** Flowchart, sequence, pie and timeline today; the others as text.
  Next candidates are in the backlog: state, class, ER, Gantt, mind map, Sankey.
- **Node at build time.** Static drawing needs Node 20 or later. Without it, diagrams are drawn
  in the browser.
- **Fonts.** In Node, Pele measures with Arial's widths: use Arimo, Arial or Helvetica for
  diagrams drawn at build time, or draw in the browser.

The [specs](../specs/) say exactly how diagrammari behaves, with examples that ran when that page
was built.
"""
nbSave
