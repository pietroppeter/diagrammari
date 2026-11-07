## The devlog's index, docs/devlog/index.html: the living documents (a table below: add a row for
## a new one), then every dated post, newest first, read from the first line of its source
## (`## devlog: <dd Mon yyyy> | <title> | <lede>`). A new post needs no entry here.
import std/[os, strutils, times, algorithm, strformat]
import nimib
import ../tavola

let here = currentSourcePath().parentDir

type Post = object
  slug, date, title, lede: string
  day: DateTime

var posts: seq[Post]
for kind, path in walkDir(here):
  let (_, name, ext) = path.splitFile
  if kind != pcFile or ext != ".nim" or name == "index": continue
  let first = readFile(path).splitLines[0]
  if not first.startsWith("## devlog:"): continue
  let parts = first["## devlog:".len .. ^1].split('|')
  if parts.len < 3: continue
  posts.add Post(slug: name.replace('_', '-'), date: parts[0].strip, title: parts[1].strip,
                 lede: parts[2 .. ^1].join("|").strip, day: parse(parts[0].strip, "dd MMM yyyy"))
# newest first; posts of the same day by slug, so the order is stable
posts.sort(proc (a, b: Post): int = (if a.day == b.day: cmp(a.slug, b.slug) else: cmp(b.day, a.day)))

nbInit
nb.doc.filename = here / "index.html"
nb.useTavola(titolo = "Devlog", tavola = "D", scala = "living pages · posts",
               title = "mari devlog", homeHref = "../")

type Living = tuple[href, title, what, updated: string]
let living: seq[Living] = @[
  ("../explainer/", "Explainer", "Mermaid and Pele, how Pele draws, the art of diagrams, and diagrammari step by step.",
   "as diagrammari grows"),
  ("../specs/", "Specs", "How diagrammari behaves today: requirements with examples that run, and the diagrams they draw.",
   "on every push, from openspec/"),
]
var docs = ""
for d in living:
  docs.add &"""<div class="nota"><span class="titolo"><a href="{d.href}">{d.title}</a></span>{d.what}<br><small>updated {d.updated}</small></div>"""
var items = ""
for p in posts:
  items.add &"""<div class="nota"><small>{p.date}</small><span class="titolo"><a href="{p.slug}/">{p.title}</a></span>{p.lede}</div>"""

nbRawHtml: &"""<p class="kicker">Devlog</p>
<h1>How diagrammari is made</h1>
<p class="lede">Living documents that say how diagrammari is today, then dated posts on the steps that led here.</p>
<h2>Living documents</h2>
<p>Kept up to date as diagrammari changes.</p>
<div class="cards">{docs}</div>
<h2>Posts</h2>
<p>Each tells one step as it happened, and is not updated afterwards. Newest first.</p>
{items}"""
nbSave
