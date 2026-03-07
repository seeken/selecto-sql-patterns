# J002 Left Join Review Counts

## Metadata

- Source: PostgreSQL Exercises
- Source URL: https://github.com/AlisdairO/pgexercises
- Source License: BSD-style
- Dialect: postgres
- Tags: joins, left-join, aggregates, group-by

## Problem

List all products and how many reviews each product has, including products with no reviews.

## SQL

```sql
SELECT p.name, COUNT(r.id) AS review_count
FROM products AS p
LEFT JOIN reviews AS r ON r.product_id = p.id
GROUP BY p.name
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
  |> Selecto.select(["name", {:count, "reviews.id"}])
  |> Selecto.group_by(["name"])
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `left join`
- includes keyword: `count`
- includes keyword: `group by`

## Notes

- Uses `LEFT JOIN` so products with zero related rows still appear.
- Count targets joined key (`reviews.id`) to avoid counting all rows blindly.
