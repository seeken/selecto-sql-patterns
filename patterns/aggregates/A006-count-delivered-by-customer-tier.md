# A006 Count Delivered By Customer Tier

## Metadata

- Source: Database Design - 2nd Edition
- Source URL: https://opentextbc.ca/dbdesign01/
- Source License: CC BY 4.0
- Dialect: postgres
- Tags: aggregates, count, joins, filtering

## Problem

Count delivered orders by customer tier.

## SQL

```sql
SELECT c.tier, COUNT(*) AS delivered_orders
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id
WHERE o.status = 'delivered'
GROUP BY c.tier
ORDER BY c.tier ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["customer.tier", {:count, "*"}])
  |> Selecto.filter({"status", "delivered"})
  |> Selecto.group_by(["customer.tier"])
  |> Selecto.order_by({"customer.tier", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `count`
- includes keyword: `where`
- includes keyword: `group by`

## Notes

- Combines root-side filtering with joined dimension aggregation.
- Useful for fulfillment/operations summaries.
