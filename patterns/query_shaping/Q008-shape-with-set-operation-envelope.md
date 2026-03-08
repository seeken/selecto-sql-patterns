# Q008 Shape With Set-Operation Envelope

## Metadata

- Source: PostgreSQL Documentation
- Source URL: https://www.postgresql.org/docs/current/queries-union.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: shaping, set-operations, envelope

## Problem

Apply a set-operation envelope to shape which rows survive from merged sources.

## SQL

```sql
(
  (SELECT o.order_number, o.total FROM orders AS o)
  UNION ALL
  (SELECT ao.order_number, ao.total FROM archived_orders AS ao)
)
EXCEPT
(SELECT ao.order_number, ao.total FROM archived_orders AS ao);
```

## Selecto

```elixir
current_orders =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "total"])

archived_orders =
  Selecto.configure(archived_order_domain(), :mock_connection, validate: false)
  |> Selecto.select(["order_number", "total"])

merged_orders = Selecto.union(current_orders, archived_orders, all: true)
query = Selecto.except(merged_orders, archived_orders)

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
((
        select selecto_root.order_number, selecto_root.total
        from orders selecto_root)
UNION ALL
(
        select selecto_root.order_number, selecto_root.total
        from archived_orders selecto_root))
EXCEPT
(
        select selecto_root.order_number, selecto_root.total
        from archived_orders selecto_root)
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `union all`
- includes keyword: `except`
- includes keyword: `from archived_orders`
- includes keyword: `select`

## Notes

- Set-operation envelopes are useful for coarse shaping before downstream steps.
- Keep projection compatibility strict across all envelope branches.
