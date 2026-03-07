# A007 Sum And Count By Status

## Metadata

- Source: Introduction to SQL
- Source URL: https://github.com/bobbyiliev/introduction-to-sql
- Source License: MIT
- Dialect: postgres
- Tags: aggregates, sum, count, group-by

## Problem

Return total revenue and row count per order status.

## SQL

```sql
SELECT
  o.status,
  SUM(o.total) AS total_amount,
  COUNT(*) AS row_count
FROM orders AS o
GROUP BY o.status
ORDER BY o.status ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select([
    "status",
    {:func, "SUM", ["total"], as: "total_amount"},
    {:count, "*"}
  ])
  |> Selecto.group_by(["status"])
  |> Selecto.order_by({"status", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `sum`
- includes keyword: `count`
- includes keyword: `group by`

## Notes

- Combines two aggregate views in one grouped query.
- Useful as a compact status KPI summary.
