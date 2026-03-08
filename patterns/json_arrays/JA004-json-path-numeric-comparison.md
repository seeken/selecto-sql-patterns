# JA004 JSON Path Exists Filter

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-json.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: jsonb, path, exists, json-filter

## Problem

Find products that contain a nested stock quantity path in JSON metadata.

## SQL

```sql
SELECT p.name,
       p.metadata -> 'stock' ->> 'quantity' AS stock_quantity
FROM products AS p
WHERE JSONB_PATH_EXISTS(p.metadata, '$.stock.quantity')
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name"])
  |> Selecto.json_select([
    {:json_extract_text, "metadata", "$.stock.quantity", as: "stock_quantity"}
  ])
  |> Selecto.json_filter({:json_path_exists, "metadata", "$.stock.quantity", nil})
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, metadata -> 'stock' ->> 'quantity' AS "stock_quantity"
        from products selecto_root
        where (( JSONB_PATH_EXISTS(metadata, '$.stock.quantity') ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `jsonb_path_exists`
- includes keyword: `stock`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- `json_path_exists` can validate required nested attributes before downstream extraction.
- Pair existence checks with typed comparisons when path values are guaranteed present.
