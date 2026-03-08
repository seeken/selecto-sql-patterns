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

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.tier, high_value_delivered.order_number, high_value_delivered.total
        from customers selecto_root inner join (
        select selecto_root.customer_id, selecto_root.order_number, selecto_root.total
        from orders selecto_root
        where (((( selecto_root.status = $1 ) and ( selecto_root.total > $2 ))))
      ) high_value_delivered on selecto_root.id = high_value_delivered.customer_id
```

**Params:** `["delivered", 1000]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `inner join`
- includes keyword: `from (`
- includes keyword: `where`

## Notes

- This pattern keeps aggregate or pre-filter logic isolated in a reusable subquery.
- Subquery parameters remain parameterized when merged into outer SQL.
