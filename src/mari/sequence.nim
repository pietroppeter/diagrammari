## Sequence diagrams: participants, the messages between them in time order, notes, and
## blocks (`loop`, `alt` with `orElse`, `opt`, `par` with `also`, `critical`, `rect`).
##
## ```nim
## let s = sequence()
##   .participant("a", "Alice")
##   .actor("b", "Bob")
##   .message("a", "b", "Hello Bob")
##   .message("b", "a", "Hi Alice", reply)
## echo s
## ```

import std/strutils
import core

type
  Message* = enum
    ## How a message is drawn: the Mermaid arrow is the enum's string.
    call = "->>", reply = "-->>", solidLine = "->", dottedLine = "-->", lost = "-x",
    dottedLost = "--x", async = "-)", dottedAsync = "--)", both = "<<->>", dottedBoth = "<<-->>"

  NotePlace* = enum
    leftOf = "left of", rightOf = "right of", over = "over"

  Sequence* = object
    title*: string
    lines: seq[string]
    depth: int

func initSequence*(title = "", autonumber = false): Sequence =
  ## An empty sequence diagram; `autonumber` numbers the messages.
  result = Sequence(title: title)
  if autonumber: result.lines.add "  autonumber"

func indent(s: Sequence): string = "  ".repeat(s.depth + 1)

proc declare(s: sink Sequence, word, id, label: string): Sequence =
  checkId(id)
  result = s
  result.lines.add result.indent & word & " " & id &
    (if label.len > 0 and label != id: " as " & plainText(label) else: "")

proc participant*(s: sink Sequence, id: string, label = ""): Sequence =
  ## A participant drawn as a box, labelled `label` (the id when empty). Participants appear
  ## in the order they are declared, then in the order messages first name them.
  s.declare("participant", id, label)

proc actor*(s: sink Sequence, id: string, label = ""): Sequence =
  ## A participant drawn as a stick figure.
  s.declare("actor", id, label)

proc message*(s: sink Sequence, a, b, text: string, kind = call,
              activate = false, deactivate = false): Sequence =
  ## A message from `a` to `b`. `activate` starts an activation bar on `b`, `deactivate`
  ## ends the one on `a`.
  checkId(a)
  checkId(b)
  result = s
  let mark = if activate: "+" elif deactivate: "-" else: ""
  result.lines.add result.indent & a & $kind & mark & b & ": " & plainText(text)

proc note*(s: sink Sequence, text: string, place: NotePlace, a: string, b = ""): Sequence =
  ## A note to the left or right of a participant, or over one or two.
  checkId(a)
  result = s
  var who = a
  if b.len > 0:
    checkId(b)
    who.add "," & b
  result.lines.add result.indent & "note " & $place & " " & who & ": " & plainText(text)

proc open(s: sink Sequence, word, label: string): Sequence =
  result = s
  result.lines.add result.indent & word & (if label.len > 0: " " & plainText(label) else: "")
  inc result.depth

proc loop*(s: sink Sequence, label = ""): Sequence =
  ## Opens a loop: the messages until `endBlock` repeat. In the block macro,
  ## `loop "Every minute": body` opens and closes it around `body`.
  s.open("loop", label)

proc alt*(s: sink Sequence, label = ""): Sequence =
  ## Opens alternatives: the first branch, until `orElse` or `endBlock`.
  s.open("alt", label)

proc opt*(s: sink Sequence, label = ""): Sequence =
  ## Opens an optional part.
  s.open("opt", label)

proc par*(s: sink Sequence, label = ""): Sequence =
  ## Opens parallel parts: the first, until `also` or `endBlock`.
  s.open("par", label)

proc critical*(s: sink Sequence, label = ""): Sequence =
  ## Opens a critical region; `option` adds the cases around it.
  s.open("critical", label)

proc rect*(s: sink Sequence, color: string): Sequence =
  ## Opens a background rectangle in `color` (`rgb(200, 220, 255)`), to highlight messages.
  s.open("rect", color)

proc reopen(s: sink Sequence, word, label: string, after: openArray[string]): Sequence =
  ## The next branch of the block just closed: removes its `end` and adds `word label`.
  result = s
  let closing = result.indent & "end"
  if result.lines.len == 0 or result.lines[^1] != closing:
    raise newException(ValueError, word & " must follow a closed " & after.join(" or ") & " block")
  result.lines[^1] = result.indent & word & (if label.len > 0: " " & plainText(label) else: "")
  inc result.depth

proc orElse*(s: sink Sequence, label = ""): Sequence =
  ## The next branch of the `alt` just closed (Mermaid's `else`).
  s.reopen("else", label, ["alt"])

proc also*(s: sink Sequence, label = ""): Sequence =
  ## The next parallel part of the `par` just closed (Mermaid's `and`).
  s.reopen("and", label, ["par"])

proc option*(s: sink Sequence, label = ""): Sequence =
  ## The next case of the `critical` just closed.
  s.reopen("option", label, ["critical"])

proc endBlock*(s: sink Sequence): Sequence =
  ## Closes the innermost open block.
  result = s
  if result.depth == 0: raise newException(ValueError, "endBlock without an open block")
  dec result.depth
  result.lines.add result.indent & "end"

proc raw*(s: sink Sequence, line: string): Sequence =
  ## A line of Mermaid as it is.
  result = s
  result.lines.add result.indent & line

func toDiagram*(s: Sequence): Diagram =
  var src = "sequenceDiagram"
  if s.title.len > 0: src.add "\n  title " & plainText(s.title)
  for l in s.lines: src.add "\n" & l
  for k in countdown(s.depth - 1, 0): src.add "\n" & "  ".repeat(k + 1) & "end"
  Diagram(kind: dkSequence, source: src)

func `$`*(s: Sequence): string = s.toDiagram.source
