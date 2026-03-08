# F004 Text Search Predicate

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/textsearch-controls.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: filtering, full-text, text-search

## Problem

Search product names using PostgreSQL full-text query semantics.

## SQL

```sql
SELECT p.name, p.sku
FROM products AS p
WHERE p.name @@ websearch_to_tsquery('wireless charger')
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "sku"])
  |> Selecto.filter({"name", {:text_search, "wireless charger"}})
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, selecto_root.sku
        from products selecto_root
        where (( selecto_root.name @@ websearch_to_tsquery($1) ))
      
        order by selecto_root.name asc
```

**Params:** `["wireless charger"]`

## Expected SQL Shape

- includes keyword: `@@ websearch_to_tsquery`
- includes keyword: `where`
- includes keyword: `order by`
- includes keyword: `from products`

## Notes

- `{:text_search, value}` emits a `websearch_to_tsquery` predicate.
- This shape is useful for user-friendly search box behavior.
