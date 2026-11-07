## Diagrams, part 1: Boxes, Lines and Arrows. The nimib version of the hand-made page in
## diagram-history/index.html: the same text, with the timeline kept as Nim data, so the rug
## plot and the era tables are drawn from it, and the tables made with tabelline.
## Writes docs/series/diagram-history/nimib.html.
import std/[os, strformat, strutils, sequtils, math]
import nimib except md
import tabelline, tabelline/nimib
import serie

let root = currentSourcePath().parentDir
nbInit
nb.doc.filename = root / "diagram-history" / "nimib.html"
nb.useSerie(part = "1", title = "Boxes, Lines and Arrows: a short history of diagrams (nimib version)",
  description = "A Tufte-style history of diagrams, from Babylonian maps to Mermaid and Pele, as a nimib notebook.",
  css = "history.css", original = "index.html",
  fonts = """<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Crimson+Pro:ital,wght@0,400;0,600;1,400&family=Inconsolata:wght@400;600&display=swap">""")

nbRawHtml "<article>"
nbText: """
# Boxes, Lines and Arrows

<p class="subtitle">A short history of diagrams, from clay tablets to Mermaid and Pele, and the stories behind their names</p>

<div class="epigraph"><blockquote>The world is complex, dynamic, multidimensional; the paper is static, flat. How are we to represent the rich visual world of experience and measurement on mere flatland?</blockquote><footer>Edward Tufte, <i>Envisioning Information</i>, 1990</footer></div>

<span class="newthought">A diagram is a picture</span> of something you cannot see: a relation, a
process, an argument, a structure. A painting of Königsberg shows bridges; Euler’s diagram of
Königsberg shows only which land touches which, and that was enough to found a branch of
mathematics. This page follows that idea across 2,600 years, in four eras, ending with the newest
turn: diagrams written as plain text and drawn by a machine, which is where Mermaid, Pele and
diagrammari live.
"""

nbText: """
In this version of the page the timeline is data. Every event below is one value of a Nim
`seq`, and the rug plot, the four era tables and the count of events are all computed from it
when the page is built.
"""

nbCode:
  type Event = object
    year: int          # negative for BCE
    date: string       # how the date is written
    era: int           # 1..4
    text: string       # markdown
    source: string     # markdown, may be empty
    tool: bool         # a text-to-diagram tool
  func ev(year: int, text: string, source = "", tool = false, date = ""): Event =
    let era = if year < 1700: 1 elif year < 1900: 2 elif year < 1980: 3 else: 4
    Event(year: year, date: (if date.len > 0: date else: $year), era: era, text: text,
          source: source, tool: tool)

nbCodeSkip:
  discard "the events: 42 values like the two below, the full list is in the page source"
  # ev(-600, "The Babylonian *Map of the World* ...", "British Museum, BM 92687", date = "600 BCE")
  # ev(2026, "Obsidian releases **Pele** ...", "github.com/obsidianmd/pele", tool = true)

