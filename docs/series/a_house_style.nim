## Part 5 of the Diagrams series, "A House Style": the first brainstorm for the look of everything
## outside the series (explainer, specs, devlog). Three specimens, each the same small page drawn
## in a different mix of Neurath, Enzo Mari, Tufte and the sea of part 4.
## Writes docs/series/a-house-style/index.html.
import std/[os, json, strformat]
import nimib except md
import tabelline, tabelline/nimib
import mari, mari/nimib
import serie

let root = currentSourcePath().parentDir
nbInit
nb.doc.filename = root / "a-house-style" / "index.html"
nb.useSerie(part = "5", title = "A House Style · Diagrams, part 5",
  description = "Part five of the Diagrams series: looking for the house style of diagrammari, a mix of Neurath, Enzo Mari, Tufte and a little sea.",
  css = "house.css",
  fonts = "<style>" & fontFace("Jost", "jost-latin-400-normal.woff2") &
    fontFace("Jost", "jost-latin-500-normal.woff2", 500) &
    fontFace("Crimson Pro", "crimson-pro-latin-400-normal.woff2") &
    fontFace("Crimson Pro", "crimson-pro-latin-400-italic.woff2", 400, "italic") & "</style>")

const
  officina = Theme(bg: "#ffffff", fg: "#111111", muted: "#555555", line: "#111111",
    surface: "#ffffff", surfaceAlt: "#f1f1f1", border: "#111111", accent: "#d9472b",
    font: "Jost, sans-serif", radius: "0px")
  isotype = Theme(bg: "transparent", fg: "#13304a", muted: "#4d6b84", line: "#2f6fa8",
    surface: "#ffffff", surfaceAlt: "#d6e8ee", border: "#2f6fa8", accent: "#d9472b",
    font: "Jost, sans-serif", radius: "4px")
  quaderno = Theme(bg: "transparent", fg: "#2b2b2b", muted: "#77716a", line: "#2b2b2b",
    surface: "#fffdf6", surfaceAlt: "#f3eee2", border: "#2b2b2b", accent: "#2f6fa8",
    font: "'Crimson Pro', Georgia, serif", radius: "12px")
nb.doc.context["stylesheet"] = %(nb.doc.context["stylesheet"].getStr & "\n<style>" &
  officina.css(".spec-a .mari") & isotype.css(".spec-b .mari") & quaderno.css(".spec-c .mari") & "</style>")
nb.useDiagrams(mode = rmStatic, fontFamily = "Jost")

func page(color: string): string =
  ## One page, as an Isotype symbol: a sheet with a folded corner.
  &"""<svg viewBox="0 0 16 20"><path d="M1 1h10l4 4v14H1z" fill="{color}"/><path d="M11 1v4h4" fill="#fff8"/></svg>"""

func mark(kind: string): string =
  ## The four ingredients as small marks: a person, a joint, a dot plot, a wave.
  case kind
  of "neurath": """<svg viewBox="0 0 30 40"><circle cx="15" cy="7" r="6" fill="#2f6fa8"/><path d="M6 16h18v13h-4v10h-10v-10h-4z" fill="#2f6fa8"/></svg>"""
  of "mari": """<svg viewBox="0 0 40 40"><path d="M4 10h32M4 22h32M10 4v34M30 4v34" stroke="#111" stroke-width="3" fill="none"/><circle cx="10" cy="10" r="2.5" fill="#d9472b"/><circle cx="30" cy="22" r="2.5" fill="#d9472b"/></svg>"""
  of "tufte": """<svg viewBox="0 0 60 40"><path d="M2 36h56" stroke="#111" stroke-width="1"/><g fill="#111"><circle cx="8" cy="28" r="1.6"/><circle cx="16" cy="24" r="1.6"/><circle cx="24" cy="26" r="1.6"/><circle cx="32" cy="16" r="1.6"/><circle cx="40" cy="18" r="1.6"/><circle cx="48" cy="9" r="1.6"/></g><circle cx="48" cy="9" r="3" fill="none" stroke="#d9472b"/></svg>"""
  else: """<svg viewBox="0 0 60 40"><circle cx="44" cy="14" r="10" fill="#e9b43c" opacity=".7"/><path d="M2 26q7-7 14 0t14 0t14 0t14 0V40H2z" fill="#9cc9d9"/><path d="M2 26q7-7 14 0t14 0t14 0t14 0" fill="none" stroke="#2f6fa8" stroke-width="2"/></svg>"""

