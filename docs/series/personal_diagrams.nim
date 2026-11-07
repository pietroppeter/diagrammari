## The nimib version of part 3, "Ready-made, Then Made Yours" (Enzo Mari style). The prose and the
## interactive proof of concept are taken from the hand-made page as they were made; the parts
## list is a tabelline table, and the nimib family is also drawn by mari when the page is built,
## from the same Mermaid text the proof of concept starts from.
## Writes docs/series/personal-diagrams/nimib.html.
import std/[os, json, strutils]
import nimib except md
import tabelline, tabelline/nimib
import mari, mari/nimib
import serie

let root = currentSourcePath().parentDir
nbInit
nb.doc.filename = root / "personal-diagrams" / "nimib.html"
nb.useSerie(part = "3", title = "Ready-made, Then Made Yours · nimib version",
  description = "The nimib version of part three of the Diagrams series: standard diagrams with a personal layer, in the style of Enzo Mari.",
  css = "personal.css", original = "index.html",
  fonts = "<style>" & fontFace("Archivo", "archivo-latin-400-normal.woff2") &
    fontFace("Archivo", "archivo-latin-700-normal.woff2", 700) &
    fontFace("Archivo", "archivo-latin-800-normal.woff2", 800) &
    fontFace("IBM Plex Mono", "ibm-plex-mono-latin-400-normal.woff2") &
    fontFace("Crimson Pro", "crimson-pro-latin-400-normal.woff2") &
    fontFace("Jost", "jost-latin-400-normal.woff2") &
    fontFace("Patrick Hand", "patrick-hand-latin-400-normal.woff2") & "</style>")
const mariTheme = Theme(bg: "#ffffff", fg: "#161616", muted: "#6a675f", line: "#161616",
  surface: "#ffffff", surfaceAlt: "#f1ede1", border: "#161616", accent: "#d2361f",
  font: "Archivo, sans-serif", radius: "0px")
nb.doc.context["stylesheet"] = %(nb.doc.context["stylesheet"].getStr & "\n<style>" &
  ".tabella{margin:10px 0 18px;overflow-x:auto}.static{border:1.5px solid #161616;background:#fff;padding:12px;margin:12px 0}" &
  mariTheme.css(".mari") & "</style>")
nb.useDiagrams(mode = rmStatic, fontFamily = "Archivo")

let page = handmade("personal-diagrams")

nbRawHtml: page.cut("<header>", "<main class=\"wrap\">") & "<div class=\"wrap\">" &
  page.cut("<h2><span class=\"no\">1</span>", "<table class=\"parts\">")

nbText: """
The parts list, as a [tabelline](https://github.com/pietroppeter/tabelline) table: one row per
part, like the cutting list on a sheet of *Autoprogettazione*.
"""

nbCode:
  let parts = tableData:
    how_many: ["1 ×", "1 ×", "0–1 ×", "n ×"]
    part: ["Source", "Drawing", "Layer", "Themes"]
    what: ["Mermaid text. Standard, portable, diffable. Says *what* and *which links*.",
           "Pele’s SVG. Every node carries `data-id` and its position, and every edge carries its id, which is what makes a layer possible.",
           "JSON. Optional and personal. Offsets, not coordinates, so a nudge still means something after the algorithm moves things.",
           "Fonts and colours as Pele CSS variables, plus a few line weights. The same source and layer can be drawn in any of them."]
  let cuttingList = tabella(parts, rownameCol = "part"):
    fmtMarkdown ["what"]
    colsMoveToStart ["how_many"]
    colsLabel {"how_many": "", "what": ""}
    tabOptions(tableFontNames = "Archivo, sans-serif", tableBackgroundColor = "transparent",
               tableBorderTopColor = "#161616", tableBorderBottomColor = "#161616",
               columnLabelsBorderBottomColor = "transparent", tableBodyHlinesColor = "#d8d4c8",
               tableWidth = "100%")
nbTable cuttingList

nbRawHtml: page.cut("<h2><span class=\"no\">2</span>", "<h2><span class=\"no\">5</span>")

nbText: """
### The standard drawing, made when the page was built

Everything above runs in the browser. Here is the first sheet of the stack without the layer: the
nimib family, from the same Mermaid text the proof of concept starts from, drawn by mari (through
Pele) when this page was built. It is plain SVG, so it shows even without JavaScript. The
personal layer is what the library adds next.
"""

nbCode:
  let family = diagram(page.cut("const FAMILY=`", "`;")["const FAMILY=`".len .. ^1])
nbRawHtml: "<div class=\"static\">"
nbDiagram family, showSource = true
nbRawHtml: "</div>"

nbRawHtml: page.cut("<h2><span class=\"no\">5</span>", "<p class=\"foot\">") & "</div>" &
  page.cut("<script src=\"vendor/pele", "</body>")

nbSave
