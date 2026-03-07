# W003 Lag Total By Customer

## Metadata

- Source: Structured Query Language (Wikibooks)
- Source URL: https://en.wikibooks.org/wiki/Structured_Query_Language/Window_functions
- Source License: CC BY-SA 4.0
- Dialect: postgres
- Tags: windows, lag, partition, ordering

## Problem

Return each order with the previous order total for the same customer.

## SQL

```sql
SELECT
  o.id,
  o.customer_id,
  o.total,
  LAG(o.total, 1) OVER (
    PARTITION BY o.customer_id
    ORDER BY o.id
  ) AS prev_total
FROM orders AS o;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["id", "customer_id", "total"])
  |> Selecto.window_function(:lag, ["total", 1],
    over: [partition_by: ["customer_id"], order_by: ["id"]],
    as: "prev_total"
  )

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `lag`
- includes keyword: `over`
- includes keyword: `partition by`

## Notes

- Useful for change-detection logic and deltas between sequential events.
- Keeps row-level detail while adding comparative context.
