# S002 Subquery Join Delivered Orders

## Metadata

- Source: PostgreSQL Exercises
- Source URL: https://github.com/AlisdairO/pgexercises
- Source License: BSD-style
- Dialect: postgres
- Tags: subquery, derived-table, filtering, join

## Problem

Build a filtered orders subquery, then join it to customers for reporting.

## SQL

```sql
SELECT c.name, d.order_number, d.total
FROM customers AS c
LEFT JOIN (
  SELECT o.customer_id, o.order_number, o.total
  FROM orders AS o
  WHERE o.status = 'delivered'
) AS d ON d.customer_id = c.id
ORDER BY c.name ASC;
```

## Selecto

```elixir
delivered_orders =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["customer_id", "order_number", "total"])
  |> Selecto.filter({"status", "delivered"})

query =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.join_subquery(:delivered_orders, delivered_orders,
    type: :left,
    on: [%{left: "id", right: "customer_id"}]
  )
  |> Selecto.select(["name", "delivered_orders.order_number", "delivered_orders.total"])
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `left join (`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- Useful for moving complex filters into a reusable derived table.
- Keeps outer query focused on projection and result shaping.
