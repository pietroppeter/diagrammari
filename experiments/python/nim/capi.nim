## diagrammari for Python, proof of concept: a Nim shared library with a C ABI, loaded by
## Python's ctypes. No nimpy, so one binary works for every Python 3 version on a platform.
##
##   mari_draw(request) -> answer   both JSON text; free the answer with mari_free
##   mari_pele_version() -> "1.13.0"
##
## request: {"source": "<mermaid>", "layer": {...} | null, "options": {...}}
## answer:  {"ok": true, "svg": "...", "type": "flowchart", "ids": {"nodes": [...], "edges": [...]}}
##          or {"ok": false, "code": "syntax", "message": ..., "line": 2, "column": 9, ...}
##
## Pele runs in QuickJS, compiled into the library (qjs.nim, vendor/quickjs): no Node needed.
## With `MARI_ENGINE=node`, it runs in one Node process instead, as in src/mari/pele.nim; Node is
## `$MARI_NODE` or on the PATH (the Python package sets MARI_NODE to the Node of the
## `nodejs-wheel-binaries` wheel when `diagrammari[node]` is installed).

import std/[os, osproc, streams, json, tables, strutils, sequtils]
import layer, qjs

const
  peleVersion = "1.13.0"
  # the Pele bundle diagrammari ships (src/mari/vendor), not a copy
  peleBundle = staticRead(currentSourcePath().parentDir / ".." / ".." / ".." / "src" / "mari" / "vendor" / "pele.global.js")
  runnerJs = """
const vm = require('vm'), fs = require('fs'), readline = require('readline');
vm.runInThisContext(fs.readFileSync(process.argv[2], 'utf8'));
readline.createInterface({ input: process.stdin }).on('line', (line) => {
  let a;
  try {
    const q = JSON.parse(line);
    const r = pele.render(q.source, q.options || {});
    a = { ok: true, svg: r.svg, width: r.width, height: r.height, type: r.type, ends: {} };
    if (r.type === 'flowchart') for (const e of pele.parse(q.source).edges) a.ends[e.id] = [e.start, e.end];
  } catch (e) {
    a = { ok: false, code: e.code || 'error', message: String(e.message || e),
          line: e.line || 0, column: e.column || 0, snippet: e.snippet || '' };
  }
  process.stdout.write(JSON.stringify(a) + '\n');
});
"""
  # The themes of the personal-diagrams POC: a font Pele measures with, and --pele-* variables.
  themes = {
    "pele": ("sans-serif", ""),
    "tufte": ("\"Crimson Pro\", Georgia, serif", "--pele-bg:#fffff8;--pele-fg:#111;--pele-surface:#fffff8;--pele-border:#111;--pele-line:#111;--pele-accent:#a4161a;--pele-radius:0px"),
    "isotype": ("Jost, Futura, sans-serif", "--pele-bg:#f1ead9;--pele-fg:#1c1b19;--pele-surface:#e2a52a;--pele-border:#1c1b19;--pele-line:#1c1b19;--pele-accent:#c8402b;--pele-radius:0px"),
    "blueprint": ("\"IBM Plex Mono\", monospace", "--pele-bg:#1d4f7a;--pele-fg:#f4f8fb;--pele-surface:#1d4f7a;--pele-border:#f4f8fb;--pele-line:#f4f8fb;--pele-accent:#ffd166;--pele-radius:0px;--pele-muted:#bcd"),
    "mari": ("Archivo, Helvetica, sans-serif", "--pele-bg:#fbfaf6;--pele-fg:#161616;--pele-surface:#e3c48c;--pele-border:#161616;--pele-line:#161616;--pele-accent:#d2361f;--pele-radius:0px")}.toTable

var server: Process

proc askNode(req: JsonNode): JsonNode =
  if server == nil or not server.running:
    let node = (let e = getEnv("MARI_NODE"); if e.len > 0: e else: findExe("node"))
    if node.len == 0:
      return %*{"ok": false, "code": "no-node", "message": "Node is needed to draw: set MARI_NODE"}
    let dir = getTempDir() / "mari-py-" & peleVersion
    createDir(dir)
    writeFile(dir / "pele.global.js", peleBundle)
    writeFile(dir / "runner.cjs", runnerJs)
    server = startProcess(node, args = [dir / "runner.cjs", dir / "pele.global.js"], options = {})
  server.inputStream.writeLine($req)
  server.inputStream.flush()
  var line: string
  if not server.outputStream.readLine(line):
    return %*{"ok": false, "code": "node", "message": "the Pele process stopped"}
  parseJson(line)

proc ask(req: JsonNode): JsonNode =
  if getEnv("MARI_ENGINE") == "node": askNode(req) else: askQjs(peleBundle, req)

proc mari_engine(): cstring {.exportc, dynlib, cdecl.} =
  if getEnv("MARI_ENGINE") == "node": "node" else: "quickjs"

proc draw(req: JsonNode): JsonNode =
  let lay = if req{"layer"} != nil and req["layer"].kind == JObject: req["layer"] else: newJObject()
  let theme = lay{"theme"}.getStr("pele")
  let (font, vars) = themes.getOrDefault(theme, themes["pele"])
  var options = if req{"options"} != nil: req["options"] else: newJObject()
  if not options.hasKey("fontFamily"): options["fontFamily"] = %font
  if not options.hasKey("idPrefix"): options["idPrefix"] = %"mari-"
  let r = ask(%*{"source": req["source"], "options": options})
  if not r["ok"].getBool: return r
  var ends: Table[string, (string, string)]
  for id, se in r["ends"]: ends[id] = (se[0].getStr, se[1].getStr)
  var svg = r["svg"].getStr
  if r["type"].getStr == "flowchart" and lay.len > 0:
    svg = applyLayer(svg, lay, ends)
  if vars.len > 0:
    svg = svg.replace("style=\"max-width:100%;", "style=\"" & vars & ";max-width:100%;")
  var nodeIds: seq[string]
  for m in svg.split("data-id=\"")[1..^1]:
    let id = m.split("\"")[0]
    if id notin ends and id notin nodeIds: nodeIds.add id
  %*{"ok": true, "svg": svg, "type": r["type"], "ids": {"nodes": nodeIds, "edges": toSeq(ends.keys)}}

proc mari_draw(request: cstring): cstring {.exportc, dynlib, cdecl.} =
  var answer: string
  try:
    answer = $draw(parseJson($request))
  except CatchableError as e:
    answer = $(%*{"ok": false, "code": "error", "message": e.msg})
  result = cast[cstring](allocShared0(answer.len + 1))
  copyMem(result, answer.cstring, answer.len)

proc mari_free(p: cstring) {.exportc, dynlib, cdecl.} = deallocShared(p)

proc mari_pele_version(): cstring {.exportc, dynlib, cdecl.} = peleVersion

