# Q006 Query-Member Shape Preset

## Metadata

- Source: Selecto Query Members Tests
- Source URL: https://github.com/seeken/selecto
- Source License: MIT
- Dialect: postgres
- Tags: shaping, query-members, subquery-preset

## Problem

Apply a preconfigured domain query member to shape output without rebuilding join logic inline.

## SQL

```sql
SELECT c.name, c.tier, pom.order_number
FROM customers AS c
LEFT JOIN (
  SELECT o.customer_id, o.order_number, o.total
  FROM orders AS o
  WHERE o.status = 'processing'
) AS pom ON pom.customer_id = c.id
ORDER BY c.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(customer_domain_with_shape_members(), :mock_connection, validate: false)
  |> Selecto.with_subquery(:processing_orders_member)
  |> Selecto.select(["name", "tier", "processing_orders_member.order_number"])
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.tier, processing_orders_member.order_number
        from customers selecto_root left join (
        select subq_root_orders_processing_orders_member.customer_id, subq_root_orders_processing_orders_member.order_number, subq_root_orders_processing_orders_member.total
        from orders subq_root_orders_processing_orders_member
        where (( subq_root_orders_processing_orders_member.status = $1 ))
      ) processing_orders_member on selecto_root.id = processing_orders_member.customer_id
        order by selecto_root.name asc
```

**Params:** `["processing"]`

## Expected SQL Shape

- includes keyword: `left join`
- includes keyword: `processing_orders_member`
- includes keyword: `from customers`
- includes keyword: `order by`

## Notes

- Named query members reduce repeated shaping boilerplate.
- Domain-owned presets keep cross-query behavior consistent.
