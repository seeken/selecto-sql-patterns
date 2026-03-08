# C002 With Recursive CTE Order Chain

## Metadata

- Source: Structured Query Language (Wikibooks)
- Source URL: https://en.wikibooks.org/wiki/Structured_Query_Language/with_clause
- Source License: CC BY-SA 4.0
- Dialect: postgres
- Tags: cte, recursive, with-recursive

## Problem

Build a recursive CTE structure and project recursive rows back into the root query.

## SQL

```sql
WITH RECURSIVE order_chain (id, status) AS (
  SELECT o.id, o.status
  FROM orders AS o
  WHERE o.status = 'processing'
  UNION ALL
  SELECT o2.id, o2.status
  FROM orders AS o2
)
SELECT o.order_number, oc.status
FROM orders AS o
LEFT JOIN order_chain AS oc ON oc.id = o.id;
```

## Selecto

```elixir
query =
  Selecto.configure(order_domain(), :mock_connection, validate: false)
  |> Selecto.with_recursive_cte("order_chain",
    base_query: fn ->
      Selecto.configure(order_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "status"])
      |> Selecto.filter({"status", "processing"})
    end,
    recursive_query: fn _cte_ref ->
      Selecto.configure(order_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "status"])
    end,
    columns: ["id", "status"],
    join: true
  )
  |> Selecto.select(["order_number", "order_chain.status"])

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
WITH RECURSIVE order_chain (id, status) AS (
    
        select selecto_root.id, selecto_root.status
        from orders selecto_root
        where (( selecto_root.status = $1 ))
      
    UNION ALL
    
        select selecto_root.id, selecto_root.status
        from orders selecto_root
)

        select selecto_root.order_number, order_chain.status
        from orders selecto_root left join order_chain order_chain on order_chain.id = selecto_root.id
```

**Params:** `["processing"]`

## Expected SQL Shape

- includes keyword: `with recursive`
- includes keyword: `union all`
- includes keyword: `left join`
- includes keyword: `select`

## Notes

- Recursive CTE wiring is useful for hierarchy/path scenarios once recursive step is expanded.
- Keep `columns` explicit so field inference for joins remains deterministic.
