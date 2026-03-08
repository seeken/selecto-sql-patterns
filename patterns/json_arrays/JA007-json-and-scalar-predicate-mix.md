# JA007 JSON And Scalar Predicate Mix

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-json.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: jsonb, mixed-predicates, filtering

## Problem

Filter rows using both a nested JSON path condition and a scalar column predicate.

## SQL

```sql
SELECT p.name, p.sku, p.metadata #>> '{warehouse,zone}' AS warehouse_zone
FROM products AS p
WHERE p.metadata #>> '{warehouse,zone}' = 'A1'
  AND p.active = TRUE
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "sku", "metadata.warehouse.zone"])
  |> Selecto.filter({"metadata.warehouse.zone", "A1"})
  |> Selecto.filter({"active", true})
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.sku, "selecto_root"."metadata"#>>'{warehouse,zone}'
        from products selecto_root
        where (( "selecto_root"."metadata"#>>'{warehouse,zone}' = $1 ) and ( selecto_root.active = $2 ))
      
        order by selecto_root.name asc
```

**Params:** `["A1", true]`

## Expected SQL Shape

- includes keyword: `#>>`
- includes keyword: `active`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- Mixed predicates let JSON attributes and relational flags cooperate naturally.
- Keep JSON-path filters explicit to avoid implicit app-side decoding logic.
