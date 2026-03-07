# W002 Running Total Per Customer

## Metadata

- Source: Structured Query Language (Wikibooks)
- Source URL: https://en.wikibooks.org/wiki/Structured_Query_Language/Window_functions
- Source License: CC BY-SA 4.0
- Dialect: postgres
- Tags: windows, sum, running-total, partition

## Problem

Calculate a running spend total per customer across ordered rows.

## SQL

```sql
SELECT
  o.id,
  o.customer_id,
  o.total,
  SUM(o.total) OVER (
    PARTITION BY o.customer_id
    ORDER BY o.id
  ) AS running_total
FROM orders AS o;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["id", "customer_id", "total"])
  |> Selecto.window_function(:sum, ["total"],
    over: [partition_by: ["customer_id"], order_by: ["id"]],
    as: "running_total"
  )

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `sum`
- includes keyword: `over`
- includes keyword: `order by`

## Notes

- Running totals are row-preserving unlike `GROUP BY` aggregates.
- Uses root fields only, so no additional join resolution is needed.
