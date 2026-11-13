#!/usr/bin/env python3
"""Refresh each pattern's PostgreSQL SQL section from the verified full export."""

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATTERNS = ROOT / "patterns"


def main() -> None:
    exported = (PATTERNS / "SELECTO_YIELDED_SQL.md").read_text()
    blocks = re.split(r"^## ([A-Z]+\d{3})\n", exported, flags=re.MULTILINE)
    count = 0
    for pattern_id, block in zip(blocks[1::2], blocks[2::2], strict=True):
        match = re.search(
            r"^### PostgreSQL\n\n(```sql\n.*?\n```\n\n\*\*Params:\*\* `[^\n]+`)",
            block,
            re.MULTILINE | re.DOTALL,
        )
        if match is None:
            raise ValueError(f"{pattern_id}: missing successful PostgreSQL export")
        paths = list(PATTERNS.glob(f"*/{pattern_id}-*.md"))
        if len(paths) != 1:
            raise ValueError(f"{pattern_id}: expected exactly one pattern page")
        path = paths[0]
        content = path.read_text()
        section = "## Selecto Yielded SQL\n\n" + match.group(1) + "\n\n"
        if "## Selecto Yielded SQL\n" in content:
            content = re.sub(
                r"## Selecto Yielded SQL\n.*?(?=^## |\Z)",
                lambda _: section,
                content,
                count=1,
                flags=re.MULTILINE | re.DOTALL,
            )
        else:
            marker = "## Expected SQL Shape\n"
            if marker not in content:
                raise ValueError(f"{pattern_id}: missing expected SQL shape section")
            content = content.replace(marker, section + marker, 1)
        path.write_text(content)
        count += 1
    if count != 121:
        raise ValueError(f"expected 121 exports, found {count}")
    print(f"Synced PostgreSQL yielded SQL sections for {count} patterns")


if __name__ == "__main__":
    main()
