# F007 JSON Path Predicate

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-json.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: filtering, jsonb, path, predicates

## Problem

Filter products by requiring a nested JSON path to exist.

## SQL

```sql
SELECT p.name, p.metadata #>> '{warehouse,zone}' AS warehouse_zone
FROM products AS p
WHERE p.metadata -> 'warehouse' ? 'zone'
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "metadata.warehouse.zone"])
  |> Selecto.filter({"metadata.warehouse.zone", :exists})
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, "selecto_root"."metadata"#>>'{warehouse,zone}'
        from products selecto_root
        where (( "selecto_root"."metadata"->'warehouse' ? 'zone' ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `#>>`
- includes keyword: `?`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- `:exists` on a JSON path checks key presence.
- This keeps JSON-structure validation in SQL, not app-side parsing.
