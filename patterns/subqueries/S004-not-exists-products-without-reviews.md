# S004 Not Exists Products Without Reviews

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, not-exists, correlated, join-subquery

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
reviewed_products =
  Selecto.configure(review_domain(), :mock_connection, validate: false)
  |> Selecto.select(["product_id"])
  |> Selecto.group_by(["product_id"])

query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name"])
  |> Selecto.join_subquery(:reviewed_products, reviewed_products,
    type: :left,
    on: [%{left: "id", right: "product_id"}]
  )
  |> Selecto.filter({"reviewed_products.product_id", nil})
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.name
        from products selecto_root left join (
        select selecto_root.product_id
        from reviews selecto_root
        group by selecto_root.product_id
      ) reviewed_products on selecto_root.id = reviewed_products.product_id
        where (( reviewed_products.product_id is null ))
      
        order by selecto_root.name asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `left join`
- includes keyword: `is null`
- includes keyword: `order by`

## Notes

- Uses `LEFT JOIN` + `IS NULL` anti-join semantics equivalent to `NOT EXISTS`.
- The grouped subquery ensures one row per reviewed product key.
