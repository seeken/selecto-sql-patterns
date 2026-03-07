# J005 Anti Join Products Without Reviews

## Metadata

- Source: PostgreSQL Exercises
- Source URL: https://github.com/AlisdairO/pgexercises
- Source License: BSD-style
- Dialect: postgres
- Tags: joins, anti-join, left-join, is-null

## Problem

Find products that have no related reviews.

## SQL

```sql
SELECT p.name
FROM products AS p
LEFT JOIN reviews AS r ON r.product_id = p.id
WHERE r.id IS NULL
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.join(:reviews,
    source: "reviews",
    type: :left,
    owner_key: :id,
    related_key: :product_id,
    fields: %{
      id: %{type: :integer},
      rating: %{type: :integer}
    }
  )
  |> Selecto.select(["name"])
  |> Selecto.filter({"reviews.id", nil})
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `left join`
- includes keyword: `is null`
- includes keyword: `order by`

## Notes

- Anti-join is modeled with `LEFT JOIN` plus `IS NULL` filter.
- This pattern is useful for orphan detection and completeness checks.
