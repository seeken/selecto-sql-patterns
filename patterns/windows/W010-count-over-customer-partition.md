# W010 Count Over Customer Partition

## Metadata

- Source: Structured Query Language (Wikibooks)
- Source URL: https://en.wikibooks.org/wiki/Structured_Query_Language/Window_functions
- Source License: CC BY-SA 4.0
- Dialect: postgres
- Tags: windows, count, partition

## Problem

Annotate each order row with the count of orders in its customer partition.

## SQL

```sql
SELECT
  o.id,
  o.customer_id,
  o.total,
  COUNT(*) OVER (PARTITION BY o.customer_id) AS customer_order_count
FROM orders AS o;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["id", "customer_id", "total"])
  |> Selecto.window_function(:count, ["*"],
    over: [partition_by: ["customer_id"]],
    as: "customer_order_count"
  )

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.customer_id, selecto_root.total, COUNT(*) OVER (PARTITION BY selecto_root.customer_id) AS customer_order_count
        from orders selecto_root
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `count`
- includes keyword: `over`
- includes keyword: `partition by`

## Notes

- Window counts preserve each row while adding per-partition volume.
- This is useful for density-aware scoring and UI badges.
