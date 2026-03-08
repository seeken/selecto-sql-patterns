# JA003 Array Overlap Filter

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-array.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: array, overlap, filters

## Problem

Filter products to those tagged with any value in a target tag list.

## SQL

```sql
SELECT p.name, p.tags
FROM products AS p
WHERE p.tags && ARRAY['featured', 'clearance']
  AND p.active = TRUE
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "tags"])
  |> Selecto.filter({:array_overlap, "tags", ["featured", "clearance"]})
  |> Selecto.filter({"active", true})
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.tags
        from products selecto_root
        where (( selecto_root.tags && $1 ) and ( selecto_root.active = $2 ))
      
        order by selecto_root.name asc
```

**Params:** `[["featured", "clearance"], true]`

## Expected SQL Shape

- includes keyword: `&&`
- includes keyword: `where`
- includes keyword: `order by`
- includes keyword: `from products`

## Notes

- `:array_overlap` maps to PostgreSQL `&&`.
- This is useful for feature-flag and faceted-search tag filtering.
