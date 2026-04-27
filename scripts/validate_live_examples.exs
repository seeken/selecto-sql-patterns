#!/usr/bin/env elixir

System.put_env("SELECTO_SQL_PATTERNS_NO_AUTO", "1")
System.put_env("SELECTO_SQL_PATTERNS_LIVE_VALIDATION", "1")
Code.require_file("verify_examples.exs", __DIR__)

defmodule SelectoSqlPatterns.LiveValidation do
  @moduledoc false

  @output_path "patterns/SELECTO_LIVE_VALIDATION.json"
  @tmp_dir Path.expand("../tmp/live_validation", __DIR__)

  @smoke_patterns [
    %{id: "J001", assert: {:columns_include, ["order_number", "name"]}},
    %{id: "A003", assert: {:columns_include, ["status"]}},
    %{id: "E001", assert: {:columns_include, ["order_number", "status"]}},
    %{
      id: "E002",
      assert: {:columns_include, ["order_number"]}
    },
    %{
      id: "E003",
      assert: {:columns_include, ["status"]},
      adapters: %{
        "sqlite" =>
          {:generated_only,
           "SQLite smoke validation does not register stddev/variance aggregate functions."}
      }
    },
    %{id: "E004", assert: {:columns_include, ["tier", "status"]}},
    %{id: "W001", assert: {:columns_include, ["first_name", "department", "salary"]}},
    %{id: "P002", assert: {:columns_include, ["id", "order_number", "total"]}},
    %{id: "T001", assert: {:columns_include, ["order_number", "inserted_at", "total"]}},
    %{
      id: "J007",
      assert: {:columns_include, ["name"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Lateral join smoke case needs a richer seeded product/order dataset before live execution is meaningful."},
        "sqlite" => {:unsupported_expected, "Adapter does not support lateral/apply joins"},
        "mysql" => {:unsupported_expected, "Adapter does not support lateral/apply joins"},
        "mariadb" => {:unsupported_expected, "Adapter does not support lateral/apply joins"},
        "mssql" =>
          {:generated_only,
           "APPLY join smoke case needs a richer seeded product/order dataset before live execution is meaningful."},
        "duckdb" => {:unsupported_expected, "Adapter does not support lateral/apply joins"}
      }
    },
    %{
      id: "SO001",
      assert: {:columns_include, ["name", "tier"]},
      adapters: %{
        "sqlite" =>
          {:generated_only,
           "SQLite still rejects the parenthesized UNION form generated for this pattern during execution."}
      }
    },
    %{
      id: "F004",
      assert: {:columns_include, ["name", "sku"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "PostgreSQL smoke validation still needs seeded text-search indexes before this pattern can execute live."},
        "sqlite" =>
          {:unsupported_expected,
           "SQLite needs an FTS5-backed field configuration before this text-search pattern can execute."},
        "mysql" =>
          {:generated_only,
           "MySQL smoke validation still needs a MATCH-compatible full-text index before this pattern can execute live."},
        "mariadb" =>
          {:unsupported_expected,
           "MariaDB text-search support is not wired into this smoke harness yet."},
        "mssql" =>
          {:unsupported_expected,
           "MSSQL full-text search support is not wired into this smoke harness yet."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB does not currently support the text-search feature used by this pattern."}
      }
    },
    %{
      id: "JA002",
      assert: {:columns_include, ["name"]},
      adapters: %{
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB JSON field-path validation is not wired into this harness yet."}
      }
    },
    %{
      id: "JA001",
      assert: {:columns_include, ["name", "sku"]},
      adapters: %{
        "sqlite" =>
          {:unsupported_expected,
           "SQLite does not support the JSON containment helper used by this pattern."},
        "duckdb" =>
          {:unsupported_expected, "DuckDB JSON containment is not wired into this harness yet."}
      }
    },
    %{
      id: "JA004",
      assert: {:columns_include, ["name"]},
      adapters: %{
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB JSON path-exists validation is not wired into this harness yet."}
      }
    },
    %{
      id: "JA005",
      assert: {:columns_include, ["name", "sku"]},
      adapters: %{
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB JSON order-by validation is not wired into this harness yet."}
      }
    },
    %{
      id: "JA007",
      assert: {:columns_include, ["name", "sku"]},
      adapters: %{
        "sqlite" =>
          {:generated_only,
           "SQLite JSON field-path equality still needs boolean coercion handling in the smoke fixture to execute live."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB JSON field-path equality is not wired into this harness yet."}
      }
    },
    %{
      id: "JA008",
      assert: {:columns_include, ["name", "sku"]},
      adapters: %{
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB JSON multi-select extraction is not wired into this harness yet."}
      }
    },
    %{
      id: "JA003",
      assert: {:columns_include, ["name"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Array-overlap smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "sqlite" =>
          {:generated_only,
           "Array-overlap smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "mysql" =>
          {:generated_only,
           "Array-overlap smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "mariadb" =>
          {:generated_only,
           "Array-overlap smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "mssql" =>
          {:generated_only,
           "Array-overlap smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB array overlap validation is not wired into this harness yet."}
      }
    },
    %{
      id: "JA006",
      assert: {:columns_include, ["name"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Array-containment smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "sqlite" =>
          {:generated_only,
           "Array-containment smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "mysql" =>
          {:generated_only,
           "Array-containment smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "mariadb" =>
          {:generated_only,
           "Array-containment smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "mssql" =>
          {:generated_only,
           "Array-containment smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB array containment validation is not wired into this harness yet."}
      }
    },
    %{
      id: "Q006",
      assert: {:columns_include, ["name", "tier"]},
      adapters: %{
        "duckdb" =>
          {:generated_only,
           "DuckDB query-member shape validation needs a dedicated smoke assertion for subquery member aliases."}
      }
    },
    %{
      id: "Q007",
      assert: {:columns_include, ["order_number"]},
      adapters: %{
        "duckdb" =>
          {:generated_only,
           "DuckDB CTE shape validation needs a dedicated smoke assertion for joined CTE aliases."}
      }
    },
    %{
      id: "Q008",
      assert: {:columns_include, ["order_number", "total"]},
      adapters: %{
        "sqlite" =>
          {:generated_only,
           "SQLite still rejects the parenthesized set-operation form generated for this query-shaping pattern."}
      }
    },
    %{id: "W002", assert: {:columns_include, ["id", "customer_id", "total"]}},
    %{id: "W003", assert: {:columns_include, ["id", "customer_id", "total"]}},
    %{id: "W004", assert: {:columns_include, ["order_number", "total"]}},
    %{id: "T002", assert: {:columns_include, ["order_number", "inserted_at", "total"]}},
    %{id: "T004", assert: {:columns_include, ["order_number", "inserted_at", "total"]}},
    %{id: "W005", assert: {:columns_include, ["id", "total"]}},
    %{id: "W006", assert: {:columns_include, ["first_name", "department", "salary"]}},
    %{id: "W007", assert: {:columns_include, ["id", "customer_id", "total"]}},
    %{id: "W008", assert: {:columns_include, ["order_number", "status", "total"]}},
    %{id: "T005", assert: {:columns_include, ["order_number", "inserted_at", "total"]}},
    %{id: "W009", assert: {:columns_include, ["order_number", "total"]}},
    %{id: "W010", assert: {:columns_include, ["id", "customer_id", "total"]}},
    %{id: "T006", assert: {:columns_include, ["order_number", "status", "inserted_at", "total"]}},
    %{id: "T007", assert: {:columns_include, ["id", "order_number", "inserted_at", "total"]}},
    %{
      id: "T008",
      assert: {:columns_include, ["order_number", "inserted_at", "total"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "PostgreSQL still needs a simplified UNION wrapper for this timeseries set-operation pattern."},
        "sqlite" =>
          {:generated_only,
           "SQLite still needs a less parenthesized UNION form for this timeseries set-operation pattern."},
        "mysql" =>
          {:generated_only,
           "MySQL still needs a simplified UNION wrapper for this timeseries set-operation pattern."},
        "mariadb" =>
          {:generated_only,
           "MariaDB still needs a simplified UNION wrapper for this timeseries set-operation pattern."},
        "mssql" =>
          {:generated_only,
           "MSSQL still needs a simplified UNION wrapper for this timeseries set-operation pattern."},
        "duckdb" =>
          {:generated_only,
           "DuckDB still needs a simplified UNION wrapper for this timeseries set-operation pattern."}
      }
    },
    %{id: "S001", assert: {:columns_include, ["order_number", "customer_id", "status", "total"]}},
    %{id: "S002", assert: {:columns_include, ["name"]}},
    %{id: "S003", assert: {:columns_include, ["order_number", "status", "total"]}},
    %{id: "S004", assert: {:columns_include, ["name"]}},
    %{id: "S005", assert: {:columns_include, ["order_number", "customer_id", "total"]}},
    %{id: "S006", assert: {:columns_include, ["order_number", "status", "total"]}},
    %{id: "S007", assert: {:columns_include, ["order_number", "customer_id", "total"]}},
    %{
      id: "S008",
      assert: {:columns_include, ["order_number", "status", "total"]},
      adapters: %{
        "sqlite" =>
          {:generated_only,
           "SQLite quantifier subqueries with ALL still need dedicated live-execution handling in this smoke harness."}
      }
    },
    %{
      id: "S009",
      assert: {:columns_include, ["order_number", "status", "total"]},
      adapters: %{
        "sqlite" =>
          {:generated_only,
           "SQLite quantifier subqueries with ANY still need dedicated live-execution handling in this smoke harness."}
      }
    },
    %{id: "S010", assert: {:columns_include, ["order_number", "customer_id", "total"]}},
    %{
      id: "SO002",
      assert: {:columns_include, ["order_number", "total"]},
      adapters: %{
        "sqlite" =>
          {:generated_only,
           "SQLite still needs set-operation execution handling for this UNION ALL smoke case."}
      }
    },
    %{
      id: "SO003",
      assert: {:columns_include, ["id", "name"]},
      adapters: %{
        "sqlite" =>
          {:generated_only,
           "SQLite still needs INTERSECT execution handling in this smoke harness."}
      }
    },
    %{
      id: "SO004",
      assert: {:columns_include, ["id", "name"]},
      adapters: %{
        "sqlite" =>
          {:generated_only, "SQLite still needs EXCEPT execution handling in this smoke harness."}
      }
    },
    %{
      id: "SO005",
      assert: {:columns_include, ["id", "name"]},
      adapters: %{
        "sqlite" =>
          {:generated_only,
           "SQLite still needs nested INTERSECT execution handling in this smoke harness."}
      }
    },
    %{
      id: "SO006",
      assert: {:columns_include, ["id", "name"]},
      adapters: %{
        "sqlite" =>
          {:generated_only,
           "SQLite still needs INTERSECT ALL execution handling in this smoke harness."},
        "mssql" =>
          {:generated_only,
           "MSSQL still needs INTERSECT ALL execution handling in this smoke harness."}
      }
    },
    %{id: "F001", assert: {:columns_include, ["order_number", "name", "status"]}},
    %{id: "F002", assert: {:columns_include, ["order_number", "status", "total"]}},
    %{id: "F003", assert: {:columns_include, ["order_number", "status", "total"]}},
    %{id: "F005", assert: {:columns_include, ["order_number", "status", "total"]}},
    %{
      id: "F006",
      assert: {:columns_include, ["name"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Array-contains smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "sqlite" =>
          {:generated_only,
           "Array-contains smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "mysql" =>
          {:generated_only,
           "Array-contains smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "mariadb" =>
          {:generated_only,
           "Array-contains smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "mssql" =>
          {:generated_only,
           "Array-contains smoke validation still needs adapter-specific array fixtures instead of JSON-backed tag storage."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB array containment validation is not wired into this harness yet."}
      }
    },
    %{
      id: "F007",
      assert: {:columns_include, ["name"]},
      adapters: %{
        "duckdb" =>
          {:generated_only,
           "DuckDB still needs JSON field-exists path extraction support for this smoke case."}
      }
    },
    %{id: "F008", assert: {:columns_include, ["order_number", "customer_id", "total"]}},
    %{id: "P001", assert: {:columns_include, ["id", "order_number", "total"]}},
    %{id: "P003", assert: {:columns_include, ["id", "order_number", "total"]}},
    %{id: "P004", assert: {:columns_include, ["order_number", "name", "total"]}},
    %{id: "P005", assert: {:columns_include, ["id", "order_number", "inserted_at", "total"]}},
    %{id: "P006", assert: {:columns_include, ["id", "order_number", "total"]}},
    %{
      id: "P007",
      assert: {:columns_include, ["order_number", "total"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Set-operation pagination still needs a simplified UNION wrapper or a larger fixture window for live execution."},
        "sqlite" =>
          {:generated_only,
           "SQLite still needs set-operation pagination execution handling for this UNION ALL pattern."},
        "mysql" =>
          {:generated_only,
           "Set-operation pagination still needs a simplified UNION wrapper or a larger fixture window for live execution."},
        "mariadb" =>
          {:generated_only,
           "Set-operation pagination still needs a simplified UNION wrapper or a larger fixture window for live execution."},
        "mssql" =>
          {:generated_only,
           "Set-operation pagination still needs a simplified UNION wrapper or a larger fixture window for live execution."},
        "duckdb" =>
          {:generated_only,
           "Set-operation pagination still needs a simplified UNION wrapper or a larger fixture window for live execution."}
      }
    },
    %{id: "P008", assert: {:columns_include, ["id", "order_number", "total"]}},
    %{
      id: "SO007",
      assert: {:columns_include, ["id", "name"]},
      adapters: %{
        "sqlite" =>
          {:generated_only,
           "SQLite still needs EXCEPT ALL execution handling in this smoke harness."},
        "mssql" =>
          {:generated_only,
           "MSSQL still needs EXCEPT ALL execution handling in this smoke harness."}
      }
    },
    %{
      id: "SO008",
      assert: {:columns_include, ["name", "tier"]},
      adapters: %{
        "sqlite" =>
          {:generated_only,
           "SQLite still needs set-operation execution handling for this column-mapped UNION smoke case."}
      }
    },
    %{
      id: "Q001",
      assert: {:columns_include, ["name", "email"]},
      adapters: %{
        "duckdb" =>
          {:generated_only,
           "DuckDB still needs a compatible JSON object aggregation strategy for subselect output."}
      }
    },
    %{id: "Q002", assert: {:columns_include, ["product_name", "quantity"]}},
    %{id: "Q003", assert: {:columns_include, ["product_name", "quantity"]}},
    %{
      id: "Q004",
      assert: {:columns_include, ["name", "email"]},
      adapters: %{
        "duckdb" =>
          {:generated_only,
           "DuckDB still needs a compatible JSON object aggregation strategy for multi-subselect output."}
      }
    },
    %{id: "Q005", assert: {:columns_include, ["name", "email"]}},
    %{id: "Q009", assert: {:columns_include, ["customer_id", "name", "tier"]}},
    %{id: "Q010", assert: {:columns_include, ["order_number", "status", "name"]}},
    %{
      id: "G001",
      assert: {:columns_include, ["id", "name"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Spatial predicate smoke validation requires geo fixtures and is not executed in this harness."},
        "sqlite" =>
          {:unsupported_expected, "SQLite has no spatial adapter configured in this harness."},
        "mysql" =>
          {:generated_only,
           "Spatial predicate smoke validation requires geo fixtures and is not executed in this harness."},
        "mariadb" =>
          {:generated_only,
           "Spatial predicate smoke validation requires geo fixtures and is not executed in this harness."},
        "mssql" =>
          {:generated_only,
           "Spatial predicate smoke validation requires geo fixtures and is not executed in this harness."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB spatial smoke execution is not wired into this harness."}
      }
    },
    %{
      id: "G002",
      assert: {:columns_include, ["id", "name"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Spatial exists-join smoke validation requires geo fixtures and is not executed in this harness."},
        "sqlite" =>
          {:unsupported_expected, "SQLite has no spatial adapter configured in this harness."},
        "mysql" =>
          {:generated_only,
           "Spatial exists-join smoke validation requires geo fixtures and is not executed in this harness."},
        "mariadb" =>
          {:generated_only,
           "Spatial exists-join smoke validation requires geo fixtures and is not executed in this harness."},
        "mssql" =>
          {:generated_only,
           "Spatial exists-join smoke validation requires geo fixtures and is not executed in this harness."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB spatial smoke execution is not wired into this harness."}
      }
    },
    %{
      id: "G003",
      assert: {:columns_include, ["id", "name"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Spatial containment smoke validation requires geo fixtures and is not executed in this harness."},
        "sqlite" =>
          {:unsupported_expected, "SQLite has no spatial adapter configured in this harness."},
        "mysql" =>
          {:generated_only,
           "Spatial containment smoke validation requires geo fixtures and is not executed in this harness."},
        "mariadb" =>
          {:generated_only,
           "Spatial containment smoke validation requires geo fixtures and is not executed in this harness."},
        "mssql" =>
          {:generated_only,
           "Spatial containment smoke validation requires geo fixtures and is not executed in this harness."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB spatial smoke execution is not wired into this harness."}
      }
    },
    %{
      id: "G004",
      assert: {:columns_include, ["id", "name"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Spatial bbox smoke validation requires geo fixtures and is not executed in this harness."},
        "sqlite" =>
          {:unsupported_expected, "SQLite has no spatial adapter configured in this harness."},
        "mysql" =>
          {:generated_only,
           "Spatial bbox smoke validation requires geo fixtures and is not executed in this harness."},
        "mariadb" =>
          {:generated_only,
           "Spatial bbox smoke validation requires geo fixtures and is not executed in this harness."},
        "mssql" =>
          {:generated_only,
           "Spatial bbox smoke validation requires geo fixtures and is not executed in this harness."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB spatial smoke execution is not wired into this harness."}
      }
    },
    %{
      id: "G005",
      assert: {:columns_include, ["id", "name"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Spatial buffer/intersects smoke validation requires geo fixtures and is not executed in this harness."},
        "sqlite" =>
          {:unsupported_expected, "SQLite has no spatial adapter configured in this harness."},
        "mysql" =>
          {:generated_only,
           "Spatial buffer/intersects smoke validation requires geo fixtures and is not executed in this harness."},
        "mariadb" =>
          {:generated_only,
           "Spatial buffer/intersects smoke validation requires geo fixtures and is not executed in this harness."},
        "mssql" =>
          {:generated_only,
           "Spatial buffer/intersects smoke validation requires geo fixtures and is not executed in this harness."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB spatial smoke execution is not wired into this harness."}
      }
    },
    %{
      id: "G006",
      assert: {:columns_include, ["id", "name"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Spatial distance-order smoke validation requires geo fixtures and is not executed in this harness."},
        "sqlite" =>
          {:unsupported_expected, "SQLite has no spatial adapter configured in this harness."},
        "mysql" =>
          {:generated_only,
           "Spatial distance-order smoke validation requires geo fixtures and is not executed in this harness."},
        "mariadb" =>
          {:generated_only,
           "Spatial distance-order smoke validation requires geo fixtures and is not executed in this harness."},
        "mssql" =>
          {:generated_only,
           "Spatial distance-order smoke validation requires geo fixtures and is not executed in this harness."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB spatial smoke execution is not wired into this harness."}
      }
    },
    %{
      id: "G007",
      assert: {:columns_include, ["geom_type"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Spatial grouping smoke validation requires geo fixtures and is not executed in this harness."},
        "sqlite" =>
          {:unsupported_expected, "SQLite has no spatial adapter configured in this harness."},
        "mysql" =>
          {:generated_only,
           "Spatial grouping smoke validation requires geo fixtures and is not executed in this harness."},
        "mariadb" =>
          {:generated_only,
           "Spatial grouping smoke validation requires geo fixtures and is not executed in this harness."},
        "mssql" =>
          {:generated_only,
           "Spatial grouping smoke validation requires geo fixtures and is not executed in this harness."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB spatial smoke execution is not wired into this harness."}
      }
    },
    %{
      id: "G008",
      assert: {:columns_include, ["id", "name"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "Spatial parameterized exists smoke validation requires geo fixtures and is not executed in this harness."},
        "sqlite" =>
          {:unsupported_expected, "SQLite has no spatial adapter configured in this harness."},
        "mysql" =>
          {:generated_only,
           "Spatial parameterized exists smoke validation requires geo fixtures and is not executed in this harness."},
        "mariadb" =>
          {:generated_only,
           "Spatial parameterized exists smoke validation requires geo fixtures and is not executed in this harness."},
        "mssql" =>
          {:generated_only,
           "Spatial parameterized exists smoke validation requires geo fixtures and is not executed in this harness."},
        "duckdb" =>
          {:unsupported_expected,
           "DuckDB spatial smoke execution is not wired into this harness."}
      }
    },
    %{id: "C001", assert: {:columns_include, ["order_number"]}},
    %{
      id: "C004",
      assert: {:columns_include, ["order_number"]},
      adapters: %{}
    },
    %{id: "C002", assert: {:columns_include, ["order_number"]}},
    %{id: "C003", assert: {:columns_include, ["order_number"]}},
    %{id: "C005", assert: {:columns_include, ["order_number"]}},
    %{id: "C006", assert: {:columns_include, ["order_number"]}},
    %{id: "C007", assert: {:columns_include, ["order_number"]}},
    %{id: "A001", assert: {:columns_include, ["status"]}},
    %{id: "A002", assert: {:columns_include, ["customer_id"]}},
    %{id: "A004", assert: {:columns_include, ["name"]}},
    %{id: "A005", assert: {:columns_include, ["tier"]}},
    %{id: "A006", assert: {:columns_include, ["tier"]}},
    %{id: "A007", assert: {:columns_include, ["status"]}},
    %{id: "A008", assert: {:columns_include, ["tier"]}},
    %{id: "A009", assert: {:columns_include, ["status"]}},
    %{id: "A010", assert: {:columns_include, ["name"]}},
    %{
      id: "C008",
      assert: {:columns_include, ["order_number", "status", "status_label"]},
      adapters: %{}
    },
    %{id: "J002", assert: {:columns_include, ["name"]}},
    %{id: "J003", assert: {:columns_include, ["name", "tier", "order_number", "total"]}},
    %{id: "J004", assert: {:columns_include, ["first_name"]}},
    %{id: "J005", assert: {:columns_include, ["name"]}},
    %{id: "J006", assert: {:columns_include, ["order_number"]}},
    %{
      id: "J008",
      assert: {:columns_include, ["name", "product_tag"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "UNNEST join smoke validation still needs true array-backed tags fixtures instead of JSON/text tags."},
        "sqlite" =>
          {:generated_only,
           "UNNEST join smoke validation still needs true array-backed tags fixtures instead of JSON/text tags."},
        "mysql" =>
          {:generated_only,
           "UNNEST join smoke validation still needs true array-backed tags fixtures instead of JSON/text tags."},
        "mariadb" =>
          {:generated_only,
           "UNNEST join smoke validation still needs true array-backed tags fixtures instead of JSON/text tags."},
        "mssql" =>
          {:generated_only,
           "UNNEST join smoke validation still needs true array-backed tags fixtures instead of JSON/text tags."},
        "duckdb" =>
          {:generated_only,
           "UNNEST join smoke validation still needs true array-backed tags fixtures instead of JSON/text tags."}
      }
    },
    %{id: "J009", assert: {:columns_include, ["order_number"]}},
    %{id: "J010", assert: {:columns_include, ["name"]}},
    %{id: "J011", assert: {:columns_include, ["order_number", "name", "total"]}},
    %{id: "J012", assert: {:columns_include, ["name", "tier", "order_number"]}},
    %{
      id: "T003",
      assert: {:columns_include, ["order_number", "total"]},
      adapters: %{
        "postgresql" =>
          {:generated_only,
           "date_trunc day-bucket smoke validation still needs proper structured datetime truncation support in Selecto."},
        "sqlite" =>
          {:generated_only,
           "date_trunc day-bucket smoke validation still needs proper structured datetime truncation support in Selecto."},
        "mysql" =>
          {:generated_only,
           "date_trunc day-bucket smoke validation still needs proper structured datetime truncation support in Selecto."},
        "mariadb" =>
          {:generated_only,
           "date_trunc day-bucket smoke validation still needs proper structured datetime truncation support in Selecto."},
        "mssql" =>
          {:generated_only,
           "date_trunc day-bucket smoke validation still needs proper structured datetime truncation support in Selecto."},
        "duckdb" =>
          {:generated_only,
           "date_trunc day-bucket smoke validation still needs proper structured datetime truncation support in Selecto."}
      }
    }
  ]

  @adapters [
    %{
      key: "postgresql",
      label: "PostgreSQL",
      module: SelectoDBPostgreSQL.Adapter,
      connection: :postgresql
    },
    %{key: "sqlite", label: "SQLite", module: SelectoDBSQLite.Adapter, connection: :sqlite},
    %{key: "mysql", label: "MySQL", module: SelectoDBMySQL.Adapter, connection: :mysql},
    %{key: "mariadb", label: "MariaDB", module: SelectoDBMariaDB.Adapter, connection: :mariadb},
    %{key: "mssql", label: "MSSQL", module: SelectoDBMSSQL.Adapter, connection: :mssql},
    %{key: "duckdb", label: "DuckDB", module: SelectoDBDuckDB.Adapter, connection: :duckdb}
  ]

  def run(argv \\ System.argv()) do
    opts = parse_args(argv)
    File.mkdir_p!(@tmp_dir)

    contexts = connect_available_adapters(opts)
    payload = build_payload(contexts)
    output_path = opts[:output] || @output_path

    File.write!(output_path, Jason.encode_to_iodata!(payload, pretty: true))
    IO.puts("Wrote #{output_path}")

    if opts[:summary] do
      print_summary(payload)
    end
  end

  defp parse_args(argv) do
    {opts, _args, _invalid} =
      OptionParser.parse(argv,
        strict: [output: :string, summary: :boolean],
        aliases: [o: :output]
      )

    Keyword.put_new(opts, :summary, true)
  end

  defp build_payload(contexts) do
    patterns =
      Enum.into(@smoke_patterns, %{}, fn spec ->
        {spec.id,
         Enum.into(@adapters, %{}, fn adapter ->
           {adapter.key, validate_pattern(spec, adapter, Map.get(contexts, adapter.key))}
         end)}
      end)

    %{
      generated_at: DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601(),
      mode: "smoke",
      adapters: Enum.map(@adapters, &Map.take(&1, [:key, :label])),
      patterns: patterns
    }
  end

  defp connect_available_adapters(opts) do
    Enum.into(@adapters, %{}, fn adapter ->
      {adapter.key, connect_and_seed(adapter, opts)}
    end)
  end

  defp connect_and_seed(adapter, _opts) do
    with {:ok, connection_opts} <- connection_options(adapter.connection),
         {:ok, connection} <- adapter.module.connect(connection_opts),
         :ok <- seed_fixture_data(adapter, connection) do
      %{status: :ok, connection: connection}
    else
      {:skip, reason} -> %{status: :skipped, reason: reason}
      {:error, reason} -> %{status: :skipped, reason: inspect(reason)}
    end
  end

  defp connection_options(:postgresql) do
    env_connection_options("SELECTO_LIVE_POSTGRES")
  end

  defp connection_options(:mysql) do
    env_connection_options("SELECTO_LIVE_MYSQL")
  end

  defp connection_options(:mariadb) do
    env_connection_options("SELECTO_LIVE_MARIADB")
  end

  defp connection_options(:mssql) do
    env_connection_options("SELECTO_LIVE_MSSQL")
  end

  defp connection_options(:sqlite) do
    path = System.get_env("SELECTO_LIVE_SQLITE_PATH", Path.join(@tmp_dir, "patterns.sqlite3"))
    File.rm(path)
    {:ok, [database: path]}
  end

  defp connection_options(:duckdb) do
    path = System.get_env("SELECTO_LIVE_DUCKDB_PATH", Path.join(@tmp_dir, "patterns.duckdb"))
    File.rm(path)
    {:ok, [database: path]}
  end

  defp env_connection_options(prefix) do
    url = System.get_env(prefix <> "_URL")

    cond do
      is_binary(url) and url != "" ->
        {:ok, url_to_keyword(url)}

      true ->
        host = System.get_env(prefix <> "_HOST")
        db = System.get_env(prefix <> "_DB") || System.get_env(prefix <> "_DATABASE")

        if host && db do
          {:ok,
           [
             hostname: host,
             port: parse_int(System.get_env(prefix <> "_PORT")),
             username: System.get_env(prefix <> "_USER") || System.get_env(prefix <> "_USERNAME"),
             password: System.get_env(prefix <> "_PASS") || System.get_env(prefix <> "_PASSWORD"),
             database: db
           ]
           |> Enum.reject(fn {_key, value} -> is_nil(value) end)}
        else
          {:skip, "connection not configured"}
        end
    end
  end

  defp url_to_keyword(url) do
    uri = URI.parse(url)

    base = [
      hostname: uri.host,
      port: uri.port,
      username: if(uri.userinfo, do: String.split(uri.userinfo, ":", parts: 2) |> Enum.at(0)),
      password: if(uri.userinfo, do: String.split(uri.userinfo, ":", parts: 2) |> Enum.at(1)),
      database: uri.path |> to_string() |> String.trim_leading("/")
    ]

    query_opts =
      (uri.query || "")
      |> URI.decode_query()
      |> Enum.map(fn {key, value} -> {String.to_atom(key), normalize_url_value(value)} end)

    (base ++ query_opts)
    |> Enum.reject(fn {_key, value} -> is_nil(value) or value == "" end)
  end

  defp normalize_url_value(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> value
    end
  end

  defp parse_int(nil), do: nil

  defp parse_int(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> nil
    end
  end

  defp seed_fixture_data(adapter, connection) do
    statements = fixture_sql(adapter.key)

    Enum.reduce_while(statements, :ok, fn statement, :ok ->
      case execute_seed_statement(adapter.key, connection, statement) do
        {:ok, _result} -> {:cont, :ok}
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
  end

  defp execute_seed_statement("postgresql", connection, statement),
    do: Postgrex.query(connection, statement, [])

  defp execute_seed_statement("mysql", connection, statement),
    do: MyXQL.query(connection, statement, [])

  defp execute_seed_statement("mariadb", connection, statement),
    do: MyXQL.query(connection, statement, [])

  defp execute_seed_statement("mssql", connection, statement),
    do: Tds.query(connection, statement, [])

  defp execute_seed_statement("duckdb", connection, statement),
    do: SelectoDBDuckDB.Adapter.execute(connection, statement, [], [])

  defp execute_seed_statement("sqlite", connection, statement),
    do: SelectoDBSQLite.Adapter.execute(connection, statement, [], [])

  defp execute_seed_statement(_adapter_key, _connection, statement),
    do: {:error, {:unsupported_seed_adapter, statement}}

  defp validate_pattern(_spec, _adapter, %{status: :skipped, reason: reason}) do
    %{status: "skipped", reason: reason}
  end

  defp validate_pattern(spec, adapter, %{status: :ok, connection: connection}) do
    case adapter_expectation(spec, adapter.key) do
      {:unsupported_expected, reason} ->
        %{status: "unsupported_expected", reason: reason}

      {:generated_only, reason} ->
        %{status: "generated_only", reason: reason}

      :execute ->
        execute_pattern(spec, adapter, connection)
    end
  end

  defp execute_pattern(spec, adapter, connection) do
    {_id, query, _fragments} = SelectoSqlPatterns.VerifyExamples.example(spec.id)
    bound_query = bind_query(query, adapter, connection)

    try do
      case Selecto.execute(bound_query, analyze_complexity: false) do
        {:ok, {rows, columns, aliases}} ->
          case assert_result(spec.assert, rows, columns, aliases) do
            :ok ->
              %{
                status: "executed",
                row_count: length(rows),
                columns: columns,
                aliases: alias_names(aliases)
              }

            {:error, reason} ->
              attach_debug(%{status: "failed", reason: reason}, bound_query)
          end

        {:error, reason} ->
          attach_debug(%{status: "failed", reason: inspect(reason)}, bound_query)
      end
    rescue
      error ->
        attach_debug(%{status: "failed", reason: Exception.message(error)}, bound_query)
    end
  end

  defp adapter_expectation(spec, adapter_key) do
    case Map.get(Map.get(spec, :adapters, %{}), adapter_key, :execute) do
      expectation -> expectation
    end
  end

  defp bind_query(query, %{key: "postgresql"}, connection) do
    %{query | adapter: nil, connection: connection, postgrex_opts: connection}
  end

  defp bind_query(query, adapter, connection) do
    %{query | adapter: adapter.module, connection: connection, postgrex_opts: connection}
  end

  defp assert_result({:columns_include, expected_columns}, rows, columns, aliases) do
    available_columns = columns ++ alias_names(aliases)

    cond do
      rows == [] ->
        {:error, "query returned no rows"}

      Enum.all?(expected_columns, &(&1 in available_columns)) ->
        :ok

      true ->
        {:error, "missing expected columns: #{inspect(expected_columns -- available_columns)}"}
    end
  end

  defp alias_names(aliases) when is_map(aliases), do: Map.keys(aliases)
  defp alias_names(_aliases), do: []

  defp attach_debug(result, selecto) do
    {sql, params} = Selecto.to_sql(selecto)
    Map.merge(result, %{sql: sql, params: params})
  rescue
    _error -> result
  end

  defp print_summary(payload) do
    Enum.each(payload.patterns, fn {pattern_id, adapter_results} ->
      line =
        Enum.map(@adapters, fn adapter ->
          result = Map.fetch!(adapter_results, adapter.key)
          "#{adapter.key}=#{result.status}"
        end)
        |> Enum.join(" ")

      IO.puts("#{pattern_id}: #{line}")
    end)
  end

  defp fixture_sql("mssql") do
    [
      "IF OBJECT_ID('products', 'U') IS NOT NULL DROP TABLE products",
      "IF OBJECT_ID('reviews', 'U') IS NOT NULL DROP TABLE reviews",
      "IF OBJECT_ID('attendees', 'U') IS NOT NULL DROP TABLE attendees",
      "IF OBJECT_ID('events', 'U') IS NOT NULL DROP TABLE events",
      "IF OBJECT_ID('premium_customers', 'U') IS NOT NULL DROP TABLE premium_customers",
      "IF OBJECT_ID('active_customers', 'U') IS NOT NULL DROP TABLE active_customers",
      "IF OBJECT_ID('blocked_customers', 'U') IS NOT NULL DROP TABLE blocked_customers",
      "IF OBJECT_ID('archived_orders', 'U') IS NOT NULL DROP TABLE archived_orders",
      "IF OBJECT_ID('orders', 'U') IS NOT NULL DROP TABLE orders",
      "IF OBJECT_ID('active_customers_view', 'V') IS NOT NULL DROP VIEW active_customers_view",
      "IF OBJECT_ID('customers', 'U') IS NOT NULL DROP TABLE customers",
      "IF OBJECT_ID('employees', 'U') IS NOT NULL DROP TABLE employees",
      "IF OBJECT_ID('vendor_contacts', 'U') IS NOT NULL DROP TABLE vendor_contacts",
      "IF OBJECT_ID('vendors', 'U') IS NOT NULL DROP TABLE vendors",
      "CREATE TABLE customers (id INT PRIMARY KEY, name VARCHAR(255), tier VARCHAR(50))",
      "CREATE TABLE orders (id INT PRIMARY KEY, order_id INT NULL, order_number VARCHAR(50), customer_id INT NULL, attendee_id INT NULL, product_name VARCHAR(255) NULL, quantity INT NULL, price DECIMAL(10,2) NULL, status VARCHAR(50), total DECIMAL(10,2), inserted_at DATETIME2)",
      "CREATE TABLE archived_orders (id INT PRIMARY KEY, order_number VARCHAR(50), total DECIMAL(10,2))",
      "CREATE TABLE events (event_id INT PRIMARY KEY, name VARCHAR(255), date DATE)",
      "CREATE TABLE attendees (attendee_id INT PRIMARY KEY, event_id INT, name VARCHAR(255), email VARCHAR(255))",
      "CREATE TABLE premium_customers (id INT PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE active_customers (id INT PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE blocked_customers (id INT PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE products (id INT PRIMARY KEY, name VARCHAR(255), sku VARCHAR(50), price DECIMAL(10,2), active BIT, tags NVARCHAR(MAX), metadata NVARCHAR(MAX))",
      "CREATE TABLE reviews (id INT PRIMARY KEY, product_id INT, rating INT)",
      "CREATE TABLE employees (id INT PRIMARY KEY, first_name VARCHAR(255), manager_id INT NULL, department VARCHAR(100), salary DECIMAL(10,2))",
      "CREATE TABLE vendors (id INT PRIMARY KEY, name VARCHAR(255), tier VARCHAR(50))",
      vendor_contacts_table_sql("mssql"),
      active_customers_view_sql()
    ] ++ mssql_insert_statements()
  end

  defp fixture_sql("postgresql") do
    [
      "DROP VIEW IF EXISTS active_customers_view",
      "DROP TABLE IF EXISTS products",
      "DROP TABLE IF EXISTS reviews",
      "DROP TABLE IF EXISTS attendees",
      "DROP TABLE IF EXISTS events",
      "DROP TABLE IF EXISTS premium_customers",
      "DROP TABLE IF EXISTS active_customers",
      "DROP TABLE IF EXISTS blocked_customers",
      "DROP TABLE IF EXISTS archived_orders",
      "DROP TABLE IF EXISTS orders",
      "DROP TABLE IF EXISTS customers",
      "DROP TABLE IF EXISTS employees",
      "DROP TABLE IF EXISTS vendor_contacts",
      "DROP TABLE IF EXISTS vendors",
      "CREATE TABLE customers (id INTEGER PRIMARY KEY, name VARCHAR(255), tier VARCHAR(50))",
      "CREATE TABLE orders (id INTEGER PRIMARY KEY, order_id INTEGER, order_number VARCHAR(50), customer_id INTEGER, attendee_id INTEGER, product_name VARCHAR(255), quantity INTEGER, price DECIMAL(10,2), status VARCHAR(50), total DECIMAL(10,2), inserted_at TIMESTAMP)",
      "CREATE TABLE archived_orders (id INTEGER PRIMARY KEY, order_number VARCHAR(50), total DECIMAL(10,2))",
      "CREATE TABLE events (event_id INTEGER PRIMARY KEY, name VARCHAR(255), date DATE)",
      "CREATE TABLE attendees (attendee_id INTEGER PRIMARY KEY, event_id INTEGER, name VARCHAR(255), email VARCHAR(255))",
      "CREATE TABLE premium_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE active_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE blocked_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE products (id INTEGER PRIMARY KEY, name VARCHAR(255), sku VARCHAR(50), price DECIMAL(10,2), active BOOLEAN, tags JSONB, metadata JSONB)",
      "CREATE TABLE reviews (id INTEGER PRIMARY KEY, product_id INTEGER, rating INTEGER)",
      "CREATE TABLE employees (id INTEGER PRIMARY KEY, first_name VARCHAR(255), manager_id INTEGER, department VARCHAR(100), salary DECIMAL(10,2))",
      "CREATE TABLE vendors (id INTEGER PRIMARY KEY, name VARCHAR(255), tier VARCHAR(50))",
      vendor_contacts_table_sql("postgresql"),
      active_customers_view_sql()
    ] ++ insert_statements()
  end

  defp fixture_sql("mysql") do
    [
      "DROP VIEW IF EXISTS active_customers_view",
      "DROP TABLE IF EXISTS products",
      "DROP TABLE IF EXISTS reviews",
      "DROP TABLE IF EXISTS attendees",
      "DROP TABLE IF EXISTS events",
      "DROP TABLE IF EXISTS premium_customers",
      "DROP TABLE IF EXISTS active_customers",
      "DROP TABLE IF EXISTS blocked_customers",
      "DROP TABLE IF EXISTS archived_orders",
      "DROP TABLE IF EXISTS orders",
      "DROP TABLE IF EXISTS customers",
      "DROP TABLE IF EXISTS employees",
      "DROP TABLE IF EXISTS vendor_contacts",
      "DROP TABLE IF EXISTS vendors",
      "CREATE TABLE customers (id INTEGER PRIMARY KEY, name VARCHAR(255), tier VARCHAR(50))",
      "CREATE TABLE orders (id INTEGER PRIMARY KEY, order_id INTEGER, order_number VARCHAR(50), customer_id INTEGER, attendee_id INTEGER, product_name VARCHAR(255), quantity INTEGER, price DECIMAL(10,2), status VARCHAR(50), total DECIMAL(10,2), inserted_at TIMESTAMP)",
      "CREATE TABLE archived_orders (id INTEGER PRIMARY KEY, order_number VARCHAR(50), total DECIMAL(10,2))",
      "CREATE TABLE events (event_id INTEGER PRIMARY KEY, name VARCHAR(255), date DATE)",
      "CREATE TABLE attendees (attendee_id INTEGER PRIMARY KEY, event_id INTEGER, name VARCHAR(255), email VARCHAR(255))",
      "CREATE TABLE premium_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE active_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE blocked_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE products (id INTEGER PRIMARY KEY, name VARCHAR(255), sku VARCHAR(50), price DECIMAL(10,2), active BOOLEAN, tags JSON, metadata JSON)",
      "CREATE TABLE reviews (id INTEGER PRIMARY KEY, product_id INTEGER, rating INTEGER)",
      "CREATE TABLE employees (id INTEGER PRIMARY KEY, first_name VARCHAR(255), manager_id INTEGER, department VARCHAR(100), salary DECIMAL(10,2))",
      "CREATE TABLE vendors (id INTEGER PRIMARY KEY, name VARCHAR(255), tier VARCHAR(50))",
      vendor_contacts_table_sql("mysql"),
      active_customers_view_sql()
    ] ++ insert_statements()
  end

  defp fixture_sql("mariadb") do
    [
      "DROP VIEW IF EXISTS active_customers_view",
      "DROP TABLE IF EXISTS products",
      "DROP TABLE IF EXISTS reviews",
      "DROP TABLE IF EXISTS attendees",
      "DROP TABLE IF EXISTS events",
      "DROP TABLE IF EXISTS premium_customers",
      "DROP TABLE IF EXISTS active_customers",
      "DROP TABLE IF EXISTS blocked_customers",
      "DROP TABLE IF EXISTS archived_orders",
      "DROP TABLE IF EXISTS orders",
      "DROP TABLE IF EXISTS customers",
      "DROP TABLE IF EXISTS employees",
      "DROP TABLE IF EXISTS vendor_contacts",
      "DROP TABLE IF EXISTS vendors",
      "CREATE TABLE customers (id INTEGER PRIMARY KEY, name VARCHAR(255), tier VARCHAR(50))",
      "CREATE TABLE orders (id INTEGER PRIMARY KEY, order_id INTEGER, order_number VARCHAR(50), customer_id INTEGER, attendee_id INTEGER, product_name VARCHAR(255), quantity INTEGER, price DECIMAL(10,2), status VARCHAR(50), total DECIMAL(10,2), inserted_at TIMESTAMP)",
      "CREATE TABLE archived_orders (id INTEGER PRIMARY KEY, order_number VARCHAR(50), total DECIMAL(10,2))",
      "CREATE TABLE events (event_id INTEGER PRIMARY KEY, name VARCHAR(255), date DATE)",
      "CREATE TABLE attendees (attendee_id INTEGER PRIMARY KEY, event_id INTEGER, name VARCHAR(255), email VARCHAR(255))",
      "CREATE TABLE premium_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE active_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE blocked_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE products (id INTEGER PRIMARY KEY, name VARCHAR(255), sku VARCHAR(50), price DECIMAL(10,2), active BOOLEAN, tags LONGTEXT, metadata LONGTEXT)",
      "CREATE TABLE reviews (id INTEGER PRIMARY KEY, product_id INTEGER, rating INTEGER)",
      "CREATE TABLE employees (id INTEGER PRIMARY KEY, first_name VARCHAR(255), manager_id INTEGER, department VARCHAR(100), salary DECIMAL(10,2))",
      "CREATE TABLE vendors (id INTEGER PRIMARY KEY, name VARCHAR(255), tier VARCHAR(50))",
      vendor_contacts_table_sql("mariadb"),
      active_customers_view_sql()
    ] ++ insert_statements()
  end

  defp fixture_sql("duckdb") do
    [
      "DROP VIEW IF EXISTS active_customers_view",
      "DROP TABLE IF EXISTS products",
      "DROP TABLE IF EXISTS reviews",
      "DROP TABLE IF EXISTS premium_customers",
      "DROP TABLE IF EXISTS active_customers",
      "DROP TABLE IF EXISTS blocked_customers",
      "DROP TABLE IF EXISTS archived_orders",
      "DROP TABLE IF EXISTS orders",
      "DROP TABLE IF EXISTS customers",
      "DROP TABLE IF EXISTS employees",
      "DROP TABLE IF EXISTS vendor_contacts",
      "DROP TABLE IF EXISTS vendors",
      "CREATE TABLE customers (id INTEGER PRIMARY KEY, name VARCHAR, tier VARCHAR)",
      "CREATE TABLE orders (id INTEGER PRIMARY KEY, order_id INTEGER, order_number VARCHAR, customer_id INTEGER, attendee_id INTEGER, product_name VARCHAR, quantity INTEGER, price DECIMAL(10,2), status VARCHAR, total DECIMAL(10,2), inserted_at TIMESTAMP)",
      "CREATE TABLE archived_orders (id INTEGER PRIMARY KEY, order_number VARCHAR, total DECIMAL(10,2))",
      "CREATE TABLE events (event_id INTEGER PRIMARY KEY, name VARCHAR, date DATE)",
      "CREATE TABLE attendees (attendee_id INTEGER PRIMARY KEY, event_id INTEGER, name VARCHAR, email VARCHAR)",
      "CREATE TABLE premium_customers (id INTEGER PRIMARY KEY, name VARCHAR)",
      "CREATE TABLE active_customers (id INTEGER PRIMARY KEY, name VARCHAR)",
      "CREATE TABLE blocked_customers (id INTEGER PRIMARY KEY, name VARCHAR)",
      "CREATE TABLE products (id INTEGER PRIMARY KEY, name VARCHAR, sku VARCHAR, price DECIMAL(10,2), active BOOLEAN, tags JSON, metadata JSON)",
      "CREATE TABLE reviews (id INTEGER PRIMARY KEY, product_id INTEGER, rating INTEGER)",
      "CREATE TABLE employees (id INTEGER PRIMARY KEY, first_name VARCHAR, manager_id INTEGER, department VARCHAR, salary DECIMAL(10,2))",
      "CREATE TABLE vendors (id INTEGER PRIMARY KEY, name VARCHAR, tier VARCHAR)",
      vendor_contacts_table_sql("duckdb"),
      active_customers_view_sql()
    ] ++ insert_statements()
  end

  defp fixture_sql("sqlite") do
    [
      "DROP VIEW IF EXISTS active_customers_view",
      "DROP TABLE IF EXISTS products",
      "DROP TABLE IF EXISTS reviews",
      "DROP TABLE IF EXISTS attendees",
      "DROP TABLE IF EXISTS events",
      "DROP TABLE IF EXISTS premium_customers",
      "DROP TABLE IF EXISTS active_customers",
      "DROP TABLE IF EXISTS blocked_customers",
      "DROP TABLE IF EXISTS archived_orders",
      "DROP TABLE IF EXISTS orders",
      "DROP TABLE IF EXISTS customers",
      "DROP TABLE IF EXISTS employees",
      "DROP TABLE IF EXISTS vendor_contacts",
      "DROP TABLE IF EXISTS vendors",
      "CREATE TABLE customers (id INTEGER PRIMARY KEY, name VARCHAR(255), tier VARCHAR(50))",
      "CREATE TABLE orders (id INTEGER PRIMARY KEY, order_id INTEGER, order_number VARCHAR(50), customer_id INTEGER, attendee_id INTEGER, product_name VARCHAR(255), quantity INTEGER, price DECIMAL(10,2), status VARCHAR(50), total DECIMAL(10,2), inserted_at TIMESTAMP)",
      "CREATE TABLE archived_orders (id INTEGER PRIMARY KEY, order_number VARCHAR(50), total DECIMAL(10,2))",
      "CREATE TABLE events (event_id INTEGER PRIMARY KEY, name VARCHAR(255), date DATE)",
      "CREATE TABLE attendees (attendee_id INTEGER PRIMARY KEY, event_id INTEGER, name VARCHAR(255), email VARCHAR(255))",
      "CREATE TABLE premium_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE active_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE blocked_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE products (id INTEGER PRIMARY KEY, name VARCHAR(255), sku VARCHAR(50), price DECIMAL(10,2), active BOOLEAN, tags TEXT, metadata TEXT)",
      "CREATE TABLE reviews (id INTEGER PRIMARY KEY, product_id INTEGER, rating INTEGER)",
      "CREATE TABLE employees (id INTEGER PRIMARY KEY, first_name VARCHAR(255), manager_id INTEGER, department VARCHAR(100), salary DECIMAL(10,2))",
      "CREATE TABLE vendors (id INTEGER PRIMARY KEY, name VARCHAR(255), tier VARCHAR(50))",
      vendor_contacts_table_sql("sqlite"),
      active_customers_view_sql()
    ] ++ insert_statements()
  end

  defp fixture_sql(_adapter_key) do
    [
      "DROP VIEW IF EXISTS active_customers_view",
      "DROP TABLE IF EXISTS products",
      "DROP TABLE IF EXISTS reviews",
      "DROP TABLE IF EXISTS attendees",
      "DROP TABLE IF EXISTS events",
      "DROP TABLE IF EXISTS premium_customers",
      "DROP TABLE IF EXISTS active_customers",
      "DROP TABLE IF EXISTS blocked_customers",
      "DROP TABLE IF EXISTS archived_orders",
      "DROP TABLE IF EXISTS orders",
      "DROP TABLE IF EXISTS customers",
      "DROP TABLE IF EXISTS employees",
      "DROP TABLE IF EXISTS vendor_contacts",
      "DROP TABLE IF EXISTS vendors",
      "CREATE TABLE customers (id INTEGER PRIMARY KEY, name VARCHAR(255), tier VARCHAR(50))",
      "CREATE TABLE orders (id INTEGER PRIMARY KEY, order_id INTEGER, order_number VARCHAR(50), customer_id INTEGER, attendee_id INTEGER, product_name VARCHAR(255), quantity INTEGER, price DECIMAL(10,2), status VARCHAR(50), total DECIMAL(10,2), inserted_at TIMESTAMP)",
      "CREATE TABLE archived_orders (id INTEGER PRIMARY KEY, order_number VARCHAR(50), total DECIMAL(10,2))",
      "CREATE TABLE events (event_id INTEGER PRIMARY KEY, name VARCHAR(255), date DATE)",
      "CREATE TABLE attendees (attendee_id INTEGER PRIMARY KEY, event_id INTEGER, name VARCHAR(255), email VARCHAR(255))",
      "CREATE TABLE premium_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE active_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE blocked_customers (id INTEGER PRIMARY KEY, name VARCHAR(255))",
      "CREATE TABLE products (id INTEGER PRIMARY KEY, name VARCHAR(255), sku VARCHAR(50), price DECIMAL(10,2), active BOOLEAN, tags TEXT, metadata TEXT)",
      "CREATE TABLE reviews (id INTEGER PRIMARY KEY, product_id INTEGER, rating INTEGER)",
      "CREATE TABLE employees (id INTEGER PRIMARY KEY, first_name VARCHAR(255), manager_id INTEGER, department VARCHAR(100), salary DECIMAL(10,2))",
      "CREATE TABLE vendors (id INTEGER PRIMARY KEY, name VARCHAR(255), tier VARCHAR(50))",
      vendor_contacts_table_sql("default"),
      active_customers_view_sql()
    ] ++ insert_statements()
  end

  defp vendor_contacts_table_sql("mssql") do
    "CREATE TABLE vendor_contacts (id INT PRIMARY KEY, company_name VARCHAR(255), segment VARCHAR(50))"
  end

  defp vendor_contacts_table_sql(_adapter_key) do
    "CREATE TABLE vendor_contacts (id INTEGER PRIMARY KEY, company_name VARCHAR(255), segment VARCHAR(50))"
  end

  defp active_customers_view_sql do
    "CREATE VIEW active_customers_view AS SELECT id AS customer_id, name, tier FROM customers WHERE tier IN ('premium', 'platinum')"
  end

  defp insert_statements do
    [
      "INSERT INTO customers (id, name, tier) VALUES (1, 'Alice', 'gold'), (2, 'Bob', 'silver'), (3, 'Cara', 'premium'), (4, 'Dina', 'platinum')",
      orders_insert_statement(),
      archived_orders_insert_statement(),
      attendee_events_insert_statement(),
      attendees_insert_statement(),
      "INSERT INTO premium_customers (id, name) VALUES (1, 'Alice'), (3, 'Cara'), (4, 'Dina')",
      "INSERT INTO active_customers (id, name) VALUES (1, 'Alice'), (4, 'Dina')",
      "INSERT INTO blocked_customers (id, name) VALUES (2, 'Bob')",
      "INSERT INTO products (id, name, sku, price, active, tags, metadata) VALUES (1, 'Charger', 'SKU-1', 49.99, true, '[\"featured\",\"electronics\"]', '{\"warehouse\":{\"zone\":\"A1\"},\"stock\":{\"quantity\":12},\"price_band\":\"premium\"}'), (2, 'Cable', 'SKU-2', 19.99, true, '[\"clearance\",\"electronics\"]', '{\"warehouse\":{\"zone\":\"B2\"},\"stock\":{\"quantity\":3},\"price_band\":\"budget\"}'), (3, 'Stand', 'SKU-3', 29.99, false, '[\"office\"]', '{\"stock\":{\"quantity\":0},\"price_band\":\"standard\"}')",
      "INSERT INTO reviews (id, product_id, rating) VALUES (1, 1, 5), (2, 1, 4), (3, 2, 3)",
      "INSERT INTO employees (id, first_name, manager_id, department, salary) VALUES (1, 'Ellen', NULL, 'Sales', 90000.00), (2, 'Marco', 1, 'Sales', 85000.00), (3, 'Priya', NULL, 'Engineering', 120000.00), (4, 'Luis', 3, 'Engineering', 110000.00)",
      "INSERT INTO vendors (id, name, tier) VALUES (1, 'SupplyCo', 'gold'), (2, 'Northwind', 'silver')",
      vendor_contacts_insert_statement()
    ]
  end

  defp mssql_insert_statements do
    [
      "INSERT INTO customers (id, name, tier) VALUES (1, 'Alice', 'gold'), (2, 'Bob', 'silver'), (3, 'Cara', 'premium'), (4, 'Dina', 'platinum')",
      mssql_orders_insert_statement(),
      mssql_archived_orders_insert_statement(),
      attendee_events_insert_statement(),
      attendees_insert_statement(),
      "INSERT INTO premium_customers (id, name) VALUES (1, 'Alice'), (3, 'Cara'), (4, 'Dina')",
      "INSERT INTO active_customers (id, name) VALUES (1, 'Alice'), (4, 'Dina')",
      "INSERT INTO blocked_customers (id, name) VALUES (2, 'Bob')",
      "INSERT INTO products (id, name, sku, price, active, tags, metadata) VALUES (1, 'Charger', 'SKU-1', 49.99, 1, '[\"featured\",\"electronics\"]', '{\"warehouse\":{\"zone\":\"A1\"},\"stock\":{\"quantity\":12},\"price_band\":\"premium\"}'), (2, 'Cable', 'SKU-2', 19.99, 1, '[\"clearance\",\"electronics\"]', '{\"warehouse\":{\"zone\":\"B2\"},\"stock\":{\"quantity\":3},\"price_band\":\"budget\"}'), (3, 'Stand', 'SKU-3', 29.99, 0, '[\"office\"]', '{\"stock\":{\"quantity\":0},\"price_band\":\"standard\"}')",
      "INSERT INTO reviews (id, product_id, rating) VALUES (1, 1, 5), (2, 1, 4), (3, 2, 3)",
      "INSERT INTO employees (id, first_name, manager_id, department, salary) VALUES (1, 'Ellen', NULL, 'Sales', 90000.00), (2, 'Marco', 1, 'Sales', 85000.00), (3, 'Priya', NULL, 'Engineering', 120000.00), (4, 'Luis', 3, 'Engineering', 110000.00)",
      "INSERT INTO vendors (id, name, tier) VALUES (1, 'SupplyCo', 'gold'), (2, 'Northwind', 'silver')",
      vendor_contacts_insert_statement()
    ]
  end

  defp vendor_contacts_insert_statement do
    "INSERT INTO vendor_contacts (id, company_name, segment) VALUES (1, 'SupplyCo AP', 'gold'), (2, 'Northwind Buyer Desk', 'silver')"
  end

  defp orders_insert_statement do
    rows =
      [
        "(1001, 1001, 'ORD-1001', 1, NULL, NULL, NULL, NULL, 'delivered', 120.50, '2024-01-05 10:00:00')",
        "(1002, 1002, 'ORD-1002', 1, NULL, NULL, NULL, NULL, 'processing', 75.00, '2024-01-10 12:00:00')",
        "(1003, 1003, 'ORD-1003', 2, NULL, NULL, NULL, NULL, 'delivered', 210.00, '2024-01-18 09:00:00')",
        "(1004, 1004, 'ORD-1004', 3, NULL, NULL, NULL, NULL, 'shipped', 95.25, '2024-02-03 08:30:00')",
        "(1005, 1005, 'ORD-1005', 2, NULL, NULL, NULL, NULL, 'delivered', 55.75, '2024-01-28 15:15:00')",
        "(1006, 1006, 'ORD-1006', 3, NULL, NULL, NULL, NULL, 'processing', 180.00, '2024-02-10 11:45:00')",
        "(1007, 1007, 'ORD-1007', 4, NULL, NULL, NULL, NULL, 'processing', 320.00, '2024-02-14 14:20:00')",
        "(1008, 1008, 'ORD-1008', 4, NULL, NULL, NULL, NULL, 'delivered', 1450.00, '2024-02-15 09:10:00')",
        "(3001, 3001, 'EVT-3001', NULL, 1, 'Badge', 2, 25.00, 'completed', 50.00, '2024-01-02 09:00:00')",
        "(3002, 3002, 'EVT-3002', NULL, 1, 'Lanyard', 1, 5.00, 'completed', 5.00, '2024-01-02 09:05:00')",
        "(3003, 3003, 'EVT-3003', NULL, 2, 'Notebook', 3, 12.00, 'completed', 36.00, '2024-01-03 10:00:00')",
        "(3004, 3004, 'EVT-3004', NULL, 3, 'Sticker Pack', 4, 3.00, 'completed', 12.00, '2024-01-04 11:00:00')"
      ] ++ generated_order_rows(" ")

    "INSERT INTO orders (id, order_id, order_number, customer_id, attendee_id, product_name, quantity, price, status, total, inserted_at) VALUES " <>
      Enum.join(rows, ", ")
  end

  defp archived_orders_insert_statement do
    rows =
      [
        "(2001, 'ORD-0901', 44.00)",
        "(2002, 'ORD-0902', 88.50)",
        "(2003, 'ORD-1003', 210.00)"
      ] ++ generated_archived_order_rows()

    "INSERT INTO archived_orders (id, order_number, total) VALUES " <> Enum.join(rows, ", ")
  end

  defp mssql_orders_insert_statement do
    rows =
      [
        "(1001, 1001, 'ORD-1001', 1, NULL, NULL, NULL, NULL, 'delivered', 120.50, '2024-01-05T10:00:00')",
        "(1002, 1002, 'ORD-1002', 1, NULL, NULL, NULL, NULL, 'processing', 75.00, '2024-01-10T12:00:00')",
        "(1003, 1003, 'ORD-1003', 2, NULL, NULL, NULL, NULL, 'delivered', 210.00, '2024-01-18T09:00:00')",
        "(1004, 1004, 'ORD-1004', 3, NULL, NULL, NULL, NULL, 'shipped', 95.25, '2024-02-03T08:30:00')",
        "(1005, 1005, 'ORD-1005', 2, NULL, NULL, NULL, NULL, 'delivered', 55.75, '2024-01-28T15:15:00')",
        "(1006, 1006, 'ORD-1006', 3, NULL, NULL, NULL, NULL, 'processing', 180.00, '2024-02-10T11:45:00')",
        "(1007, 1007, 'ORD-1007', 4, NULL, NULL, NULL, NULL, 'processing', 320.00, '2024-02-14T14:20:00')",
        "(1008, 1008, 'ORD-1008', 4, NULL, NULL, NULL, NULL, 'delivered', 1450.00, '2024-02-15T09:10:00')",
        "(3001, 3001, 'EVT-3001', NULL, 1, 'Badge', 2, 25.00, 'completed', 50.00, '2024-01-02T09:00:00')",
        "(3002, 3002, 'EVT-3002', NULL, 1, 'Lanyard', 1, 5.00, 'completed', 5.00, '2024-01-02T09:05:00')",
        "(3003, 3003, 'EVT-3003', NULL, 2, 'Notebook', 3, 12.00, 'completed', 36.00, '2024-01-03T10:00:00')",
        "(3004, 3004, 'EVT-3004', NULL, 3, 'Sticker Pack', 4, 3.00, 'completed', 12.00, '2024-01-04T11:00:00')"
      ] ++ generated_order_rows("T")

    "INSERT INTO orders (id, order_id, order_number, customer_id, attendee_id, product_name, quantity, price, status, total, inserted_at) VALUES " <>
      Enum.join(rows, ", ")
  end

  defp attendee_events_insert_statement do
    "INSERT INTO events (event_id, name, date) VALUES (1000, 'Launch Day', '2024-01-10'), (2000, 'Customer Summit', '2024-02-20')"
  end

  defp attendees_insert_statement do
    "INSERT INTO attendees (attendee_id, event_id, name, email) VALUES (1, 1000, 'Avery', 'avery@example.com'), (2, 1000, 'Blair', 'blair@example.com'), (3, 2000, 'Casey', 'casey@example.com')"
  end

  defp mssql_archived_orders_insert_statement do
    rows =
      [
        "(2001, 'ORD-0901', 44.00)",
        "(2002, 'ORD-0902', 88.50)",
        "(2003, 'ORD-1003', 210.00)"
      ] ++ generated_archived_order_rows()

    "INSERT INTO archived_orders (id, order_number, total) VALUES " <> Enum.join(rows, ", ")
  end

  defp generated_order_rows(separator) do
    1..60
    |> Enum.map(fn offset ->
      id = 1100 + offset
      customer_id = rem(offset, 4) + 1
      status = Enum.at(["processing", "delivered", "shipped", "delivered"], rem(offset, 4))
      total = 60 + offset * 17
      day = rem(offset, 28) + 1
      hour = rem(offset, 9) + 9
      minute = rem(offset * 7, 60)
      timestamp = "2024-03-#{pad2(day)}#{separator}#{pad2(hour)}:#{pad2(minute)}:00"

      "(#{id}, #{id}, 'ORD-#{id}', #{customer_id}, NULL, NULL, NULL, NULL, '#{status}', #{total}.00, '#{timestamp}')"
    end)
  end

  defp generated_archived_order_rows do
    1..25
    |> Enum.map(fn offset ->
      id = 2100 + offset
      total = 35 + offset * 11
      "(#{id}, 'ARC-#{id}', #{total}.00)"
    end)
  end

  defp pad2(number) when number < 10, do: "0#{number}"
  defp pad2(number), do: Integer.to_string(number)
end

SelectoSqlPatterns.LiveValidation.run()
