"""Tests for tools.py tool factories, run against a real host shell (LocalShellEnv).

These exercise the actual unix commands the tools issue (find/grep/cat/sed/python3)
without a Docker container.
"""
import pytest

from agent.tools import (
    make_list_dir, make_find_files, make_grep_content, make_view_file,
    make_view_symbol, make_view_outline, make_edit_file, make_search_replace,
    normalize_docker_path, _DOCKER_NOT_READY,
)


# ---------------- docker guard ----------------
@pytest.mark.parametrize("factory", [
    make_list_dir, make_find_files, make_grep_content, make_view_file,
    make_view_symbol, make_view_outline, make_edit_file, make_search_replace,
])
def test_tools_guard_when_no_docker(factory):
    tool = factory(None)
    # invoke with a minimal-but-valid arg for each tool's first param
    first_arg = {
        "list_dir": {"path": "."},
        "find_files": {"pattern": "*.py"},
        "grep_content": {"pattern": "x"},
        "view_file": {"path": "x.py"},
        "view_symbol": {"path": "x.py", "symbol_name": "f"},
        "view_outline": {"path": "x.py"},
        "edit_file": {"path": "x.py", "start_line": 1, "end_line": 1, "new_content": "x"},
        "search_replace": {"path": "x.py", "old_text": "a", "new_text": "b"},
    }[tool.name]
    out = str(tool.invoke(first_arg))
    assert out == _DOCKER_NOT_READY


# ---------------- normalize_docker_path ----------------
@pytest.mark.parametrize("path,repo,expected", [
    ("core.py", "/app", "/app/core.py"),
    ("./core.py", "/app", "/app/core.py"),
    ("/app/core.py", "/app", "/app/core.py"),
    ("/abs/elsewhere.py", "/app", "/app/abs/elsewhere.py"),
])
def test_normalize_docker_path(path, repo, expected):
    assert normalize_docker_path(path, repo) == expected


# ---------------- list_dir ----------------
def test_list_dir(local_env):
    out = str(make_list_dir(local_env).invoke({"path": "."}))
    assert "pkg" in out and "app.js" in out


# ---------------- find_files ----------------
def test_find_files(local_env):
    out = str(make_find_files(local_env).invoke({"pattern": "*.py"}))
    assert "core.py" in out


# ---------------- grep_content ----------------
def test_grep_content_finds_match(local_env):
    out = str(make_grep_content(local_env).invoke({"pattern": "def helper"}))
    assert "helper" in out and "core.py" in out


def test_grep_content_no_match(local_env):
    out = str(make_grep_content(local_env).invoke({"pattern": "zzz_nonexistent_zzz"}))
    assert "core.py" not in out  # nothing matched


# ---------------- view_file ----------------
def test_view_file_has_line_numbers(local_env):
    out = str(make_view_file(local_env).invoke({"path": "pkg/core.py"}))
    assert "class Greeter" in out
    assert "1 |" in out or "1\t" in out or "  1" in out  # some line-number gutter


def test_view_file_missing(local_env):
    out = str(make_view_file(local_env).invoke({"path": "pkg/nope.py"}))
    assert "ERROR" in out.upper() or "not found" in out.lower()


# ---------------- view_symbol (Python AST) ----------------
def test_view_symbol_function(local_env):
    out = str(make_view_symbol(local_env).invoke({"path": "pkg/core.py", "symbol_name": "helper"}))
    assert "def helper" in out and "hello" in out


def test_view_symbol_class(local_env):
    out = str(make_view_symbol(local_env).invoke({"path": "pkg/core.py", "symbol_name": "Greeter"}))
    assert "class Greeter" in out and "def greet" in out


# ---------------- view_outline ----------------
def test_view_outline_lists_symbols(local_env):
    out = str(make_view_outline(local_env).invoke({"path": "pkg/core.py"}))
    assert "Greeter" in out and "helper" in out


# ---------------- edit_file ----------------
def test_edit_file_replaces_lines(local_env, sample_repo):
    tool = make_edit_file(local_env)
    # replace the body of helper() (find its line first)
    src = (sample_repo / "pkg" / "core.py").read_text().splitlines()
    # locate 'def helper' line (1-indexed)
    idx = next(i for i, l in enumerate(src) if l.startswith("def helper")) + 1
    out = str(tool.invoke({"path": "pkg/core.py", "start_line": idx + 1, "end_line": idx + 1,
                           "new_content": '    return f"HI {name}"'}))
    after = (sample_repo / "pkg" / "core.py").read_text()
    assert "HI {name}" in after, out


# ---------------- search_replace ----------------
def test_search_replace(local_env, sample_repo):
    tool = make_search_replace(local_env)
    out = str(tool.invoke({"path": "pkg/core.py", "old_text": 'hello {name}', "new_text": 'hey {name}'}))
    after = (sample_repo / "pkg" / "core.py").read_text()
    assert "hey {name}" in after, out
