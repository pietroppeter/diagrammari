## Part 4 of the Diagrams series, "A Name from the Sea": Pietro reading parts 1-3, how the name
## diagrammari was found, and how the library was set up. A nimib notebook from the start, in a
## seaside picture-book style with small hand-drawn pictures in the margin.
## Writes docs/series/a-name-from-the-sea/index.html.
import std/[os, json]
import nimib except md
import tabelline, tabelline/nimib
import mari, mari/nimib
import serie, doodles

let root = currentSourcePath().parentDir
nbInit
nb.doc.filename = root / "a-name-from-the-sea" / "index.html"
nb.useSerie(part = "4", title = "A Name from the Sea · Diagrams, part 4",
  description = "Part four of the Diagrams series: reading the first three parts, finding the name diagrammari, and setting up the library.",
  css = "sea.css",
  fonts = "<style>" & fontFace("Zen Maru Gothic", "zen-maru-gothic-latin-400-normal.woff2") &
    fontFace("Zen Maru Gothic", "zen-maru-gothic-latin-700-normal.woff2", 700) &
    fontFace("Klee One", "klee-one-latin-400-normal.woff2") &
    fontFace("Klee One", "klee-one-latin-600-normal.woff2", 600) & "</style>")

const seaTheme = Theme(bg: "transparent", fg: "#28405a", muted: "#5a7690", line: "#28405a",
  surface: "#fffdf6", surfaceAlt: "#eef8fa", border: "#28405a", accent: "#e0533d",
  font: "'Zen Maru Gothic', sans-serif", radius: "14px")
nb.doc.context["stylesheet"] = %(nb.doc.context["stylesheet"].getStr &
  "\n<style>" & seaTheme.css(".mari") & "</style>")
nb.useDiagrams(mode = rmStatic, fontFamily = "Zen Maru Gothic")

template say(who, cls, text: string): string =
  "<div class=\"bubble " & cls & "\"><b>" & who & "</b>" & text & "</div>"

nbRawHtml: doodleDefs & "<article>" & "<div class=\"hero\">" & seaBand() & "</div>" & """
<h1>A Name from the Sea<span class="dot">.</span></h1>
<p class="lede">Part four, written as it happens: Pietro reading the first three parts, the
morning we found a name, and the first day of the library that carries it.</p>"""

nbText: """
The first three parts of this series were made for one question that nobody had asked out loud
yet: *what should a Nim diagram library built on Pele be called?* To answer it we went
looking for where diagrams come from ([part 1](../diagram-history/)), for the people who made the
everyday ones ([part 2](../everyday-diagrams/)), and for a way to make a ready-made diagram your
own ([part 3](../personal-diagrams/)). This part tells what came back from that trip.

It is also the first part written as a nimib notebook from the start. Parts 1 to 3 were
hand-made pages first and got nimib versions afterwards; this one is a Nim program, its tables
are made by [tabelline](https://github.com/pietroppeter/tabelline) and its one diagram is drawn
by the library it is about.
"""

nbRawHtml: side(fish(), "a question, still swimming") & """<h2><span class="n">1</span>Reading parts one to three</h2>"""

nbText: """
Pietro reads these pages on his phone. What he said while the parts were being
made is below, in short; what he takes from each of them, now that they are done, is his to
write, in the dashed notes.
"""

