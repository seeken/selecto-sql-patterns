# JA002 JSON Path Existence And Equality

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-json.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: jsonb, path, exists, equality

## Problem

Return products where a nested metadata path exists and matches a specific value.

## SQL

```sql
SELECT p.name,
       p.metadata #>> '{warehouse,zone}' AS warehouse_zone
FROM products AS p
WHERE p.metadata -> 'warehouse' ? 'zone'
  AND p.metadata #>> '{warehouse,zone}' = 'A1'
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "metadata.warehouse.zone"])
  |> Selecto.filter({"metadata.warehouse.zone", :exists})
  |> Selecto.filter({"metadata.warehouse.zone", "A1"})
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, "selecto_root"."metadata"#>>'{warehouse,zone}'
        from products selecto_root
        where (( "selecto_root"."metadata"->'warehouse' ? 'zone' ) and ( "selecto_root"."metadata"#>>'{warehouse,zone}' = $1 ))
      
        order by selecto_root.name asc
```

**Params:** `["A1"]`

## Expected SQL Shape

- includes keyword: `->`
- includes keyword: `#>>`
- includes keyword: `?`
- includes keyword: `order by`

## Notes

- Dot notation (`metadata.warehouse.zone`) targets nested JSON paths.
- `:exists` on a JSON path emits a key-existence predicate.
