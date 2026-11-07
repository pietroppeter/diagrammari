## Pie charts: a title and slices, each a label and a value.
##
## ```nim
## let p = pie("Pets adopted", showData = true)
##   .slice("Dogs", 386)
##   .slice("Cats", 85)
## echo p
## ```

import core

type
  Pie* = object
    title*: string
    showData*: bool
    slices*: seq[(string, float)]

func initPie*(title = "", showData = false): Pie =
  ## An empty pie chart; `showData` writes each value next to its label.
  Pie(title: title, showData: showData)

func initPie*(title: string, slices: openArray[(string, float)], showData = false): Pie =
  ## A pie chart with its slices, in order.
  Pie(title: title, showData: showData, slices: @slices)

proc slice*(p: sink Pie, label: string, value: float): Pie =
  ## A slice. Values must be positive; Mermaid draws slices in the order given.
  if value <= 0: raise newException(ValueError, "a pie slice needs a positive value: " & label)
  result = p
  result.slices.add (label, value)

func toDiagram*(p: Pie): Diagram =
  var s = "pie"
  if p.showData: s.add " showData"
  if p.title.len > 0: s.add "\n  title " & plainText(p.title)
  for (label, value) in p.slices: s.add "\n  " & quoted(label) & " : " & number(value)
  Diagram(kind: dkPie, source: s)

func `$`*(p: Pie): string = p.toDiagram.source
