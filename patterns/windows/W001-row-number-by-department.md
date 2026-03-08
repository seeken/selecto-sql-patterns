# W001 Row Number By Department

## Metadata

- Source: Structured Query Language (Wikibooks)
- Source URL: https://en.wikibooks.org/wiki/Structured_Query_Language/Window_functions
- Source License: CC BY-SA 4.0
- Dialect: postgres
- Tags: windows, row-number, partition, ranking

## Problem

Rank employees by salary within each department.

## SQL

```sql
SELECT
  e.first_name,
  e.department,
  e.salary,
  ROW_NUMBER() OVER (
    PARTITION BY e.department
    ORDER BY e.salary DESC
  ) AS department_salary_rank
FROM employees AS e;
```

## Selecto

```elixir
query =
  Selecto.configure(employee_domain(), :mock_connection, validate: false)
  |> Selecto.select(["first_name", "department", "salary"])
  |> Selecto.window_function(:row_number, [],
    over: [partition_by: ["department"], order_by: [{"salary", :desc}]],
    as: "department_salary_rank"
  )

{sql, params} = Selecto.to_sql(query)
```

## Selecto Yielded SQL

```sql
select selecto_root.first_name, selecto_root.department, selecto_root.salary, ROW_NUMBER() OVER (PARTITION BY selecto_root.department ORDER BY selecto_root.salary DESC) AS department_salary_rank
        from employees selecto_root
```

**Params:** `[]`

## Expected SQL Shape

- includes keyword: `select`
- includes keyword: `row_number`
- includes keyword: `over`
- includes keyword: `partition by`

## Notes

- Uses the dedicated `Selecto.window_function/4` API.
- Keeps base columns plus analytic output in a single pass.
