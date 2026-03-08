# A010 Count And Average Rating By Product

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-agg.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: aggregates, count, avg, joins

## Problem

Aggregate product review counts and average rating per product name.

## SQL

```sql
SELECT p.name, COUNT(r.id) AS review_count, AVG(r.rating) AS avg_rating
FROM products AS p
LEFT JOIN reviews AS r ON r.product_id = p.id
GROUP BY p.name
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain_with_reviews_join(), :mock_connection, validate: false)
  |> Selecto.select([
    "name",
    {:count, "reviews.id"},
    {:func, "AVG", ["reviews.rating"], as: "avg_rating"}
  ])
  |> Selecto.group_by(["name"])
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name, count(reviews.id), AVG(reviews.rating)
        from products selecto_root left join reviews reviews on reviews.product_id = selecto_root.id
        group by selecto_root.name
      
        order by selecto_root.name asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `count`
- includes keyword: `avg`
- includes keyword: `group by`

## Notes

- Combining count and average gives both coverage and quality signals.
- Left join preserves products that have no reviews yet.
