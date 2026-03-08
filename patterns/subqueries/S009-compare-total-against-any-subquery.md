# S009 Compare Total Against ANY Subquery

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-subquery.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: subquery, any, comparison

## Problem

Find orders whose total is below at least one reference total from delivered orders.

## SQL

```sql
SELECT o.order_number, o.status, o.total
FROM orders AS o
WHERE o.total < ANY (
  SELECT i.total
  FROM orders AS i
  WHERE i.status = 'delivered'
)
ORDER BY o.total ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "status", "total"])
  |> Selecto.filter(
    {"total", :<, {:subquery, :any, "SELECT total FROM orders WHERE status = 'delivered'", []}}
  )
  |> Selecto.order_by({"total", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.total < any (SELECT total FROM orders WHERE status = 'delivered') ))
      
        order by selecto_root.total asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: ` any (`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- `ANY` compares against at least one row from the subquery.
- Useful for relative comparisons without hardcoded thresholds.
