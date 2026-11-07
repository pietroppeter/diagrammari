## devlog: 07 Nov 2026 | Day one: from Mermaid to Pele to diagrammari | Reading Pele, deciding to wrap it rather than rewrite it, and a first diagrammari with four builders, two ways to draw, and its own look.
import std/os
import nimib
import mari, mari/nimib
import ../tavola

let here = currentSourcePath().parentDir
nbInit
nb.doc.filename = here / "day-one" / "index.html"
nb.useTavola(titolo = "Day one", tavola = "D1", scala = "devlog", data = "7 November 2026",
             homeHref = "../../", title = "mari devlog: day one")

nbRawHtml: """<p class="kicker">Devlog · 7 November 2026</p>
<h1>Day one: from Mermaid to Pele to diagrammari</h1>
<p class="lede">Pietro wanted to learn Mermaid diagrams and have them work well with nimib, and
asked to build on Pele instead of Mermaid. This is how the first day went.</p>"""

nbText: """
## The ask

Three things, in Pietro's words: a repository set up like [tabelline](https://github.com/pietroppeter/tabelline)
(specs with examples that run, a devlog, living documents, a themed nimib site), a wrapper of Pele
for Nim with a few diagram types first, and the history of diagram making, "the art of making
diagrams that Mermaid and Pele allow", with references, as tabelline's explainer had for tables.
The code was written under a placeholder name, and renamed at the end of the day, when Pietro
picked one: the repository is *diagrammari* and the module is `mari` (the series tells how the
name was found).

## Reading Pele

Pele is three weeks old and moves fast: version 1.13.0 came out on 31 October, the thirteenth
minor release since mid October. Its GitHub repository and its npm package could be read from
the sandbox; its website (pele.run) and jsDelivr could not, so everything here comes from the
package and the sources. The first test settled the design:
"""

nbCode:
  let s = diagram("flowchart LR\n  a[Mermaid text] --> b[SVG]").toSvg
  echo s.kind, ", ", s.width, " × ", s.height, " px, ", s.svg.len, " characters of SVG"

nbText: """
Pele's `render` is synchronous and needs no DOM, so it runs in Node, which every machine that
builds nimib pages for the web usually has. Loading the bundle takes about 30 ms; a diagram takes
well under a millisecond. So diagrams can be drawn *when the page is built*, and the page needs no
JavaScript. That is the mode nimib wanted for years (nimibook issue #88, the nimibex backlog),
and Mermaid could only offer it through a headless browser.

## Wrap, not rewrite

tabelline was written in plain Nim, because a table library is mostly formatting. A diagram
library is mostly layout, and Pele's layout is the hard part: the layered layout alone is 2,227
lines, the whole of it about 53,000. Rewriting that in Nim would be a project of its own. So
diagrammari wraps Pele:

- it ships Pele's browser bundle (MIT, pinned to 1.13.0) inside the package;
- at build time, one Node process loads it once and answers requests, one JSON line each way;
- in the browser, the page carries the bundle (or a pinned jsDelivr link) and mounts each diagram.
"""

let protocol = sequence:
  participant "nim", "diagrammari"
  participant "node", "Node + Pele"
  message "nim", "node", "{source, options}"
  message "node", "nim", "{svg, width, height} or {code, line, column}", reply
nbDiagram protocol

nbText: """
## What Nim adds

If Pele draws, what is left for Nim? Three things.

1. **A value for a diagram**, `Diagram`, with its kind, that every renderer takes, so a diagram
   can be passed around, printed, saved as SVG, Markdown or a page.
2. **Typed builders** that write correct Mermaid: `flowchart`, `sequence`, `pie`, `timeline`.
   Ids are checked, labels are quoted with Mermaid's entities, blocks are closed. In a block,
   each line is a verb, and `"a" --> "b"` is a link: Nim's operators happen to include Mermaid's
   arrows.
3. **nimib integration**: `nbDiagram`, static or client, and a ```` ```mermaid ```` block in
   Markdown so a README made by a notebook is drawn by GitHub.

The specs have a requirement for each, with examples that run and the diagrams they draw.

## The look: a tavola

tabelline's pages are a school exercise book. A diagram library asks for the other school
notebook: the *tavola* of technical drawing, an F4 sheet with a drawn frame and a title block
(*cartiglio*) in the corner. Diagrams sit on graph paper (*carta millimetrata*) with registration
marks; code is on tracing paper. The lettering is Architects Daughter, the text IBM Plex, and the
diagrams Arimo, which has Arial's widths: Pele in Node measures text with an Arial table, so with
Arimo the labels fit their boxes.

## What could not be done

- pele.run and jsDelivr are blocked from the sandbox, so the CDN option (`cdn = true`) is not
  tested here; the inlined bundle is.
- Builders exist for four types only; the other 29 work as text.
- The narrow drawing for phones is a second SVG chosen by a container query. Client mode does it
  better (Pele measures the real width), at the cost of JavaScript.

## Next

In the backlog: more builders (state, class, ER, Gantt, mind map, Sankey), a Nim text measurer
so any font works at build time, and moving the nimib block into nimibex once the API settles.
"""
nbSave
