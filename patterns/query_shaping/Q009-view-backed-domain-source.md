# Q009 View-Backed Domain Source

## Metadata

- Source: Selecto Views Support
- Source URL: https://github.com/seeken/selecto
- Source License: MIT
- Dialect: postgres
- Tags: shaping, view-backed-domain, source-kind, readonly, sigil

## Problem

Query a read-only reporting relation backed by a database view without changing
the normal Selecto query pipeline.

## SQL

```sql
SELECT ac.customer_id, ac.name, ac.tier
FROM active_customers_view AS ac
WHERE ac.tier = 'premium'
ORDER BY ac.name ASC;
```

## Selecto

```elixir
customer_tier = "premium"

query =
  Selecto.configure(active_customer_view_domain(), :mock_connection, validate: false)
  |> Selecto.select(["customer_id", "name", "tier"])
  |> Selecto.filter({"tier", customer_tier})
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Selecto Expr

```elixir
import Selecto.ExprMacros
import Selecto.Sigil

customer_tier = "premium"

Selecto.configure(active_customer_view_domain(), :mock_connection, validate: false)
|> Selecto.select(select([customer_id, name, tier]))
|> Selecto.filter(~SELECTO"tier == ^customer_tier")
|> Selecto.order_by(order_by([asc(name)]))
```

## Selecto Yielded SQL

```sql
select selecto_root.customer_id, selecto_root.name, selecto_root.tier
        from active_customers_view selecto_root
        where (( selecto_root.tier = $1 ))
      
        order by selecto_root.name asc
```

**Params:** `["premium"]`

## Expected SQL Shape

- includes keyword: `from active_customers_view`
- includes keyword: `where`
- includes keyword: `tier`
- includes keyword: `order by`

## Notes

- `source_kind: :view` and `readonly: true` change domain metadata, not the
  normal query-building surface.
- The `~SELECTO` sigil is a good fit when the view-backed example is mainly
  about readable filter authoring.
- Real apps may also point at schema-qualified view names when the configured
  adapter/name-validation path allows them.
