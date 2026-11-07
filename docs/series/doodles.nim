## Small drawings for part 4: soft crayon lines and watercolour fills, drawn by hand in SVG.
## Every drawing uses the `crayon` and `wash` filters from `doodleDefs`, which a page puts once
## near the top.
import std/strformat

const doodleDefs* = """<svg width="0" height="0" style="position:absolute" aria-hidden="true"><defs>
<filter id="crayon" x="-10%" y="-10%" width="120%" height="120%">
  <feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" seed="3" result="n"/>
  <feDisplacementMap in="SourceGraphic" in2="n" scale="1.6"/>
</filter>
<filter id="wash" x="-10%" y="-10%" width="120%" height="120%">
  <feTurbulence type="fractalNoise" baseFrequency="0.035" numOctaves="3" seed="8" result="n"/>
  <feDisplacementMap in="SourceGraphic" in2="n" scale="7" result="d"/>
  <feGaussianBlur in="d" stdDeviation="0.6"/>
</filter>
</defs></svg>"""

func svgOpen(w, h: int, label: string): string =
  &"""<svg viewBox="0 0 {w} {h}" role="img" aria-label="{label}" class="doodle">"""

const
  ink = "#28405a"
  sea = "#3b86c4"
  sea2 = "#8fd0dc"
  coral = "#e0533d"
  sun = "#f4c15a"
  leaf = "#7aa95c"

func seaBand*(): string =
  ## The page's opening picture: a low moon, a little boat with a round flag, three waves and a
  ## fish jumping between them.
  svgOpen(720, 230, "A small boat with a round flag on a wavy sea under a big moon, a fish jumping") & &"""
<g filter="url(#wash)">
  <circle cx="540" cy="92" r="70" fill="{sun}" opacity=".55"/>
  <path d="M0 150 Q60 128 120 150 T240 150 T360 150 T480 150 T600 150 T720 150 V230 H0Z" fill="{sea2}" opacity=".7"/>
  <path d="M0 175 Q45 158 90 175 T180 175 T270 175 T360 175 T450 175 T540 175 T630 175 T720 175 V230 H0Z" fill="{sea}" opacity=".55"/>
  <path d="M0 202 Q40 190 80 202 T160 202 T240 202 T320 202 T400 202 T480 202 T560 202 T640 202 T720 202 V230 H0Z" fill="{sea}" opacity=".75"/>
</g>
<g filter="url(#crayon)" fill="none" stroke="{ink}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M0 150 Q60 128 120 150 T240 150 T360 150 T480 150 T600 150 T720 150"/>
  <path d="M0 175 Q45 158 90 175 T180 175 T270 175 T360 175 T450 175 T540 175 T630 175 T720 175" stroke-width="1.6"/>
  <path d="M196 148 L284 148 L270 166 L212 166 Z" fill="{coral}" fill-opacity=".85"/>
  <path d="M240 148 V86"/>
  <path d="M242 90 L276 100 L242 112" fill="#fff" fill-opacity=".9"/>
  <circle cx="256" cy="101" r="5" fill="{coral}" stroke="none"/>
  <path d="M410 120 q16 -34 40 -20" stroke-dasharray="2 6"/>
  <path d="M452 98 q8 -8 18 -2 q-6 10 -18 2z M470 96 l9 -6 l-1 13z" fill="{coral}" fill-opacity=".8"/>
  <circle cx="458" cy="98" r=".8" fill="{ink}"/>
</g>
</svg>"""

func fish*(color = coral, label = "a small fish"): string =
  svgOpen(120, 70, label) & &"""
<g filter="url(#wash)"><ellipse cx="55" cy="35" rx="38" ry="20" fill="{color}" opacity=".55"/></g>
<g filter="url(#crayon)" fill="none" stroke="{ink}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M17 35 Q40 10 74 22 Q90 28 93 35 Q90 42 74 48 Q40 60 17 35Z"/>
  <path d="M93 35 L114 20 L110 35 L114 50Z"/>
  <circle cx="34" cy="31" r="2.4" fill="{ink}"/>
  <path d="M52 24 q6 11 0 22" stroke-width="1.4"/>
</g></svg>"""

func boat*(): string =
  svgOpen(140, 120, "a toy boat with a round flag") & &"""
<g filter="url(#wash)"><path d="M10 100 q30 -10 60 0 t60 0 v20 h-120z" fill="{sea2}" opacity=".8"/></g>
<g filter="url(#crayon)" fill="none" stroke="{ink}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M24 82 H118 L104 100 H38 Z" fill="#fff" fill-opacity=".9"/>
  <path d="M70 82 V20"/>
  <path d="M72 24 H112 V52 H72" fill="#fff"/>
  <circle cx="92" cy="38" r="8" fill="{coral}" stroke="none"/>
  <path d="M44 90 h8 M60 90 h8 M76 90 h8" stroke-width="1.4"/>
</g></svg>"""

