# S003 Exists Correlated Filter

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, exists, correlated, filtering, join-subquery

## Problem

Return orders only when a matching gold-tier customer exists.

## SQL

```sql
SELECT o.order_number, o.status, o.total
FROM orders AS o
WHERE EXISTS (
  SELECT 1
  FROM customers AS c
  WHERE c.id = o.customer_id
    AND c.tier = 'gold'
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
  |> Selecto.select(["order_number", "status", "total"])
  |> Selecto.join_subquery(:gold_customers, gold_customers,
    type: :inner,
    on: [%{left: "customer_id", right: "id"}]
  )
  |> Selecto.filter({"gold_customers.id", :not_null})
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
      ) gold_customers on selecto_root.customer_id = gold_customers.id
        where (( gold_customers.id is not null ))
      
        order by selecto_root.total desc
```

**Params:** `["gold"]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `inner join`
- includes keyword: `from customers`
- includes keyword: `order by`

## Notes

- Uses a join-subquery shape equivalent to `EXISTS (...)` semantics without raw SQL.
- Includes a joined-key `is not null` guard to keep the existence join explicit.
- Works well when translating legacy SQL step by step.
