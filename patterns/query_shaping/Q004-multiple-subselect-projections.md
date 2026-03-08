# Q004 Multiple Subselect Projections

## Metadata

- Source: Selecto Subselect Integration Tests
- Source URL: https://github.com/seeken/selecto
- Source License: MIT
- Dialect: postgres
- Tags: shaping, subselect, json-agg, array-agg

## Problem

Return attendee rows with two correlated subselect outputs: JSON product names and array-aggregated quantities.

## SQL

```sql
SELECT a.name,
       a.email,
       (
         SELECT json_agg(json_build_object('product_name', o.product_name))
         FROM orders AS o
         WHERE o.attendee_id = a.attendee_id
       ) AS products,
       (
         SELECT array_agg(o.quantity)
         FROM orders AS o
         WHERE o.attendee_id = a.attendee_id
       ) AS quantities
FROM attendees AS a
ORDER BY a.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(attendee_domain_with_orders_join(), :mock_connection, validate: false)
  |> Selecto.select(["name", "email"])
  |> Selecto.subselect([
    %{
      fields: ["product_name"],
      target_schema: :orders,
      format: :json_agg,
      alias: "products"
    },
    %{
      fields: ["quantity"],
      target_schema: :orders,
      format: :array_agg,
      alias: "quantities"
    }
  ])
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.email, (SELECT json_agg(sub_orders."product_name") FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "products", (SELECT array_agg(sub_orders."quantity") FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "quantities"
        from attendees selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `json_agg`
- includes keyword: `array_agg`
- includes keyword: `products`
- includes keyword: `quantities`

## Notes

- Multiple `subselect` specs let you project distinct related summaries together.
- This avoids extra post-processing passes in application code.
