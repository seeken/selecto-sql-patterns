# J008 Cross Join Unnest Tags

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: joins, cross-join, lateral, unnest

## Problem

Expand each product tag array into one row per tag.

## SQL

```sql
SELECT p.name, t.product_tag
FROM products AS p
CROSS JOIN LATERAL UNNEST(p.tags) AS t(product_tag)
WHERE p.active = TRUE;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.unnest("tags", as: "product_tag")
  |> Selecto.select([
    "name",
    "product_tag"
  ])
  |> Selecto.filter({"active", true})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `cross join lateral unnest`
- includes keyword: `where`
- includes keyword: `active`

## Notes

- Uses `Selecto.unnest/3` which emits a `CROSS JOIN LATERAL UNNEST(...)` clause.
- Registers the UNNEST alias as a selectable field, so no raw selector is needed.
- Helpful for faceting/tag analytics from array-backed columns.
