import std/[unittest, strutils, os]
import mari

suite "rendering":
  test "every builder draws":
    check flowchart(LR).chain(["a", "b"]).toSvg.kind == "flowchart"
    check sequence().message("a", "b", "hi").toSvg.kind == "sequence"
    check pie("p").slice("a", 1).toSvg.kind == "pie"
    check timeline().period("1", "x").toSvg.kind == "timeline"

  test "types without a builder draw from text":
    for src in ["mindmap\n  root\n    a\n    b", "gantt\n  title g\n  dateFormat YYYY-MM-DD\n  a : 2026-01-01, 3d",
                "sankey\n  a,b,10\n  a,c,5", "venn-beta\n  set A\n  set B\n  union A,B"]:
      let d = diagram(src)
      check d.check == ""

  test "the same text gives the same svg, ids from the text":
    let d = diagram("flowchart LR\n  accTitle: Two nodes\n  a --> b")
    let s = d.toSvg.svg
    check s == d.toSvg.svg
    check (idFor(d.source) & "-title") in s
    check d.toSvg(renderOptions(idPrefix = "x-")).svg.contains("id=\"x--title\"")

  test "narrow drawing only when it differs":
    let f = flowchart(LR).chain(["a", "b", "c", "d", "e", "f", "g"])
    check "dg-narrow" in f.toHtml(rmStatic, narrow = 360)
    check "dg-narrow" notin pie("p").slice("a", 1).toHtml(rmStatic, narrow = 360)

  test "client mode keeps the text, escaped":
    let h = flowchart().link("a", "b", "x < y").toHtml(rmClient)
    check "x &lt; y" in h
    check "<svg" notin h

  test "no node: auto draws in the browser":
    putEnv("MARI_NODE", "/no/such/node")
    check not nodeAvailable()
    check rmAuto.resolve == rmClient
    delEnv("MARI_NODE")
    check rmAuto.resolve == rmStatic

  test "save svg, md and html":
    let dir = getTempDir() / "mari-test"
    createDir(dir)
    let p = pie("p").slice("a", 1)
    p.save(dir / "p.svg")
    p.save(dir / "p.md")
    p.save(dir / "p.html")
    check readFile(dir / "p.svg").startsWith("<svg")
    check readFile(dir / "p.md").startsWith("```mermaid\npie")
    check readFile(dir / "p.html").startsWith("<!doctype html>")

  test "theme css, light and dark":
    let c = css(flexoki, flexokiDark)
    check "@media (prefers-color-scheme: dark)" in c
    check "--pele-bg: #100f0f;" in c
