## The look of the "Diagrams" series: each part keeps the style of its hand-made original (a CSS
## file in assets/), with a small series bar on top and a footer that shows the page's source.
## The parts are nimib notebooks; the hand-made HTML originals sit beside them.
import std/[os, strformat, strutils, json, base64]
import nimib except md

const
  assets = currentSourcePath().parentDir / "assets"
  repoUrl* = "https://github.com/pietroppeter/diagrammari"
  parts* = [
    ("1", "diagram-history", "Boxes, Lines and Arrows"),
    ("2", "everyday-diagrams", "Diagrams Nobody Has to Think About"),
    ("3", "personal-diagrams", "Ready-made, Then Made Yours"),
    ("4", "a-name-from-the-sea", "A Name from the Sea"),
    ("5", "a-house-style", "A House Style")]
  seriesIndex* = "../../devlog/diagrams-series/"

proc asset*(name: string): string = readFile(assets / name)

proc fontFace*(family, file: string, weight = 400, style = "normal"): string =
  ## An @font-face rule with the font (from assets/fonts/, SIL OFL) inlined, so the page needs
  ## nothing remote.
  &"""@font-face{{font-family:"{family}";font-weight:{weight};font-style:{style};font-display:swap;""" &
    &"""src:url(data:font/woff2;base64,{encode(readFile(assets / "fonts" / file))}) format("woff2")}}""" & "\n"

func serieText(blk: JsonNode, nb: Nb): string =
  ## Markdown as nimib renders it, without the default wrapper.
  markdownToHtml(blk{"text"}.getStr)

func serieHeader(blk: JsonNode, nb: Nb): string =
  let cur = nb.doc.context{"serie_part"}.getStr
  let base = nb.doc.context{"serie_base"}.getStr("../")
  var links = ""
  for (n, slug, title) in parts:
    let href = &"{base}{slug}/"
    let cls = if n == cur: " class=\"cur\"" else: ""
    links.add &"""<a href="{href}"{cls} title="{title}">{n}</a>"""
  let orig = nb.doc.context{"serie_original"}.getStr
  &"""<nav class="serie"><a href="{seriesIndex}">Diagrams · a series in five parts</a><span class="parts">{links}</span>""" &
    (if orig.len > 0: &"""<a href="{orig}">hand-made version</a>""" else: "") & "</nav>"

func serieFooter(blk: JsonNode, nb: Nb): string =
  let source = nb.doc.context{"source_highlighted"}.getStr
  let what = if nb.doc.context{"serie_original"}.getStr.len > 0:
      "This is the nimib version of the page: a Nim program that ran when the page was built"
    else: "This page is a nimib notebook: a Nim program that ran when the page was built"
  &"""<footer class="serie">{what}, with
tables by <a href="https://github.com/pietroppeter/tabelline">tabelline</a>. Part of
<a href="{seriesIndex}">Diagrams, a series in five parts</a>, in
<a href="{repoUrl}">diagrammari</a>.""" &
    (if source.len == 0: "" else:
      """<details><summary>show the source of this page</summary><pre><code class="nohighlight nim">""" &
      source & "</code></pre></details>") & "</footer>"

func emptyPartial(blk: JsonNode, nb: Nb): string = ""

const serieCss = """
nav.serie{display:flex;gap:14px;align-items:center;flex-wrap:wrap;font:13px/1.4 ui-monospace,Menlo,monospace;
  padding:8px 14px;border-bottom:1px solid currentColor;opacity:.85}
nav.serie a{color:inherit}
nav.serie .parts{display:flex;gap:6px}
nav.serie .parts a{display:inline-grid;place-items:center;width:22px;height:22px;border:1px solid currentColor;text-decoration:none}
nav.serie .parts a.cur{border-width:2px;font-weight:700;text-decoration:underline}
.tabella td.tb_stub{white-space:nowrap}
footer.serie{font:13px/1.5 ui-monospace,Menlo,monospace;margin:48px auto 40px;max-width:900px;padding:12px 16px;border-top:1px solid currentColor;opacity:.85}
footer.serie details pre{max-height:420px;overflow:auto;font-size:12px}
body pre > code{display:block}
"""

proc useSerie*(nb: var Nb, part, title, description, css: string, fonts = "", original = "",
               base = "../") =
  ## Sets the page title, the part's own CSS (from assets/) and the series bar and footer.
  nb.doc.context["title"] = %title
  nb.doc.context["serie_part"] = %part
  nb.doc.context["serie_original"] = %original
  nb.doc.context["serie_base"] = %base
  nb.doc.context["stylesheet"] = %(
    &"""<meta name="description" content="{description.replace("\"", "&quot;")}">""" & "\n" & fonts &
    "\n<style>\n" & asset(css) & "\n" & serieCss & "</style>")
  nb.doc.context["highlight"] = %""
  nb.doc.context["nb_style"] = %""
  nb.doc.context["disableHighlightJs"] = %true
  nb.backend.partials["header"] = serieHeader
  nb.backend.partials["footer"] = serieFooter
  nb.backend.partials["nbText"] = serieText
  nb.backend.partials["left"] = emptyPartial
  nb.backend.partials["right"] = emptyPartial

proc handmade*(slug: string): string =
  ## The hand-made page of a part, so its nimib version can reuse the prose as it was written.
  readFile(currentSourcePath().parentDir / slug / "index.html")

func cut*(html, first, last: string): string =
  ## The piece of `html` from `first` (included) up to `last` (excluded); `last = ""` goes to the
  ## end. Fails loudly when a marker is missing, so a change to the hand-made page shows up.
  let a = html.find(first)
  doAssert a >= 0, "marker not found: " & first
  if last.len == 0: return html[a .. ^1]
  let b = html.find(last, a + first.len)
  doAssert b >= 0, "marker not found: " & last
  html[a ..< b]
