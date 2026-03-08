# A001 Count Orders By Status

## Metadata

- Source: Introduction to SQL
- Source URL: https://github.com/bobbyiliev/introduction-to-sql
- Source License: MIT
- Dialect: postgres
- Tags: aggregates, count, group-by

## Problem

Count how many orders exist in each status bucket.

## SQL

```sql
SELECT o.status, COUNT(*) AS order_count
FROM orders AS o
GROUP BY o.status
ORDER BY o.status ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["status", {:count, "*"}])
  |> Selecto.group_by(["status"])
  |> Selecto.order_by({"status", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.status, count(*)
        from orders selecto_root
        group by selecto_root.status
      
        order by selecto_root.status asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `count`
- includes keyword: `group by`
- includes keyword: `order by`

## Notes

- `{:count, "*"}` uses Selecto's current tuple style for aggregate functions.
- Grouping is explicit and mirrors typical analytics/report SQL.
