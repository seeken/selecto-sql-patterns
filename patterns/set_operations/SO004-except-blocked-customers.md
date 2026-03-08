# SO004 Except Blocked Customers

## Metadata

- Source: SQL Notes for Professionals
- Source URL: http://goalkicker.com/SQLBook/
- Source License: CC BY-SA (Stack Overflow Documentation derivative)
- Dialect: postgres
- Tags: set-operations, except

## Problem

Return all customers except those in the blocked customer set.

## SQL

```sql
SELECT c.id, c.name
FROM customers AS c
EXCEPT
SELECT bc.id, bc.name
FROM blocked_customers AS bc;
```

## Selecto

```elixir
all_customers =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])

blocked_customers =
  Selecto.configure(blocked_customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name"])

query = Selecto.except(all_customers, blocked_customers)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
(
        select selecto_root.id, selecto_root.name
        from customers selecto_root)
EXCEPT
(
        select selecto_root.id, selecto_root.name
        from blocked_customers selecto_root)
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `except`
- includes keyword: `from customers`
- includes keyword: `from blocked_customers`

## Notes

- `EXCEPT` performs set subtraction on compatible projections.
- Useful for deny-list exclusion scenarios.
