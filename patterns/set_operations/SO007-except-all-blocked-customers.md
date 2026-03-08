# SO007 Except All Blocked Customers

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: set-operations, except-all, duplicates

## Problem

Return customer rows minus blocked rows while preserving duplicate subtraction behavior.

## SQL

```sql
SELECT c.id, c.name
FROM customers AS c
EXCEPT ALL
SELECT bc.id, bc.name
FROM blocked_customers AS bc;
```

## Selecto

```elixir
all_customers =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])

blocked_customers =
  Selecto.configure(blocked_customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])

query = Selecto.except(all_customers, blocked_customers, all: true)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
(
        select selecto_root.id, selecto_root.name
        from customers selecto_root)
EXCEPT ALL
(
        select selecto_root.id, selecto_root.name
        from blocked_customers selecto_root)
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `except all`
- includes keyword: `from customers`
- includes keyword: `from blocked_customers`

## Notes

- `all: true` maps to `EXCEPT ALL`.
- Use this when duplicate counts are meaningful in set subtraction workflows.