nbRawHtml: """<article>
<p class="kicker">Diagrams · part five · a working sheet</p>
<h1>A House Style<b>.</b></h1>
<p class="lede">Each part of this series kept the style of its own figure. Everything else
diagrammari writes needs one style of its own: this part is where we look for it.</p>"""

nbText: """
The series has four figures so far, one per part: Edward Tufte for the history, Otto Neurath for
the everyday diagrams, Enzo Mari for the personal layer, and a seaside picture book for the
name. The rest of diagrammari (the explainer, the specs, the devlog, the pages of the API) needs
one style that does not change from page to page.

Pietro's brief for it, in short: *a mix along Neurath and Enzo Mari, with a hint of Tufte and the
whimsical touch of part 4. It may sound impossible and come out not great, so we iterate.* This
page is the first round, and the page itself is a fifth attempt: Jost for the text, as Futura was
Isotype's face; Crimson Pro italic for the notes, after Tufte; flat colours from the sea; black
lines for structure.
"""

nbRawHtml: """<h2><span class="n">1</span>Four ingredients</h2>
<div class="ingredients">
<div>""" & mark("neurath") & """<b>Neurath</b>One symbol, one meaning. Count by repeating, never by making bigger. Flat colours, a few of them.</div>
<div>""" & mark("mari") & """<b>Enzo Mari</b>Show the joints. Standard parts, numbered, that anyone can rebuild. Black and one red.</div>
<div>""" & mark("tufte") & """<b>a hint of Tufte</b>Notes in the margin, small multiples, ink spent only on data.</div>
<div>""" & mark("sea") & """<b>the sea</b>From part 4: a soft hand, a wave, a joke in the corner. Used sparingly.</div>
</div>"""

nbText: """
They pull in different directions. Neurath and Mari are both *systems*: rules first, so that
anyone can make the next chart or the next chair. Tufte is a *craft*: every figure is thought
through by hand. The sea is a *mood*. A house style for a library is mostly a system, because
the next page will be written by someone else, maybe by an agent; the craft and the mood are
what keep it from being dull.
<span class="mn">The style also draws the diagrams: a mari <code>Theme</code> is a set of Pele
colours and a font, so every specimen below draws its own diagram.</span>

What the style has to carry, from the start: long prose (the explainer), requirements with
scenarios and examples that run (the specs), dated posts (the devlog), code, tabelline tables,
and diagrams.
"""

nbRawHtml: """<h2><span class="n">2</span>Three specimens</h2>
<p>The same small page three times: a title, a paragraph, a diagram drawn by mari with that
specimen's theme, a table and a line of code. Only the mix changes.</p>
<div class="specimens">
<section class="specimen spec-a"><span class="tag">A · officina</span>
<h4>Drawing a flowchart</h4>
<p>Enzo Mari first. Everything is a part with a number; lines are joints, drawn black, and the
one red marks what you can change. Like a sheet of <i>Autoprogettazione</i>.</p>"""
nbDiagram "flowchart LR\n  t[Mermaid text] --> p[Pele] --> s[SVG]"
nbRawHtml: """<table class="mini"><tr><th>part</th><th>what</th><th>since</th></tr>
<tr><td>01</td><td>flowchart builder</td><td>0.1</td></tr><tr><td>02</td><td>sequence builder</td><td>0.1</td></tr>
<tr><td>03</td><td>personal layer</td><td>to come</td></tr></table>
<p><code>nbDiagram flowchart(LR): "a" --&gt; "b"</code></p></section>
<section class="specimen spec-b"><span class="tag">B · isotype al mare</span>
<h4>Drawing a flowchart</h4>
<p>Neurath first, in the colours of the sea. Quantities are counted in symbols: the series so
far, one page per part, each in its figure's colour.</p>
<div class="count">""" & page("#8a8a8a") & page("#2f6fa8") & page("#111") & page("#e0533d") &
  page("#e9b43c") & """&nbsp; five parts</div>"""
