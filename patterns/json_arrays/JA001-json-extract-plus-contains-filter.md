# JA001 JSON Extract Plus Contains Filter

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-json.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: jsonb, json-select, json-filter, contains

## Problem

Project a JSON path from product metadata and keep only rows whose metadata contains a target object.

## SQL

```sql
SELECT p.name,
       p.sku,
       p.metadata ->> 'price_band' AS price_band
FROM products AS p
WHERE p.metadata @> '{"price_band":"premium"}'
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "sku"])
  |> Selecto.json_select([{:json_extract_text, "metadata", "$.price_band", as: "price_band"}])
  |> Selecto.json_filter({:json_contains, "metadata", %{"price_band" => "premium"}})
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.sku, metadata ->> 'price_band' AS "price_band"
        from products selecto_root
        where (( metadata @> '{"price_band":"premium"}' ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `->>`
- includes keyword: `@>`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- `json_select` keeps extraction logic in the SELECT list.
- `json_filter` with `:json_contains` maps to Postgres `@>` containment.
