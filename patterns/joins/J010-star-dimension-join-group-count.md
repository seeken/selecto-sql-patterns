# J010 Star Dimension Join Group Count

## Metadata

- Source: Database Design - 2nd Edition
- Source URL: https://opentextbc.ca/dbdesign01/
- Source License: CC BY 4.0
- Dialect: postgres
- Tags: joins, star-dimension, analytics, group-by

## Problem

Group orders by a star-dimension customer attribute.

## SQL

```sql
SELECT c.name, COUNT(*) AS order_count
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id
GROUP BY c.name
ORDER BY c.name ASC;
```

## Selecto

Shared domain configuration: [Join Domain Configuration](./DOMAIN_CONFIGURATION.md).

```elixir
star_domain =
  order_domain_with_customer_join()
  |> put_in([:joins, :customer, :type], :star_dimension)

query =
  Selecto.configure(star_domain, :mock_connection, validate: false)
  |> Selecto.select(["customer.name", {:count, "*"}])
  |> Selecto.group_by(["customer.name"])
  |> Selecto.order_by({"customer.name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `left join`
- includes keyword: `count`
- includes keyword: `group by`

## Notes

- `:star_dimension` join type keeps BI-style dimension semantics explicit.
- Query still compiles to standard SQL joins and aggregates.

## References

- [Join Domain Configuration](./DOMAIN_CONFIGURATION.md)
