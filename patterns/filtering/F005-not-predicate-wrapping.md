# F005 NOT Predicate Wrapping

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-logical.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: filtering, not, boolean-logic

## Problem

Exclude cancelled orders while keeping a minimum total threshold.

## SQL

```sql
SELECT o.order_number, o.status, o.total
FROM orders AS o
WHERE NOT (o.status = 'cancelled')
  AND o.total > 50
ORDER BY o.total DESC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "status", "total"])
  |> Selecto.filter({:not, {"status", "cancelled"}})
  |> Selecto.filter({"total", {:>, 50}})
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root
        where ((not (  selecto_root.status = $1  ) ) and ( selecto_root.total > $2 ))
      
        order by selecto_root.total desc
```

**Params:** `["cancelled", 50]`

## Expected SQL Shape

- includes keyword: `not (`
- includes keyword: `where`
- includes keyword: `>`
- includes keyword: `order by`

## Notes

- Wrap individual predicates with `{:not, predicate}` for explicit negation.
- Keep additional filters separate to preserve readability.
