# S001 IN Subquery Filter

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, in, filtering

## Problem

Filter orders so only customers in the `gold` tier remain.

## SQL

```sql
SELECT o.order_number, o.customer_id, o.status, o.total
FROM orders AS o
WHERE o.customer_id IN (
  SELECT c.id
  FROM customers AS c
  WHERE c.tier = 'gold'
)
ORDER BY o.total DESC;
```

## Selecto

```elixir
gold_customers =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id"])
  |> Selecto.filter({"tier", "gold"})

query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "customer_id", "status", "total"])
  |> Selecto.filter({"customer_id", {:subquery, :in, gold_customers}})
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.status, selecto_root.total
        from orders selecto_root
        where (( selecto_root.customer_id in (
        select selecto_root.id
        from customers selecto_root
        where (( selecto_root.tier = $1 ))
      ) ))
      
        order by selecto_root.total desc
```

**Params:** `["gold"]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `in (`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- Uses a fully constructed Selecto query as the `IN` subquery source.
- This pattern is useful for migrating existing hand-written SQL incrementally.
