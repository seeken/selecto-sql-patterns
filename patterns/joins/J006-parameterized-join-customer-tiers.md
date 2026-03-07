# J006 Parameterized Join Customer Tiers

## Metadata

- Source: PostgreSQL Exercises
- Source URL: https://github.com/AlisdairO/pgexercises
- Source License: BSD-style
- Dialect: postgres
- Tags: joins, parameterized-join, aliasing, comparison

## Problem

Join the same customer relationship twice with different tier constraints.

## SQL

```sql
SELECT
  o.order_number,
  c_premium.name AS premium_customer,
  c_standard.name AS standard_customer
FROM orders AS o
LEFT JOIN customers AS c_premium
  ON c_premium.id = o.customer_id AND c_premium.tier = 'premium'
LEFT JOIN customers AS c_standard
  ON c_standard.id = o.customer_id AND c_standard.tier = 'standard';
```

## Selecto

Shared domain configuration: [Join Domain Configuration](./DOMAIN_CONFIGURATION.md).

```elixir
query =
  Selecto.configure(order_domain_with_customer_join_filter(), :mock_connection, validate: false)
  |> Selecto.join_parameterize(:customer, "tier_premium", tier: "premium")
  |> Selecto.join_parameterize(:customer, "tier_standard", tier: "standard")
  |> Selecto.select([
    "order_number",
    "customer:tier_premium.name",
    "customer:tier_standard.name"
  ])

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `left join`
- includes keyword: `and`
- includes keyword: `customer:tier_premium`

## Notes

- Parameterized joins allow multiple instances of one association.
- Filters are applied in each join `ON` clause with proper bind parameters.

## References

- [Join Domain Configuration](./DOMAIN_CONFIGURATION.md)
