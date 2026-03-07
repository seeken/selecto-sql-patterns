# J001 Inner Join Delivered Orders

## Metadata

- Source: Introduction to SQL
- Source URL: https://github.com/bobbyiliev/introduction-to-sql
- Source License: MIT
- Dialect: postgres
- Tags: joins, inner-join, filtering, ordering

## Problem

Return delivered orders with the customer name in one result set.

## SQL

```sql
SELECT o.order_number, c.name AS customer_name
FROM orders AS o
INNER JOIN customers AS c ON c.id = o.customer_id
WHERE o.status = 'delivered'
ORDER BY o.order_number ASC;
```

## Selecto

```elixir
query =
  # see shared config: patterns/joins/DOMAIN_CONFIGURATION.md
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.join(:customer_lookup,
    source: "customers",
    type: :inner,
    on: [%{left: "customer_id", right: "id"}],
    fields: %{
      name: %{type: :string},
      tier: %{type: :string}
    }
  )
  |> Selecto.select(["order_number", "customer_lookup.name"])
  |> Selecto.filter({"status", "delivered"})
  |> Selecto.order_by({"order_number", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `inner join`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- Starts from a shared domain-configured customer relationship, then applies a runtime inner-join override.
- Keeps filters parameterized through Selecto.
