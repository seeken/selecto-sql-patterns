# J012 Join Subquery Processing Orders

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: joins, subquery, filtering

## Problem

Join customers to a filtered order subquery to attach processing order numbers.

## SQL

```sql
SELECT c.name, c.tier, po.order_number
FROM customers AS c
LEFT JOIN (
  SELECT o.customer_id, o.order_number
  FROM orders AS o
  WHERE o.status = 'processing'
) AS po ON po.customer_id = c.id
ORDER BY c.name ASC;
```

## Selecto

Shared domain configuration: [Join Domain Configuration](./DOMAIN_CONFIGURATION.md).

```elixir
processing_orders =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["customer_id", "order_number"])
  |> Selecto.filter({"status", "processing"})

query =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.join_subquery(:processing_orders, processing_orders,
    type: :left,
    on: [%{left: "id", right: "customer_id"}]
  )
  |> Selecto.select(["name", "tier", "processing_orders.order_number"])
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.tier, processing_orders.order_number
        from customers selecto_root left join (
        select subq_root_orders_processing_orders.customer_id, subq_root_orders_processing_orders.order_number
        from orders subq_root_orders_processing_orders
        where (( subq_root_orders_processing_orders.status = $1 ))
      ) processing_orders on selecto_root.id = processing_orders.customer_id
        order by selecto_root.name asc
```

**Params:** `["processing"]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `left join`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- Subquery joins are useful for enriching entities with workflow-state slices.
- Keep join keys explicit in `on` so correlation remains obvious.

## References

- [Join Domain Configuration](./DOMAIN_CONFIGURATION.md)
