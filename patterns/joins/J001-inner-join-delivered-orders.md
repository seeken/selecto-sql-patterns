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

Shared domain configuration: [Join Domain Configuration](./DOMAIN_CONFIGURATION.md).

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "customer.name"])
  |> Selecto.filter({"customer.id", :not_null})
  |> Selecto.filter({"status", "delivered"})
  |> Selecto.order_by({"order_number", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `left join`
- includes keyword: `is not null`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- Uses the domain-configured customer join and an `IS NOT NULL` guard for inner-join equivalent semantics.
- Keeps filters parameterized through Selecto.

## References

- [Join Domain Configuration](./DOMAIN_CONFIGURATION.md)
