# S004 Not Exists Products Without Reviews

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, not-exists, correlated

## Problem

Find products that do not have any review rows.

## SQL

```sql
SELECT p.name
FROM products AS p
WHERE NOT EXISTS (
  SELECT 1
  FROM reviews AS r
  WHERE r.product_id = p.id
)
ORDER BY p.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name"])
  |> Selecto.filter({:not, {:exists, "SELECT 1 FROM reviews r WHERE r.product_id = selecto_root.id"}})
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `not (`
- includes keyword: `exists (`
- includes keyword: `order by`

## Notes

- `NOT EXISTS` is usually preferred over `NOT IN` for nullable key safety.
- Correlation is explicit via `selecto_root.id` in the subquery.
