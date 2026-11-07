## Diagrams in HTML pages.
##
## Two modes:
##
## - `rmStatic`: Pele draws the SVG at build time (`toSvg`, with Node) and the page holds it.
##   No JavaScript; works in feeds, PDF export and pages that block scripts. With `narrow`, a
##   second drawing for narrow screens (Pele's vertical layouts) is shown below that width.
## - `rmClient`: the page holds the Mermaid text and Pele draws it when the page opens, at the
##   width of the page, with zoom for large diagrams. The page needs `peleScript` once, before
##   the first diagram. Without JavaScript the reader sees the Mermaid text.
##
## `rmAuto` is static when Node is there, client otherwise.

import std/[strutils, json]
import core, pele, flowchart, sequence, pie, timeline

type
  AnyDiagram* = Diagram | Flowchart | Sequence | Pie | Timeline
    ## What the renderers accept: Mermaid text or a typed builder.

  RenderMode* = enum
    rmAuto = "auto", rmStatic = "static", rmClient = "client"

func esc(s: string): string =
  s.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"), ("\"", "&quot;"))

proc toSvg*(d: Flowchart | Sequence | Pie | Timeline, options = defaultOptions): Svg =
  d.toDiagram.toSvg(options)

proc resolve*(mode: RenderMode): RenderMode =
  ## `rmAuto` made concrete: static when Node is there.
  if mode != rmAuto: mode elif nodeAvailable(): rmStatic else: rmClient

proc peleScript*(cdn = false): string =
  ## What a page needs once, before its first client-mode diagram: Pele (inlined, or from
  ## jsDelivr pinned to `peleVersion` when `cdn`) and the small function that mounts each diagram.
  let lib = if cdn: "<script src=\"" & peleCdn & "\"></script>"
            else: "<script>" & peleBundle.replace("</script", "<\\/script") & "</script>"
  lib & """<script>
function mariMount(script) {
  const fig = script.parentElement, src = fig.querySelector('.mari-source');
  const box = fig.querySelector('.mari-mount');
  const opts = JSON.parse(fig.dataset.options || '{}');
  pele.mount(box, src.textContent, opts);
  if (box.querySelector('svg')) src.hidden = true;
}
</script>"""

func captionHtml(c: string): string =
  if c.len > 0: "<figcaption>" & c & "</figcaption>" else: ""

proc toHtml*(d: AnyDiagram, mode = rmAuto, options = defaultOptions, narrow = 0.0,
             caption = ""): string =
  ## The diagram as a `<figure class="mari">`, drawn as `mode` says. `caption` is HTML.
  let dg = d.toDiagram
  let cls = "mari mari-" & $dg.kind
  case mode.resolve
  of rmStatic:
    let wide = dg.toSvg(options).svg
    var narrowSvg = ""
    if narrow > 0:
      let p = if options.idPrefix.len > 0: options.idPrefix else: idFor(dg.source)
      var o = options
      o.maxWidth = narrow
      o.idPrefix = p & "n-"
      narrowSvg = dg.toSvg(o).svg
      # the same drawing at both widths (most diagrams but flowcharts): keep one
      if narrowSvg.replace(o.idPrefix, "") == wide.replace(p, ""): narrowSvg = ""
    if narrowSvg.len == 0:
      result = "<figure class=\"" & cls & "\">" & wide & captionHtml(caption) & "</figure>"
    else:
      let id = idFor(dg.source) & "fig"
      let w = $int(narrow)
      result = "<figure class=\"" & cls & "\" id=\"" & id & "\" style=\"container-type:inline-size\">" &
        "<style>#" & id & " .dg-narrow{display:none}@container (max-width:" & w & "px){#" & id &
        " .dg-wide{display:none}#" & id & " .dg-narrow{display:block}}</style>" &
        "<div class=\"dg-wide\">" & wide & "</div><div class=\"dg-narrow\">" & narrowSvg & "</div>" &
        captionHtml(caption) & "</figure>"
  of rmClient, rmAuto:
    var o = options.toJson(dg.source)
    o.delete("idPrefix")   # mount gives each diagram its own
    result = "<figure class=\"" & cls & "\" data-options=\"" & esc($o) & "\">" &
      "<div class=\"mari-mount\"></div><pre class=\"mari-source\">" & esc(dg.source) &
      "</pre><script>mariMount(document.currentScript)</script>" & captionHtml(caption) & "</figure>"

proc toPage*(d: AnyDiagram, title = "diagram", mode = rmAuto, css = ""): string =
  ## A standalone HTML page with the diagram.
  let m = mode.resolve
  "<!doctype html>\n<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">\n" &
    "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n<title>" &
    esc(title) & "</title>\n<style>body{margin:0;padding:1rem;font-family:sans-serif}" &
    "figure.mari{margin:0}" & css & "</style>\n</head>\n<body>\n" &
    (if m == rmClient: peleScript() else: "") & d.toHtml(m) & "\n</body>\n</html>\n"

proc save*(d: AnyDiagram, path: string, mode = rmAuto) =
  ## Writes the diagram to `path`: an `.svg` file (drawn at build time), a `.md` file (a
  ## ```mermaid block) or a standalone `.html` page.
  if path.endsWith(".svg"): writeFile(path, d.toSvg.svg)
  elif path.endsWith(".md"): writeFile(path, d.toDiagram.toMarkdown & "\n")
  else: writeFile(path, d.toPage(mode = mode))
