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
- `CATALOG.md` high-level tracking for planned pattern coverage
- `scripts/verify_examples.exs` runs `Selecto.to_sql/1` for every published pattern example

## Notes

- Prefer paraphrasing plus original SQL examples over copying large source text.
- Keep attribution in each pattern file.
- For SQL assertions in tests, prefer case-insensitive keyword checks.

## Verify Examples

Run all current examples through `Selecto.to_sql/1`:

```bash
elixir scripts/verify_examples.exs
```
