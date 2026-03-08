# F001 Null And Not-Null Checks

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/functions-comparison.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: filtering, null, not-null, predicates

## Problem

Keep only orders that have a related customer row and exclude cancelled/returned statuses.

## SQL

```sql
SELECT o.order_number, c.name, o.status
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id
WHERE c.id IS NOT NULL
  AND o.status NOT IN ('cancelled', 'returned')
ORDER BY o.order_number ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "customer.name", "status"])
  |> Selecto.filter({"customer.id", :not_null})
  |> Selecto.filter({"status", {:not_in, ["cancelled", "returned"]}})
  |> Selecto.order_by({"order_number", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, customer.name, selecto_root.status
        from orders selecto_root left join customers customer on customer.id = selecto_root.customer_id
        where (( customer.id is not null ) and ( NOT (selecto_root.status = ANY($1)) ))
      
        order by selecto_root.order_number asc
```

**Params:** `[["cancelled", "returned"]]`

## Expected SQL Shape

- includes keyword: `is not null`
- includes keyword: `not (`
- includes keyword: `any(`
- includes keyword: `order by`

## Notes

- Use `:not_null` for explicit `IS NOT NULL` checks.
- `{:not_in, list}` compiles to a PostgreSQL-safe `NOT (... = ANY($n))` shape.
