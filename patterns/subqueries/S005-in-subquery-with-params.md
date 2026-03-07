# S005 In Subquery With Params

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, in, parameters, filtering, escape-hatch

## Problem

Use a parameterized `IN` subquery to filter orders by customer tier.

## SQL

```sql
SELECT o.order_number, o.customer_id, o.total
FROM orders AS o
WHERE o.customer_id IN (
  SELECT c.id
  FROM customers AS c
  WHERE c.tier = $1
)
ORDER BY o.total DESC;
```

## Selecto

```elixir
alias SelectoSqlPatterns.EscapeHatchHelpers, as: EscapeHatch

query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "customer_id", "total"])
  |> Selecto.filter({"customer_id", {:subquery, :in, EscapeHatch.in_customer_tier_ids_sql(), ["silver"]}})
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: ` in (`
- includes keyword: `$1`
- includes keyword: `order by`

## Notes

- Subquery parameters are appended after outer-query parameters in placeholder order.
- Keep reusable raw snippets in shared helpers instead of repeating SQL strings.
- This approach supports safe migration from hand-written SQL to Selecto.
