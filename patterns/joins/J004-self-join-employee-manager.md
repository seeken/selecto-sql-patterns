# J004 Self Join Employee Manager

## Metadata

- Source: Database Design - 2nd Edition
- Source URL: https://opentextbc.ca/dbdesign01/
- Source License: CC BY 4.0
- Dialect: postgres
- Tags: joins, self-join, hierarchy, left-join

## Problem

Show each employee with their manager name using a self-join style pattern.

## SQL

```sql
SELECT e.first_name AS employee_name, m.first_name AS manager_name
FROM employees AS e
LEFT JOIN employees AS m ON e.manager_id = m.id
ORDER BY e.first_name ASC;
```

## Selecto

Shared domain configuration: [Join Domain Configuration](./DOMAIN_CONFIGURATION.md).

```elixir
query =
  Selecto.configure(employee_domain_with_manager_join(), :mock_connection, validate: false)
  |> Selecto.select(["first_name", "manager.first_name"])
  |> Selecto.order_by({"first_name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `left join`
- includes keyword: `on`
- includes keyword: `order by`

## Notes

- Uses a domain-configured self-join (`manager`) against the same physical table.
- The join alias (`manager`) keeps the selected fields unambiguous.

## References

- [Join Domain Configuration](./DOMAIN_CONFIGURATION.md)
