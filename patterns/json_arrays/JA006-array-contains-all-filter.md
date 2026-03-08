# JA006 Array Contains-All Filter

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-array.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: arrays, contains-all, json-arrays

## Problem

Select products whose tag arrays include all required tags.

## SQL

```sql
SELECT p.name, p.tags
FROM products AS p
WHERE p.tags @> ARRAY['featured', 'clearance']
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "tags"])
  |> Selecto.filter({:array_contains, "tags", ["featured", "clearance"]})
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.tags
        from products selecto_root
        where (( selecto_root.tags @> $1 ))
      
        order by selecto_root.name asc
```

**Params:** `[["featured", "clearance"]]`

## Expected SQL Shape

- includes keyword: `@>`
- includes keyword: `where`
- includes keyword: `order by`
- includes keyword: `from products`

## Notes

- `:array_contains` maps to PostgreSQL `@>` for contains-all semantics.
- This pattern is useful for strict multi-tag matching.
