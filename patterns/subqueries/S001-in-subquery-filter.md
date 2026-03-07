# S001 IN Subquery Filter

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, in, filtering, escape-hatch

## Problem

Filter orders so only customers in the `gold` tier remain.

## SQL

```sql
SELECT o.order_number, o.customer_id, o.status, o.total
FROM orders AS o
WHERE o.customer_id IN (
  SELECT c.id
  FROM customers AS c
  WHERE c.tier = 'gold'
)
ORDER BY o.total DESC;
```

## Selecto

```elixir
alias SelectoSqlPatterns.EscapeHatchHelpers, as: EscapeHatch

query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "customer_id", "status", "total"])
  |> Selecto.filter({"customer_id", {:subquery, :in, EscapeHatch.in_gold_customer_ids_sql(), []}})
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `in (`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- Subquery text remains explicit and can be replaced with parameterized SQL + args list.
- Keep reusable raw snippets in shared helpers instead of repeating SQL strings.
- This pattern is useful for migrating existing hand-written SQL incrementally.
