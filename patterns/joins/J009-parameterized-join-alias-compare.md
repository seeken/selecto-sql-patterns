# J009 Parameterized Join Alias Compare

## Metadata

- Source: PostgreSQL Exercises
- Source URL: https://github.com/AlisdairO/pgexercises
- Source License: BSD-style
- Dialect: postgres
- Tags: joins, parameterized-join, aliasing

## Problem

Join the same relationship twice and project both aliases side by side.

## SQL

```sql
SELECT
  o.order_number,
  c_a.name AS alias_a_name,
  c_b.tier AS alias_b_tier
FROM orders AS o
LEFT JOIN customers AS c_a ON c_a.id = o.customer_id
LEFT JOIN customers AS c_b ON c_b.id = o.customer_id;
```

## Selecto

Shared domain configuration: [Join Domain Configuration](./DOMAIN_CONFIGURATION.md).

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.join_parameterize(:customer, "alias_a")
  |> Selecto.join_parameterize(:customer, "alias_b")
  |> Selecto.select(["order_number", "customer:alias_a.name", "customer:alias_b.tier"])

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, "customer:alias_a".name, "customer:alias_b".tier
        from orders selecto_root left join customers "customer:alias_a" on "customer:alias_a".id = selecto_root.customer_id left join customers "customer:alias_b" on "customer:alias_b".id = selecto_root.customer_id
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `left join`
- includes keyword: `customer:alias_a`
- includes keyword: `customer:alias_b`

## Notes

- Parameterized joins let one association be reused multiple times safely.
- Alias-scoped dot paths avoid field collisions in projections.

## References

- [Join Domain Configuration](./DOMAIN_CONFIGURATION.md)
