# C007 With Recursive CTE Inline Format

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: cte, recursive, inline-format

## Problem

Build a recursive CTE using the inline `(base_fn, recursive_fn)` function format.

## SQL

```sql
WITH RECURSIVE order_chain (id, status) AS (
  SELECT o.id, o.status
  FROM orders AS o
  WHERE o.status = 'processing'
  UNION ALL
  SELECT o2.id, o2.status
  FROM orders AS o2
)
SELECT o.order_number, oc.status
FROM orders AS o
LEFT JOIN order_chain AS oc ON oc.id = o.id;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.with_recursive_cte(
    "order_chain",
    fn ->
      Selecto.configure(order_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "status"])
      |> Selecto.filter({"status", "processing"})
    end,
    fn _cte_ref ->
      Selecto.configure(order_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "status"])
    end,
    columns: ["id", "status"],
    join: true
  )
  |> Selecto.select(["order_number", "order_chain.status"])

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `with recursive`
- includes keyword: `union all`
- includes keyword: `left join`
- includes keyword: `select`

## Notes

- This variant is useful when defining recursive queries inline near call sites.
- Keep CTE columns explicit so join field inference is stable.
