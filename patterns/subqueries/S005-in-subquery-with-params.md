# S005 In Subquery With Params

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, in, parameters, filtering, join-subquery

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
silver_customers =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id"])
  |> Selecto.filter({"tier", "silver"})

query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "customer_id", "total"])
  |> Selecto.join_subquery(:silver_customers, silver_customers,
    type: :inner,
    on: [%{left: "customer_id", right: "id"}]
  )
  |> Selecto.filter({"silver_customers.id", :not_null})
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.customer_id, selecto_root.total
        from orders selecto_root inner join (
        select selecto_root.id
        from customers selecto_root
        where (( selecto_root.tier = $1 ))
      ) silver_customers on selecto_root.customer_id = silver_customers.id
        where (( silver_customers.id is not null ))
      
        order by selecto_root.total desc
```

**Params:** `["silver"]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `inner join`
- includes keyword: `$1`
- includes keyword: `order by`

## Notes

- Subquery parameters are appended after outer-query parameters in placeholder order.
- Uses a parameterized join-subquery equivalent to `IN (...)` semantics.
- Includes a joined-key `is not null` guard to keep the membership join explicit.
- This approach supports safe migration from hand-written SQL to Selecto.
