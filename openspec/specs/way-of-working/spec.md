# way-of-working Specification

## Purpose
How diagrammari is made: specs with examples that run, living documents and a devlog built as
nimib notebooks, previews before merges.

## Requirements

### Requirement: Behaviour lives in the specs
Every agreed behaviour SHALL be a requirement with scenarios in `openspec/specs/`. New work SHALL
start as an OpenSpec change in `openspec/changes/` (proposal, spec deltas, tasks), be built in one
PR, and be archived when it ships. Ideas not yet picked up SHALL live in `BACKLOG.md`.

#### Scenario: An idea becomes work
- **WHEN** a backlog idea is picked up
- **THEN** it becomes a change, its backlog entry is marked in progress, and when the change is archived the entry is removed and CHANGELOG.md gets a line

### Requirement: Examples that run
A requirement that describes Nim API SHALL have an example: a ```nim block followed by a ```text
block with what it prints. `nim r tools/specexamples.nim` SHALL run every example of the specs in
one program and fail when an output differs; `--update` SHALL write the actual outputs back. CI
SHALL run them on every push and pull request.

#### Scenario: A change breaks an example
- **WHEN** a change to the code makes an example print something else
- **THEN** `tools/specexamples.nim` exits with an error showing the expected and the actual output

### Requirement: Pages are notebooks
Every page SHALL be a nimib notebook in `docs/` that writes a standalone HTML file, in the
tavola theme (`docs/tavola.nim`), with the code that made each diagram shown next to it. CI
SHALL build all pages (`docs/all.nim`) and deploy them to GitHub Pages from `main`; the HTML SHALL
NOT be committed.

### Requirement: Living documents and a devlog
The site SHALL have living documents, kept up to date as diagrammari changes (the explainer, the
specs page), and a devlog of dated posts, each telling one step as it happened and not updated
afterwards. The devlog index SHALL list the living documents first, then the posts newest first,
read from the posts' sources. The specs page SHALL show every spec with its examples, their
output and the diagram each example makes.

#### Scenario: A new post
- **WHEN** a post `docs/devlog/<slug>.nim` is added
- **THEN** it appears on the devlog index at the next build with nothing else to edit, and gets a line in the README

### Requirement: English, preview first
Specs, code, commits, PRs and the devlog SHALL be in English (Italian words are welcome as names).
A change SHALL be shown to Pietro as a published preview before it is merged, and nothing SHALL
go to `main` without his go.

### Requirement: Pele pinned
diagrammari SHALL ship one Pele release (`src/mari/vendor/pele.global.js`, from the npm
package, with its license) and name it in `peleVersion`. Moving to a new release SHALL be its own
change: replace the bundle, bump `peleVersion`, run the tests, the spec examples and the pages,
and note in the CHANGELOG what Pele changed.
