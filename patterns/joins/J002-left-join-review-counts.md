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

Shared domain configuration: [Join Domain Configuration](./DOMAIN_CONFIGURATION.md).

```elixir
query =
  Selecto.configure(product_domain_with_reviews_join(), :mock_connection, validate: false)
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
- Join definition is domain-configured and reused by multiple join examples.
- Count targets joined key (`reviews.id`) to avoid counting all rows blindly.

## References

- [Join Domain Configuration](./DOMAIN_CONFIGURATION.md)
