# rendering Specification

## Purpose
Pele draws the diagrams. diagrammari ships Pele's browser bundle (pinned, `peleVersion`) and uses
it at build time, through Node, or in the reader's browser.

## Requirements

### Requirement: SVG at build time
`toSvg(d, options)` SHALL send the Mermaid text to one Node process running the shipped Pele
(started on first use, reused, stopped at exit) and return the SVG with its natural width and
height and Pele's names for its type. The same text and options SHALL give the same SVG: the id
prefix SHALL be derived from the text unless `options.idPrefix` is set.

```nim
let s = diagram("flowchart LR\n  a --> b").toSvg
echo s.kind, " ", s.mermaidType
echo s.svg.startsWith("<svg"), " ", s.svg == diagram("flowchart LR\n  a --> b").toSvg.svg
echo peleVersion
```

```text
flowchart flowchart-v2
true true
1.13.0
```

#### Scenario: No Node
- **WHEN** Node is not on the PATH and `$MARI_NODE` is not set
- **THEN** `toSvg` raises `DiagramError` with code `no-node`, and `rmAuto` draws in the browser instead

### Requirement: Errors with their place
When Pele cannot draw a text, `toSvg` SHALL raise `DiagramError` with Pele's `code` (`syntax`,
`semantic`, `limit`, `unsupported-diagram`), message, `line`, `column` and `snippet`.
`check d` SHALL give "" for a diagram Pele draws, else the code and message.

```nim
try:
  discard diagram("flowchart LR\n  a --> [").toSvg
except DiagramError as e:
  echo e.code, " at ", e.line, ":", e.column
  echo e.snippet
echo check(diagram("Hello")).len > 0
```

```text
syntax at 2:9
  a --> [
--------^
true
```

### Requirement: Render options
`renderOptions` SHALL set Pele's options: `fontFamily` (the font Pele measures labels with),
`fontSize`, `maxWidth` (below 640 px a wide flowchart may turn vertical, unless
`autoDirection = false`), `responsive`, `padding`, `idPrefix` and `config` (Mermaid settings).

```nim
let f = flowchart(LR).chain(["a", "b", "c", "d", "e", "f"])
let wide = f.toSvg
let narrow = f.toSvg(renderOptions(maxWidth = 320))
echo wide.width > wide.height, " ", narrow.width < narrow.height
```

```text
true true
```

### Requirement: HTML, static or in the browser
`toHtml(d, mode)` SHALL give a `<figure class="mari mari-<kind>">`. In `rmStatic` it
SHALL hold the SVG drawn at build time; with `narrow = w` it SHALL also hold a drawing at that
width, shown below it by a container query, when the two differ. In `rmClient` it SHALL hold
the Mermaid text, shown as text until Pele (`peleScript`, once per page, inlined or from
jsDelivr pinned to `peleVersion`) mounts the diagram at the page's width. `rmAuto` SHALL be
static when Node is there.

```nim
let d = diagram("pie\n  \"a\" : 1")
echo d.toHtml(rmStatic).startsWith("<figure class=\"mari mari-pie\"><svg")
echo "mariMount" in d.toHtml(rmClient)
echo peleCdn
```

```text
true
true
https://cdn.jsdelivr.net/npm/pele@1.13.0/dist/pele.global.js
```

### Requirement: Files
`save(d, path)` SHALL write an `.svg` file (drawn at build time), a `.md` file (a ```mermaid
block) or, for any other extension, a standalone HTML page.
