## *Tavola*: the look of diagrammari's pages, a sheet of technical drawing.
##
## An Italian school *tavola* is an F4 sheet with a drawn frame (*squadratura*) and a title
## block (*cartiglio*: name, title, sheet number, scale, date). Here the page is the sheet; the
## cartiglio is the header; diagrams are pinned on graph paper (*carta millimetrata*) with
## registration marks; code is on tracing paper (*carta da lucido*); headings are hand-lettered
## with a technical pen; the *indice delle tavole* (table of contents) is built with the page.
##
## Nothing loads from elsewhere: the fonts (Architects Daughter for the lettering, IBM Plex Sans
## and Mono for the text, Arimo for the diagrams, all OFL) are inlined from `docs/assets/fonts`,
## Nim code is highlighted at build time by nimib, and diagrams are SVG drawn at build time. A
## page is one standalone HTML file.
##
## Arimo has the widths of Arial, the table Pele measures with in Node: so labels fit their
## boxes in diagrams drawn at build time.
##
## Usage, right after `nbInit`:
##   nb.useTavola(nome = "diagrammari", titolo = "...", tavola = "1", scala = "1:1")
##   nbIndice          # the table of contents of the `##` and `###` headings, where you put it

import std/[json, os, strutils, strformat, base64]
import nimib
import mari, mari/nimib

const
  repoUrl* = "https://github.com/pietroppeter/diagrammari"
  siteUrl* = "https://pietroppeter.github.io/diagrammari/"
  fontDir = currentSourcePath().parentDir / "assets" / "fonts"

func fontFace(family, file, weight, style: string): string =
  let data = encode(staticRead(fontDir / file & ".woff2"))
  &"@font-face{{font-family:'{family}';src:url(data:font/woff2;base64,{data}) format('woff2');" &
    &"font-weight:{weight};font-style:{style};font-display:swap}}\n"

const fonts = fontFace("Architects Daughter", "architects-daughter", "400", "normal") &
              fontFace("IBM Plex Sans", "plex-sans-regular", "400", "normal") &
              fontFace("IBM Plex Sans", "plex-sans-italic", "400", "italic") &
              fontFace("IBM Plex Sans", "plex-sans-semibold", "600", "normal") &
              fontFace("IBM Plex Mono", "plex-mono-regular", "400", "normal") &
              fontFace("Arimo", "arimo-regular", "400", "normal") &
              fontFace("Arimo", "arimo-bold", "700", "normal")

const tavolaTheme* = Theme(bg: "#FFFDF7", fg: "#1D232B", muted: "#5D6470", line: "#1D232B",
  surface: "#FFFDF7", surfaceAlt: "#F1EBDC", border: "#2B323C", accent: "#2457A6",
  critical: "#B23A2E", font: "Arimo, Arial, sans-serif", radius: "3px",
  series: @["#2457A6", "#B23A2E", "#C98A1B", "#3F7D4E", "#6B4C9A", "#2C8C99", "#8A5A3C", "#6D737D"])
  ## The diagrams' colours: India ink on drawing paper, a technical blue, red pencil.

const tavolaThemeDark* = Theme(bg: "#1B1F24", fg: "#E8E3D6", muted: "#A3A8B0", line: "#E8E3D6",
  surface: "#1B1F24", surfaceAlt: "#262B32", border: "#C9C3B4", accent: "#7FA7E8",
  critical: "#E8786B",
  series: @["#7FA7E8", "#E8786B", "#E3B55A", "#7FBF8E", "#B49BE0", "#6CC3CF", "#C99A78", "#A3A8B0"])

