## Pele inside the program: QuickJS (quickjs-ng, MIT, vendor/quickjs) compiled in by Nim's C
## compiler, so drawing a diagram needs no Node. Same request and answer as the Node runner.

import std/[json, strutils, locks]

const
  # Paths built by hand with "/": cross-compiling for Windows, Nim's path procs turn this
  # Linux path into "\home\...", which the compiler then cannot find.
  here = currentSourcePath().replace('\\', '/').rsplit('/', 1)[0]
  qjsDir = here & "/vendor/quickjs"
  qjsFlags = "-D_GNU_SOURCE -w -O2 -I" & qjsDir

{.compile(qjsDir & "/quickjs.c", qjsFlags).}
{.compile(qjsDir & "/libregexp.c", qjsFlags).}
{.compile(qjsDir & "/libunicode.c", qjsFlags).}
{.compile(qjsDir & "/dtoa.c", qjsFlags).}
{.compile(here & "/mari_qjs.c", qjsFlags).}
when not defined(windows): {.passL: "-lm -lpthread".}

proc mari_js_new(code: cstring, len: csize_t, err: ptr cstring): pointer {.importc, cdecl.}
proc mari_js_call(h: pointer, fn, arg: cstring, len: csize_t, ok: ptr cint): cstring {.importc, cdecl.}
proc mari_js_free_str(s: cstring) {.importc, cdecl.}

const glue* = """
;globalThis.__mari = function (line) {
  let a;
  try {
    const q = JSON.parse(line);
    const r = pele.render(q.source, q.options || {});
    a = { ok: true, svg: r.svg, width: r.width, height: r.height, type: r.type, mermaidType: r.mermaidType, ends: {} };
    if (r.type === 'flowchart') for (const e of pele.parse(q.source).edges) a.ends[e.id] = [e.start, e.end];
  } catch (e) {
    a = { ok: false, code: e.code || 'error', message: String(e.message || e),
          line: e.line || 0, column: e.column || 0, snippet: e.snippet || '' };
  }
  return JSON.stringify(a);
};
"""

# One QuickJS runtime for the process. It may be called from any thread (ctypes lets go of
# the GIL during a call, and Python code can draw from a thread pool), so calls take a lock,
# and the shim tells QuickJS where the calling thread's stack is (mari_js_call).
var
  engine: pointer
  engineLock: Lock
initLock engineLock

proc startEngine*(bundle: string) =
  if engine != nil: return
  let code = bundle & glue
  var err: cstring
  engine = mari_js_new(code.cstring, code.len.csize_t, addr err)
  if err != nil:
    let msg = $err
    mari_js_free_str(err)
    raise newException(CatchableError, "Pele did not load in QuickJS: " & msg)

proc askQjs*(bundle: string, req: JsonNode): JsonNode =
  let s = $req
  var ok: cint
  var answer: string
  withLock engineLock:
    startEngine(bundle)
    let r = mari_js_call(engine, "__mari", s.cstring, s.len.csize_t, addr ok)
    answer = $r
    mari_js_free_str(r)
  if ok == 0: return %*{"ok": false, "code": "js", "message": answer}
  parseJson(answer)
