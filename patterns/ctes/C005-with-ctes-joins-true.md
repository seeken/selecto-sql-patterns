# C005 With CTEs Joins True

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: cte, with, auto-join, inferred-keys

## Problem

Attach a CTE and rely on automatic join inference with `joins: true`.

## SQL

```sql
WITH order_totals (id, total) AS (
  SELECT o.id, o.total
  FROM orders AS o
)
SELECT o.order_number, ot.total
FROM orders AS o
LEFT JOIN order_totals AS ot ON ot.id = o.id;
```

## Selecto

```elixir
order_totals_cte =
  Selecto.Advanced.CTE.create_cte(
    "order_totals",
    fn ->
      Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
      |> Selecto.select(["id", "total"])
    end,
    columns: ["id", "total"]
  )

query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.with_ctes([order_totals_cte], joins: true)
  |> Selecto.select(["order_number", "order_totals.total"])

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `with`
- includes keyword: `left join`
- includes keyword: `order_totals`
- includes keyword: `select`

## Notes

- `joins: true` infers join keys from declared CTE columns and root schema.
- Keeps CTE wiring concise when naming conventions are consistent.
