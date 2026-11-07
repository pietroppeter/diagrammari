## devlog: 07 Nov 2026 | Diagrams, a series in five parts | How diagrammari came about: five pieces on the history of diagrams, the everyday ones, making them yours, the name, and the house style, each in the style of its own figure.
## The first post of the devlog and the index of the Diagrams series (docs/series/). The parts are
## cross-linked through the series bar (docs/series/serie.nim); add a part there and here.
import std/[os, json, strformat]
import nimib except md
import ../series/serie

let docs = currentSourcePath().parentDir.parentDir
nbInit
nb.doc.filename = docs / "devlog" / "diagrams-series" / "index.html"
nb.useSerie(part = "", title = "Diagrams, a series in five parts · diagrammari devlog",
  description = "How diagrammari came about: a series in five parts, each in the style of a figure from the history of diagrams.",
  css = "house.css", base = "../../series/",
  fonts = "<style>" & fontFace("Jost", "jost-latin-400-normal.woff2") &
    fontFace("Jost", "jost-latin-500-normal.woff2", 500) &
    fontFace("Jost", "jost-latin-700-normal.woff2", 700) &
    fontFace("Crimson Pro", "crimson-pro-latin-400-normal.woff2") &
    fontFace("Crimson Pro", "crimson-pro-latin-400-italic.woff2", 400, "italic") &
    fontFace("Klee One", "klee-one-latin-600-normal.woff2", 600) & "</style>")
nb.doc.context["stylesheet"] = %(nb.doc.context["stylesheet"].getStr & """
<style>
.parts-list{display:grid;gap:14px;margin:20px 0 26px}
.card{display:grid;grid-template-columns:64px 1fr;gap:4px 16px;padding:16px 18px;border:2px solid var(--c);background:var(--bg);color:var(--fg)}
.card > :not(.num){grid-column:2}
.card .num{grid-row:1 / span 4;grid-column:1;font:500 44px/1 Jost,sans-serif;color:var(--c)}
.card h3{margin:0;font:var(--f);color:var(--fg)}
.card h3 a{color:inherit;text-decoration:none}
.card .who{font-size:13.5px;letter-spacing:.06em;text-transform:uppercase;color:var(--c)}
.card p{margin:2px 0 4px;font-size:15.5px}
.card .links{font-size:14px}
.card .links a{color:var(--fg)}
.p1{--c:#a4161a;--bg:#fffff8;--fg:#111;--f:italic 400 25px/1.2 'Crimson Pro',Georgia,serif}
.p2{--c:#2d5d8c;--bg:#f1ead9;--fg:#1c1b19;--f:500 22px/1.2 Jost,sans-serif}
.p3{--c:#d2361f;--bg:#fbfaf6;--fg:#161616;--f:700 21px/1.2 Jost,sans-serif}
.p3 h3{text-transform:uppercase;letter-spacing:.02em}
.p4{--c:#3b86c4;--bg:#fbf6ea;--fg:#28405a;--f:600 25px/1.2 'Klee One',cursive;border-radius:18px}
.p5{--c:#161616;--bg:#f7f3ea;--fg:#161616;--f:500 22px/1.2 Jost,sans-serif;border-style:dashed}
.principles{counter-reset:pr;list-style:none;padding:0}
.principles li{counter-increment:pr;position:relative;padding-left:44px;margin:0 0 12px}
.principles li::before{content:counter(pr);position:absolute;left:0;top:0;width:28px;height:28px;border:2px solid var(--ink);
  border-radius:50%;display:grid;place-items:center;font:500 14px/1 Jost,sans-serif}
</style>""")