nbRawHtml: """<h3><a href="../diagram-history/">Part 1 · Boxes, Lines and Arrows</a></h3>
<div class="bubbles">""" &
  say("Pietro", "p", "Where does the name Mermaid come from? And Pelé, I guess from the footballer? I like Tufte, I don't know if he fits the history of diagrams. I think he kind of does.") &
  say("Claude", "c", "Mermaid came from a cartoon on the television at home: Knut Sveidqvist's children were watching <i>The Little Mermaid</i>. Pele is probably not the footballer but the Hawaiian goddess of volcanoes, with no accent and a volcano in the tagline. And Tufte fits: the page is in his style, sidenotes and small multiples.") &
  """</div>
<div class="note todo"><span class="who">Pietro's notes on part 1</span><br>To be written: what you took from it.</div>
<h3><a href="../everyday-diagrams/">Part 2 · Diagrams Nobody Has to Think About</a></h3>
<div class="bubbles">""" &
  say("Pietro", "p", "There's a big gap between Tufte, who makes meticulously thought diagrams, and Mermaid and Pele, the industrial ones everybody uses. Is there a Tufte of those?") &
  say("Claude", "c", "Otto Neurath. In 1920s Vienna his workshop turned statistics into charts by fixed rules, and a <i>transformer</i> stood between the data and the drawing. Mermaid automates that transformer.") &
  say("Pietro", "p", "Beautiful, really beautiful. Can you add what these would output? Use Pele and D3 directly, committed in the repo, no CDN. And \"set that last rule beside Mermaid\", I'm not sure I understand the English.") &
  say("Claude", "c", "Both now run live under their code, from copies in <code>vendor/</code>. The sentence meant <i>compare that last rule with Mermaid</i>, so the page now says that.") &
  """</div>
<div class="note todo"><span class="who">Pietro's notes on part 2</span><br>To be written.</div>""" &
  side(bucket(), "the personal layer, carried home") & """
<h3><a href="../personal-diagrams/">Part 3 · Ready-made, Then Made Yours</a></h3>
<div class="bubbles">""" &
  say("Pietro", "p", "What if we mix the two approaches: the standard diagrams of Mermaid and Pele, plus a layer of our own on top, to move things, style them, and shape the arrows?") &
  say("Claude", "c", "Here is a proof of concept in Enzo Mari's <i>Autoprogettazione</i> style: plain Mermaid drawn by Pele, then a JSON layer keyed by the diagram's ids.") &
  say("Pietro", "p", "Part 3 is beautiful. I can move the boxes, but the arrows don't change much. Let's find a different example.") &
  say("Claude", "c", "The nimib family, drawn top to bottom with eleven links: moving the boxes now re-routes every arrow.") &
  """</div>
<div class="note todo"><span class="who">Pietro's notes on part 3</span><br>To be written.</div>
<div class="clear"></div>"""

nbRawHtml: side(boat(), "maru, 丸: a circle, and the end of a ship's name") & """<h2><span class="n">2</span>Picking a name</h2>"""

nbText: """
Mermaid was named after a film playing in the living room. A name like that has to come from
somewhere personal, so the first answer was not a name but six places to look: myths that join a
mermaid and a volcano (Partenope under Vesuvius, Colapesce under Etna), Italian school words next
to *tabelline*, Italian volcanoes, football on purpose, people from the history in part 1, and
"something of your own".

The something of his own came out of part 3. Enzo Mari had just become the figure of the page,
and Pietro said: *the name will be Enzo. It contains the N.* From there it took three ports to
reach the name.
"""

nbRawHtml: """<ol class="ports">
<li><b>Enzo</b><br>The designer of <i>Autoprogettazione</i>, an Italian name that is more popular abroad than at home, with the N of Nim. But a small .NET diagram tool is already called Enzo.</li>
<li><b>Mari</b><br>His surname, and Iela Mari's, who made picture books without words. In Italian it means <i>seas</i>; in Basque myth Mari is a goddess of fire and storms, a sister for Pele. But Foundry's MARI is a well-known painting program, and there is no N.</li>
<li><b>diagrammari</b><br><i>Diagrammare</i> is the Italian verb for drawing a diagram, and <i>-ari</i> is how a Sicilian says it: "to diagram", with the accent of Colapesce's island. It ends in the seas, and it is free everywhere.</li>
</ol>"""

nbText: """
Pietro's own story for the last one was a film too, the way Mermaid's was: the word made him
think of Ponyo, Miyazaki's fish girl, of her mother Gran Mamare (*mamma* and *mare*), and of
boats whose names end in *maru*. *Maru*, 丸, is a circle, and a circle is where a diagram starts.
Then the last decision: the repository is called diagrammari, but in Nim you write `import mari`.

Here is the same story as data. Each row is one candidate, with what it brought and what was in the
way:
"""

nbCode:
  let names = tableData:
    name: ["Enzo", "Mari", "diagrammari", "mari"]
    story: ["Enzo Mari, *Autoprogettazione*; has the N of Nim",
            "the seas; a Basque fire goddess; Enzo and Iela Mari",
            "*diagrammare* with a Sicilian ending; ends in the seas",
            "the import, inside the name"]
    inTheWay: ["a .NET diagram tool called Enzo", "Foundry's MARI, 3D painting software",
               "may read as a typo of *diagrammare*", "searches for “mari” are crowded"]
    nimble: [true, true, true, true]
    kept: [false, false, true, true]
  let candidates = tabella(names, rownameCol = "name"):
    tabHeader "Four names", "the free ones on nimble, and the two we kept"
    fmtMarkdown ["story", "inTheWay"]
    fmtTf ["nimble", "kept"], trueText = "●", falseText = "○"
    colsLabel {"story": "what it brings", "inTheWay": "what is in the way",
               "nimble": "free on nimble", "kept": "kept"}
    tabOptions(tableFontNames = "'Zen Maru Gothic', sans-serif", tableFontColor = "#28405a",
               tableBackgroundColor = "transparent", tableBorderTopColor = "#3b86c4",
               tableBorderBottomColor = "#3b86c4", columnLabelsBorderBottomColor = "#3b86c4",
               tableBodyHlinesColor = "#8fd0dc", headingAlign = "left", tableWidth = "100%")
