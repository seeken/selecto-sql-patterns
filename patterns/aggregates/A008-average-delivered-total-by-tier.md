# A008 Average Delivered Total By Tier

## Metadata

- Source: Database Design - 2nd Edition
- Source URL: https://opentextbc.ca/dbdesign01/
- Source License: CC BY 4.0
- Dialect: postgres
- Tags: aggregates, avg, joins, filtering

## Problem

Compute the average delivered order value per customer tier.

## SQL

```sql
SELECT c.tier, AVG(o.total) AS avg_delivered_total
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
  |> Selecto.select(["customer.tier", {:func, "AVG", ["total"], as: "avg_delivered_total"}])
  |> Selecto.filter({"status", "delivered"})
  |> Selecto.group_by(["customer.tier"])
  |> Selecto.order_by({"customer.tier", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select customer.tier, AVG(selecto_root.total)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( selecto_root.status = $1 ))
      
        group by customer.tier
      
        order by customer.tier asc
```

**Params:** `["delivered"]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `avg`
- includes keyword: `where`
- includes keyword: `group by`

## Notes

- Keeps business slice (`delivered`) in the root filter layer.
- Outputs a useful per-tier spend quality metric.
