# View-Backed Domains Guide

Use this guide when a Selecto domain points at a database view or materialized
view instead of a base table.

## When To Use

- reporting relations that already exist in the database
- read-only rollups backed by `CREATE VIEW`
- precomputed summaries backed by `CREATE MATERIALIZED VIEW`
- generated domains created from `mix selecto.gen.domain --view` or
  `--materialized-view`

## Required Metadata

- Set `source.source_kind` to `:view` or `:materialized_view`.
- Set `source.readonly` to `true` for view-backed sources.
- Declare an explicit `primary_key`; views often do not expose one cleanly.
- Keep `source.columns` typed the same way you would for a table-backed domain.

The same `source_kind` and `readonly` fields can also be used on joined schema
entries when a relation behind `schemas` is view-backed.

## Example: Existing Database View

```elixir
def domain do
  %{
    name: "Active Customers",
    source: %{
      source_table: "active_customers_view",
      primary_key: :customer_id,
      source_kind: :view,
      readonly: true,
      fields: [:customer_id, :name, :tier],
      redact_fields: [],
      columns: %{
        customer_id: %{type: :integer},
        name: %{type: :string},
        tier: %{type: :string}
      },
      associations: %{}
    },
    schemas: %{},
    joins: %{}
  }
end

query =
  Selecto.configure(domain(), :mock_connection, validate: false)
  |> Selecto.select(["customer_id", "name", "tier"])
  |> Selecto.order_by({"name", :asc})

{sql, params} = Selecto.to_sql(query)
```

## Example: Existing Materialized View

```elixir
def domain do
  %{
    name: "Daily Order Rollup",
    source: %{
      source_table: "daily_order_rollup_view",
      primary_key: :day,
      source_kind: :materialized_view,
      readonly: true,
      fields: [:day, :status, :order_count, :gross_total],
      redact_fields: [],
      columns: %{
        day: %{type: :date},
        status: %{type: :string},
        order_count: %{type: :integer},
        gross_total: %{type: :decimal}
      },
      associations: %{}
    },
    schemas: %{},
    joins: %{}
  }
end
```

## Generator Shortcuts

```bash
mix selecto.gen.domain --adapter postgresql --view reporting.active_customers --primary-key customer_id

mix selecto.gen.domain --adapter postgresql --materialized-view reporting.daily_order_rollup --primary-key day
```

## Notes

- Query building stays the same after configuration; the extra metadata is about
  relation identity and safety, not a different query API.
- Prefer explicit `readonly: true` for view-backed domains so downstream write or
  publication tooling can treat them correctly.
- If a generated reporting domain also needs custom joins, filters, or schemas,
  prefer adding them in an overlay instead of editing the generated base config.
- Real applications may use schema-qualified relation names; keep examples here
  verifier-friendly and confirm name-validation behavior in the target adapter
  path before depending on dotted relation names in docs or generated samples.
