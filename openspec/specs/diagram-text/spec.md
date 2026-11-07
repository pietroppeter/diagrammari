# diagram-text Specification

## Purpose
A diagram is Mermaid text. Everything in diagrammari, written by hand or built in Nim, ends up as a
`Diagram`: the text and the kind of diagram it is. Mermaid is the language; Pele is one renderer.

## Requirements

### Requirement: Diagrams from Mermaid text
`diagram(text)` (also `mermaid(text)`) SHALL make a `Diagram` from Mermaid text, removing the
indentation common to all lines so a triple-quoted string can follow the code around it.
`echo d` SHALL print the text.

```nim
let d = diagram """
  flowchart LR
    A[Mermaid text] --> B[SVG]"""
echo d
```

```text
flowchart LR
  A[Mermaid text] --> B[SVG]
```

#### Scenario: Any diagram type
- **WHEN** the text is any diagram type Pele knows (33 in Pele 1.13, every type built into Mermaid 12.1)
- **THEN** it is a `Diagram`, and the renderers draw it, even when no typed builder exists for it

### Requirement: The kind of a diagram
A `Diagram` SHALL know its kind (`DiagramKind`, named as Pele names the types) from the first
keyword of the text, after frontmatter, `%%` comments and blank lines; `dkUnknown` when no
keyword matches.

```nim
echo diagram("graph TD\n  a --> b").kind
echo diagram("---\ntitle: Pets\n---\npie\n  \"Dogs\" : 3").kind
echo diagram("sequenceDiagram\n  A->>B: Hi").kind
echo diagram("Hello").kind
```

```text
flowchart
pie
sequence
unknown
```

### Requirement: Markdown
`toMarkdown` SHALL give the diagram as a fenced ```mermaid block, which GitHub, GitLab, Obsidian
and most Markdown viewers draw.

```nim
let md = diagram("pie\n  \"Nim\" : 1").toMarkdown
echo md.splitLines[0 .. 1].join(" | ")
echo md.endsWith("\n```")
```

```text
```mermaid | pie
true
```

### Requirement: Builders write Mermaid
Every typed builder (flowchart, sequence, pie, timeline) SHALL write Mermaid text that Mermaid
itself reads, so a diagram built in Nim can be copied to any Mermaid tool. Labels SHALL be quoted
or written with Mermaid entities (`#quot;`, `#58;`, `#59;`, `#35;`, `<br>` for a new line) so that
any text is safe; ids SHALL be letters, digits and `_`, not `end`, else `ValueError`.

```nim
try:
  discard flowchart().node("my node")
except ValueError as e:
  echo e.msg
```

```text
not a valid diagram id: "my node" (use letters, digits and _, not starting with a digit, not "end")
```
