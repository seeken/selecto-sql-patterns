# JA005 JSON Path Ordering

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-json.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: jsonb, ordering, json-order-by

## Problem

Sort product rows by a nested JSON path while still selecting scalar columns.

## SQL

```sql
SELECT p.name,
       p.sku,
       p.metadata -> 'warehouse' ->> 'zone' AS warehouse_zone
FROM products AS p
ORDER BY p.metadata -> 'warehouse' ->> 'zone' ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "sku"])
  |> Selecto.json_select([{:json_extract_text, "metadata", "$.warehouse.zone", as: "warehouse_zone"}])
  |> Selecto.json_order_by({:json_extract_text, "metadata", "$.warehouse.zone", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.sku, metadata -> 'warehouse' ->> 'zone' AS "warehouse_zone"
        from products selecto_root
        order by metadata -> 'warehouse' ->> 'zone' asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `->`
- includes keyword: `->>`
- includes keyword: `order by`
- includes keyword: `warehouse`

## Notes

- `json_order_by` keeps JSON extraction out of manual raw SQL sorts.
- You can combine `json_select` and `json_order_by` for display + sorting.
