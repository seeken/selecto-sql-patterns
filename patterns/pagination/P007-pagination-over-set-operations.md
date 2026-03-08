# P007 Pagination Over Set Operations

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-union.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: pagination, set-operations, union-all

## Problem

Paginate each source slice, then union them into one ordered view.

## SQL

```sql
(
  SELECT o.order_number, o.total
  FROM orders AS o
  ORDER BY o.order_number ASC
  LIMIT 20 OFFSET 20
)
UNION ALL
(
  SELECT ao.order_number, ao.total
  FROM archived_orders AS ao
  ORDER BY ao.order_number ASC
  LIMIT 20 OFFSET 20
)
ORDER BY order_number ASC;
```

## Selecto

```elixir
current_orders =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "total"])
  |> Selecto.order_by({"order_number", :asc})
  |> Selecto.limit(20)
  |> Selecto.offset(20)

archived_orders =
  Selecto.configure(archived_order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "total"])
  |> Selecto.order_by({"order_number", :asc})
  |> Selecto.limit(20)
  |> Selecto.offset(20)

query =
  Selecto.union(current_orders, archived_orders, all: true)
  |> Selecto.order_by({"order_number", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
(
        select selecto_root.order_number, selecto_root.total
        from orders selecto_root
        order by selecto_root.order_number asc
      
        limit 20
      
        offset 20
      )
UNION ALL
(
        select selecto_root.order_number, selecto_root.total
        from archived_orders selecto_root
        order by selecto_root.order_number asc
      
        limit 20
      
        offset 20
      )
ORDER BY selecto_root.order_number asc, selecto_root.order_number asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `union all`
- includes keyword: `order by`
- includes keyword: `limit`
- includes keyword: `offset`

## Notes

- Applying per-branch windows is a practical fallback when outer set limits are unavailable.
- Useful for timeline views spanning active and archived storage.
