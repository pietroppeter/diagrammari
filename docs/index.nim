## The home page, docs/index.html: what diagrammari is, one diagram, and the way to the living
## documents and the devlog.
import std/os
import nimib
import mari, mari/nimib
import tavola

let docs = currentSourcePath().parentDir
nbInit
nb.doc.filename = docs / "index.html"
nb.useTavola(titolo = "diagrams for Nim, drawn by Pele", tavola = "0", scala = "1:1",
             title = "diagrammari: diagrams for Nim, drawn by Pele",
             description = "diagrammari: Mermaid diagrams in Nim and nimib, drawn as SVG by Pele.")

nbText: """
<p class="lede"><strong>diagrammari</strong> makes diagrams in Nim: write Mermaid text, or build
flowcharts, sequence diagrams, pie charts and timelines with Nim verbs, and
<a href="https://pele.run">Pele</a> draws them as SVG, when the page is built or in the browser.
It fits in <a href="https://github.com/pietroppeter/nimib">nimib</a> notebooks, and every page
of this site is one.</p>
"""

nbCode:
  let f = flowchart(LR):
    node "nim", "Nim code", stadium
    node "text", "Mermaid text"
    node "pele", "Pele", hexagon
    node "svg", "SVG", round
    node "md", "GitHub draws it"
    "nim" --> "text"
    link "text", "pele", "in Node, at build time"
    "pele" --> "svg"
    link "text", "md", "in a README", dotted
nbDiagram f, caption = "<b>Tavola 0.</b> How a diagram is made here."

nbText: """
<div class="cards">
<div class="nota"><span class="titolo"><a href="explainer/">Explainer</a></span>From one arrow to every kind of diagram: Mermaid text, diagrammari's verbs, where each kind of diagram comes from, and at the end how it is all built.</div>
<div class="nota"><span class="titolo"><a href="specs/">Specs</a></span>How diagrammari behaves today, with examples that ran, and the diagrams they drew, when the page was built.</div>
<div class="nota"><span class="titolo"><a href="devlog/">Devlog</a></span>Living documents first, then dated posts on how diagrammari is made.</div>
</div>

Status: a first version, a proof of concept. The API will change.
"""
nbSave
