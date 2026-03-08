# SO002 Union All Current And Archived Orders

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: set-operations, union-all, archival

## Problem

Combine current and archived order rows while preserving duplicates.

## SQL

```sql
SELECT o.order_number, o.total
FROM orders AS o
UNION ALL
SELECT ao.order_number, ao.total
FROM archived_orders AS ao;
```

## Selecto

```elixir
current_orders =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "total"])

archived_orders =
  Selecto.configure(archived_order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "total"])

query = Selecto.union(current_orders, archived_orders, all: true)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
(
        select selecto_root.order_number, selecto_root.total
        from orders selecto_root)
UNION ALL
(
        select selecto_root.order_number, selecto_root.total
        from archived_orders selecto_root)
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `union all`
- includes keyword: `from orders`
- includes keyword: `from archived_orders`

## Notes

- `all: true` maps to `UNION ALL` and avoids duplicate-elimination overhead.
- This shape is useful for time-partitioned archival tables.
