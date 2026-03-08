# SO006 Intersect All Premium And Active Customers

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: set-operations, intersect-all, duplicates

## Problem

Find rows that appear in both premium and active customer sets while preserving duplicate intersections.

## SQL

```sql
SELECT pc.id, pc.name
FROM premium_customers AS pc
INTERSECT ALL
SELECT ac.id, ac.name
FROM active_customers AS ac;
```

## Selecto

```elixir
premium_customers =
  Selecto.configure(premium_customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])

active_customers =
  Selecto.configure(active_customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])

query = Selecto.intersect(premium_customers, active_customers, all: true)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
(
        select selecto_root.id, selecto_root.name
        from premium_customers selecto_root)
INTERSECT ALL
(
        select selecto_root.id, selecto_root.name
        from active_customers selecto_root)
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `intersect all`
- includes keyword: `from premium_customers`
- includes keyword: `from active_customers`

## Notes

- `all: true` maps to `INTERSECT ALL`.
- This shape is useful when source sets may contain duplicates and multiset semantics matter.
