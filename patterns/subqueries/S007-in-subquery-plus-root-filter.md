# S007 In Subquery Plus Root Filter

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: subquery, in, filtering, conjunction, escape-hatch

## Problem

Apply a root filter and an `IN` subquery filter in one predicate tree.

## SQL

```sql
SELECT o.order_number, o.customer_id, o.total
FROM orders AS o
WHERE o.status = 'delivered'
  AND o.customer_id IN (
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
  |> Selecto.select(["order_number", "customer_id", "total"])
  |> Selecto.filter(
    {:and,
     [
       {"status", "delivered"},
       {"customer_id", {:subquery, :in, EscapeHatch.in_gold_customer_ids_sql(), []}}
     ]}
  )
  |> Selecto.order_by({"total", :desc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `where`
- includes keyword: ` and `
- includes keyword: ` in (`

## Notes

- Demonstrates mixed predicate trees with both root and subquery conditions.
- Keep reusable raw snippets in shared helpers instead of repeating SQL strings.
- Useful for reproducing common reporting filters from legacy SQL.
