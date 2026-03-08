# W006 Rank Salary By Department

## Metadata

- Source: Structured Query Language (Wikibooks)
- Source URL: https://en.wikibooks.org/wiki/Structured_Query_Language/Window_functions
- Source License: CC BY-SA 4.0
- Dialect: postgres
- Tags: windows, rank, partition, ordering

## Problem

Assign rank numbers to employee salaries within each department.

## SQL

```sql
SELECT
  e.first_name,
  e.department,
  e.salary,
  RANK() OVER (
    PARTITION BY e.department
    ORDER BY e.salary DESC
  ) AS department_rank
FROM employees AS e;
```

## Selecto

```elixir
query =
  Selecto.configure(employee_domain(), :mock_connection, validate: false)
  |> Selecto.select(["first_name", "department", "salary"])
  |> Selecto.window_function(:rank, [],
    over: [partition_by: ["department"], order_by: [{"salary", :desc}]],
    as: "department_rank"
  )

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.first_name, selecto_root.department, selecto_root.salary, RANK() OVER (PARTITION BY selecto_root.department ORDER BY selecto_root.salary DESC) AS department_rank
        from employees selecto_root
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `rank`
- includes keyword: `partition by`
- includes keyword: `order by`

## Notes

- Unlike `DENSE_RANK`, `RANK` leaves gaps after ties.
- Useful where tie-awareness matters for business rules.