func jelly*(): string =
  svgOpen(100, 130, "a jellyfish") & &"""
<g filter="url(#wash)"><path d="M14 54 Q14 12 50 12 Q86 12 86 54 Z" fill="#c9a7e0" opacity=".6"/></g>
<g filter="url(#crayon)" fill="none" stroke="{ink}" stroke-width="2" stroke-linecap="round">
  <path d="M14 54 Q14 12 50 12 Q86 12 86 54 Q78 48 68 54 Q58 48 50 54 Q42 48 32 54 Q22 48 14 54Z"/>
  <path d="M26 56 q-6 18 2 30 t0 30 M44 58 q6 16 -2 28 t2 34 M60 58 q-6 16 2 28 t-2 30 M76 56 q6 16 -2 28 t2 24"/>
</g></svg>"""

func bucket*(): string =
  svgOpen(110, 120, "a green bucket of sea water with a small fish in it") & &"""
<g filter="url(#wash)"><path d="M18 40 H92 L84 112 H26 Z" fill="{leaf}" opacity=".6"/>
  <ellipse cx="55" cy="40" rx="37" ry="8" fill="{sea2}" opacity=".9"/></g>
<g filter="url(#crayon)" fill="none" stroke="{ink}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M18 40 L26 112 H84 L92 40"/>
  <ellipse cx="55" cy="40" rx="37" ry="8"/>
  <path d="M20 40 Q55 -6 90 40"/>
  <path d="M44 38 q6 -8 14 -2 q-6 7 -14 2z M58 36 l6 -4 v8z" fill="{coral}" stroke-width="1.4"/>
</g></svg>"""

func lighthouse*(): string =
  svgOpen(100, 150, "a lighthouse on a rock") & &"""
<g filter="url(#wash)"><path d="M8 140 Q30 118 54 124 Q80 116 94 140Z" fill="#b9a78f" opacity=".7"/>
  <path d="M42 30 L30 20 M58 30 L72 18" stroke="{sun}" stroke-width="10" opacity=".6"/></g>
<g filter="url(#crayon)" fill="none" stroke="{ink}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M36 124 L42 44 H58 L64 124Z" fill="#fff"/>
  <path d="M38 100 H62 M40 76 H60" stroke="{coral}" stroke-width="6"/>
  <path d="M40 44 V30 H60 V44"/><path d="M38 30 L50 18 L62 30Z" fill="{coral}"/>
</g></svg>"""

func shell*(): string =
  svgOpen(90, 80, "a scallop shell") & &"""
<g filter="url(#wash)"><path d="M10 52 Q45 -10 80 52 L52 68 H38Z" fill="#f3b8a2" opacity=".75"/></g>
<g filter="url(#crayon)" fill="none" stroke="{ink}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <path d="M10 52 Q45 -10 80 52 L52 68 H38Z"/>
  <path d="M45 66 L45 18 M45 66 L26 28 M45 66 L64 28 M45 66 L15 44 M45 66 L75 44" stroke-width="1.4"/>
</g></svg>"""

func nameChain*(): string =
  ## Three names drawn like a diagram in wet sand: mermaid, pele, mari, joined by wavy arrows.
  svgOpen(640, 150, "Three circles joined by wavy arrows: mermaid, then pele, then mari") & &"""
<g filter="url(#wash)">
  <circle cx="95" cy="75" r="56" fill="{sea2}" opacity=".6"/>
  <circle cx="320" cy="75" r="56" fill="#f6a37f" opacity=".55"/>
  <circle cx="545" cy="75" r="56" fill="{sea}" opacity=".45"/>
</g>
<g filter="url(#crayon)" fill="none" stroke="{ink}" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="95" cy="75" r="56"/><circle cx="320" cy="75" r="56"/><circle cx="545" cy="75" r="56"/>
  <path d="M156 75 q20 -14 40 0 t40 0 t20 0"/><path d="M248 66 l12 9 l-12 9"/>
  <path d="M381 75 q20 -14 40 0 t40 0 t20 0"/><path d="M473 66 l12 9 l-12 9"/>
</g>
<g font-family="Klee One, cursive" font-size="22" text-anchor="middle" fill="{ink}">
  <text x="95" y="72">mermaid</text><text x="95" y="96" font-size="13">a fairy tale</text>
  <text x="320" y="72">pele</text><text x="320" y="96" font-size="12">volcano goddess</text>
  <text x="545" y="72">mari</text><text x="545" y="96" font-size="13">the seas</text>
</g></svg>"""

func side*(drawing: string, caption = ""): string =
  ## A drawing in the margin (beside the text on wide screens, small and floated on phones).
  "<figure class=\"side\">" & drawing &
    (if caption.len > 0: "<figcaption>" & caption & "</figcaption>" else: "") & "</figure>"
