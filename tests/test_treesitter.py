"""Tests for treesitter_outline (JS/TS/Go/Java parsing)."""
import pytest

from agent.treesitter_outline import (
    get_language_for_file, treesitter_outline, treesitter_find_symbol,
)

JS = """\
function add(a, b) { return a + b; }
class Calc {
  mul(a, b) { return a * b; }
}
"""

GO = """\
package main

func Add(a int, b int) int { return a + b }

type Calc struct{}

func (c Calc) Mul(a int, b int) int { return a * b }
"""


@pytest.mark.parametrize("path,lang", [
    ("app.js", "javascript"),
    ("app.jsx", "javascript"),
    ("main.go", "go"),
    ("x.ts", "typescript"),
    ("X.java", "java"),
    ("notes.txt", None),
])
def test_get_language_for_file(path, lang):
    assert get_language_for_file(path) == lang


def _require(lang):
    try:
        import importlib
        importlib.import_module(f"tree_sitter_{ 'javascript' if lang=='javascript' else lang}")
    except Exception:
        pytest.skip(f"tree-sitter binding for {lang} not installed")


def test_js_outline_finds_function_and_class():
    _require("javascript")
    outline = treesitter_outline(JS, "javascript")
    names = {item.get("name") for item in outline}
    assert "add" in names
    assert "Calc" in names


def test_js_find_symbol():
    _require("javascript")
    matches = treesitter_find_symbol(JS, "javascript", "add")
    assert matches and any(m.get("name") == "add" for m in matches)


def test_go_outline_finds_func():
    _require("go")
    outline = treesitter_outline(GO, "go")
    names = {item.get("name") for item in outline}
    assert "Add" in names
