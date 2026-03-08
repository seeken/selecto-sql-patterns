# SO008 Union With Column Mapping

## Metadata

- Source: PostgreSQL Tutorial
- Source URL: https://www.postgresql.org/docs/current/tutorial-sql.html
- Source License: PostgreSQL License
- Dialect: postgres
- Tags: set-operations, union, column-mapping

## Problem

Union customer and vendor-contact lists when equivalent columns use different names.

## SQL

```sql
SELECT c.name, c.tier
FROM customers AS c
UNION
SELECT vc.company_name, vc.segment
FROM vendor_contacts AS vc;
```

## Selecto

```elixir
customers =
  Selecto.configure(customer_domain(), :mock_connection, validate: false)
  |> Selecto.select(["name", "tier"])

vendor_contacts =
  Selecto.configure(vendor_contact_domain(), :mock_connection, validate: false)
  |> Selecto.select(["company_name", "segment"])

query =
  Selecto.union(customers, vendor_contacts,
    column_mapping: [
      {"name", "company_name"},
      {"tier", "segment"}
    ]
  )

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
(
        select selecto_root.name, selecto_root.tier
        from customers selecto_root)
UNION
(
        select selecto_root.company_name, selecto_root.segment
        from vendor_contacts selecto_root)
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `union`
- includes keyword: `from customers`
- includes keyword: `from vendor_contacts`

## Notes

- `column_mapping` documents equivalent columns across schemas for compatibility checks.
- Set operations still require compatible projection counts and types on both sides.
