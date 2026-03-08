# F002 Grouped AND/OR Predicates

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-logical.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: filtering, boolean-logic, and, or

## Problem

Find orders in processing/shipped states that are also above a minimum total amount.

## SQL

```sql
SELECT o.order_number, o.status, o.total
FROM orders AS o
WHERE (o.status = 'processing' OR o.status = 'shipped')
  AND o.total > 100
ORDER BY o.total DESC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "status", "total"])
  |> Selecto.filter(
    {:and,
     [
       {:or, [{"status", "processing"}, {"status", "shipped"}]},
       {"total", {:>, 100}}
     ]}
  )
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (((((( selecto_root.status = $1 ) or ( selecto_root.status = $2 ))) and ( selecto_root.total > $3 ))))
      
        order by selecto_root.total desc
```

**Params:** `["processing", "shipped", 100]`

## Expected SQL Shape

- includes keyword: `where`
- includes keyword: ` and `
- includes keyword: ` or `
- includes keyword: `order by`

## Notes

- Nested boolean logic uses explicit `{:and, [...]}` and `{:or, [...]}` tuples.
- This keeps SQL grouping predictable for non-trivial predicates.
