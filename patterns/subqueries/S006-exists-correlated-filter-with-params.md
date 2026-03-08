# S006 Exists Correlated Filter With Params

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, exists, correlated, parameters, join-subquery

## Problem

Use a correlated `EXISTS` subquery with bind parameters.

## SQL

```sql
SELECT o.order_number, o.status, o.total
FROM orders AS o
WHERE EXISTS (
  SELECT 1
  FROM customers AS c
  WHERE c.id = o.customer_id
    AND c.tier = $1
)
ORDER BY o.total DESC;
```

## Selecto

```elixir
customers_by_tier =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id"])
  |> Selecto.filter({"tier", "gold"})

query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "status", "total"])
  |> Selecto.join_subquery(:customers_by_tier, customers_by_tier,
    type: :inner,
    on: [%{left: "customer_id", right: "id"}]
  )
  |> Selecto.filter({"customers_by_tier.id", :not_null})
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.status, selecto_root.total
        from orders selecto_root inner join (
        select selecto_root.id
        from customers selecto_root
        where (( selecto_root.tier = $1 ))
      ) customers_by_tier on selecto_root.customer_id = customers_by_tier.id
        where (( customers_by_tier.id is not null ))
      
        order by selecto_root.total desc
```

**Params:** `["gold"]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `inner join`
- includes keyword: `$1`
- includes keyword: `order by`

## Notes

- Uses a parameterized join-subquery equivalent to `EXISTS (...)` semantics.
- Includes a joined-key `is not null` guard to keep the existence join explicit.
- Parameters from the subquery are appended to the final params list.
