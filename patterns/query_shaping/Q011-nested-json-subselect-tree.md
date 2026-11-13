# Q011 Nested JSON Subselect Tree

## Metadata

- Source: Selecto Subselect Integration Tests
- Source URL: https://github.com/seeken/selecto
- Source License: MIT
- Dialect: postgres
- Tags: shaping, subselect, json-agg, nested

## Problem

Return attendee rows with related orders, and include each order's line items as a nested JSON array.

## SQL

```sql
SELECT a.name,
       a.email,
       (
         SELECT json_agg(
           json_build_object(
             'product_name', o.product_name,
             'items',
             COALESCE(
               (
                 SELECT json_agg(json_build_object('sku', oi.sku, 'quantity', oi.quantity))
                 FROM order_items AS oi
                 WHERE oi.order_id = o.order_id
               ),
               '[]'::json
             )
           )
         )
         FROM orders AS o
         WHERE o.attendee_id = a.attendee_id
       ) AS orders
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
      alias: "orders",
      join_path: [:orders],
      nested: [
        %{
          key: "items",
          fields: ["sku", "quantity"],
          target_schema: :order_items,
          format: :json_agg,
          join_path: [:orders, :order_items]
        }
      ]
    }
  ])
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

configure(attendee_domain_with_orders_join(), :mock_connection, validate: false)
|> Selecto.select(["name", "email"])
|> Selecto.subselect([
  %{
    fields: ["product_name"],
    target_schema: :orders,
    format: :json_agg,
    alias: "orders",
    join_path: [:orders],
    nested: [
      %{
        key: "items",
        fields: ["sku", "quantity"],
        target_schema: :order_items,
        format: :json_agg,
        join_path: [:orders, :order_items]
      }
    ]
  }
])
|> Selecto.order_by([asc("name")])
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.email, (SELECT json_agg(json_build_object('product_name', sub_orders."product_name", 'items', COALESCE((SELECT json_agg(json_build_object('sku', sub_orders_items."sku", 'quantity', sub_orders_items."quantity")) FROM order_items sub_orders_items WHERE sub_orders_items."order_id" = sub_orders."order_id"), '[]'::json))) FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "orders"
        from attendees selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `json_agg`
- includes keyword: `'items'`
- includes keyword: `from order_items`
- includes keyword: `sub_orders_items`
- includes keyword: `order_id`

## Notes

- Child specs in `:nested` are rendered inside the parent JSON object.
- The child `join_path` is relative to the root path, so `[:orders, :order_items]` correlates line items to each order row.
