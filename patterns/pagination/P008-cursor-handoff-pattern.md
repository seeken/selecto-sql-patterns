# P008 Cursor Handoff Pattern

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-order.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: pagination, cursor, keyset

## Problem

Resume pagination using a cursor composed of a primary and tie-breaker key.

## SQL

```sql
SELECT o.id, o.order_number, o.total
FROM orders AS o
WHERE o.total < 1000
   OR (o.total = 1000 AND o.id < 500)
ORDER BY o.total DESC, o.id DESC
LIMIT 20;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "order_number", "total"])
  |> Selecto.filter(
    {:or,
     [
       {"total", {:<, 1000}},
       {:and, [{"total", 1000}, {"id", {:<, 500}}]}
     ]}
  )
  |> Selecto.order_by({"total", :desc})
  |> Selecto.order_by({"id", :desc})
  |> Selecto.limit(20)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        where (((( selecto_root.total < $1 ) or ((( selecto_root.total = $2 ) and ( selecto_root.id < $3 ))))))
      
        order by selecto_root.total desc, selecto_root.id desc
      
        limit 20
```

**Params:** `[1000, 1000, 500]`

## Expected SQL Shape

- includes keyword: `where`
- includes keyword: ` or `
- includes keyword: `order by`
- includes keyword: `limit`

## Notes

- Composite cursor predicates preserve deterministic traversal across pages.
- Use this for high-volume feeds where offset pagination is too expensive.
