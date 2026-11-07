## diagrammari in nimib notebooks: `nbDiagram d` shows a diagram as a block of the page.
##
## ```nim
## import nimib, mari, mari/nimib
## nbInit
## nb.useDiagrams(mode = rmStatic)    # optional: how this page draws its diagrams
## nbCode:
##   let f = flowchart(LR):
##     "a" --> "b"
## nbDiagram f
## nbDiagram """
##   pie
##     "Nim" : 80
##     "Other" : 20"""
## nbSave
## ```
##
## The block keeps the HTML and the Mermaid text, so it renders with both of nimib's backends:
## with `nbInitMd` (a README) it writes a ```mermaid block, which GitHub draws.
## In client mode the first diagram of the page brings Pele with it.

import std/[json, strutils]
import pkg/nimib
import ../mari

newNbBlock(NbDiagram):
  html: string
  source: string
  client: bool
  cdn: bool
  toHtml:
    var first = false
    if blk.client:
      for b in nb.doc.blocksFlattened:
        if b of NbDiagram and b.NbDiagram.client:
          first = cast[pointer](b) == cast[pointer](blk)
          break
    (if first: peleScript(blk.cdn) else: "") & blk.html

func nbDiagramToMd*(blk: NbBlock, nb: Nb): string =
  "```mermaid\n" & blk.NbDiagram.source & "\n```\n"
nbToMd.funcs["NbDiagram"] = nbDiagramToMd

proc useDiagrams*(nb: var Nb, mode = rmAuto, cdn = false, narrow = 0.0, fontFamily = "") =
  ## How the page draws its diagrams: `mode` (static at build time, in the browser, or auto),
  ## `cdn` to load Pele from jsDelivr instead of inlining it, `narrow` to add a narrow-screen
  ## drawing in static mode, and `fontFamily` to measure labels with the page's font.
  nb.doc.context["diagrammari"] = %*{"mode": $mode, "cdn": cdn, "narrow": narrow,
                                   "fontFamily": fontFamily}

proc settings(nb: Nb): JsonNode =
  result = nb.doc.context{"diagrammari"}
  if result.isNil: result = %*{"mode": "auto", "cdn": false, "narrow": 0.0, "fontFamily": ""}

proc diagramBlock*(nb: var Nb, d: AnyDiagram, caption = "", showSource = false) =
  let s = nb.settings
  let mode = (case s["mode"].getStr
    of "static": rmStatic
    of "client": rmClient
    else: rmAuto).resolve
  var o = defaultOptions
  o.fontFamily = s["fontFamily"].getStr
  let dg = d.toDiagram
  var html = dg.toHtml(mode, o, narrow = s["narrow"].getFloat, caption = caption)
  if showSource:
    html.add "<details class=\"mari-text\"><summary>Mermaid text</summary><pre><code class=\"language-mermaid\">" &
      dg.source.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;")) & "</code></pre></details>"
  nb.add newNbDiagram(html = html, source = dg.source, client = mode == rmClient,
                      cdn = s["cdn"].getBool)

template nbDiagram*(d: AnyDiagram, caption = "", showSource = false) =
  ## Adds the diagram `d` to the page; `caption` is HTML, `showSource` adds the Mermaid text
  ## in a fold under it.
  nb.diagramBlock(d, caption, showSource)

template nbDiagram*(source: string, caption = "", showSource = false) =
  ## Adds a diagram written as Mermaid text.
  nb.diagramBlock(diagram(source), caption, showSource)