const tavolaCss* = """
:root {
  --sheet: #FBF8F0;          /* Fabriano drawing paper */
  --frame: #1D232B;          /* the squadratura, in India ink */
  --ink: #1D232B;
  --graphite: #4A515C;
  --blue: #2457A6;           /* technical blue: links, headings */
  --red: #B23A2E;            /* red pencil */
  --muted: #6A707A;
  --mm: rgba(214, 120, 60, .13);   /* carta millimetrata, 1 mm */
  --cm: rgba(214, 120, 60, .30);   /* and its 10 mm lines */
  --lucido: rgba(236, 243, 250, .82);
  --rule: #C9C2B0;
  --letter: "Architects Daughter", "Segoe Print", "Bradley Hand", cursive;
  --text: "IBM Plex Sans", system-ui, -apple-system, "Segoe UI", sans-serif;
  --mono: "IBM Plex Mono", ui-monospace, "SF Mono", Menlo, Consolas, monospace;
}
* { box-sizing: border-box; }
[hidden] { display: none !important; }
html { -webkit-text-size-adjust: 100%; }
body { margin: 0; color: var(--ink); font: 16.5px/1.62 var(--text); background: #E9E4D8;
  padding: max(10px, env(safe-area-inset-top, 0px)) max(10px, env(safe-area-inset-right, 0px)) 10px max(10px, env(safe-area-inset-left, 0px)); }
.foglio { max-width: 54rem; margin: 0 auto; background: var(--sheet); padding: 14px;
  box-shadow: 0 1px 2px rgba(0,0,0,.12), 0 8px 26px rgba(60,40,10,.12); }
.squadratura { border: 2px solid var(--frame); outline: 1px solid var(--frame); outline-offset: 4px;
  padding: 0 2.2rem 1.5rem; position: relative; }
@media (max-width: 640px) { .foglio { padding: 8px; } .squadratura { padding: 0 .9rem 1rem; outline-offset: 3px; } }

/* the cartiglio */
.crumbs { display: flex; justify-content: space-between; gap: 1rem; flex-wrap: wrap; font: .95rem var(--letter);
  padding: .7rem 0 .2rem; }
.crumbs a { color: var(--blue); }
.cartiglio { display: grid; grid-template-columns: 1.4fr 1fr auto auto; gap: 1px; background: var(--frame);
  border: 1.5px solid var(--frame); margin: .6rem 0 1.6rem;
  grid-template-areas: "nome nome tavola scala" "titolo titolo titolo data"; }
.cartiglio > div { background: var(--sheet); padding: .25rem .65rem .35rem; min-width: 0; }
.cartiglio .k { display: block; font: 600 .62rem/1.2 var(--mono); letter-spacing: .12em; text-transform: uppercase; color: var(--muted); }
.cartiglio .v { display: block; font: 1.25rem/1.25 var(--letter); color: var(--ink); }
.cartiglio .nome { grid-area: nome; } .cartiglio .tavola { grid-area: tavola; } .cartiglio .scala { grid-area: scala; }
.cartiglio .titolo { grid-area: titolo; } .cartiglio .data { grid-area: data; }
.cartiglio .nome .v { font-size: 2.2rem; color: var(--blue); }
@media (max-width: 520px) { .cartiglio { grid-template-columns: 1fr 1fr;
  grid-template-areas: "nome nome" "tavola scala" "titolo titolo" "data data"; } }
.lede { font-size: 1.12rem; color: var(--graphite); margin: 0 0 1.2rem; max-width: 44rem; }
.kicker { font: 600 .7rem/1 var(--mono); letter-spacing: .16em; text-transform: uppercase; color: var(--red); margin: 0; }

/* lettering */
h1, h2, h3, h4 { font-family: var(--letter); font-weight: 400; color: var(--ink); line-height: 1.2; letter-spacing: .01em; }
h1 { font-size: 2.3rem; margin: 1.2rem 0 .4rem; }
h2 { font-size: 1.75rem; margin: 2.6rem 0 .8rem; padding-bottom: .15rem; border-bottom: 1.5px solid var(--ink);
  scroll-margin-top: 1rem; }
/* one marker, everywhere: a red ink dot before every section heading and every entry of the indice.
   The triangle is kept for warnings (.nota.avviso). */
h2::before, .indice > ul > li::before { content: ""; display: inline-block; width: .42em; height: .42em;
  border-radius: 50%; background: var(--red); margin-right: .5em; vertical-align: .14em; }
h3 { font-size: 1.32rem; margin: 1.8rem 0 .5rem; color: var(--blue); scroll-margin-top: 1rem; }
a { color: var(--blue); text-decoration-thickness: 1px; text-underline-offset: 2px; }
strong { font-weight: 600; }
p, li { max-width: 44rem; }
blockquote { margin: 1.2rem 0; padding: .5rem 1rem; border-left: 3px solid var(--red); color: var(--graphite); font-style: italic; }
blockquote p { margin: .3rem 0; }
hr { border: 0; border-top: 1px dashed var(--rule); margin: 2rem 0; }
img { max-width: 100%; }

/* code on tracing paper, outputs typed */
pre { margin: 1rem 0; }
body pre > code, pre.nb-output { display: block; overflow-x: auto; font: 12.75px/1.55 var(--mono); padding: .75rem 1rem; }
body pre > code { background: var(--lucido); border: 1px solid #B9C7D6; border-radius: 2px;
  box-shadow: 1px 2px 0 rgba(36, 87, 166, .07); }
pre.nb-output { background: transparent; border: 1px dashed var(--rule); white-space: pre; color: var(--graphite); }
pre.nb-output::before { content: "output"; display: block; font: .85rem var(--letter); color: var(--red); margin-bottom: .1rem; }
:not(pre) > code { white-space: nowrap; font: .86em var(--mono); background: rgba(36, 87, 166, .07); padding: .05em .3em; border-radius: 3px; }
.hljs-keyword { color: #7A2E8E; font-weight: 600; } .hljs-string { color: #2F6B3F; } .hljs-number { color: #A0521B; }
.hljs-comment { color: #7A8394; font-style: italic; } .hljs-type { color: #2457A6; } .hljs-built_in { color: #9B3020; }
.hljs-literal { color: #A0521B; } .hljs-meta { color: #5B4E98; }

/* diagrams pinned on graph paper, with registration marks */
figure.mari { margin: 1.4rem 0 1.8rem; padding: 18px 14px 12px; text-align: center;
  background-color: #FFFDF7;
  background-image: linear-gradient(var(--cm) 1px, transparent 1px), linear-gradient(90deg, var(--cm) 1px, transparent 1px),
    linear-gradient(var(--mm) 1px, transparent 1px), linear-gradient(90deg, var(--mm) 1px, transparent 1px);
  background-size: 40px 40px, 40px 40px, 8px 8px, 8px 8px;
  border: 1px solid #E2CDB8; }
figure.mari svg { max-width: 100%; height: auto; }
figure.mari figcaption { font: .9rem/1.4 var(--text); color: var(--graphite); margin-top: .5rem; text-align: left; }
figure.mari figcaption b { font: 1rem var(--letter); color: var(--red); font-weight: 400; }
details.mari-text { margin: -1.2rem 0 1.6rem; }
details.mari-text summary { cursor: pointer; font: .95rem var(--letter); color: var(--muted); }
/* side by side: the blocks of nbBeside, one column on a phone */
.beside { display: grid; grid-template-columns: repeat(auto-fit, minmax(min(100%, 20rem), 1fr)); gap: .2rem 1.2rem;
  align-items: start; margin: 1rem 0 1.4rem; }
.beside > * { min-width: 0; }
.beside figure.mari { margin: 1rem 0 .6rem; }
.beside pre { margin: 1rem 0 .4rem; }
.gallery { display: grid; grid-template-columns: repeat(auto-fill, minmax(min(100%, 22rem), 1fr)); gap: 0 1.2rem; }

main table { display: block; overflow-x: auto; max-width: max-content; border-collapse: collapse; margin: 1rem 0; background: var(--sheet); font-size: .93rem; }
main table th, main table td { border: 1px solid var(--rule); padding: .3rem .55rem; text-align: left; vertical-align: top; }
main table td:last-child { min-width: 9rem; }
main table th { font: 600 .72rem var(--mono); letter-spacing: .08em; text-transform: uppercase; color: var(--muted); }
.scroll { overflow-x: auto; }

/* the indice delle tavole */
.indice { border: 1.5px solid var(--frame); padding: .8rem 1.2rem 1rem; margin: 1.4rem 0 2rem; max-width: 36rem; background: var(--sheet); }
.indice h2.indice-title { font-size: 1.3rem; border: 0; margin: 0 0 .4rem; padding: 0; }
.indice h2.indice-title::before { display: none; }
.indice > ul > li { padding-left: .92em; text-indent: -.92em; }
.indice > ul > li > ul { text-indent: 0; }
.indice ul { margin: 0; padding: 0; list-style: none; font: 1.02rem/1.6 var(--letter); }
.indice ul ul { font-size: .95rem; padding-left: .6em; }
.indice a { text-decoration: none; color: var(--ink); }
.indice a:hover { color: var(--blue); text-decoration: underline; }

/* notes, stamps, cards */
.nota { border: 1px solid var(--rule); border-left: 4px solid var(--blue); background: #FFFEFA; padding: .7rem 1rem; margin: 1.3rem 0; }
.nota.avviso { border-left-color: var(--red); }
.nota.avviso .titolo::before { content: "▲ "; color: var(--red); }
.nota > :first-child { margin-top: 0; } .nota > :last-child { margin-bottom: 0; }
.nota .titolo { font: 1.12rem var(--letter); color: var(--ink); display: block; }
.timbro.ok { color: #3F7D4E; border-color: #3F7D4E; }
.timbro { display: inline-block; font: .95rem var(--letter); color: var(--red); border: 1.5px solid var(--red);
  border-radius: 3px; padding: 0 .45rem; }
.cards { display: grid; grid-template-columns: repeat(auto-fill, minmax(min(100%, 14rem), 1fr)); gap: 1rem; margin: 1.2rem 0; }
.cards .nota { margin: 0; }
footer { font: .95rem var(--letter); color: var(--muted); padding: 1.5rem 0 .5rem; text-align: center; border-top: 1px solid var(--rule); margin-top: 2rem; }
footer a { color: var(--blue); }
details.source { margin-top: 1rem; text-align: left; }
details.source summary { cursor: pointer; }
details.source pre { max-height: 32rem; overflow: auto; }
"""

