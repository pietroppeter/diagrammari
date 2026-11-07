## The nimib version of part 2, "Diagrams Nobody Has to Think About" (Isotype style). The prose is
## taken from the hand-made page as it was written; the two tables are tabelline tables made
## from data, and the Mermaid example is drawn by mari when the page is built.
## Writes docs/series/everyday-diagrams/nimib.html.
import std/[os, json, strutils, sequtils]
import nimib except md
import tabelline, tabelline/nimib
import mari, mari/nimib
import serie

let root = currentSourcePath().parentDir
nbInit
nb.doc.filename = root / "everyday-diagrams" / "nimib.html"
nb.useSerie(part = "2", title = "Diagrams Nobody Has to Think About · nimib version",
  description = "The nimib version of part two of the Diagrams series: crafted graphics and standard diagrams, in the style of Otto Neurath.",
  css = "everyday.css", original = "index.html",
  fonts = "<style>" & fontFace("Jost", "jost-latin-400-normal.woff2") &
    fontFace("Jost", "jost-latin-500-normal.woff2", 500) &
    fontFace("Jost", "jost-latin-700-normal.woff2", 700) & "</style>")
const isotype = Theme(bg: "transparent", fg: "#1c1b19", muted: "#5d5a52", line: "#1c1b19",
  surface: "#fbf7ec", surfaceAlt: "#f1ead9", border: "#1c1b19", accent: "#c8402b",
  font: "Jost, sans-serif", radius: "0px")
nb.doc.context["stylesheet"] = %(nb.doc.context["stylesheet"].getStr & "\n<style>" &
  "main{max-width:none;padding:0}.page{max-width:860px;margin:0 auto;padding:0 20px 80px}" &
  ".tabella{margin:10px 0 18px;overflow-x:auto}.tabella svg.ic{width:20px;height:26px;vertical-align:middle}" &
  ".tabella svg.ic.p{fill:#c8402b}.tabella svg.ic.g{fill:#2d5d8c}" &
  isotype.css(".mari") & "</style>")
nb.useDiagrams(mode = rmStatic, fontFamily = "Jost")

let page = handmade("everyday-diagrams")

nbRawHtml: page.cut("<header class=\"hero\">", "<main>") & "<div class=\"page\">" &
  page.cut("<svg viewBox=\"0 0 860 70\"", "<table class=\"vs\">")

nbText: """
In this version the comparison is a [tabelline](https://github.com/pietroppeter/tabelline) table,
made from two lists of the same length:
"""

nbCode:
  let lines = tableData:
    aspect: ["Reader", "Unit of design", "Who decides the form", "Measure of quality",
             "Typical failure", "Tools"]
    crafted: ["An expert with time to study", "One graphic", "The designer, each time",
              "Data density, data-ink, integrity", "Chartjunk", "D3, Vega-Lite, ggplot2, Plot"]
    standard: ["Anyone, at a glance", "A system of symbols and rules", "The convention, once",
               "Recognisability, consistency, speed of reading",
               "Spaghetti: boxes and arrows that say nothing", "Graphviz, PlantUML, Mermaid, D2, Pele"]
  let twoLines = tabella(lines, rownameCol = "aspect"):
    colsLabel {"crafted": "Crafted graphic", "standard": "Standard diagram"}
    tabOptions(tableFontNames = "Jost, sans-serif", tableBackgroundColor = "transparent",
               tableBorderTopColor = "#1c1b19", tableBorderBottomColor = "#1c1b19",
               columnLabelsBorderBottomColor = "#1c1b19", tableBodyHlinesColor = "#cfc6b0",
               tableWidth = "100%")
nbTable twoLines

nbRawHtml: page.cut("<p>The word “industrial”", "<div class=\"panel\">") &
  page.cut("<div class=\"panel\">", "<div class=\"dec\"")

nbText: """
The chart is a table too. Each tool is one row of six booleans, *true* when you decide; the
symbols are a formatter, and the count in the last column is computed:
"""

nbCode:
  const decisions = ["what", "links", "kind", "place", "route", "look"]
  let byTool = @[
    ("Pen, whiteboard, Excalidraw", [true, true, true, true, true, true]),
    ("D3 (you also write the drawing)", [true, true, true, true, true, true]),
    ("draw.io, Visio, Lucidchart", [true, true, true, true, false, false]),
    ("Graphviz dot", [true, true, true, false, false, true]),
    ("Mermaid, Pele, PlantUML, D2", [true, true, true, false, false, false]),
    ("C4 model in Structurizr", [true, true, false, false, false, false])]
  let who = TableData()
  who.addColumn("tool", byTool.mapIt(toValue(it[0])))
  for k, d in decisions:
    who.addColumn(d, byTool.mapIt(toValue(it[1][k])))
  who.addColumn("yours", byTool.mapIt(toValue(it[1].countIt(it))))

  const
    you = """<svg viewBox="0 0 30 40" class="ic p" aria-label="you"><use href="#person"/></svg>"""
    tool = """<svg viewBox="0 0 40 40" class="ic g" aria-label="tool"><use href="#cog"/></svg>"""
  let whoDecides = tabella(who, rownameCol = "tool"):
    fmt decisions, proc (v: Value, ctx: RenderContext): string =
      if ctx == rcHtml: (if v.b: you else: tool) else: (if v.b: "you" else: "tool")
    colsLabel {"what": "What", "links": "Links", "kind": "Kind", "place": "Place",
               "route": "Route", "look": "Look", "yours": "of 6"}
    colsAlign alCenter, decisions
    tabOptions(tableFontNames = "Jost, sans-serif", tableBackgroundColor = "transparent",
               tableBorderTopColor = "#1c1b19", tableBorderBottomColor = "#1c1b19",
               columnLabelsBorderBottomColor = "#1c1b19", tableBodyHlinesColor = "#cfc6b0",
               tableWidth = "100%")
nbTable whoDecides

nbRawHtml: page.cut("<div class=\"legend\">", "<h2><span class=\"n\">4</span>") &
  page.cut("<h2><span class=\"n\">4</span>", "<p>The difference in effort")

nbText: """
Here is the same four-step process in Mermaid and in D3. In this version the Mermaid text is drawn
by mari when the page is built, so it reaches the reader as SVG, with no JavaScript. The D3 code
still runs in the browser, from the copy of D3 7.9.2 kept next to the hand-made page.
"""

nbCode:
  let process = diagram("""
flowchart LR
  idea --> draft
  draft --> review
  review --> ship""")
nbDiagram process, caption = "Drawn by Pele, through mari, when this page was built."

nbRawHtml: "<div class=\"code2\" style=\"grid-template-columns:1fr\">" &
  page.cut("<div><h3>D3</h3>", "<p class=\"cap\">Four lines against nineteen") &
  page.cut("<p class=\"cap\">Four lines against nineteen", "<p class=\"foot\">") &
  "</div>" & """<script src="vendor/d3-7.9.2.min.js"></script>
<script>try{new Function("d3",document.getElementById("d3-src").textContent)(d3);}
catch(e){document.getElementById("d3-out").innerHTML='<span class="err">D3 did not load: '+e.message+'</span>';}</script>"""

nbSave
