# E002 Coalesce Nullif Selectors

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-conditional.html
- Source License: PostgreSQL License
- Dialect: ansi
- Tags: expressions, coalesce, nullif, null-handling

## Problem

Display a fallback customer name and suppress one status value from reporting
output without filtering rows away.

## SQL

```sql
SELECT o.order_number,
       COALESCE(c.name, 'Unassigned') AS customer_name,
       NULLIF(o.status, 'processing') AS non_processing_status
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id
ORDER BY o.order_number ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select([
    "order_number",
    {:field, {:coalesce, ["customer.name", {:literal, "Unassigned"}]}, "customer_name"},
    {:field, {:nullif, ["status", {:literal, "processing"}]}, "non_processing_status"}
  ])
  |> Selecto.order_by({"order_number", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.Expr

Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
|> Selecto.select([
  "order_number",
  as(coalesce(["customer.name", lit("Unassigned")]), "customer_name"),
  as({:nullif, ["status", lit("processing")]}, "non_processing_status")
])
|> Selecto.order_by([asc("order_number")])
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, coalesce( customer.name, 'Unassigned' ), nullif( selecto_root.status, 'processing' )
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        order by selecto_root.order_number asc
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `coalesce`
- includes keyword: `nullif`
- includes keyword: `left join`
- includes keyword: `order by`

## Notes

- `COALESCE` is useful for presentation fallbacks after an outer join.
- `NULLIF` is a projection helper; it should not be confused with a filter.
