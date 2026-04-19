# Published Views Guide

Use this guide when a Selecto domain should publish a stable SQL view or
materialized view contract.

## What Published Views Add

- a named `published_views` registry on the domain
- validation that the published query selects stable aliased columns
- generated `CREATE VIEW` or `CREATE MATERIALIZED VIEW` DDL
- optional generated index statements for follow-up migration work

## Required Rules

- `:database_name` must be a non-empty string.
- `:kind` must be `:view` or `:materialized_view`.
- `:query` must be a function with arity `1` that returns a `Selecto` struct.
- `:columns` must exactly match the aliased columns selected by the query.
- Published view queries cannot depend on runtime bind params.

## Example Domain Configuration

```elixir
def domain do
  %{
    name: "Orders",
    source: %{
      source_table: "orders",
      primary_key: :id,
      fields: [:id, :status, :customer_id, :inserted_at],
      redact_fields: [],
      columns: %{
        id: %{type: :integer},
        status: %{type: :string},
        customer_id: %{type: :integer},
        inserted_at: %{type: :naive_datetime}
      },
      associations: %{}
    },
    schemas: %{},
    joins: %{},
    published_views: %{
      order_rollup: %{
        database_name: "reporting.order_rollup",
        kind: :view,
        query: &__MODULE__.order_rollup_query/1,
        columns: %{
          order_id: %{type: :integer},
          status: %{type: :string}
        },
        indexes: [
          %{columns: [:order_id], unique: true},
          %{columns: [:status]}
        ]
      },
      recent_order_snapshot: %{
        database_name: "reporting.recent_order_snapshot",
        kind: :materialized_view,
        query: &__MODULE__.recent_order_snapshot_query/1,
        columns: %{
          order_id: %{type: :integer},
          status: %{type: :string},
          inserted_at: %{type: :naive_datetime}
        },
        indexes: [
          %{columns: [:inserted_at, :status], concurrently: true}
        ]
      }
    }
  }
end

def order_rollup_query(selecto) do
  selecto
  |> Selecto.select([
    {:field, "id", "order_id"},
    {:field, "status", "status"}
  ])
end

def recent_order_snapshot_query(selecto) do
  selecto
  |> Selecto.select([
    {:field, "id", "order_id"},
    {:field, "status", "status"},
    {:field, "inserted_at", "inserted_at"}
  ])
end
```

## Build SQL and DDL

```elixir
spec = domain().published_views.order_rollup

{:ok, result} = Selecto.ViewPublisher.build_sql(domain(), spec)

result.sql
result.ddl
result.index_statements
```

For materialized views, generate refresh SQL explicitly:

```elixir
Selecto.ViewPublisher.refresh_sql("reporting.recent_order_snapshot", concurrently: true)
```

## Mix Task Flow

```bash
mix selecto.gen.view MyApp.SelectoDomains.OrderDomain order_rollup --dry-run

mix selecto.gen.view MyApp.SelectoDomains.OrderDomain recent_order_snapshot --repo-module MyApp.Repo
```

## Notes

- Published views are for stable read contracts, not ad hoc runtime queries.
- Keep selected aliases explicit and durable; alias drift will fail validation.
- Put migration-time concerns such as index follow-up beside the published view
  spec instead of hiding them in a separate notebook or release checklist.
- In current verification, publishability keys off Selecto's selected-alias
  metadata via `Selecto.ViewPublisher.build_sql/2`; inspect the published-view
  build output directly instead of assuming the plain `Selecto.to_sql/1` text is
  the whole publication contract.
