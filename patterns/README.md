# Patterns

Each pattern lives in a category directory and follows the template in
`patterns/_template.md`.

For raw SQL and lateral join examples, follow `patterns/ESCAPE_HATCH_GUIDE.md`.
Prefer non-escape Selecto patterns whenever equivalent semantics are available.
Join examples share domain setup in `patterns/joins/DOMAIN_CONFIGURATION.md`.
All generated SQL output snapshots are in `patterns/SELECTO_YIELDED_SQL.md`.
Each pattern file includes a `Selecto Yielded SQL` section generated from `Selecto.to_sql/1`.

Companion guides live alongside the query patterns for capability areas that are
not best expressed as one SQL query shape.

## Categories

- `joins/`
- `aggregates/`
- `expressions/`
- `windows/`
- `subqueries/`
- `ctes/`
- `set_operations/`
- `filtering/`
- `pagination/`
- `json_arrays/`
- `query_shaping/`
- `time_series/`
- `cohort_analysis/`
- `geospatial/`

## Companion Guides

- `EXPRESSION_DSL_GUIDE.md`
- `ESCAPE_HATCH_GUIDE.md`
- `VIEW_BACKED_DOMAINS_GUIDE.md`
- `PUBLISHED_VIEWS_GUIDE.md`
- `OVERLAY_DSL_GUIDE.md`
- `PORTABLE_WRITES_GUIDE.md`
