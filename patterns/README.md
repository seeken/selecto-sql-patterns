# Patterns

Each pattern lives in a category directory and follows the template in
`patterns/_template.md`.

For raw SQL and lateral join examples, follow `patterns/ESCAPE_HATCH_GUIDE.md`.
Prefer non-escape Selecto patterns whenever equivalent semantics are available.
Join examples share domain setup in `patterns/joins/DOMAIN_CONFIGURATION.md`.
All generated SQL output snapshots are in `patterns/SELECTO_YIELDED_SQL.md`.
Each pattern file includes a `Selecto Yielded SQL` section generated from `Selecto.to_sql/1`.

## Categories

- `joins/`
- `aggregates/`
- `windows/`
- `subqueries/`
- `ctes/`
- `set_operations/`
