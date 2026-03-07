# J007 Lateral Join Delivered Order Count

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: joins, lateral-join, subquery, correlated, escape-hatch

## Problem

Attach a per-row lateral subquery result (delivered order count) beside each product.

## SQL

```sql
SELECT p.name, s.delivered_order_count
FROM products AS p
LEFT JOIN LATERAL (
  SELECT COUNT(*) AS delivered_order_count
  FROM orders AS o
  WHERE o.status = 'delivered'
) AS s ON TRUE;
```

## Selecto

```elixir
alias SelectoSqlPatterns.EscapeHatchHelpers, as: EscapeHatch

subquery_query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select([{:count, "*"}])
  |> Selecto.filter({"status", "delivered"})

query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select([
    "name",
    EscapeHatch.lateral_alias_field("delivered_stats", "count", "delivered_order_count")
  ])
  |> Selecto.lateral_join(:left, fn _ -> subquery_query end, "delivered_stats")

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `left join lateral`
- includes keyword: `count`
- includes keyword: `where`

## Notes

- Uses `LATERAL` for subqueries that can be attached as join-time projections.
- Keeps raw selector usage centralized in a helper module.
- Keeps subquery parameters in global placeholder order.