type Part = tuple[n, slug, title, figure, what: string, handmade: bool]
let series: seq[Part] = @[
  ("1", "diagram-history", "Boxes, Lines and Arrows", "Edward Tufte",
   "A short history of diagrams, from clay tablets to Mermaid and Pele, and where the names of the tools come from.", true),
  ("2", "everyday-diagrams", "Diagrams Nobody Has to Think About", "Otto Neurath",
   "The crafted diagram against the standard one: what Mermaid and Pele do differently from draw.io or D3, and who the Tufte of everyday diagrams is.", true),
  ("3", "personal-diagrams", "Ready-made, Then Made Yours", "Enzo Mari",
   "Standard diagrams with a personal layer on top: move the boxes, shape the arrows, swap the style. A working proof of concept over Pele.", true),
  ("4", "a-name-from-the-sea", "A Name from the Sea", "a seaside picture book",
   "Pietro reading the first three parts, how the name diagrammari was found, and how the library was set up.", false),
  ("5", "a-house-style", "A House Style", "all of them, mixed",
   "The first round of looking for the style of everything else: Neurath, Enzo Mari, a hint of Tufte and a little sea.", false)]

var cards = ""
for p in series:
  let links = if p.handmade:
      &"""<a href="../../series/{p.slug}/">hand-made page</a> · <a href="../../series/{p.slug}/nimib.html">nimib version</a>"""
    else: &"""<a href="../../series/{p.slug}/">read it</a> · a nimib notebook"""
  cards.add &"""<div class="card p{p.n}"><span class="num">{p.n}</span><span class="who">in the style of {p.figure}</span>
<h3><a href="../../series/{p.slug}/">{p.title}</a></h3><p>{p.what}</p><span class="links">{links}</span></div>"""

nbRawHtml: &"""<article>
<p class="kicker">Devlog · 7 November 2026 · the first post</p>
<h1>Diagrams, a series in five parts<b>.</b></h1>
<p class="lede">How diagrammari came about: five pieces written before and during its first day,
each in the style of a figure from the history of diagrams.</p>"""

nbText: """
diagrammari began with a renderer and a missing name. In October 2026 Obsidian released
[Pele](https://github.com/obsidianmd/pele), by Steph Ango: it draws Mermaid diagrams as SVG, fast
and clean, and its output names every box and arrow. Pietro wanted it as the diagram engine of
[nimib](https://github.com/pietroppeter/nimib), and the library needed a name.

Looking for the name turned into a short course in diagrams. Each step became a page, and each
page took the look of the person it was about. This post is the index of that series. It is
also the first post of the devlog, because the series is how the library came about. The day the
code was written has [its own post](../day-one/).
"""

nbRawHtml: "<div class=\"parts-list\">" & cards & "</div>"

nbText: """
Parts 1 to 3 were made as hand-made HTML pages and are kept as they were. Each one also has a
*nimib version*, the same page rebuilt as a Nim notebook with [tabelline](https://github.com/pietroppeter/tabelline)
tables, to see what that gives. Parts 4 and 5 are notebooks from the start. A bar at the top of
every part links them all together and back here.

## What the series taught the library

These are first ideas, taken from the parts. Pietro's reading in part 4 may change them.
"""

nbRawHtml: """<ol class="principles">
<li><b>A diagram is a picture of something you cannot see</b>: a relation, a process, an argument (part 1). The library draws structure, not decoration.</li>
<li><b>A transformer in between.</b> Neurath's workshop turned data into charts by fixed rules, so nobody had to design each one (part 2). Mermaid text and Pele's layout play that role, and diagrammari keeps them.</li>
<li><b>Standard first, then yours.</b> The Mermaid text stays the source; a personal layer on top, keyed by the diagram's own ids, moves, styles and reshapes it, and survives a change of theme (part 3).</li>
<li><b>Nothing remote.</b> Pele, D3 and the fonts are copies in the repository, so a page works offline and does not change on its own.</li>
<li><b>Every page is a notebook</b>, so the docs are programs that use the library they describe (parts 4 and 5).</li>
</ol>"""

nbRawHtml: """<p class="ending">The series is in <code>docs/series/</code> of
<a href="https://github.com/pietroppeter/diagrammari">diagrammari</a>. Parts 4 and 5 are still being
written.</p></article>"""

nbSave
