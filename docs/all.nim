## Builds every page in one program: `nim r -d:release docs/all.nim`.
## A page is a nimib notebook in docs/ or docs/devlog/; each renders when its module is
## initialised, in import order.
{.warning[UnusedImport]: off.}
import index, explainer, specs
import series/[diagram_history, everyday_diagrams, personal_diagrams, a_name_from_the_sea,
              a_house_style]
import devlog/[day_one, diagrams_series, python_jupyter_marimo, index as devlogIndex]
