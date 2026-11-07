## Themes: Pele colours and fonts come from CSS variables (`--pele-bg`, `--pele-fg`, ...), so a
## diagram follows the page's theme, light or dark, without being drawn again. A `Theme` is
## those variables as a Nim value; `css` writes them for a selector.
##
## ```nim
## echo flexoki.css(".pele")
## ```

import std/strutils

type
  Theme* = object
    ## Each field is one `--pele-*` variable; an empty field keeps Pele's default.
    bg*, fg*, muted*, line*, surface*, surfaceAlt*, border*, accent*, critical*: string
    font*, fontMono*, radius*: string
    series*: seq[string]       ## `--pele-series-1` ... `--pele-series-8`, for charts

const
  peleDefault* = Theme(bg: "#ffffff", fg: "#1f1f1f", muted: "#6e6e6e", line: "#1f1f1f",
    surface: "#f3f3f3", surfaceAlt: "#e6e6e6", border: "#8a8a8a", accent: "#5b7bd5",
    critical: "#e45756",
    series: @["#4c78a8", "#f58518", "#54a24b", "#e45756", "#72b7b2", "#eeca3b", "#b279a2", "#9d755d"])
    ## Pele's own colours.

  flexoki* = Theme(bg: "#fffcf0", fg: "#100f0f", muted: "#6f6e69", line: "#100f0f",
    surface: "#f2f0e5", surfaceAlt: "#e6e4d9", border: "#cecdc3", accent: "#205ea6",
    critical: "#af3029")
    ## The light colours of Pele's docs (kepano's Flexoki palette).

  flexokiDark* = Theme(bg: "#100f0f", fg: "#cecdc3", muted: "#878580", line: "#cecdc3",
    surface: "#1c1b1a", surfaceAlt: "#282726", border: "#403e3c", accent: "#4385be",
    critical: "#d14d41")
    ## Its dark colours.

func variables*(t: Theme): seq[(string, string)] =
  ## The variables a theme sets, in Pele's order.
  for (name, value) in [("bg", t.bg), ("fg", t.fg), ("muted", t.muted), ("line", t.line),
                        ("surface", t.surface), ("surface-alt", t.surfaceAlt),
                        ("border", t.border), ("accent", t.accent), ("critical", t.critical),
                        ("font", t.font), ("font-mono", t.fontMono), ("radius", t.radius)]:
    if value.len > 0: result.add ("--pele-" & name, value)
  for k, c in t.series:
    if k < 8 and c.len > 0: result.add ("--pele-series-" & $(k + 1), c)

func css*(t: Theme, selector = ".pele"): string =
  ## A CSS rule setting the theme's variables on `selector`.
  var decls: seq[string]
  for (name, value) in t.variables: decls.add "  " & name & ": " & value & ";"
  selector & " {\n" & decls.join("\n") & "\n}"

func css*(light, dark: Theme, selector = ".pele"): string =
  ## Light colours, and dark ones when the reader's system is in dark mode.
  light.css(selector) & "\n@media (prefers-color-scheme: dark) {\n" &
    dark.css(selector).indent(2) & "\n}"
