# A005 Sum Total By Customer Tier

## Metadata

- Source: Introduction to SQL
- Source URL: https://github.com/bobbyiliev/introduction-to-sql
- Source License: MIT
- Dialect: postgres
- Tags: aggregates, sum, joins, group-by

## Problem

Aggregate order totals by customer tier.

## SQL

```sql
SELECT c.tier, SUM(o.total) AS tier_total
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id
GROUP BY c.tier
ORDER BY c.tier ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["customer.tier", {:func, "SUM", ["total"], as: "tier_total"}])
  |> Selecto.group_by(["customer.tier"])
  |> Selecto.order_by({"customer.tier", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select customer.tier, SUM(selecto_root.total)
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        group by customer.tier
      
        order by customer.tier asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `sum`
- includes keyword: `left join`
- includes keyword: `group by`

## Notes

- Grouping on joined dimensions is a common OLAP pattern.
- This query can be pivoted later for dashboard slices.
