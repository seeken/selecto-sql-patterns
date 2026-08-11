workspace = Path.expand("..", __DIR__) |> Path.dirname()

selecto_path = System.get_env("SELECTO_PATH") || Path.join(workspace, "selecto")
updato_path = System.get_env("SELECTO_UPDATO_PATH") || Path.join(workspace, "selecto_updato")

postgres_path =
  System.get_env("SELECTO_DB_POSTGRESQL_PATH") ||
    Path.join(workspace, "selecto_db_postgresql")

Mix.install([
  {:selecto, path: selecto_path},
  {:selecto_updato, path: updato_path},
  {:selecto_db_postgresql, path: postgres_path}
])

alias Selecto.Write.AdapterConformance
alias SelectoDBPostgreSQL.Adapter

domain = %{
  source: %{
    source_table: "work_items",
    primary_key: :id,
    fields: [:id, :tenant_id, :external_id, :project_id, :title, :state],
    columns: %{
      id: %{type: :integer},
      tenant_id: %{type: :integer},
      external_id: %{type: :string},
      project_id: %{type: :integer},
      title: %{type: :string},
      state: %{type: :string}
    },
    associations: %{}
  },
  schemas: %{},
  writes: %{
    operations: %{
      insert: %{enabled: true, expected_cardinality: {:exactly, 1}},
      update: %{enabled: true, require_filter: true},
      upsert: %{
        enabled: true,
        conflict_targets: [[:tenant_id, :external_id]],
        expected_cardinality: {:exactly, 1}
      },
      delete: %{enabled: true, require_filter: true}
    },
    fields: %{
      tenant_id: %{insertable: true, immutable: true},
      external_id: %{insertable: true, immutable: true},
      project_id: %{insertable: true, updatable: true},
      title: %{insertable: true, updatable: true},
      state: %{insertable: true, updatable: true}
    },
    scope: %{
      tenant: %{required: true, field: :tenant_id, satisfied_by: [:trusted_context]}
    },
    constraints: %{
      foreign_keys: %{
        project_id: %{
          source: {:context, :project_id},
          references: %{relation: "projects", field: :id},
          required: true
        }
      }
    }
  }
}

selecto = struct(Selecto, adapter: Adapter, connection: :preview_only)
context = %{tenant_id: 7, project_id: 42}

preview! = fn operation ->
  case SelectoUpdato.preview(operation, selecto, context: context) do
    {:ok, %{statements: [%{text: text, params: params}]} = preview}
    when is_binary(text) and is_list(params) ->
      preview

    other ->
      raise "portable write preview failed: #{inspect(other)}"
  end
end

base = fn ->
  domain
  |> SelectoUpdato.new()
  |> SelectoUpdato.with_tenant(%{tenant_id: 7})
end

insert =
  base.()
  |> SelectoUpdato.insert(%{external_id: "WI-100", title: "Inspect adapter"})
  |> preview!.()

[%{text: insert_sql, params: insert_params}] = insert.statements
true = insert_sql =~ "INSERT INTO \"work_items\""
true = insert_sql =~ "EXISTS (SELECT 1 FROM \"projects\" WHERE \"id\" = $"
true = 7 in insert_params
true = 42 in insert_params

update =
  base.()
  |> SelectoUpdato.filter({:id, 100})
  |> SelectoUpdato.update(%{state: "archived"})
  |> preview!.()

[%{text: update_sql, params: ["archived", 100, 7]}] = update.statements
true = update_sql =~ "UPDATE \"work_items\""
true = update_sql =~ "\"tenant_id\" = $3"

upsert =
  base.()
  |> SelectoUpdato.upsert(%{
    external_id: "WI-100",
    title: "Inspect adapter",
    state: "open"
  })
  |> preview!.()

[%{text: upsert_sql}] = upsert.statements
true = upsert_sql =~ "ON CONFLICT (\"tenant_id\", \"external_id\")"
true = upsert_sql =~ "\"title\" = EXCLUDED.\"title\""
false = upsert_sql =~ "\"external_id\" = EXCLUDED.\"external_id\""

delete =
  base.()
  |> SelectoUpdato.filter({:id, 100})
  |> SelectoUpdato.delete()
  |> preview!.()

[%{text: delete_sql, params: [100, 7]}] = delete.statements
true = delete_sql =~ "DELETE FROM \"work_items\""
true = delete_sql =~ "\"tenant_id\" = $2"

{:ok, report} = AdapterConformance.check(selecto)
[:insert, :update, :upsert, :delete] = report.operations

IO.puts("Verified portable insert, update, upsert, delete, and adapter conformance previews")
