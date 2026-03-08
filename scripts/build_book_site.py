#!/usr/bin/env python3

from __future__ import annotations

import json
import re
import shutil
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
SITE_SRC = ROOT / "site"
SITE_OUT = ROOT / "_site"
PATTERNS_DIR = ROOT / "patterns"


def extract_title(path: Path) -> str:
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            if line.startswith("# "):
                return line[2:].strip()
    return path.stem


def pattern_sort_key(path: Path):
    stem = path.stem
    match = re.match(r"([A-Z])(\d+)", stem)
    if not match:
        return ("Z", 9999, stem)
    return (match.group(1), int(match.group(2)), stem)


def build_manifest() -> dict:
    categories = [
        ("joins", "Joins"),
        ("aggregates", "Aggregates"),
        ("windows", "Window Functions"),
        ("subqueries", "Subqueries"),
        ("ctes", "CTEs"),
    ]

    groups: list[dict] = []

    for slug, title in categories:
        dir_path = PATTERNS_DIR / slug
        excluded = {"README.md", "DOMAIN_CONFIGURATION.md"}
        files = [path for path in dir_path.glob("*.md") if path.name not in excluded]
        files = sorted(files, key=pattern_sort_key)

        entries = []
        for md_file in files:
            entries.append(
                {
                    "id": md_file.stem.split("-", 1)[0],
                    "title": extract_title(md_file),
                    "path": str(md_file.relative_to(ROOT)).replace("\\", "/"),
                }
            )

        groups.append({"slug": slug, "title": title, "entries": entries})

    extras = [
        {
            "id": "JOIN-DOMAIN",
            "title": extract_title(PATTERNS_DIR / "joins" / "DOMAIN_CONFIGURATION.md"),
            "path": "patterns/joins/DOMAIN_CONFIGURATION.md",
        },
        {
            "id": "GUIDE",
            "title": extract_title(PATTERNS_DIR / "ESCAPE_HATCH_GUIDE.md"),
            "path": "patterns/ESCAPE_HATCH_GUIDE.md",
        },
        {
            "id": "CATALOG",
            "title": extract_title(ROOT / "CATALOG.md"),
            "path": "CATALOG.md",
        },
        {
            "id": "README",
            "title": extract_title(ROOT / "README.md"),
            "path": "README.md",
        },
    ]

    return {"title": "Selecto SQL Patterns", "groups": groups, "extras": extras}


def copy_site_files() -> None:
    if SITE_OUT.exists():
        shutil.rmtree(SITE_OUT)

    SITE_OUT.mkdir(parents=True)

    shutil.copytree(SITE_SRC, SITE_OUT, dirs_exist_ok=True)
    shutil.copytree(PATTERNS_DIR, SITE_OUT / "patterns", dirs_exist_ok=True)
    shutil.copy2(ROOT / "README.md", SITE_OUT / "README.md")
    shutil.copy2(ROOT / "CATALOG.md", SITE_OUT / "CATALOG.md")
    shutil.copy2(
        PATTERNS_DIR / "joins" / "DOMAIN_CONFIGURATION.md",
        SITE_OUT / "DOMAIN_CONFIGURATION.md",
    )


def write_manifest(manifest: dict) -> None:
    output = SITE_OUT / "book.json"
    output.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    copy_site_files()
    manifest = build_manifest()
    write_manifest(manifest)
    print("Built book site in", SITE_OUT)


if __name__ == "__main__":
    main()
