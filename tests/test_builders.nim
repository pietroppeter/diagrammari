import std/[unittest, strutils]
import mari

suite "builders":
  test "the block macro and chaining write the same text":
    let a = flowchart(LR):
      node "a", "A"
      "a" --> "b"
    let b = flowchart(LR).node("a", "A").link("a", "b")
    check $a == $b

  test "for, if and plain statements in a body":
    let names = ["a", "b", "c"]
    let f = flowchart():
      for k in 1 ..< names.len:
        link names[k - 1], names[k]
      if names.len > 2:
        node "c", "last", circle
      let unused {.used.} = 1
    check ($f).splitLines.len == 4
    check "c((\"last\"))" in $f

  test "an open subgraph is closed when written":
    check ($flowchart().subgraph("s").node("a")).endsWith("\n  end")

  test "endBlock without a block":
    expect ValueError: discard flowchart().endBlock

  test "orElse needs a closed alt":
    expect ValueError: discard sequence().message("a", "b", "x").orElse("no")

  test "par and also":
    let s = sequence:
      par "one":
        message "a", "b", "x"
      also "two":
        message "a", "c", "y"
    check "  and two\n" in $s

  test "labels with quotes and new lines":
    check $flowchart().node("a", "say \"hi\"\nthere") == "flowchart TB\n  a[\"say #quot;hi#quot;<br>there\"]"

  test "pie from pairs, and positive values":
    check $pie("t", [("a", 1.0), ("b", 2.5)]) == "pie\n  title t\n  \"a\" : 1\n  \"b\" : 2.5"
    expect ValueError: discard pie().slice("zero", 0)

  test "kind of the builders":
    check flowchart().toDiagram.kind == dkFlowchart
    check sequence().toDiagram.kind == dkSequence
    check pie().toDiagram.kind == dkPie
    check timeline().toDiagram.kind == dkTimeline
    check diagram("  %% a comment\n  mindmap\n    root").kind == dkMindmap
