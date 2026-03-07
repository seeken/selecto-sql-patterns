# W004 Dense Rank By Total

## Metadata

- Source: Structured Query Language (Wikibooks)
- Source URL: https://en.wikibooks.org/wiki/Structured_Query_Language/Window_functions
- Source License: CC BY-SA 4.0
- Dialect: postgres
- Tags: windows, dense-rank, ordering

## Problem

Rank orders by total value without gaps in rank numbering.

## SQL

```sql
SELECT
  o.order_number,
  o.total,
  DENSE_RANK() OVER (ORDER BY o.total DESC) AS total_rank
FROM orders AS o;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "total"])
  |> Selecto.window_function(:dense_rank, [],
    over: [order_by: [{"total", :desc}]],
    as: "total_rank"
  )

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `dense_rank`
- includes keyword: `over`
- includes keyword: `order by`

## Notes

- `DENSE_RANK` avoids rank gaps when ties occur.
- Good fit for leaderboard-style reporting.
