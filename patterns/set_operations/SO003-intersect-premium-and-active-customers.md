# SO003 Intersect Premium And Active Customers

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: set-operations, intersect

## Problem

Find customers that appear in both premium and active customer sets.

## SQL

```sql
SELECT pc.id, pc.name
FROM premium_customers AS pc
INTERSECT
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

query = Selecto.intersect(premium_customers, active_customers)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
(
        select selecto_root.id, selecto_root.name
        from premium_customers selecto_root)
INTERSECT
(
        select selecto_root.id, selecto_root.name
        from active_customers selecto_root)
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `intersect`
- includes keyword: `from premium_customers`
- includes keyword: `from active_customers`

## Notes

- `INTERSECT` returns only rows present in both inputs.
- Projection alignment rules match `UNION`/`EXCEPT` requirements.
