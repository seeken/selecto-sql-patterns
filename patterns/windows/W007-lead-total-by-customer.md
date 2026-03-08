# W007 Lead Total By Customer

## Metadata

- Source: Structured Query Language (Wikibooks)
- Source URL: https://en.wikibooks.org/wiki/Structured_Query_Language/Window_functions
- Source License: CC BY-SA 4.0
- Dialect: postgres
- Tags: windows, lead, partition, ordering

## Problem

Return each order with the next order total for the same customer.

## SQL

```sql
SELECT
  o.id,
  o.customer_id,
  o.total,
  LEAD(o.total, 1) OVER (
    PARTITION BY o.customer_id
    ORDER BY o.id
  ) AS next_total
FROM orders AS o;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["id", "customer_id", "total"])
  |> Selecto.window_function(:lead, ["total", 1],
    over: [partition_by: ["customer_id"], order_by: ["id"]],
    as: "next_total"
  )

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, LEAD(selecto_root.total) OVER (PARTITION BY selecto_root.customer_id ORDER BY selecto_root.id ASC) AS next_total
        from orders selecto_root
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `lead`
- includes keyword: `over`
- includes keyword: `partition by`

## Notes

- Complements `LAG` for forward-looking comparisons.
- Useful in forecasting and sequence validation logic.
