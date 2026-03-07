# S007 In Subquery Plus Root Filter

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, in, filtering, conjunction, join-subquery

## Problem

Apply a root filter and an `IN` subquery filter in one predicate tree.

## SQL

```sql
SELECT o.order_number, o.customer_id, o.total
FROM orders AS o
WHERE o.status = 'delivered'
  AND o.customer_id IN (
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
  |> Selecto.select(["order_number", "customer_id", "total"])
  |> Selecto.join_subquery(:gold_customers, gold_customers,
    type: :inner,
    on: [%{left: "customer_id", right: "id"}]
  )
  |> Selecto.filter({"gold_customers.id", :not_null})
  |> Selecto.filter({"status", "delivered"})
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `where`
- includes keyword: ` and `
- includes keyword: `inner join`

## Notes

- Demonstrates mixed predicate trees with both root and subquery conditions.
- Uses a join-subquery for the customer slice plus a root-side filter.
- Includes a joined-key `is not null` guard to keep the membership join explicit.
- Useful for reproducing common reporting filters from legacy SQL.
