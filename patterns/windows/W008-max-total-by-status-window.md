# W008 Max Total By Status Window

## Metadata

- Source: Structured Query Language (Wikibooks)
- Source URL: https://en.wikibooks.org/wiki/Structured_Query_Language/Window_functions
- Source License: CC BY-SA 4.0
- Dialect: postgres
- Tags: windows, max, partition

## Problem

Annotate each order row with the maximum order total in its status partition.

## SQL

```sql
SELECT
  o.order_number,
  o.status,
  o.total,
  MAX(o.total) OVER (PARTITION BY o.status) AS status_max_total
FROM orders AS o;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "status", "total"])
  |> Selecto.window_function(:max, ["total"],
    over: [partition_by: ["status"]],
    as: "status_max_total"
  )

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `max`
- includes keyword: `over`
- includes keyword: `partition by`

## Notes

- Row-preserving partition maxima are useful for top-gap calculations.
- Avoids separate aggregate subqueries when full row context is needed.
