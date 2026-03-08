# SO005 Chained Union Plus Intersect

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: set-operations, union, intersect, chaining

## Problem

Build a staged set operation: union premium and active customers, then keep only rows that are present in the full customer table.

## SQL

```sql
(
  SELECT pc.id, pc.name
  FROM premium_customers AS pc
  UNION
  SELECT ac.id, ac.name
  FROM active_customers AS ac
)
INTERSECT
SELECT c.id, c.name
FROM customers AS c;
```

## Selecto

```elixir
premium_customers =
  Selecto.configure(premium_customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])

active_customers =
  Selecto.configure(active_customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])

all_customers =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])

premium_or_active = Selecto.union(premium_customers, active_customers)
query = Selecto.intersect(premium_or_active, all_customers)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
((
        select selecto_root.id, selecto_root.name
        from premium_customers selecto_root)
UNION
(
        select selecto_root.id, selecto_root.name
        from active_customers selecto_root))
INTERSECT
(
        select selecto_root.id, selecto_root.name
        from customers selecto_root)
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `union`
- includes keyword: `intersect`
- includes keyword: `from premium_customers`
- includes keyword: `from customers`

## Notes

- Chaining set operators lets you model multi-step set logic without raw SQL.
- Keep projection columns aligned on every branch of the set expression.
