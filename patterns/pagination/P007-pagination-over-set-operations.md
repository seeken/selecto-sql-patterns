# P007 Pagination Over Set Operations

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-union.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: pagination, set-operations, union-all

## Problem

Paginate a combined active+archived feed after unioning both sources.

## SQL

```sql
(
  SELECT o.order_number, o.total
  FROM orders AS o
)
UNION ALL
(
  SELECT ao.order_number, ao.total
  FROM archived_orders AS ao
)
ORDER BY order_number ASC
LIMIT 20 OFFSET 20;
```

## Selecto

```elixir
current_orders =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "total"])

archived_orders =
  Selecto.configure(archived_order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "total"])

query =
  Selecto.union(current_orders, archived_orders, all: true)
  |> Selecto.order_by({"order_number", :asc})
  |> Selecto.limit(20)
  |> Selecto.offset(20)

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
ORDER BY selecto_root.order_number asc
LIMIT 20
OFFSET 20
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `union all`
- includes keyword: `order by`
- includes keyword: `limit`
- includes keyword: `offset`

## Notes

- Pagination now applies on the merged set result (outer `ORDER BY/LIMIT/OFFSET`).
- Useful for timeline views spanning active and archived storage.