# ----------------------------------------------------------------------------- headings and TOC

func slugify*(s: string): string =
  ## The anchor of a heading: lowercase words joined by `-`.
  var last = '-'
  for c in s.toLowerAscii:
    if c in {'a'..'z', '0'..'9'}:
      result.add c
      last = c
    elif last != '-':
      result.add '-'
      last = '-'
  result = result.strip(chars = {'-'})

func stripInline(s: string): string =
  ## Heading text without Markdown marks or tags, for anchors and the indice.
  var inTag = false
  for c in s:
    if c == '<': inTag = true
    elif c == '>': inTag = false
    elif not inTag and c notin {'*', '`', '_'}: result.add c

func headingsOf*(markdownText: string): seq[(int, string)] =
  ## The `##` and `###` headings of a Markdown text, with their level (outside code fences).
  var fence = false
  for line in markdownText.splitLines:
    if line.strip.startsWith("```"): fence = not fence
    if fence: continue
    if line.startsWith("## "): result.add (2, line[3 .. ^1].strip.stripInline)
    elif line.startsWith("### "): result.add (3, line[4 .. ^1].strip.stripInline)

func addHeadingIds(html: string): string =
  ## `<h2>Text</h2>` becomes `<h2 id="text">Text</h2>`, matching `slugify` of the indice.
  result = html
  for tag in ["h2", "h3"]:
    var res = ""
    var i = 0
    let open = "<" & tag & ">"
    let close = "</" & tag & ">"
    while true:
      let a = result.find(open, i)
      if a < 0: break
      let b = result.find(close, a)
      if b < 0: break
      let inner = result[a + open.len ..< b]
      res.add result[i ..< a] & "<" & tag & " id=\"" & slugify(stripInline(inner).replace("&amp;", "&")) & "\">" & inner & close
      i = b + close.len
    res.add result[i .. ^1]
    result = res

