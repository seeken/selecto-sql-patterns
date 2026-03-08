# JA008 Nested JSON Projection Pack

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-json.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: jsonb, projection, nested-paths

## Problem

Project multiple nested JSON attributes alongside scalar columns.

## SQL

```sql
SELECT p.name,
       p.sku,
       p.metadata -> 'warehouse' ->> 'zone' AS warehouse_zone,
       p.metadata -> 'stock' ->> 'quantity' AS stock_quantity
FROM products AS p
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "sku"])
  |> Selecto.json_select([
    {:json_extract_text, "metadata", "$.warehouse.zone", as: "warehouse_zone"},
    {:json_extract_text, "metadata", "$.stock.quantity", as: "stock_quantity"}
  ])
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.sku, metadata -> 'warehouse' ->> 'zone' AS "warehouse_zone", metadata -> 'stock' ->> 'quantity' AS "stock_quantity"
        from products selecto_root
        order by selecto_root.name asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `->>`
- includes keyword: `warehouse_zone`
- includes keyword: `stock_quantity`
- includes keyword: `order by`

## Notes

- Use `json_select` to centralize nested extraction logic in one place.
- Projection packs are useful for API payload shaping.
