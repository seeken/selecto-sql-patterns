# C006 With Values Join True Status Lookup

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: cte, with-values, inferred-join, lookup

## Problem

Create an inline status lookup and infer join keys with `join: true`.

## SQL

```sql
WITH status_labels (status, status_label) AS (
  VALUES
    ('processing', 'In Progress'),
    ('shipped', 'In Transit')
)
SELECT o.order_number, sl.status_label
FROM orders AS o
LEFT JOIN status_labels AS sl ON sl.status = o.status;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.with_values(
    [
      ["processing", "In Progress"],
      ["shipped", "In Transit"]
    ],
    columns: ["status", "status_label"],
    as: "status_labels",
    join: true
  )
  |> Selecto.select(["order_number", "status_labels.status_label"])

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
WITH status_labels ("status", "status_label") AS (VALUES ('processing', 'In Progress'), ('shipped', 'In Transit'))

        select selecto_root.order_number, status_labels.status_label
        from orders selecto_root left join status_labels status_labels on status_labels.status = selecto_root.status
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `with`
- includes keyword: `values`
- includes keyword: `left join`
- includes keyword: `status_labels`

## Notes

- `join: true` infers owner/related keys from the first declared `VALUES` column.
- Useful for compact enum label enrichment without physical tables.
