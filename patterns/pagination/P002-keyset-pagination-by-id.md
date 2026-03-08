# P002 Keyset Pagination By ID

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-limit.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: pagination, keyset, seek, id

## Problem

Fetch the next page after a known `id` anchor using keyset pagination.

## SQL

```sql
SELECT o.id, o.order_number, o.total
FROM orders AS o
WHERE o.id > 1000
ORDER BY o.id ASC
LIMIT 25;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "order_number", "total"])
  |> Selecto.filter({"id", {:>, 1000}})
  |> Selecto.order_by({"id", :asc})
  |> Selecto.limit(25)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        where (( selecto_root.id > $1 ))
      
        order by selecto_root.id asc
      
        limit 25
```

**Params:** `[1000]`

## Expected SQL Shape

- includes keyword: `where`
- includes keyword: `>`
- includes keyword: `order by`
- includes keyword: `limit`

## Notes

- Keyset pagination scales better than large offsets.
- The anchor predicate must match the ordering column(s).
