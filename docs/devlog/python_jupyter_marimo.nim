## devlog: 07 Nov 2026 | diagrammari in Python, Jupyter and marimo: the evidence | A case file: a Nim library in a Python wheel with uv add, Pele in QuickJS compiled in, one editor for Jupyter and marimo, the personalized SVG exported, and the case of one repo or two, judged twice.
## Written as a case file, in its own look (devlog posts keep their own themes for now). The
## content is docs/assets/python-case/case.html, first published as a claude.ai artifact and in
## claude-artifacts; the outputs in it are files in docs/assets/python-case, copied from real
## runs. Fonts, screenshots, Pele and the editor are inlined, so the page loads nothing remote.
## The loop diagram at the top is drawn here, at build time, by mari.
import std/[os, strutils, base64, strformat, json]
import nimib
import mari

let
  here = currentSourcePath().parentDir
  assets = here.parentDir / "assets"
  ev = assets / "python-case"
  fontDir = assets / "fonts"
  peleJs = here.parentDir.parentDir / "src" / "mari" / "vendor" / "pele.global.js"
  widgetJs = here.parentDir.parentDir / "experiments" / "python" / "src" / "mari" / "widget.js"

proc esc(s: string): string = s.multiReplace(("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"))
proc text(name: string): string = esc(readFile(ev / name).strip(leading = false))
proc font(family, file, weight, style: string): string =
  &"@font-face{{font-family:'{family}';src:url(data:font/woff2;base64,{encode(readFile(fontDir / file))}) format('woff2');font-weight:{weight};font-style:{style};font-display:swap}}\n"

let loop = readFile(ev / "pipeline.mmd")
let opts = renderOptions(fontFamily = "IBM Plex Sans, sans-serif", idPrefix = "pipe-")
let wide = diagram(loop).toSvg(opts).svg
let narrow = diagram(loop.replace("flowchart LR", "flowchart TD")).toSvg(
  renderOptions(fontFamily = "IBM Plex Sans, sans-serif", idPrefix = "pipn-")).svg

var page = readFile(ev / "case.html")
for (k, v) in [("{{build}}", text("build_qjs.txt")), ("{{wheel}}", text("wheel.txt")),
               ("{{add}}", text("add.txt")), ("{{run}}", text("run.txt")), ("{{qjs}}", text("qjs.txt")),
               ("{{demo_py}}", text("demo.py")), ("{{add_qjs}}", text("add_qjs.txt")),
               ("{{run_qjs}}", text("run_qjs.txt")), ("{{qjs_nim}}", text("qjs_nim.txt")),
               ("{{pipeline}}", wide), ("{{pipeline_narrow}}", narrow),
               ("{{plain}}", readFile(ev / "plain.svg").replace("\"mari-", "\"plain-")),
               ("{{personal}}", readFile(ev / "personal.svg"))]:
  doAssert k in page, k
  page = page.replace(k, v)
for img in ["marimo.png", "jupyterlab.png"]:
  page = page.replace("img/" & img, "data:image/png;base64," & encode(readFile(ev / img)))

let style = page[page.find("<style>") + 7 ..< page.find("</style>")]
var body = page[page.find("<main>") + 6 ..< page.find("</main>")]
body = body.replace("diagrammari · case file · 7 Nov 2026",
  """<a href="../">diagrammari devlog</a> · case file · 7 Nov 2026""")
let demo = page[page.find("<script type=\"module\">") + 22 ..< page.rfind("</script>")]
  .replace("import w from \"./widget.js\";", "")
let module = readFile(widgetJs).replace("export default { render };", "const w = { render };") & demo

nbInit
nb.doc.filename = here / "python-jupyter-marimo" / "index.html"
nb.doc.context["title"] = %"diagrammari in Python, Jupyter and marimo: the evidence"
nb.doc.context["stylesheet"] = %("<style>\n" &
  font("Special Elite", "special-elite.woff2", "400", "normal") &
  font("IBM Plex Sans", "plex-sans-regular.woff2", "400", "normal") &
  font("IBM Plex Sans", "plex-sans-italic.woff2", "400", "italic") &
  font("IBM Plex Sans", "plex-sans-semibold.woff2", "600", "normal") &
  font("IBM Plex Mono", "plex-mono-regular.woff2", "400", "normal") &
  style & "\nmain{padding-top:28px}\n</style>")
nb.doc.context["highlight"] = %""
nb.doc.context["nb_style"] = %""
nb.doc.context["disableHighlightJs"] = %true
func emptyPartial(blk: JsonNode, nb: Nb): string = ""
for p in ["header", "footer", "left", "right"]: nb.backend.partials[p] = emptyPartial

nbRawHtml: body
nbRawHtml: "<script>" & readFile(peleJs) & "</script>\n<script type=\"module\">" & module & "</script>"
nbSave
