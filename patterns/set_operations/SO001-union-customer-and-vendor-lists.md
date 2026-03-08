# SO001 Union Customer And Vendor Lists

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: set-operations, union, cross-source

## Problem

Combine customer and vendor contact rows into one deduplicated result set.

## SQL

```sql
SELECT c.name, c.tier
FROM customers AS c
UNION
SELECT v.name, v.tier
FROM vendors AS v;
```

## Selecto

```elixir
customers =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "tier"])

vendors =
  Selecto.configure(vendor_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "tier"])

query = Selecto.union(customers, vendors)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
(
        select selecto_root.name, selecto_root.tier
        from customers selecto_root)
UNION
(
        select selecto_root.name, selecto_root.tier
        from vendors selecto_root)
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `union`
- includes keyword: `from customers`
- includes keyword: `from vendors`

## Notes

- `UNION` removes duplicates across the combined result.
- Both sides must project the same number and compatible types of columns.
