# C004 With Values Status Lookup

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: cte, with-values, lookup, joins

## Problem

Create an inline lookup table with `VALUES` and join it to orders for display labels.

## SQL

```sql
WITH status_labels (status, status_label) AS (
  VALUES
    ('processing', 'In Progress'),
    ('shipped', 'In Transit'),
    ('delivered', 'Completed')
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
      ["shipped", "In Transit"],
      ["delivered", "Completed"]
    ],
    columns: ["status", "status_label"],
    as: "status_labels",
    join: [owner_key: :status, related_key: :status]
  )
  |> Selecto.select(["order_number", "status_labels.status_label"])

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
WITH status_labels ("status", "status_label") AS (VALUES ('processing', 'In Progress'), ('shipped', 'In Transit'), ('delivered', 'Completed'))

        select selecto_root.order_number, status_labels.status_label
        from orders selecto_root left join status_labels status_labels on status_labels.status = selecto_root.status
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `with`
- includes keyword: `values`
- includes keyword: `left join`
- includes keyword: `select`

## Notes

- Good for small static mappings without creating physical tables.
- Keeps display labels and root facts in one query plan.
