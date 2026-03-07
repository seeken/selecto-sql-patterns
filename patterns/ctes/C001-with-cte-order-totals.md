# C001 With CTE Order Totals

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: cte, with, joins, reusable-query

## Problem

Create a reusable CTE for order totals, then auto-join it to the root query.

## SQL

```sql
WITH order_totals (id, total) AS (
  SELECT o.id, o.total
  FROM orders AS o
  WHERE o.status = 'delivered'
)
SELECT o.order_number, ot.total
FROM orders AS o
LEFT JOIN order_totals AS ot ON ot.id = o.id;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.with_cte(
    "order_totals",
    fn ->
      Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
      |> Selecto.select(["id", "total"])
      |> Selecto.filter({"status", "delivered"})
    end,
    columns: ["id", "total"],
    join: true
  )
  |> Selecto.select(["order_number", "order_totals.total"])

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `with`
- includes keyword: `select`
- includes keyword: `left join`
- includes keyword: `where`

## Notes

- `join: true` infers join keys/fields from the declared CTE columns.
- CTE SQL remains parameterized when filters are present.
