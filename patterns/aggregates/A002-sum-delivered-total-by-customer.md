# A002 Sum Delivered Total By Customer

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: aggregates, sum, group-by, filtering

## Problem

Compute delivered revenue per customer.

## SQL

```sql
SELECT o.customer_id, SUM(o.total) AS total_spend
FROM orders AS o
WHERE o.status = 'delivered'
GROUP BY o.customer_id
ORDER BY o.customer_id ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["customer_id", {:func, "SUM", ["total"], as: "total_spend"}])
  |> Selecto.filter({"status", "delivered"})
  |> Selecto.group_by(["customer_id"])
  |> Selecto.order_by({"customer_id", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `sum`
- includes keyword: `where`
- includes keyword: `group by`

## Notes

- Keeps the aggregate alias (`total_spend`) for downstream joins or CTE reuse.
- Uses the joined-order domain so `customer_id` exists on the root schema.
