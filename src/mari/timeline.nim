## Timelines: periods in order, each with one or more events, grouped in sections.
##
## ```nim
## let t = timeline("Diagrams")
##   .period("1786", "Playfair's line and bar charts")
##   .period("1801", "Playfair's pie chart")
## echo t
## ```

import core

type
  Timeline* = object
    title*: string
    lines: seq[string]

func initTimeline*(title = ""): Timeline =
  ## An empty timeline.
  Timeline(title: title)

proc section*(t: sink Timeline, name: string): Timeline =
  ## Starts a section: the periods after it share its colour, until the next section.
  result = t
  result.lines.add "  section " & plainText(name)

proc period*(t: sink Timeline, time: string, events: varargs[string]): Timeline =
  ## A period (a year, a date, any label) and its events, drawn under it in order.
  result = t
  var s = "    " & plainText(time)
  for e in events: s.add " : " & plainText(e)
  result.lines.add s

func toDiagram*(t: Timeline): Diagram =
  var s = "timeline"
  if t.title.len > 0: s.add "\n  title " & plainText(t.title)
  for l in t.lines: s.add "\n" & l
  Diagram(kind: dkTimeline, source: s)

func `$`*(t: Timeline): string = t.toDiagram.source
