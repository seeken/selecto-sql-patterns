# Q001 Subselect Aggregated Related Rows

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-aggregate.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: shaping, subselect, json-agg, correlated

## Problem

Return attendee rows with related orders collapsed into a JSON aggregate column.

## SQL

```sql
SELECT a.name,
       a.email,
       (
         SELECT json_agg(json_build_object('product_name', o.product_name, 'quantity', o.quantity))
         FROM orders AS o
         WHERE o.attendee_id = a.attendee_id
       ) AS order_items
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
      fields: ["product_name", "quantity"],
      target_schema: :orders,
      format: :json_agg,
      alias: "order_items"
    }
  ])
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.email, (SELECT json_agg(json_build_object('product_name', sub_orders."product_name", 'quantity', sub_orders."quantity")) FROM orders sub_orders WHERE sub_orders."attendee_id" = selecto_root."attendee_id") AS "order_items"
        from attendees selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `json_agg`
- includes keyword: `json_build_object`
- includes keyword: `from orders`
- includes keyword: `order_items`

## Notes

- `subselect` avoids row multiplication from one-to-many joins.
- JSON aggregation keeps related payloads attached to each root row.
