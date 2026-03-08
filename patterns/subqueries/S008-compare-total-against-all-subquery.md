# S008 Compare Total Against ALL Subquery

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-subquery.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: subquery, all, comparison

## Problem

Find orders whose total is greater than every total in a comparison subset.

## SQL

```sql
SELECT o.order_number, o.status, o.total
FROM orders AS o
WHERE o.total > ALL (
  SELECT i.total
  FROM orders AS i
  WHERE i.status = 'returned'
)
ORDER BY o.total DESC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "status", "total"])
  |> Selecto.filter(
    {"total", :>, {:subquery, :all, "SELECT total FROM orders WHERE status = 'returned'", []}}
  )
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.total > all (SELECT total FROM orders WHERE status = 'returned') ))
      
        order by selecto_root.total desc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: ` all (`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- `ALL` compares against every row produced by the subquery.
- This pattern is useful for outlier detection and threshold checks.
