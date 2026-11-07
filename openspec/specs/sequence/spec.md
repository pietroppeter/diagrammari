# sequence Specification

## Purpose
Sequence diagrams built in Nim: who talks to whom, in time order. After the message sequence
charts of telecom standards (ITU-T Z.120, 1993) and UML.

## Requirements

### Requirement: Participants and messages
`sequence(title, autonumber)` SHALL make an empty sequence diagram. `participant id, label` and
`actor id, label` SHALL declare participants (a box, a stick figure); `message a, b, text, kind`
SHALL add a message, drawn as `call` (`->>`, default), `reply` (`-->>`), `solidLine`,
`dottedLine`, `lost`, `dottedLost`, `async`, `dottedAsync`, `both` or `dottedBoth`.
`activate = true` SHALL start an activation bar on the receiver, `deactivate = true` end the
sender's.

```nim
let s = sequence:
  actor "you", "You"
  participant "nim", "Nim"
  participant "pele", "Pele"
  message "you", "nim", "nbDiagram f"
  message "nim", "pele", "Mermaid text", activate = true
  message "pele", "nim", "SVG", reply, deactivate = true
echo s
```

```text
sequenceDiagram
  actor you as You
  participant nim as Nim
  participant pele as Pele
  you->>nim: nbDiagram f
  nim->>+pele: Mermaid text
  pele-->>-nim: SVG
```

### Requirement: Text is safe
Message and note text SHALL be written with entities for the characters that would end it (`:`
`;` `#`), and new lines as `<br>`, so any text shows as written.

```nim
echo sequence().message("a", "b", "time: 3; #1")
```

```text
sequenceDiagram
  a->>b: time#58; 3#59; #35;1
```

### Requirement: Notes
`note text, place, a, b` SHALL add a note `leftOf` or `rightOf` a participant, or `over` one or
two.

```nim
echo sequence().message("a", "b", "hi").note("both see it", over, "a", "b")
```

```text
sequenceDiagram
  a->>b: hi
  note over a,b: both see it
```

### Requirement: Blocks
`loop`, `alt`, `opt`, `par`, `critical` and `rect` SHALL open a block, closed by `endBlock`; in a
body, `loop "label": body` opens and closes it around `body`. The next branch of a block just
closed SHALL be `orElse` (after `alt`), `also` (after `par`) or `option` (after `critical`).

```nim
let s = sequence:
  loop "every page":
    message "nim", "pele", "draw"
    alt "it parses":
      message "pele", "nim", "SVG", reply
    orElse "it does not":
      message "pele", "nim", "error, line and column", reply
echo s
```

```text
sequenceDiagram
  loop every page
    nim->>pele: draw
    alt it parses
      pele-->>nim: SVG
    else it does not
      pele-->>nim: error, line and column
    end
  end
```

#### Scenario: A branch without its block
- **WHEN** `orElse` does not follow a closed `alt`
- **THEN** it raises `ValueError`