let events = @[
  ev(-600, "The Babylonian *Map of the World* puts Babylon inside a ring of ocean: a diagram of a worldview rather than a survey.", "British Museum, BM 92687", date = "600 BCE"),
  ev(-300, "Euclid’s *Elements*. The lettered figure is part of the proof: the ancestors of node ids.", "Netz, *The Shaping of Deduction* (1999)", date = "300 BCE"),
  ev(270, "Porphyry’s *Isagoge*, later drawn as the *arbor porphyriana*, the first famous tree diagram.", "Lima, *The Book of Trees* (2014)", date = "c. 270"),
  ev(1000, "An anonymous scribe plots the planets against time: the oldest known time-series chart.", "Funkhouser, *Osiris* 1 (1936)", date = "c. 1000"),
  ev(1305, "Ramon Llull’s paper wheels generate every combination of concepts: the diagram as a machine.", "Gardner, *Logic Machines and Diagrams* (1958)", date = "c. 1305"),
  ev(1350, "Nicole Oresme draws intensity over extension and sees uniform acceleration as a triangle.", "", date = "c. 1350"),
  ev(1626, "Scheiner’s *Rosa Ursina* shows sunspots day after day: small multiples.", ""),
  ev(1637, "Descartes’ *La Géométrie* joins algebra and geometry with coordinates.", ""),
  ev(1686, "Halley maps the trade winds.", ""),
  ev(1736, "Euler keeps only land masses and bridges: the first graph.", "Euler, *Solutio problematis…* (1741)"),
  ev(1765, "Priestley’s *Chart of Biography*: 2,000 lives as bars on a time axis.", ""),
  ev(1768, "Euler explains syllogisms with circles, in letters to a German princess.", ""),
  ev(1786, "Playfair invents the line chart and the bar chart.", "Playfair, *Commercial and Political Atlas*"),
  ev(1801, "Playfair adds the pie chart.", "*Statistical Breviary*"),
  ev(1854, "John Snow maps cholera deaths around the Broad Street pump.", ""),
  ev(1858, "Florence Nightingale’s polar-area rose.", ""),
  ev(1859, "The only figure in Darwin’s *Origin of Species* is a tree.", ""),
  ev(1869, "Minard’s map of Napoleon’s march on Moscow.", "Tufte, *Visual Display*, pp. 40–41"),
  ev(1879, "Frege writes logic as two-dimensional strokes.", "*Begriffsschrift*"),
  ev(1880, "Venn’s overlapping circles.", "*Philosophical Magazine* (1880)"),
  ev(1896, "Peirce’s existential graphs.", "", date = "c. 1896"),
  ev(1900, "Adamiecki’s *harmonogram* (1896), then Gantt’s bar schedule.", "", date = "c. 1912"),
  ev(1921, "Frank and Lillian Gilbreth’s *Process Charts*: the first flowcharts.", "ASME (1921)"),
  ev(1925, "Neurath and Arntz begin Isotype in Vienna.", ""),
  ev(1933, "Harry Beck’s Underground diagram.", "Garland, *Mr Beck’s Underground Map* (1994)"),
  ev(1947, "Goldstine and von Neumann’s flow diagrams for programs.", ""),
  ev(1949, "Feynman diagrams.", "Kaiser, *Drawing Theories Apart* (2005)"),
  ev(1962, "Petri nets.", ""),
  ev(1967, "Bertin’s *Sémiologie graphique*.", ""),
  ev(1976, "Chen’s entity-relationship model.", "*ACM TODS* 1(1)"),
  ev(1981, "Sugiyama’s layered layout, behind nearly every flowchart renderer.", "*IEEE Trans. SMC* 11(2)"),
  ev(1982, "Kernighan’s **PIC**: `box; arrow; box` in troff.", "*Software: Practice and Experience* 12", tool = true),
  ev(1983, "Tufte’s *The Visual Display of Quantitative Information*.", ""),
  ev(1987, "Harel’s statecharts.", ""),
  ev(1990, "**dot** and Graphviz at Bell Labs.", "Gansner et al., *IEEE TSE* 19(3) (1993)", tool = true, date = "c. 1990"),
  ev(1997, "UML is standardised by the OMG.", ""),
  ev(2005, "Till Tantau’s **TikZ**.", "", tool = true, date = "c. 2005"),
  ev(2009, "**PlantUML** draws UML from text.", "", tool = true),
  ev(2014, "Knut Sveidqvist starts **Mermaid**.", "Pulse 2.0 interview (2024)", tool = true),
  ev(2020, "D. Richard Hipp revives PIC as **Pikchr**.", "", tool = true),
  ev(2022, "GitHub renders Mermaid in Markdown; Terrastruct open-sources **D2**.", "GitHub blog, 14 Feb 2022", tool = true),
  ev(2026, "Obsidian releases **Pele**, a second renderer for Mermaid’s language.", "github.com/obsidianmd/pele", tool = true)]

nbCode:
  proc rug(events: seq[Event]): string =
    ## One tick per event on a time axis stretched in three pieces; red for text-to-diagram tools.
    const segs = [(-650.0, 1300.0, 20.0, 240.0), (1300.0, 1900.0, 240.0, 560.0), (1900.0, 2030.0, 560.0, 880.0)]
    func x(y: float): float =
      for i, (a, b, p, q) in segs:
        if y <= b or i == segs.high: return p + (y - a) / (b - a) * (q - p)
    var s = """<svg class="rug" viewBox="0 0 900 132" role="img" aria-label="rug plot">"""
    s.add """<line x1="20" x2="880" y1="70" y2="70" stroke="#111" stroke-width=".8"/>"""
    for (y, label) in [(-600, "600 BCE"), (0, "0"), (1000, "1000"), (1500, "1500"), (1700, "1700"),
                       (1900, "1900"), (1950, "1950"), (2000, "2000")]:
      let px = x(y.float).round(1)
      s.add &"""<line x1="{px}" x2="{px}" y1="70" y2="75" stroke="#111" stroke-width=".8"/>"""
      s.add &"""<text x="{px}" y="90" font-size="13" text-anchor="middle">{label}</text>"""
    var stack: seq[(int, int)]       # (pixel, count) to stack ticks that land together
    for e in events:
      let px = x(e.year.float).round(1)
      var n = 1
      for (p, c) in stack.mitems:
        if p == px.int: inc c; n = c
      if n == 1: stack.add (px.int, 1)
      let col = if e.tool: "#a4161a" else: "#111"
      s.add &"""<line x1="{px}" x2="{px}" y1="{66 - (n-1)*9}" y2="{58 - (n-1)*9}" stroke="{col}" stroke-width="1.6"/>"""
    for (a, b, name) in [(-650, 1300, "I. Pictures of thought"), (1300, 1900, "II. Statistics & logic"),
                         (1900, 1980, "III. Process"), (1980, 2030, "IV. Text")]:
      let (pa, pb) = (x(a.float), x(b.float))
      s.add &"""<line x1="{pa+2:.1f}" x2="{pb-2:.1f}" y1="106" y2="106" stroke="#b9b5a3" stroke-width=".8"/>"""
      s.add &"""<text x="{(pa+pb)/2:.1f}" y="124" font-size="13" font-style="italic" text-anchor="middle">{name}</text>"""
    s & "</svg>"