nbTable candidates

nbRawHtml: """<figure class="chain">""" & nameChain() & """</figure>"""

nbText: """
And so the family is complete: a fairy tale, a volcano goddess, the seas. The practical part:
nimble names a package after its `.nimble` file, so the repository
[diagrammari](https://github.com/pietroppeter/diagrammari) holds `mari.nimble` and `src/mari.nim`.
`nimble install mari`, `import mari`.
"""

nbRawHtml: side(lighthouse(), "a light to steer by: the specs") & """<h2><span class="n">3</span>Setting up the library</h2>"""

nbText: """
The library is set up like tabelline, Pietro's table library from the week before, because that
setup worked:

- **Behaviour lives in the specs.** Every agreed behaviour is an [OpenSpec](https://github.com/Fission-AI/OpenSpec)
  requirement with scenarios and an example that runs; new work starts as a change proposal.
- **Living documents and a devlog.** The explainer and the specs page are kept up to date; devlog
  posts are dated and stay as they were written. This series is a collection of its own, and its
  index is the first post of the devlog.
- **Pages are nimib notebooks**, built by CI and deployed to GitHub Pages; the dependencies are
  pinned with atlas, and one script, `tools/setup.sh`, gets a fresh sandbox ready.
- **Pele is wrapped, not rewritten.** Version 1.13.0 ships with the library; diagrams are drawn
  to SVG when the page is built (one Node process), or in the reader's browser.

The code of the first day is told in its own devlog post. Here is the one thing this part needs
from it, the story of the name, drawn by mari when this page was built:
"""

nbCode:
  let voyage = flowchart(LR):
    "Mermaid" --> "Pele"
    "Pele" --> "Enzo"
    "Enzo" --> "Mari"
    "Mari" --> "diagrammari"
nbDiagram voyage, caption = "Five names, left to right. Pele drew it; the colours are this page's."

nbRawHtml: side(jelly(), "") & """<h3>What the nimib versions gave</h3>"""

nbText: """
Pietro asked to see parts 1 to 3 remade as nimib notebooks, "and see what it gives". All three
are done: [part 1](../diagram-history/nimib.html), [part 2](../everyday-diagrams/nimib.html),
[part 3](../personal-diagrams/nimib.html). A first reading:

- **The data became data.** In the hand-made part 1 the timeline was forty-two list items and a
  rug plot drawn by JavaScript. In the notebook it is one Nim `seq`, and the rug plot, the four
  era tables and the count of events are computed from it. Adding an event is one line. In part
  2, the Isotype chart of who decides what is six rows of booleans, and the count is a column.
- **Diagrams moved to build time.** Part 2's Mermaid example is drawn by mari when the page is
  built and reaches the reader as SVG. Part 3's proof of concept stays in the browser, because it
  is interactive; its notebook adds the same diagram drawn at build time, the sheet the layer
  sits on.
- **Tables fit the margin notes less well.** Tufte's sidenotes became a *read more* column. It is
  easier to scan, and less like a book.
- **Two ways to keep the words.** Part 1's notebook has its own text. Parts 2 and 3 cut their
  prose out of the hand-made pages when they are built, so the words live in one place and the
  notebook only replaces what is better as data.
- **The style survives.** Each page keeps its own CSS; nimib adds the series bar on top and, at
  the bottom, the source of the page.
"""

nbRawHtml: side(shell(), "") & """<h2><span class="n">4</span>What comes next</h2>"""

nbText: """
Part 5, [A House Style](../a-house-style/), looks for the style of everything else: the
explainer, the specs, the devlog. Each part of this series keeps its own figure, so the house
style can borrow from all of them: Neurath's pictures that count, Enzo Mari's honest joints, a
hint of Tufte, and something of this part's sea.
"""

nbRawHtml: """<p class="ending">〜 diagrammari, imported as mari 〜</p></article>"""

nbSave
