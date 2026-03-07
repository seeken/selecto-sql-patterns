# J003 Join Subquery High Value Orders

## Metadata

- Source: PostgreSQL Exercises
- Source URL: https://github.com/AlisdairO/pgexercises
- Source License: BSD-style
- Dialect: postgres
- Tags: joins, derived-table, join-subquery, filtering

## Problem

Join customers to a filtered order subquery so we only see high-value delivered orders.

## SQL

```sql
SELECT c.name, c.tier, h.order_number, h.total
FROM customers AS c
INNER JOIN (
  SELECT o.customer_id, o.order_number, o.total
  FROM orders AS o
  WHERE o.status = 'delivered' AND o.total > 1000
) AS h ON c.id = h.customer_id
ORDER BY h.total DESC;
```

## Selecto

```elixir
high_value_delivered_orders =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["customer_id", "order_number", "total"])
  |> Selecto.filter({:and, [{"status", "delivered"}, {"total", {:>, 1000}}]})

query =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.join_subquery(:high_value_delivered, high_value_delivered_orders,
    type: :inner,
    on: [%{left: "id", right: "customer_id"}]
  )
  |> Selecto.select(["name", "tier", "high_value_delivered.order_number", "high_value_delivered.total"])

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `inner join`
- includes keyword: `from (`
- includes keyword: `where`

## Notes

- This pattern keeps aggregate or pre-filter logic isolated in a reusable subquery.
- Subquery parameters remain parameterized when merged into outer SQL.
