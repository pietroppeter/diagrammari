## Builds every page in one program: `nim r -d:release docs/all.nim`.
## A page is a nimib notebook in docs/ or docs/devlog/; each renders when its module is
## initialised, in import order.
{.warning[UnusedImport]: off.}
import index, explainer, specs
import devlog/[day_one, index as devlogIndex]
