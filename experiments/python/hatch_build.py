"""Build hook: compile the Nim library (nim/capi.nim) into src/mari/_lib before the wheel is made.

The wheel is then tagged for this platform (py3-none-<platform>): the library has a C ABI and is
loaded with ctypes, so it does not depend on the Python version.
"""
import os, shutil, subprocess, sys
from pathlib import Path
from hatchling.builders.hooks.plugin.interface import BuildHookInterface

LIB = {"win32": "mari.dll", "darwin": "libmari.dylib"}.get(sys.platform, "libmari.so")


class NimBuild(BuildHookInterface):
    def initialize(self, version, build_data):
        if self.target_name != "wheel":
            return
        root = Path(self.root)
        out = root / "src" / "mari" / "_lib"
        out.mkdir(parents=True, exist_ok=True)
        nim = os.environ.get("NIM", shutil.which("nim") or "")
        if not nim:
            raise RuntimeError("Nim is needed to build diagrammari from source: https://nim-lang.org/install.html")
        subprocess.run([nim, "c", "--app:lib", "-d:release", "--hints:off", "--nimcache:" + str(root / "build" / "nimcache"),
                        "-o:" + str(out / LIB), str(root / "nim" / "capi.nim")], check=True)
        # the widget needs Pele in the browser too: the same bundle the Nim library ships
        shutil.copy(root.parent.parent / "src" / "mari" / "vendor" / "pele.global.js", root / "src" / "mari" / "pele.global.js")
        build_data["pure_python"] = False
        build_data["tag"] = "py3-none-" + _platform_tag()


def _platform_tag():
    from packaging.tags import sys_tags
    return next(t.platform for t in sys_tags())
