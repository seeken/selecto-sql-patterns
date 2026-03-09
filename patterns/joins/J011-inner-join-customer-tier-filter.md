# J011 Inner Join Customer Tier Filter

## Metadata

- Source: Database Design - 2nd Edition
- Source URL: https://opentextbc.ca/dbdesign01/
- Source License: CC BY 4.0
- Dialect: postgres
- Tags: joins, inner-join, filtering

## Problem

Return only orders whose customer appears in a tier-filtered customer subquery.

## SQL

```sql
SELECT o.order_number, gc.name, o.total
FROM orders AS o
INNER JOIN (
  SELECT c.id, c.name, c.tier
  FROM customers AS c
  WHERE c.tier = 'gold'
) AS gc ON o.customer_id = gc.id
ORDER BY o.order_number ASC;
```

## Selecto

Shared domain configuration: [Join Domain Configuration](./DOMAIN_CONFIGURATION.md).

```elixir
gold_customers =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["id", "name", "tier"])
  |> Selecto.filter({"tier", "gold"})

query =
  Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
  |> Selecto.join_subquery(:gold_customers, gold_customers,
    type: :inner,
    on: [%{left: "customer_id", right: "id"}]
  )
  |> Selecto.select(["order_number", "gold_customers.name", "total"])
  |> Selecto.order_by({"order_number", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.order_number, gold_customers.name, selecto_root.total
        from orders selecto_root inner join (
        select subq_root_customers_gold_customers.id, subq_root_customers_gold_customers.name, subq_root_customers_gold_customers.tier
        from customers subq_root_customers_gold_customers
        where (( subq_root_customers_gold_customers.tier = $1 ))
      ) gold_customers on selecto_root.customer_id = gold_customers.id
        order by selecto_root.order_number asc
```

**Params:** `["gold"]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `inner join`
- includes keyword: `where`
- includes keyword: `order by`

## Notes

- `join_subquery/4` keeps tier filtering isolated while preserving root query clarity.
- Inner joining the filtered subquery avoids scanning unrelated customer rows.

## References

- [Join Domain Configuration](./DOMAIN_CONFIGURATION.md)
