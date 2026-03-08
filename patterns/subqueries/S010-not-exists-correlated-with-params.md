# S010 Not Exists Correlated With Params

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, not-exists, correlated, params

## Problem

Keep processing orders while excluding rows whose customers match a disallowed tier.

## SQL

```sql
SELECT o.order_number, o.customer_id, o.total
FROM orders AS o
WHERE o.status = 'processing'
  AND NOT EXISTS (
    SELECT 1
    FROM customers AS c
    WHERE c.id = o.customer_id
      AND c.tier = 'suspended'
  )
ORDER BY o.total DESC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "customer_id", "total"])
  |> Selecto.filter({"status", "processing"})
  |> Selecto.filter({
    :not,
    {:exists, "SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = $1", ["suspended"]}
  })
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.status = $1 ) and (not (  exists (SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = $2)  ) ))
      
        order by selecto_root.total desc
```

**Params:** `["processing", "suspended"]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `not (`
- includes keyword: `exists (`
- includes keyword: `$1`

## Notes

- Wrapping `EXISTS` in `:not` provides a clear anti-correlation pattern.
- Parameterized inner predicates keep this shape reusable.
