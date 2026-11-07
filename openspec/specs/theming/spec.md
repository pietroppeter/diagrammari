# theming Specification

## Purpose
Pele takes its colours and fonts from CSS variables, so a diagram follows the page, light or
dark, without being drawn again. A `Theme` is those variables as a Nim value.

## Requirements

### Requirement: Themes as CSS
A `Theme` SHALL have one field per `--pele-*` variable (`bg`, `fg`, `muted`, `line`, `surface`,
`surfaceAlt`, `border`, `accent`, `critical`, `font`, `fontMono`, `radius`, and `series` for
`--pele-series-1` to `-8`); `css(theme, selector)` SHALL write a rule with the fields that are
set, and `css(light, dark, selector)` SHALL add the dark one under `prefers-color-scheme: dark`.
`peleDefault`, `flexoki` and `flexokiDark` SHALL be given.

```nim
echo Theme(fg: "#2b2118", accent: "#b5452b", font: "Georgia, serif").css(".mari")
```

```text
.mari {
  --pele-fg: #2b2118;
  --pele-accent: #b5452b;
  --pele-font: Georgia, serif;
}
```

#### Scenario: Fonts drawn at build time
- **WHEN** a page sets `--pele-font` and draws its diagrams at build time
- **THEN** it also passes the font as `fontFamily`, because in Node Pele measures text with Arial's widths, and labels in a much wider font may overflow their boxes