func unescapeHtml(s: string): string =
  s.multiReplace(("&lt;", "<"), ("&gt;", ">"), ("&quot;", "\""), ("&#39;", "'"), ("&amp;", "&"))

func highlightNimFences(html: string): string =
  ## ```nim fences in Markdown, highlighted like the code that ran.
  const openTag = """<pre><code class="language-nim">"""
  const close = "</code></pre>"
  var i = 0
  while true:
    let a = html.find(openTag, i)
    if a < 0: break
    let b = html.find(close, a + openTag.len)
    if b < 0: break
    result.add html[i ..< a]
    result.add """<pre><code class="nohighlight nim">""" &
      highlightNim(unescapeHtml(html[a + openTag.len ..< b]).strip(leading = false, chars = {'\n'})) & close
    i = b + close.len
  result.add html[i .. ^1]

newNbBlock(NbIndice):
  title: string
  toHtml:
    var items = ""
    var openSub = false
    for b in nb.doc.blocksFlattened:
      if not (b of NbText): continue
      for (level, text) in headingsOf(b.NbText.text):
        let link = &"""<a href="#{slugify(text)}">{text}</a>"""
        if level == 2:
          if openSub: (items.add "</ul>"; openSub = false)
          if items.len > 0: items.add "</li>"
          items.add "<li>" & link
        else:
          if not openSub: (items.add "<ul>"; openSub = true)
          items.add "<li>" & link & "</li>"
    if openSub: items.add "</ul>"
    if items.len > 0: items.add "</li>"
    &"""<nav class="indice" aria-label="{blk.title}"><h2 class="indice-title">{blk.title}</h2><ul>{items}</ul></nav>"""

proc indice*(nb: var Nb, title = "Indice") =
  nb.add newNbIndice(title = title)

