# P003 Descending Keyset Window

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-limit.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: pagination, keyset, descending

## Problem

Page backward from a known `id` anchor using descending keyset semantics.

## SQL

```sql
SELECT o.id, o.order_number, o.total
FROM orders AS o
WHERE o.id < 5000
ORDER BY o.id DESC
LIMIT 20;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "order_number", "total"])
  |> Selecto.filter({"id", {:<, 5000}})
  |> Selecto.order_by({"id", :desc})
  |> Selecto.limit(20)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        where (( selecto_root.id < $1 ))
      
        order by selecto_root.id desc
      
        limit 20
```

**Params:** `[5000]`

## Expected SQL Shape

- includes keyword: `where`
- includes keyword: `<`
- includes keyword: `order by`
- includes keyword: `limit`

## Notes

- For descending keyset paging, use `< anchor` plus `ORDER BY ... DESC`.
- This avoids offset drift on mutable datasets.
