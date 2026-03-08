# Q007 Shape With CTE Handoff

## Metadata

- Source: Selecto Query Members Tests
- Source URL: https://github.com/seeken/selecto
- Source License: MIT
- Dialect: postgres
- Tags: shaping, cte, query-members

## Problem

Use a named CTE member as a handoff stage for shaping final projections.

## SQL

```sql
WITH delivered_totals (id, total) AS (
  SELECT o.id, o.total
  FROM orders AS o
  WHERE o.status = 'delivered'
)
SELECT o.order_number, c.name, dt.total
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id
LEFT JOIN delivered_totals AS dt ON dt.id = o.id
ORDER BY o.order_number ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_shape_members(), :mock_connection, validate: false)
  |> Selecto.with_cte(:delivered_totals)
  |> Selecto.select(["order_number", "customer.name", "delivered_totals.total"])
  |> Selecto.order_by({"order_number", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
WITH delivered_totals (id, total) AS (
    
        select selecto_root.id, selecto_root.total
        from orders selecto_root
        where (( selecto_root.status = $1 ))
      
)

        select selecto_root.order_number, customer.name, delivered_totals.total
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id left join delivered_totals delivered_totals on delivered_totals.id = selecto_root.id
        order by selecto_root.order_number asc
```

**Params:** `["delivered"]`

## Expected SQL Shape

- includes keyword: `with`
- includes keyword: `delivered_totals`
- includes keyword: `left join`
- includes keyword: `order by`

## Notes

- CTE handoff shapes help split expensive logic from final display selection.
- Query-member CTEs keep reusable staging definitions centralized.
