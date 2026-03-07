# W005 Moving Average Total

## Metadata

- Source: Structured Query Language (Wikibooks)
- Source URL: https://en.wikibooks.org/wiki/Structured_Query_Language/Window_functions
- Source License: CC BY-SA 4.0
- Dialect: postgres
- Tags: windows, moving-average, frame, avg

## Problem

Compute a running moving average of order totals.

## SQL

```sql
SELECT
  o.id,
  o.total,
  AVG(o.total) OVER (
    ORDER BY o.id
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
  ) AS moving_avg_total
FROM orders AS o;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "total"])
  |> Selecto.window_function(:avg, ["total"],
    over: [
      order_by: ["id"],
      frame: {:rows, :unbounded_preceding, :current_row}
    ],
    as: "moving_avg_total"
  )

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `avg`
- includes keyword: `rows between`
- includes keyword: `current row`

## Notes

- Frame configuration controls exactly which prior rows are included.
- This pattern is useful for smoothing noisy series.
