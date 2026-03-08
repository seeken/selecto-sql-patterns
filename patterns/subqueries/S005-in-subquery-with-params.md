# S005 In Subquery With Params

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, in, parameters, filtering

## Problem

Use a parameterized `IN` subquery to filter orders by customer tier.

## SQL

```sql
SELECT o.order_number, o.customer_id, o.total
FROM orders AS o
WHERE o.customer_id IN (
  SELECT c.id
  FROM customers AS c
  WHERE c.tier = $1
)
ORDER BY o.total DESC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "customer_id", "total"])
  |> Selecto.filter({"customer_id", {:subquery, :in, "SELECT id FROM customers WHERE tier = $1", ["silver"]}})
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (SELECT id FROM customers WHERE tier = $1) ))
      
        order by selecto_root.total desc
```

**Params:** `["silver"]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `in (`
- includes keyword: `$1`
- includes keyword: `order by`

## Notes

- Subquery parameters are appended after outer-query parameters in placeholder order.
- Uses Selecto's native parameterized `{:subquery, :in, ...}` predicate.
- This approach supports safe migration from hand-written SQL to Selecto.