nbRawHtml: """<figure class="fullwidth"><div class="rug-wrap">""" & rug(events) & "</div><figcaption>" &
  &"{events.len} dated events, {events.countIt(it.tool)} of them text-to-diagram tools (in red). " &
  "The axis is stretched three times: the first 1,900 years take as much room as the last 125.</figcaption></figure>"

nbText: """
## Twelve shapes of thought

Twelve diagram forms as small multiples, drawn in the same ink at the same size, so the
differences are only in the idea. These drawings are hand-made SVG, kept as an asset of the page.
"""
nbRawHtml asset("history-multiples.html")

nbText: """
## The four eras, as tables

The hand-made page tells each era as a list with margin notes. Here each era is a tabelline
table made from the same `seq`, with the sources in their own column.
"""

nbCode:
  proc eraTable(events: seq[Event], era: int, title, span: string): Tabella =
    let es = events.filterIt(it.era == era)
    let d = tableData:
      year: es.mapIt(it.date)
      event: es.mapIt(it.text)
      source: es.mapIt(it.source)
    tabella(d, rownameCol = "year"):
      tabHeader title, span
      fmtMarkdown ["event", "source"]
      colsLabel {"event": "what happened", "source": "read more"}
      colsWidth {"event": "64%", "source": "30%"}
      tabOptions(tableFontNames = "'Crimson Pro', Georgia, serif", tableBackgroundColor = "transparent",
                 tableBorderTopColor = "#111", tableBorderBottomColor = "#111",
                 columnLabelsBorderBottomColor = "#111", tableBodyHlinesColor = "#e4e0d0",
                 headingAlign = "left", tableWidth = "100%")

nbTable eraTable(events, 1, "I. Pictures of thought", "before 1700")
nbTable eraTable(events, 2, "II. Statistics and logic find their forms", "1700–1900")
nbTable eraTable(events, 3, "III. Diagrams of process and systems", "1900–1980")
nbTable eraTable(events, 4, "IV. Diagrams written as text", "1980–today")

nbText: """
## The same graph in eight languages

```text
PIC (1982)        box "A"; arrow; box "B"
dot (c. 1990)     digraph { A -> B }
TikZ (c. 2005)    \node (a) {A}; \node[right=of a] (b) {B}; \draw[->] (a) -- (b);
PlantUML (2009)   @startuml / A -> B / @enduml
Mermaid (2014)    flowchart LR / A --> B
Pikchr (2020)     box "A"; arrow; box "B"
D2 (2022)         A -> B
Pele (2026)       flowchart LR / A --> B   (Mermaid's language, a new renderer)
```

## What’s in a name
"""

nbCode:
  let names = tableData:
    name: ["Mermaid", "Pele", "dot", "PIC", "TikZ", "Pikchr", "D2"]
    origin: [
      "When Knut Sveidqvist got home with the idea, his children were watching *The Little Mermaid*. “The name just stuck in my head.”",
      "Pele, the Hawaiian goddess of volcanoes and fire, per the project site. Tagline: “faster than you’d run from a volcano! 🌋”. Not Pelé the footballer.",
      "The language of Graphviz; a graph is dots joined by lines.",
      "Short for picture, next to troff’s *eqn* and *tbl*.",
      "*TikZ ist kein Zeichenprogramm*, “TikZ is not a drawing program”.",
      "Pronounced “picture”: PIC’s heir, spelled to be searchable.",
      "Declarative Diagramming."]
    kind: ["a story", "a story", "says what it does", "says what it does", "a joke", "a joke", "says what it does"]
  let namesTable = tabella(names, rownameCol = "name"):
    tabHeader "Where the names come from", "three ways to name a diagram tool"
    fmtMarkdown "origin"
    tabRowGroup "Named for a story", where(it["kind"] == "a story")
    tabRowGroup "Named for what they do", where(it["kind"] == "says what it does")
    tabRowGroup "Named as a joke", where(it["kind"] == "a joke")
    colsHide "kind"
    colsLabel {"origin": "where it comes from"}
    tabOptions(tableFontNames = "'Crimson Pro', Georgia, serif", tableBackgroundColor = "transparent",
               rowGroupBackgroundColor = "#f4f2e6", tableBodyHlinesColor = "#e4e0d0", headingAlign = "left",
               tableWidth = "100%")
nbTable namesTable

nbText: """
So the chain behind a Nim library is a fairy tale (a mermaid) handed to a volcano goddess
(Pele). The name diagrammari picks up the sea again: it is *diagrammare*, to diagram, with a
Sicilian ending, and inside it are *mari*, the seas, and the Maris of part 3.

## References

The full list is on the [hand-made page](index.html#references): Tufte’s four books; Friendly
and Denis’s *Milestones*; Lima’s *The Book of Trees*; Netz; Gardner; Funkhouser; Euler; Playfair;
Venn; the Gilbreths; Garland; Goldstine and von Neumann; Kaiser; Bertin; Chen; Sugiyama, Tagawa
and Toda; Kernighan; Gansner et al.; Harel; and the Mermaid, GitHub and Pele sources.
"""
nbRawHtml "</article>"
nbSave
