# selecto-sql-patterns

Open-source SQL examples rebuilt as Selecto patterns.

This repository is a working set of query patterns we can reuse for docs, tests,
and regression checks across the Selecto ecosystem.

> Disclaimer: This project is actively in progress and is being used to refine
> the Selecto interface. Patterns and APIs may evolve as that work continues.

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
- Set operations
- Filtering and predicate logic
- Pagination
- JSON and array
- Query shaping
- Time-series
- Geospatial

## Repository Layout

- `attribution/sources.md` source list and license notes
- `patterns/` query patterns grouped by topic
- `patterns/EXPRESSION_DSL_GUIDE.md` guidance for using `Selecto.Expr` and macro-based examples
- `patterns/_template.md` pattern authoring template
- `patterns/joins/DOMAIN_CONFIGURATION.md` shared domain setup for join-focused examples
- `patterns/ESCAPE_HATCH_GUIDE.md` rules for lateral/raw SQL escape-hatch patterns
- `CATALOG.md` high-level tracking for planned pattern coverage
- `scripts/verify_examples.exs` runs `Selecto.to_sql/1` for every published pattern example

## Notes

- Prefer paraphrasing plus original SQL examples over copying large source text.
- Keep attribution in each pattern file.
- For SQL assertions in tests, prefer case-insensitive keyword checks.
- For lateral/raw SQL examples, follow `patterns/ESCAPE_HATCH_GUIDE.md`.
- Prefer `Selecto.Expr` and `Selecto.ExprMacros` in new examples when they make patterns easier to read.

## Verify Examples

Run all current examples through `Selecto.to_sql/1` for PostgreSQL and SQLite:

```bash
elixir scripts/verify_examples.exs
```

Export yielded SQL for all examples:

```bash
elixir scripts/verify_examples.exs --dump-sql patterns/SELECTO_YIELDED_SQL.md
```

Export the adapter matrix consumed by the site toggle:

```bash
elixir scripts/verify_examples.exs --dump-adapter-json patterns/SELECTO_ADAPTER_OUTPUTS.json
```

Export the Expr examples consumed by the site command-mode toggle:

```bash
elixir scripts/verify_examples.exs --dump-expr-json patterns/SELECTO_EXPR_EXAMPLES.json
```

Sync the pattern markdown files so each one includes a `## Selecto Expr` section:

```bash
python scripts/sync_expr_sections.py
```

## Browse as HTML

Build the static HTML book locally:

```bash
python scripts/build_book_site.py
```

Then open `_site/index.html` in a browser.

Each pattern page keeps the original SQL visible and adds adapter switchers for
PostgreSQL and SQLite, plus a command-mode toggle for classic vs Expr Selecto examples.

This repository also includes a GitHub Pages workflow at
`.github/workflows/deploy-pages.yml` that publishes the generated site from `_site`
when GitHub Pages is available for the repository plan.