template nbIndice*(ttitle = "Indice") =
  ## The table of contents of the page's `##` and `###` headings, built when the page is saved.
  nb.indice(ttitle)

template nbBeside*(body: untyped) =
  ## The blocks made in `body` side by side, one column on a phone. Wrap a block group that
  ## must stay together (code and its drawing) in `nbCell`.
  nbRawHtml: "<div class=\"beside\">"
  body
  nbRawHtml: "</div>"

template nbCell*(body: untyped) =
  ## The blocks made in `body` as one cell of `nbBeside`.
  nbRawHtml: "<div>"
  body
  nbRawHtml: "</div>"

template nbNota*(text: string, color = "") =
  ## A note in the margin; `color` is "" or "avviso" (a warning, marked with the triangle).
  nbRawHtml: "<div class=\"nota " & color & "\">" & markdownToHtml(text) & "</div>"

# ----------------------------------------------------------------------------------------- theme

func tavolaText(blk: JsonNode, nb: Nb): string =
  highlightNimFences(addHeadingIds(markdownToHtml(blk{"text"}.getStr)))

func tavolaHeader(blk: JsonNode, nb: Nb): string =
  let c = nb.doc.context
  let home = c{"home_href"}.getStr
  let back = if home.len > 0: &"""<a href="{home}">← diagrammari</a>""" else: "<span></span>"
  let (nome, tavola, scala, titolo, data) = (c{"nome"}.getStr, c{"tavola"}.getStr,
    c{"scala"}.getStr, c{"titolo"}.getStr, c{"data"}.getStr)
  &"""<div class="foglio"><div class="squadratura"><header>
<nav class="crumbs">{back}<a href="{repoUrl}">diagrammari on GitHub ↗</a></nav>
<div class="cartiglio">
<div class="nome"><span class="k">Nome</span><span class="v">{nome}</span></div>
<div class="tavola"><span class="k">Tavola</span><span class="v">{tavola}</span></div>
<div class="scala"><span class="k">Scala</span><span class="v">{scala}</span></div>
<div class="titolo"><span class="k">Titolo</span><span class="v">{titolo}</span></div>
<div class="data"><span class="k">Data</span><span class="v">{data}</span></div>
</div>
</header>"""

func tavolaFooter(blk: JsonNode, nb: Nb): string =
  let source = nb.doc.context{"source_highlighted"}.getStr
  "<footer>Written in Nim with <a href=\"https://github.com/pietroppeter/nimib\">nimib</a> 🐳 · diagrams by " &
    &"""<a href="https://pele.run">Pele</a> through <a href="{repoUrl}">diagrammari</a>, drawn when the page was built""" &
    (if source.len == 0: "" else:
      """<details class="source"><summary>show the source of this page</summary><pre><code class="nohighlight nim">""" &
      source & "</code></pre></details>") & "</footer></div></div>"

func emptyPartial(blk: JsonNode, nb: Nb): string = ""

proc useTavola*(nb: var Nb, nome = "diagrammari", titolo = "", tavola = "", scala = "1:1",
                data = "November 2026", title = "", description = "", homeHref = "") =
  ## The tavola look, and diagrams drawn at build time in its colours. The cartiglio has
  ## `nome`, `titolo`, `tavola` (the sheet number), `scala` and `data`; `homeHref` links back.
  let desc = if description.len > 0: "<meta name=\"description\" content=\"" &
               description.replace("\"", "&quot;") & "\">\n" else: ""
  nb.doc.context["title"] = %(if title.len > 0: title else: nome & " · " & titolo)
  nb.doc.context["stylesheet"] = %(desc &
    """<link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2280%22>📐</text></svg>">""" &
    "\n<style>\n" & fonts & tavolaCss & tavolaTheme.css(".mari") & "\n</style>")
  nb.doc.context["highlight"] = %""
  nb.doc.context["nb_style"] = %""
  nb.doc.context["disableHighlightJs"] = %true
  for (k, v) in [("nome", nome), ("titolo", titolo), ("tavola", tavola), ("scala", scala),
                 ("data", data), ("home_href", homeHref)]:
    nb.doc.context[k] = %v
  nb.backend.partials["header"] = tavolaHeader
  nb.backend.partials["footer"] = tavolaFooter
  nb.backend.partials["nbText"] = tavolaText
  nb.backend.partials["left"] = emptyPartial
  nb.backend.partials["right"] = emptyPartial
  nb.useDiagrams(mode = rmStatic, narrow = 420, fontFamily = "Arimo, Arial, sans-serif")
