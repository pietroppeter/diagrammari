"""Edit a diagram in a local browser tab, without a notebook: a one-page server on 127.0.0.1
that serves the same widget module with a tiny stand-in for the anywidget model."""
import json, threading, webbrowser, http.server
from .widget import esm

PAGE = """<!doctype html><html lang="en"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1"><title>diagrammari editor</title>
<style>body{margin:0;font:14px system-ui;padding:16px}header{display:flex;gap:12px;align-items:center;margin-bottom:10px}
pre{background:#f6f6f6;padding:8px;font-size:12px}</style></head><body>
<header><b>diagrammari</b><span>drag boxes, click arrows; then</span><button id="done">Done</button></header>
<div id="app"></div><pre id="layer"></pre>
<script type="module">
import w from "/widget.js";
const state = __STATE__, subs = {};
const model = {get: k => state[k], set: (k, v) => { state[k] = v; }, on: (ev, cb) => { (subs[ev] ||= []).push(cb); },
  save_changes() { document.getElementById("layer").textContent = JSON.stringify(state.layer, null, 2); }};
w.render({model, el: document.getElementById("app")});
model.save_changes();
document.getElementById("done").onclick = async () => {
  await fetch("/done", {method: "POST", body: JSON.stringify(state.layer)});
  document.body.innerHTML = "<p>Layer sent back to Python. You can close this tab.</p>";
};
</script></body></html>"""


def edit(source, layer=None, timeout=None, open_browser=True, port=0):
    state = {"source": source, "layer": layer or {}, "svg": ""}
    result, done = {}, threading.Event()

    class H(http.server.BaseHTTPRequestHandler):
        def log_message(self, *a):
            pass

        def _send(self, body, ctype):
            b = body.encode()
            self.send_response(200); self.send_header("Content-Type", ctype); self.send_header("Content-Length", str(len(b)))
            self.end_headers(); self.wfile.write(b)

        def do_GET(self):
            if self.path == "/widget.js":
                self._send(esm(), "text/javascript")
            else:
                self._send(PAGE.replace("__STATE__", json.dumps(state)), "text/html")

        def do_POST(self):
            n = int(self.headers.get("Content-Length", 0))
            result["layer"] = json.loads(self.rfile.read(n) or b"{}")
            self._send("ok", "text/plain"); done.set()

    srv = http.server.ThreadingHTTPServer(("127.0.0.1", port), H)
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    url = f"http://127.0.0.1:{srv.server_address[1]}/"
    print("diagrammari editor:", url)
    if open_browser:
        webbrowser.open(url)
    try:
        done.wait(timeout)
    finally:
        srv.shutdown()
    return result.get("layer", layer or {})
