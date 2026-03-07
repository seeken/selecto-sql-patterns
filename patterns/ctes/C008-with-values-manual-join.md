# C008 With Values Manual Join

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: cte, with-values, manual-join

## Problem

Create an inline lookup via `VALUES` and join it manually with `Selecto.join/3`.

## SQL

```sql
WITH status_labels (status, status_label) AS (
  VALUES
    ('processing', 'In Progress'),
    ('shipped', 'In Transit'),
    ('delivered', 'Completed')
)
SELECT o.order_number, o.status, sl.status_label
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
    as: "status_labels"
  )
  |> Selecto.join(:status_labels,
    source: "status_labels",
    type: :left,
    owner_key: :status,
    related_key: :status,
    fields: %{
      status: %{type: :string},
      status_label: %{type: :string}
    }
  )
  |> Selecto.select(["order_number", "status", "status_labels.status_label"])

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `with`
- includes keyword: `values`
- includes keyword: `left join`
- includes keyword: `status_labels`

## Notes

- Useful when you need full control over join options instead of auto-join.
- Supports additional join metadata via explicit `fields` declarations.
