import mari, json, time
src = "flowchart LR\n  idea[Idea] --> draft(Draft)\n  draft --> review{Review?}\n  review -->|yes| ship((Ship))\n  review -.->|no| draft"
t=time.time(); d = mari.Diagram(src); s0 = d.svg; print("plain", len(s0), round(time.time()-t,3), "s; pele", mari.pele_version())
print(d.ids())
d.layer = {"theme": "isotype", "arrows": "curve", "nodes": {"ship": {"dx": 0, "dy": 120, "fill": "#c8402b"}},
           "edges": {"L_review_draft_0": {"route": "bezier", "c1": [0, -90], "c2": [0, -90]}}}
t=time.time(); d.save("personal.svg"); print("layer", round(time.time()-t,3))
try: mari.Diagram("flowchart LR\n a --> [").svg
except mari.DiagramError as e: print("error:", e.code, e.line, e.column)
