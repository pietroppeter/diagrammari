# Working on diagrammari

Notes for coding agents (and people) changing this repository. How diagrammari behaves is in
`openspec/specs/` (rendered at `specs/`); how it is laid out is in README.md. This file holds the
working rules that are easy to miss.

## Behaviour lives in the specs

- Every agreed behaviour is a requirement with scenarios in `openspec/specs/`. New work starts as
  an OpenSpec change in `openspec/changes/` (`/opsx:propose`), is built in a PR (`/opsx:apply`),
  and is archived when it ships (`/opsx:archive`). `openspec/config.yaml` has the rules.
- Ideas go in BACKLOG.md, not straight into work. When a change is archived, remove its BACKLOG
  entry and add a CHANGELOG.md line under Unreleased with the PR number.
- Every requirement about the API has an example: a ```nim block followed by a ```text block with
  what it prints (`echo d` prints a diagram's Mermaid text). `nim r tools/specexamples.nim` runs
  them all (Node is needed: the specs page shows the SVG each example draws); `--update` rewrites
  the outputs after a change is built; `--changes` includes open changes.
- Name builder verbs after Mermaid's keywords in camelCase; when a keyword is a Nim keyword, pick a
  word and say so (`end` is `endBlock`, `else` is `orElse`, `and` is `also`). List differences
  from Mermaid and Pele in every proposal.

## Code

- The core (`src/mari/`) needs only Nim's standard library, plus Node (20 or later) at run
  time to draw SVG. nimib is used only by `src/mari/nimib.nim` and the docs.
- diagrammari wraps Pele, it does not reimplement it. Pele is shipped as
  `src/mari/vendor/pele.global.js` (from the npm package `pele`, MIT, license beside it) and
  pinned in `peleVersion` (`src/mari/pele.nim`). To move to a new Pele: download the tarball
  from registry.npmjs.org, replace the bundle and its license, bump `peleVersion` (and the CDN
  link follows), run tests, examples and pages, and write in the CHANGELOG what Pele changed.
- Builders take a diagram (`sink`) and return the new one, and write Mermaid text that Mermaid
  itself reads. Labels go through `quoted` or `plainText` (core.nim), ids through `checkId`.
  Macros only where a proc cannot do the job (today: `flowchart`, `sequence`, `pie`, `timeline`
  with a body, which share `rewriteVerbs` in `src/mari.nim`).
- `nim r tests/all.nim` runs the tests. Dependencies are managed with atlas: nimib is the `docs`
  feature of `mari.nimble`, pinned in `atlas.lock`, cloned into `deps/` (not committed) and
  put on the path by `nim.cfg` (committed, written by atlas).

## Setup

- In a fresh checkout or sandbox, run `sh tools/setup.sh` before anything else. It installs what is
  missing (Nim from GitHub nightlies, atlas, libpcre3), checks for Node, and installs the pinned
  dependencies; it is safe to rerun. It prints the `export PATH=...` line to use when it installed
  Nim or atlas.
- To change a dependency: `atlas use <pkg>` or edit the `docs` feature, `atlas install
  --feature=docs`, run the tests and the pages, then `atlas pin --feature=docs` and commit
  `atlas.lock` and `nim.cfg`. Without `--feature=docs`, atlas leaves nimib out.
- `atlas.lock` keeps a copy of `mari.nimble`, and `atlas rep` (so `tools/setup.sh`) writes that
  copy back: after editing `mari.nimble`, run `atlas pin --feature=docs` before the setup.
- Sandboxes often block jsDelivr and pele.run; registry.npmjs.org and raw.githubusercontent.com
  usually work, and are enough to read and update Pele.

## Pages

- Every page is a nimib notebook in `docs/` in the tavola theme (`docs/tavola.nim`) and writes a
  standalone HTML file (fonts inlined, diagrams drawn at build time, nothing remote). The HTML is
  not committed: CI builds every page (`nim r -d:release docs/all.nim`) and deploys `docs/` to
  GitHub Pages from `main`.
- Diagrams drawn at build time are measured with Arial's widths (Pele has no canvas in Node), so
  pages draw them in Arimo (`tavolaTheme`). Check a phone-width screenshot: static diagrams carry
  a narrow drawing (`narrow = 420`), shown by a container query.
- Living documents (the explainer, the specs page) are kept up to date. A devlog post
  (`docs/devlog/<slug>.nim`, first line `## devlog: dd Mon yyyy | title | lede`) is dated and not
  updated afterwards; the devlog index finds it, and it gets a line in the README.
- The Diagrams series (`docs/series/`) is a collection of its own: each part keeps the style of
  its figure (CSS in `docs/series/assets/`, fonts inlined from `assets/fonts/`), and a bar from
  `docs/series/serie.nim` links the parts and their index, the devlog post `diagrams_series.nim`.
  Parts 1-3 are hand-made HTML kept as they were made (committed, with their vendored Pele and
  D3); their nimib versions (`nimib.html`) reuse that prose and rebuild tables and diagrams from
  data. Parts 4-5 are notebooks and are still being written, so the index changes with them.
- A link can show part of the specs page: `specs/?spec=<names>` or `specs/?change=<names>`
  (comma-separated, `name*` for a prefix, `all`, or the same after `#`).
- Facts in the explainer's history come with a link to their source; check them before adding.

## Previews and PRs

- Show Pietro a published preview of the pages before asking to merge; he reviews on his phone.
- Nothing goes to `main` without his go. One clean PR per change; keep the PR description in sync
  with the branch.
