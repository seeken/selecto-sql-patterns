# Portable Write Preview Patterns

Portable writes are governed domain intent, not hand-authored mutation SQL.
`selecto_updato` binds trusted scope and field policy into a
`Selecto.Write.Command`; the configured write-capable database adapter owns the
SQL dialect, parameters, transaction, and cardinality enforcement.

The current executable adapter example is PostgreSQL. The patterns below are
preview-only: they compile statements and parameters without changing data.

## Domain contract

```elixir
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
```

This contract makes three invariants data rather than caller convention:

- `tenant_id` comes from trusted tenant context and is added to every relevant
  assignment or predicate;
- `project_id` comes from trusted project context and carries a reference guard;
- the upsert conflict target and updateable conflict fields come from the
  domain, not request parameters.

## Insert with tenant and foreign-key guard

```elixir
operation =
  domain
  |> SelectoUpdato.new()
  |> SelectoUpdato.with_tenant(%{tenant_id: 7})
  |> SelectoUpdato.insert(%{external_id: "WI-100", title: "Inspect adapter"})

{:ok, preview} =
  SelectoUpdato.preview(operation, selecto,
    context: %{tenant_id: 7, project_id: 42}
  )
```

Representative adapter output:

```sql
INSERT INTO "work_items" ("external_id", "title", "tenant_id", "project_id")
SELECT $1, $2, $3, $4
WHERE EXISTS (SELECT 1 FROM "projects" WHERE "id" = $5)
```

The values stay in `preview.statements[*].params`; they are not interpolated
into SQL.

## Scoped update

```elixir
operation =
  domain
  |> SelectoUpdato.new()
  |> SelectoUpdato.with_tenant(%{tenant_id: 7})
  |> SelectoUpdato.filter({:id, 100})
  |> SelectoUpdato.update(%{state: "archived"})
```

The adapter preview must retain both the row target and tenant predicate:

```sql
UPDATE "work_items" SET "state" = $1
WHERE ("id" = $2 AND "tenant_id" = $3)
```

An update or delete with no governed predicate fails before execution.

## Domain-governed upsert

```elixir
operation =
  domain
  |> SelectoUpdato.new()
  |> SelectoUpdato.with_tenant(%{tenant_id: 7})
  |> SelectoUpdato.upsert(%{
    external_id: "WI-100",
    title: "Inspect adapter",
    state: "open"
  })
```

Representative output:

```sql
INSERT INTO "work_items" (...) VALUES (...)
ON CONFLICT ("tenant_id", "external_id")
DO UPDATE SET "title" = EXCLUDED."title", "state" = EXCLUDED."state"
```

The immutable conflict fields are absent from the update set. If multiple
conflict targets are declared, the caller may select one declared field list;
constraint names and raw fragments are rejected.

## Atomic selected-row action

For selected ids `[41, 42, 43]`, Updato produces a non-empty parameterized `IN`
predicate and `expected_cardinality: {:exactly, 3}`. The adapter executes inside
a transaction. If only two rows still satisfy all target, transition, and
tenant predicates, it rolls back the tentative mutation and returns
`:cardinality_mismatch`.

Preview is not the safety boundary. The final predicate and transactional
cardinality check are.

## Verify

Run the executable preview checks against the sibling packages:

```bash
elixir scripts/verify_portable_writes.exs
```

The script validates all four operation previews, trusted tenant binding,
foreign-key guarding, domain-governed conflict behavior, and the reusable
adapter conformance suite. It does not connect to a database or mutate data.
