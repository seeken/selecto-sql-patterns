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

Shared domain configuration: [Join Domain Configuration](./DOMAIN_CONFIGURATION.md).

```elixir
query =
  Selecto.configure(product_domain_with_reviews_join(), :mock_connection, validate: false)
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
- Uses the same domain-configured `reviews` join as J002.
- This pattern is useful for orphan detection and completeness checks.

## References

- [Join Domain Configuration](./DOMAIN_CONFIGURATION.md)
