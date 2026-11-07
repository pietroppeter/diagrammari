# timeline Specification

## Purpose
Timelines built in Nim: periods in order, each with its events, in sections. After Joseph
Priestley's *A Chart of Biography* (1765).

## Requirements

### Requirement: Periods and sections
`timeline(title)` SHALL make an empty timeline; `period time, events...` SHALL add a period with
its events, and `section name` SHALL start a section that colours the periods after it.

```nim
let t = timeline("Diagrams before computers"):
  section "Charts"
  period "1765", "Priestley: A Chart of Biography"
  period "1801", "Playfair: the pie chart"
  section "Processes"
  period "1896", "Adamiecki: the harmonogram"
  period "1921", "the Gilbreths: process charts"
echo t
```

```text
timeline
  title Diagrams before computers
  section Charts
    1765 : Priestley#58; A Chart of Biography
    1801 : Playfair#58; the pie chart
  section Processes
    1896 : Adamiecki#58; the harmonogram
    1921 : the Gilbreths#58; process charts
```
