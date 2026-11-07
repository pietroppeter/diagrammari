# Package

version       = "0.1.0"
author        = "Pietro Peterlongo"
description   = "Diagrams for Nim, drawn by Pele: Mermaid text or typed builders, rendered to SVG at build time or in the browser"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim", "js"]

# Dependencies

requires "nim >= 2.0.0"
# The core needs only the standard library (and Node at build time, for SVG). nimib is for the
# docs and `import mari/nimib` (nbDiagram): the `docs` feature, pinned in atlas.lock
# (`sh tools/setup.sh` replays it).

feature "docs":
  requires "nimib >= 0.4.3"
  requires "https://github.com/pietroppeter/tabelline"
