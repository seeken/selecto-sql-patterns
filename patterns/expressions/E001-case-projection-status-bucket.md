# E001 Case Projection Status Bucket

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-conditional.html
- Source License: PostgreSQL License
- Dialect: ansi
- Tags: expressions, case, projection

## Problem

Return a readable status bucket beside each order without changing the stored
status value.

## SQL

```sql
SELECT o.order_number,
       o.status,
       CASE
         WHEN o.status = 'processing' THEN 'Open'
         WHEN o.status = 'shipped' THEN 'In Transit'
         WHEN o.status = 'delivered' THEN 'Closed'
         ELSE 'Other'
       END AS status_bucket
FROM orders AS o
ORDER BY o.order_number ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select([
    "order_number",
    "status",
    {:field,
     {:case,
      [
        {{"status", "processing"}, {:literal, "Open"}},
        {{"status", "shipped"}, {:literal, "In Transit"}},
        {{"status", "delivered"}, {:literal, "Closed"}}
      ], {:literal, "Other"}}, "status_bucket"}
  ])
  |> Selecto.order_by({"order_number", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

Selecto.configure(order_domain(), :mock_connection, validate: false)
|> Selecto.select([
  "order_number",
  "status",
  as(
    case_when(
      [
        {eq("status", "processing"), "Open"},
        {eq("status", "shipped"), "In Transit"},
        {eq("status", "delivered"), "Closed"}
      ],
      "Other"
    ),
    "status_bucket"
  )
])
|> Selecto.order_by([asc("order_number")])
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, selecto_root.status, case when (( selecto_root.status = $1 )) then 'Open' when (( selecto_root.status = $2 )) then 'In Transit' when (( selecto_root.status = $3 )) then 'Closed' else 'Other' end
        from orders selecto_root
        order by selecto_root.order_number asc
```

**Params:** `["processing", "shipped", "delivered"]`

## Expected SQL Shape

- includes keyword: `case when`
- includes keyword: `then`
- includes keyword: `else`
- includes keyword: `order by`

## Notes

- Use `case_when/2` when the database should label or bucket rows directly.
- Predicate values are parameterized; result literals are emitted inline.
