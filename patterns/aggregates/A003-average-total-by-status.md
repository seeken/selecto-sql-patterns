# A003 Average Total By Status

## Metadata

- Source: Introduction to SQL
- Source URL: https://github.com/bobbyiliev/introduction-to-sql
- Source License: MIT
- Dialect: postgres
- Tags: aggregates, avg, group-by

## Problem

Compute average order value for each order status.

## SQL

```sql
SELECT o.status, AVG(o.total) AS avg_total
FROM orders AS o
GROUP BY o.status
ORDER BY o.status ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["status", {:func, "AVG", ["total"], as: "avg_total"}])
  |> Selecto.group_by(["status"])
  |> Selecto.order_by({"status", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `avg`
- includes keyword: `group by`
- includes keyword: `order by`

## Notes

- Uses explicit function selector to retain output alias (`avg_total`).
- Works as a base metric for trend and anomaly checks.
