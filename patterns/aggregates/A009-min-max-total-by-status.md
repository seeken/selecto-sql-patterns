# A009 Min Max Total By Status

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-agg.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: aggregates, min, max, grouping

## Problem

Compute minimum and maximum order totals for each order status.

## SQL

```sql
SELECT o.status, MIN(o.total) AS min_total, MAX(o.total) AS max_total
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
    {:func, "MIN", ["total"], as: "min_total"},
    {:func, "MAX", ["total"], as: "max_total"}
  ])
  |> Selecto.group_by(["status"])
  |> Selecto.order_by({"status", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.status, MIN(selecto_root.total), MAX(selecto_root.total)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `min`
- includes keyword: `max`
- includes keyword: `group by`

## Notes

- Pairing min/max helps bound value ranges per business state.
- This pattern is useful for anomaly checks and QA dashboards.
