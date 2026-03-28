#!/usr/bin/env python3

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
PATTERNS_DIR = ROOT / "patterns"
EXPR_JSON = PATTERNS_DIR / "SELECTO_EXPR_EXAMPLES.json"


def build_expr_section(expr_code: str) -> str:
    return "## Selecto Expr\n\n```elixir\n" + expr_code.rstrip() + "\n```\n\n"


def pattern_path(pattern_id: str) -> Path:
    matches = sorted(PATTERNS_DIR.glob(f"**/{pattern_id}-*.md"))
    if len(matches) != 1:
        raise RuntimeError(f"Expected exactly one markdown file for {pattern_id}, found {len(matches)}")
    return matches[0]


def sync_file(path: Path, expr_code: str) -> None:
    content = path.read_text(encoding="utf-8")
    expr_section = build_expr_section(expr_code)

    if "## Selecto Expr\n" in content:
        updated = re.sub(
            r"## Selecto Expr\n\n```elixir\n.*?\n```\n\n",
            expr_section,
            content,
            count=1,
            flags=re.S,
        )
    else:
        marker = "## Selecto Yielded SQL\n"
        if marker not in content:
            raise RuntimeError(f"Missing Selecto Yielded SQL section in {path}")
        updated = content.replace(marker, expr_section + marker, 1)

    path.write_text(updated, encoding="utf-8")


def main() -> None:
    payload = json.loads(EXPR_JSON.read_text(encoding="utf-8"))
    for pattern_id, expr_code in payload["patterns"].items():
        sync_file(pattern_path(pattern_id), expr_code)

    print(f"Synced Expr sections for {len(payload['patterns'])} patterns")


if __name__ == "__main__":
    main()
