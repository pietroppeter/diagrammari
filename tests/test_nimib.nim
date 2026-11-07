import std/[unittest, strutils, os]
import nimib
import mari, mari/nimib

suite "nimib":
  test "html page: client mode brings Pele once":
    nbInit
    nb.doc.filename = getTempDir() / "mari-nb.html"
    nb.useDiagrams(mode = rmClient)
    nbDiagram flowchart().link("a", "b")
    nbDiagram "pie\n  \"a\" : 1"
    nbSave
    let html = readFile(getTempDir() / "mari-nb.html")
    check html.count("<script>\nfunction mariMount") == 1
    check html.count("<script>mariMount(") == 2

  test "html page: static mode has no script":
    nbInit
    nb.doc.filename = getTempDir() / "mari-nb-static.html"
    nb.useDiagrams(mode = rmStatic)
    nbDiagram flowchart().link("a", "b"), caption = "a to b", showSource = true
    nbSave
    let html = readFile(getTempDir() / "mari-nb-static.html")
    check "<script>\nfunction mariMount" notin html
    check "<script>mariMount(" notin html
    check "<figcaption>a to b</figcaption>" in html
    check "Mermaid text" in html

  test "markdown page: a mermaid block":
    nbInitMd
    nb.doc.filename = getTempDir() / "mari-nb.md"
    nbDiagram flowchart().link("a", "b")
    nbSave
    check "```mermaid\nflowchart TB\n  a --> b\n```" in readFile(getTempDir() / "mari-nb.md")
