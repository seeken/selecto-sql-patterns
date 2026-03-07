# selecto-sql-patterns

Open-source SQL examples rebuilt as Selecto patterns.

This repository is a working set of query patterns we can reuse for docs, tests,
and regression checks across the Selecto ecosystem.

## Goals

- Build practical SQL-to-Selecto examples from permissively licensed sources.
- Keep clear source attribution and licensing for every imported pattern.
- Group patterns by topic so we can cover common real-world query shapes.
- Make examples runnable and testable with expected SQL output checks.

## Current Scope

- Joins
- Aggregates
- Window functions
- Subqueries
- CTEs

## Repository Layout

- `attribution/sources.md` source list and license notes
- `patterns/` query patterns grouped by topic
- `patterns/_template.md` pattern authoring template
- `patterns/ESCAPE_HATCH_GUIDE.md` rules for lateral/raw SQL escape-hatch patterns
- `CATALOG.md` high-level tracking for planned pattern coverage
- `scripts/verify_examples.exs` runs `Selecto.to_sql/1` for every published pattern example
- `scripts/support/escape_hatch_helpers.exs` shared helper snippets for raw SQL and lateral selectors

## Notes

- Prefer paraphrasing plus original SQL examples over copying large source text.
- Keep attribution in each pattern file.
- For SQL assertions in tests, prefer case-insensitive keyword checks.
- For lateral/raw SQL examples, follow `patterns/ESCAPE_HATCH_GUIDE.md`.

## Verify Examples

Run all current examples through `Selecto.to_sql/1`:

```bash
elixir scripts/verify_examples.exs
```

## Browse as HTML

Build the static HTML book locally:

```bash
python scripts/build_book_site.py
```

Then open `_site/index.html` in a browser.

This repository also includes a GitHub Pages workflow at
`.github/workflows/deploy-pages.yml` that publishes the generated site from `_site`
when GitHub Pages is available for the repository plan.
