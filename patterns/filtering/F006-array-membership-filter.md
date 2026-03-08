# F006 Array Membership Filter

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-array.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: filtering, arrays, membership

## Problem

Return products whose tags contain a required membership token.

## SQL

```sql
SELECT p.name, p.tags
FROM products AS p
WHERE p.tags @> ARRAY['featured']
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "tags"])
  |> Selecto.filter({:array_contains, "tags", ["featured"]})
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

**Params:** `[["featured"]]`

## Expected SQL Shape

- includes keyword: `@>`
- includes keyword: `where`
- includes keyword: `order by`
- includes keyword: `from products`

## Notes

- `:array_contains` checks whether a row's array includes all required members.
- This is useful for capability flags and taxonomy filters.
