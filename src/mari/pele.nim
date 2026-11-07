## Pele, the renderer: Mermaid text to SVG.
##
## Pele (https://pele.run, by kepano, MIT) is JavaScript. diagrammari ships its browser bundle
## (`vendor/pele.global.js`, version `peleVersion`) and uses it in two ways:
##
## - at build time, `toSvg` sends the text to one Node process that runs Pele and answers with
##   the SVG, so a page needs no JavaScript to show the diagram;
## - in the browser, `peleScript` is the bundle for a page, and the diagram is drawn by Pele's
##   `mount` when the page opens (see `render_html`).
##
## Node is found on the PATH, or at `$MARI_NODE`.

import std/[os, osproc, streams, json, strutils, hashes, exitprocs]
import core

const
  peleVersion* = "1.13.0"
  peleBundle* = staticRead(currentSourcePath().parentDir / "vendor" / "pele.global.js")
    ## The Pele browser bundle, inlined by `peleScript` (about 730 kB, 275 kB gzipped).
  peleCdn* = "https://cdn.jsdelivr.net/npm/pele@" & peleVersion & "/dist/pele.global.js"

  runnerJs = """
// diagrammari's Pele server: one JSON request per line on stdin, one JSON answer per line.
const vm = require('vm'), fs = require('fs'), readline = require('readline');
vm.runInThisContext(fs.readFileSync(process.argv[2], 'utf8'));
const rl = readline.createInterface({ input: process.stdin });
rl.on('line', (line) => {
  let answer;
  try {
    const req = JSON.parse(line);
    const r = pele.render(req.source, req.options);
    answer = { ok: true, svg: r.svg, width: r.width, height: r.height, type: r.type, mermaidType: r.mermaidType };
  } catch (e) {
    answer = { ok: false, code: e.code || 'error', message: String(e.message || e),
               line: e.line || 0, column: e.column || 0, snippet: e.snippet || '' };
  }
  process.stdout.write(JSON.stringify(answer) + '\n');
});
"""

type
  RenderOptions* = object
    ## Pele's render options; the defaults are Pele's. `idPrefix` empty means one derived
    ## from the source, so the same diagram always gives the same SVG.
    fontFamily*: string        ## label font Pele measures with ("" = Pele's default, sans-serif)
    fontSize*: float           ## base font size in px (0 = 16)
    maxWidth*: float           ## available width in px: narrow layouts below 640 (0 = no limit)
    autoDirection*: bool       ## let a wide flowchart turn vertical when `maxWidth` is small
    responsive*: bool          ## the SVG shrinks to fit its container
    padding*: float            ## space around the diagram in px (0 = Pele's)
    idPrefix*: string
    config*: JsonNode          ## Mermaid settings, as frontmatter `config:` would give them

  Svg* = object
    ## A diagram drawn by Pele.
    svg*: string
    width*, height*: float
    kind*: string              ## Pele's type, `flowchart`
    mermaidType*: string       ## Mermaid's name for it, `flowchart-v2`

func renderOptions*(fontFamily = "", fontSize = 0.0, maxWidth = 0.0, autoDirection = true,
                    responsive = true, padding = 0.0, idPrefix = "",
                    config: JsonNode = nil): RenderOptions =
  RenderOptions(fontFamily: fontFamily, fontSize: fontSize, maxWidth: maxWidth,
                autoDirection: autoDirection, responsive: responsive, padding: padding,
                idPrefix: idPrefix, config: config)

let defaultOptions* = RenderOptions(autoDirection: true, responsive: true)

func idFor*(source: string): string =
  ## The id prefix of a diagram: `dg` and a hash of its source.
  "dg" & toHex(cast[uint32](hash(source))).toLowerAscii & "-"

func toJson*(o: RenderOptions, source: string): JsonNode =
  result = %*{"autoDirection": o.autoDirection, "responsive": o.responsive,
              "idPrefix": (if o.idPrefix.len > 0: o.idPrefix else: idFor(source))}
  if o.fontFamily.len > 0: result["fontFamily"] = %o.fontFamily
  if o.fontSize > 0: result["fontSize"] = %o.fontSize
  if o.maxWidth > 0: result["maxWidth"] = %o.maxWidth
  if o.padding > 0: result["padding"] = %o.padding
  if o.config != nil: result["config"] = o.config

# ------------------------------------------------------------------------------- the Node server

var
  server: Process
  serverTried: bool

proc nodeExe*(): string =
  ## The Node executable used at build time: `$MARI_NODE`, or `node` on the PATH; "" if none.
  let env = getEnv("MARI_NODE")
  if env.len > 0: (if fileExists(env): env else: "")
  else: findExe("node")

proc nodeAvailable*(): bool =
  ## Whether `toSvg` can render: Node is there.
  nodeExe().len > 0

proc stopServer*() {.noconv.} =
  if server != nil:
    server.inputStream.close()
    discard server.waitForExit(2000)
    server.close()
    server = nil

proc startServer() =
  let node = nodeExe()
  if node.len == 0:
    raise (ref DiagramError)(code: "no-node", msg: "Node is needed to render diagrams at build " &
      "time: install it, set MARI_NODE, or render in the browser (client mode)")
  let dir = getTempDir() / "mari-pele-" & peleVersion
  createDir(dir)
  let bundle = dir / "pele.global.js"
  let runner = dir / "runner.cjs"
  if not fileExists(bundle) or getFileSize(bundle) != peleBundle.len: writeFile(bundle, peleBundle)
  if not fileExists(runner) or readFile(runner) != runnerJs: writeFile(runner, runnerJs)
  server = startProcess(node, args = [runner, bundle], options = {})
  if not serverTried:
    serverTried = true
    addExitProc(proc () = stopServer())

proc request(source: string, o: RenderOptions): JsonNode =
  if server == nil or not server.running: startServer()
  let req = $(%*{"source": source, "options": o.toJson(source)})
  server.inputStream.writeLine(req)
  server.inputStream.flush()
  var line = ""
  if not server.outputStream.readLine(line):
    let err = server.errorStream.readAll
    stopServer()
    raise (ref DiagramError)(code: "node", msg: "the Pele server stopped: " & err)
  parseJson(line)

proc toSvg*(d: Diagram, options = defaultOptions): Svg =
  ## The diagram drawn by Pele, at build time. Raises `DiagramError` when the text cannot be
  ## drawn (with Pele's code, line, column and snippet), or when Node is missing (`no-node`).
  let r = request(d.source, options)
  if not r["ok"].getBool:
    raise (ref DiagramError)(code: r["code"].getStr, msg: r["message"].getStr,
                             line: r["line"].getInt, column: r["column"].getInt,
                             snippet: r["snippet"].getStr)
  Svg(svg: r["svg"].getStr, width: r["width"].getFloat, height: r["height"].getFloat,
      kind: r["type"].getStr, mermaidType: r["mermaidType"].getStr)

proc check*(d: Diagram): string =
  ## "" when Pele can draw the diagram, else the error, with its place.
  try:
    discard d.toSvg
  except DiagramError as e:
    result = e.code & ": " & e.msg