nbDiagram "flowchart LR\n  t[Mermaid text] --> p[Pele] --> s[SVG]"
nbRawHtml: """<table class="mini"><tr><th>builder</th><th>diagram</th><th>since</th></tr>
<tr><td>flowchart</td><td>boxes and arrows</td><td>0.1</td></tr><tr><td>sequence</td><td>messages in time</td><td>0.1</td></tr>
<tr><td>layer</td><td>yours on top</td><td>to come</td></tr></table>
<p><code>nbDiagram flowchart(LR): "a" --&gt; "b"</code></p></section>
<section class="specimen spec-c"><span class="tag">C · quaderno di bordo</span>
<h4>Drawing a flowchart</h4>
<p>Tufte first, kept like a ship's log: a serif for reading, notes beside the text, and a wash
of sea and sun in the corners. The softest of the three.</p>"""
nbDiagram "flowchart LR\n  t[Mermaid text] --> p[Pele] --> s[SVG]"
nbRawHtml: """<table class="mini"><tr><th>builder</th><th>diagram</th><th>since</th></tr>
<tr><td>flowchart</td><td>boxes and arrows</td><td>0.1</td></tr><tr><td>sequence</td><td>messages in time</td><td>0.1</td></tr>
<tr><td>layer</td><td>yours on top</td><td>to come</td></tr></table>
<p><code>nbDiagram flowchart(LR): "a" --&gt; "b"</code></p></section>
</div>"""

nbText: """
How much of each ingredient went into each specimen, by eye. The table is tabelline's, with its
smallest chart, a bar in each cell:
"""

nbCode:
  let mix = tableData:
    specimen: ["A · officina", "B · isotype al mare", "C · quaderno di bordo", "this page"]
    neurath: [20, 55, 10, 35]
    mari: [60, 15, 10, 35]
    tufte: [15, 10, 55, 20]
    sea: [5, 20, 25, 10]
  let weights = tabella(mix, rownameCol = "specimen"):
    tabHeader "The mix", "percent of each ingredient, by eye"
    fmtBar ["neurath"], color = "#2f6fa8", width = "5em", domain = (0.0, 100.0)
    fmtBar ["mari"], color = "#111111", width = "5em", domain = (0.0, 100.0)
    fmtBar ["tufte"], color = "#77716a", width = "5em", domain = (0.0, 100.0)
    fmtBar ["sea"], color = "#9cc9d9", width = "5em", domain = (0.0, 100.0)
    colsLabel {"neurath": "Neurath", "mari": "Mari", "tufte": "Tufte", "sea": "the sea"}
    tabOptions(tableFontNames = "Jost, sans-serif", tableBackgroundColor = "transparent",
               tableBorderTopColor = "#161616", tableBorderBottomColor = "#161616",
               columnLabelsBorderBottomColor = "#161616", tableBodyHlinesColor = "#d8cfbd",
               headingAlign = "left", tableWidth = "100%")
nbTable weights

nbRawHtml: """<h2><span class="n">3</span>How we choose</h2>"""

nbText: """
- **Pietro picks, or mixes.** "A's tables with C's text" is a fine answer. Things to look at: the
  specs page, which is the page read most; the code, which must stay small and clear; and the
  diagrams, which must look like they belong to the page.
- **Then it becomes a spec.** The chosen style is an OpenSpec change, *house-style*: the
  fonts (inlined, nothing remote), the colours, a mari `Theme` for diagrams, a tabelline
  options preset for tables, and the rules (what the red is for, when a drawing from the sea is
  allowed).
- **Then a theme module** replaces today's provisional *tavola* look, the technical-drawing sheet
  of the first day, across the explainer, the specs and the devlog. The parts of this series
  keep their own styles.
"""

nbRawHtml: """<p class="ending">Part 5 of <a href="""" & seriesIndex & """">Diagrams, a series in five parts</a>.
Previous: <a href="../a-name-from-the-sea/">A Name from the Sea</a>. This page will change as the style is chosen.</p>
</article>"""

nbSave
