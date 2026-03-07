# A004 Count Orders By Customer Name

## Metadata

- Source: Database Design - 2nd Edition
- Source URL: https://opentextbc.ca/dbdesign01/
- Source License: CC BY 4.0
- Dialect: postgres
- Tags: aggregates, joins, count, group-by

## Problem

Count how many orders each customer has placed.

## SQL

```sql
SELECT c.name, COUNT(*) AS order_count
FROM orders AS o
LEFT JOIN customers AS c ON c.id = o.customer_id
GROUP BY c.name
ORDER BY c.name ASC;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.select(["customer.name", {:count, "*"}])
  |> Selecto.group_by(["customer.name"])
  |> Selecto.order_by({"customer.name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `count`
- includes keyword: `left join`
- includes keyword: `group by`

## Notes

- Aggregating on joined display fields is common in BI-style summaries.
- The dot-path syntax keeps join resolution declarative.
