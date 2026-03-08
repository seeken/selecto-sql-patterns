# P006 Deterministic Pagination With Tie-Breakers

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-order.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: pagination, deterministic, tie-breaker

## Problem

Paginate rows by a primary sort key with a deterministic secondary tie-breaker.

## SQL

```sql
SELECT o.id, o.order_number, o.total
FROM orders AS o
ORDER BY o.total DESC, o.id DESC
LIMIT 20 OFFSET 40;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "order_number", "total"])
  |> Selecto.order_by({"total", :desc})
  |> Selecto.order_by({"id", :desc})
  |> Selecto.limit(20)
  |> Selecto.offset(40)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        order by selecto_root.total desc, selecto_root.id desc
      
        limit 20
      
        offset 40
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `order by`
- includes keyword: `desc`
- includes keyword: `limit`
- includes keyword: `offset`

## Notes

- Add a stable secondary key to avoid page jitter on ties.
- This pattern is essential for repeatable exports and infinite scroll.
