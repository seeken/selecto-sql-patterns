# S006 Exists Correlated Filter With Params

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, exists, correlated, parameters, escape-hatch

## Problem

Use a correlated `EXISTS` subquery with bind parameters.

## SQL

```sql
SELECT o.order_number, o.status, o.total
FROM orders AS o
WHERE EXISTS (
  SELECT 1
  FROM customers AS c
  WHERE c.id = o.customer_id
    AND c.tier = $1
)
ORDER BY o.total DESC;
```

## Selecto

```elixir
alias SelectoSqlPatterns.EscapeHatchHelpers, as: EscapeHatch

query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "status", "total"])
  |> Selecto.filter({:exists, EscapeHatch.exists_customer_tier_sql(), ["gold"]})
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `exists (`
- includes keyword: `$1`
- includes keyword: `order by`

## Notes

- Keeps correlation explicit against `selecto_root` fields.
- Keeps raw SQL snippet centralized in a helper module.
- Parameters from the subquery are appended to the final params list.
