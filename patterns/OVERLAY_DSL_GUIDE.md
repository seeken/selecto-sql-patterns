# Overlay DSL Guide

Use this guide when you need to extend a generated or shared Selecto domain
without rewriting the base domain map.

## Why Use Overlays

- keep generator-managed domains stable across refreshes
- add joins and schemas without replacing the whole registry
- attach source or schema associations in one customization layer
- concentrate user-owned query members, filters, and columns in one module

## Example: Add a Join and Schema

```elixir
defmodule MyApp.SelectoDomains.Overlays.OrderReportingOverlay do
  use Selecto.Config.OverlayDSL

  defschema(:customers, %{
    source_table: "customers",
    primary_key: :id,
    fields: [:id, :name, :tier],
    redact_fields: [],
    columns: %{
      id: %{type: :integer},
      name: %{type: :string},
      tier: %{type: :string}
    },
    associations: %{}
  })

  defsource_assoc(:customer, %{
    queryable: :customers,
    field: :customer,
    owner_key: :customer_id,
    related_key: :id
  })

  defjoin(:customer, %{
    name: "Customer",
    type: :left,
    source: "customers",
    on: [%{left: "customer_id", right: "id"}],
    fields: %{
      name: %{type: :string},
      tier: %{type: :string}
    }
  })
end

domain =
  base_order_domain()
  |> Selecto.Config.Overlay.merge(MyApp.SelectoDomains.Overlays.OrderReportingOverlay.overlay())

query =
  Selecto.configure(domain, :mock_connection, validate: false)
  |> Selecto.select(["order_number", "customer.name", "customer.tier"])

{sql, params} = Selecto.to_sql(query)
```

## Schema-Scoped Associations

Use `defschema_assoc/3` when a joined schema needs its own nested association
registry.

```elixir
defschema_assoc(:customer, :account_manager, %{
  queryable: :employee,
  field: :account_manager,
  owner_key: :account_manager_id,
  related_key: :id
})
```

## Merge Guidance

- Overlays are the preferred home for app-specific joins, schemas, and filters.
- Top-level `joins` and `schemas` are deep-merged, so overlays can extend them
  without replacing the rest of the registry.
- Reach for overlays before editing regenerated domain files by hand.

## Notes

- `defjoin/2` and `defschema/2` cover the main registry-level extension points.
- `defsource_assoc/2` adds root associations under `source.associations`.
- `defschema_assoc/3` adds associations under a joined schema entry.
- If an overlay also introduces query members or custom columns, keep those in
  the same overlay module so the customization surface stays discoverable.
