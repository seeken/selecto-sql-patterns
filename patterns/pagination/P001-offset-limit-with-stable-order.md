# P001 Offset/Limit With Stable Order

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-limit.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: pagination, limit, offset, ordering

## Problem

Fetch page 3 of an order list using deterministic row ordering.

## SQL

```sql
SELECT o.id, o.order_number, o.total
FROM orders AS o
ORDER BY o.id ASC
LIMIT 25 OFFSET 50;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "order_number", "total"])
  |> Selecto.order_by({"id", :asc})
  |> Selecto.limit(25)
  |> Selecto.offset(50)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        order by selecto_root.id asc
      
        limit 25
      
        offset 50
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `order by`
- includes keyword: `limit`
- includes keyword: `offset`
- includes keyword: `from orders`

## Notes

- Always pair `LIMIT/OFFSET` with a stable `ORDER BY`.
- Offset pagination is simple but can degrade on large offsets.
