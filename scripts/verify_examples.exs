selecto_path = System.get_env("SELECTO_PATH", "../selecto")
postgresql_adapter_path = System.get_env("SELECTO_DB_POSTGRESQL_PATH", "../selecto_db_postgresql")
mysql_adapter_path = System.get_env("SELECTO_DB_MYSQL_PATH", "../selecto_db_mysql")
mariadb_adapter_path = System.get_env("SELECTO_DB_MARIADB_PATH", "../selecto_db_mariadb")
sqlite_adapter_path = System.get_env("SELECTO_DB_SQLITE_PATH", "../selecto_db_sqlite")
mssql_adapter_path = System.get_env("SELECTO_DB_MSSQL_PATH", "../selecto_db_mssql")
duckdb_adapter_path = System.get_env("SELECTO_DB_DUCKDB_PATH", "../selecto_db_duckdb")
System.put_env("SELECTO_ECOSYSTEM_USE_LOCAL", "1")

path_dep = fn app, path ->
  if File.dir?(path) do
    {app, path: path, override: true}
  end
end

deps =
  [
    {:jason, "~> 1.4"},
    {:selecto, path: selecto_path, override: true},
    path_dep.(:selecto_db_postgresql, postgresql_adapter_path),
    path_dep.(:selecto_db_mysql, mysql_adapter_path),
    path_dep.(:selecto_db_mariadb, mariadb_adapter_path),
    path_dep.(:selecto_db_sqlite, sqlite_adapter_path),
    path_dep.(:selecto_db_mssql, mssql_adapter_path),
    path_dep.(:selecto_db_duckdb, duckdb_adapter_path)
  ]
  |> Enum.reject(&is_nil/1)

Mix.install(deps)

defmodule SelectoSqlPatterns.BuildAdapter do
  @moduledoc false
  @behaviour Selecto.DB.Adapter

  @impl true
  def name, do: :sql_patterns_build

  @impl true
  def connect(connection), do: {:ok, connection}

  @impl true
  def execute(_connection, _query, _params, _opts), do: {:error, :build_only_adapter}

  @impl true
  def placeholder(index), do: ["$", Integer.to_string(index)]

  @impl true
  def quote_identifier(identifier) do
    escaped = identifier |> to_string() |> String.replace("\"", "\"\"")
    ["\"", escaped, "\""]
  end

  @impl true
  def supports?(_feature), do: true
end

defmodule SelectoSqlPatterns.VerifyExamples do
  import Selecto.ExprMacros
  import Selecto.Sigil

  alias Selecto.Expr, as: X

  @source_file Path.expand(__ENV__.file)

  defp configure(domain, connection, opts \\ []) do
    target_adapter = Keyword.get(opts, :adapter) || Process.get(:selecto_sql_patterns_adapter)

    query =
      Selecto.configure(
        domain,
        connection,
        Keyword.put(opts, :adapter, SelectoSqlPatterns.BuildAdapter)
      )

    if target_adapter && target_adapter != SelectoSqlPatterns.BuildAdapter do
      retarget_runtime(query, %{adapter: target_adapter, connection: connection})
    else
      query
    end
  end

  @adapters [
    %{
      key: "postgresql",
      label: "PostgreSQL",
      module: SelectoDBPostgreSQL.Adapter,
      verify: :strict
    },
    %{key: "sqlite", label: "SQLite", module: SelectoDBSQLite.Adapter, verify: :best_effort},
    %{key: "mysql", label: "MySQL", module: Selecto.DB.MySQL, verify: :best_effort},
    %{key: "mariadb", label: "MariaDB", module: SelectoDBMariaDB.Adapter, verify: :best_effort},
    %{key: "mssql", label: "MSSQL", module: SelectoDBMSSQL.Adapter, verify: :best_effort},
    %{key: "duckdb", label: "DuckDB", module: SelectoDBDuckDB.Adapter, verify: :best_effort}
  ]

  def adapters, do: @adapters

  def example(id) do
    Enum.find(examples(), fn {example_id, _query, _fragments} -> example_id == id end)
  end

  def examples do
    [
      {"J001", query_j001(), ["select", "left join", "is not null", "order by"]},
      {"J002", query_j002(), ["select", "left join", "count", "group by"]},
      {"J003", query_j003(), ["select", "inner join", "where", "from customers"]},
      {"J004", query_j004(), ["select", "left join", "manager", "order by"]},
      {"J005", query_j005(), ["select", "left join", "is null", "order by"]},
      {"J006", query_j006(), ["select", "left join", "customer:tier_premium", " and "]},
      {"J007", query_j007(), ["select", "left join lateral", "count", "where"]},
      {"J008", query_j008(), ["select", "cross join lateral unnest", "where", "product_tag"]},
      {"J009", query_j009(), ["select", "left join", "customer:alias_a", "customer:alias_b"]},
      {"J010", query_j010(), ["select", "left join", "count", "group by"]},
      {"J011", query_j011(), ["select", "inner join", "where", "order by"]},
      {"J012", query_j012(), ["select", "left join", "where", "order by"]},
      {"A001", query_a001(), ["select", "count", "group by", "order by"]},
      {"A002", query_a002(), ["select", "sum", "where", "group by"]},
      {"A003", query_a003(), ["select", "avg", "group by", "order by"]},
      {"A004", query_a004(), ["select", "count", "left join", "group by"]},
      {"A005", query_a005(), ["select", "sum", "left join", "group by"]},
      {"A006", query_a006(), ["select", "count", "where", "group by"]},
      {"A007", query_a007(), ["select", "sum", "count", "group by"]},
      {"A008", query_a008(), ["select", "avg", "where", "group by"]},
      {"A009", query_a009(), ["select", "min", "max", "group by"]},
      {"A010", query_a010(), ["select", "count", "avg", "group by"]},
      {"E001", query_e001(), ["case when", "then", "else", "order by"]},
      {"E002", query_e002(), ["coalesce", "nullif", "left join", "order by"]},
      {"E003", query_e003(), ["count(distinct", "stddev", "variance", "group by"]},
      {"E004", query_e004(), ["rollup", "count(*)", "group by", "order by"]},
      {"W001", query_w001(), ["select", "row_number", "over", "partition by"]},
      {"W002", query_w002(), ["select", "sum", "over", "order by"]},
      {"W003", query_w003(), ["select", "lag", "over", "partition by"]},
      {"W004", query_w004(), ["select", "dense_rank", "over", "order by"]},
      {"W005", query_w005(), ["select", "avg", "rows", "current row"]},
      {"W006", query_w006(), ["select", "rank", "partition by", "order by"]},
      {"W007", query_w007(), ["select", "lead", "over", "partition by"]},
      {"W008", query_w008(), ["select", "max", "over", "partition by"]},
      {"W009", query_w009(), ["select", "percent_rank", "over", "order by"]},
      {"W010", query_w010(), ["select", "count", "over", "partition by"]},
      {"S001", query_s001(), ["select", " in (", "from customers", "order by"]},
      {"S002", query_s002(), ["select", "left join", "where", "order by"]},
      {"S003", query_s003(), ["select", "exists (", "from customers", "order by"]},
      {"S004", query_s004(), ["select", "left join", "is null", "order by"]},
      {"S005", query_s005(), ["select", " in (", "$1", "order by"]},
      {"S006", query_s006(), ["select", "exists (", "$1", "order by"]},
      {"S007", query_s007(), ["select", " in (", "where", " and "]},
      {"S008", query_s008(), ["select", " all (", "where", "order by"]},
      {"S009", query_s009(), ["select", " any (", "where", "order by"]},
      {"S010", query_s010(), ["select", "not (", "exists (", "$1"]},
      {"SO001", query_so001(), ["union", "from customers", "from vendors", "select"]},
      {"SO002", query_so002(), ["union all", "from orders", "from archived_orders", "select"]},
      {"SO003", query_so003(),
       ["intersect", "from premium_customers", "from active_customers", "select"]},
      {"SO004", query_so004(), ["except", "from customers", "from blocked_customers", "select"]},
      {"SO005", query_so005(),
       ["union", "intersect", "from premium_customers", "from customers"]},
      {"SO006", query_so006(),
       ["intersect all", "from premium_customers", "from active_customers", "select"]},
      {"SO007", query_so007(),
       ["except all", "from customers", "from blocked_customers", "select"]},
      {"SO008", query_so008(), ["union", "from customers", "from vendor_contacts", "select"]},
      {"F001", query_f001(), ["is not null", "not (", "any(", "order by"]},
      {"F002", query_f002(), ["where", " and ", " or ", "order by"]},
      {"F003", query_f003(), ["between", "any(", "where", "order by"]},
      {"F004", query_f004(), ["@@ websearch_to_tsquery", "where", "order by", "from products"]},
      {"F005", query_f005(), ["not (", "where", ">", "order by"]},
      {"F006", query_f006(), ["@>", "where", "order by", "from products"]},
      {"F007", query_f007(), ["#>>", "?", "where", "order by"]},
      {"F008", query_f008(), [" in (", "$1", "where", "order by"]},
      {"P001", query_p001(), ["from orders", "order by", "limit", "offset"]},
      {"P002", query_p002(), ["where", ">", "order by", "limit"]},
      {"P003", query_p003(), ["where", "<", "order by", "limit"]},
      {"P004", query_p004(), ["left join", "order by", "limit", "offset"]},
      {"P005", query_p005(), ["inserted_at", ">", "order by", "limit"]},
      {"P006", query_p006(), ["order by", "desc", "limit", "offset"]},
      {"P007", query_p007(), ["union all", "order by", "limit", "offset"]},
      {"P008", query_p008(), ["where", " or ", "order by", "limit"]},
      {"JA001", query_ja001(), ["->>", "@>", "where", "order by"]},
      {"JA002", query_ja002(), ["->", "#>>", "?", "order by"]},
      {"JA003", query_ja003(), ["&&", "where", "order by", "from products"]},
      {"JA004", query_ja004(), ["metadata", "stock", "where", "order by"]},
      {"JA005", query_ja005(), ["#>>array", "warehouse", "order by", "warehouse_zone"]},
      {"JA006", query_ja006(), ["@>", "where", "order by", "from products"]},
      {"JA007", query_ja007(), ["#>>", "active", "where", "order by"]},
      {"JA008", query_ja008(), ["#>>array", "warehouse_zone", "stock_quantity", "order by"]},
      {"Q001", query_q001(), ["json_agg", "json_build_object", "from orders", "order_items"]},
      {"Q002", query_q002(), ["from orders", "exists (", "from events", "inner join"]},
      {"Q003", query_q003(), ["from orders", " in (", "from events", "join attendees"]},
      {"Q004", query_q004(), ["json_agg", "array_agg", "products", "quantities"]},
      {"Q005", query_q005(), ["count(", "order_count", "from orders", "where"]},
      {"Q006", query_q006(),
       ["left join", "processing_orders_member", "from customers", "order by"]},
      {"Q007", query_q007(), ["with", "delivered_totals", "left join", "order by"]},
      {"Q008", query_q008(), ["union all", "except", "from archived_orders", "select"]},
      {"Q009", query_q009(), ["from active_customers_view", "where", "order by", "tier"]},
      {"Q010", query_q010(), ["from orders", "left join", "customers customer", "order by"]},
      {"Q011", query_q011(),
       ["json_agg", "'items'", "from order_items", "sub_orders_items", "order_id"]},
      {"T001", query_t001(), [">=", "<", "where", "order by"]},
      {"T002", query_t002(), ["sum", "over", "order by", "running_total"]},
      {"T003", query_t003(),
       ["date_trunc('day'", "from orders", "order by", "selecto_root.inserted_at"]},
      {"T004", query_t004(), ["avg", "over", "preceding", "trailing_avg_total"]},
      {"T005", query_t005(), ["lag(", "over", "previous_total", "order by"]},
      {"T006", query_t006(), ["sum", "partition by", "order by", "status_running_total"]},
      {"T007", query_t007(), ["where", " or ", "order by", "limit"]},
      {"T008", query_t008(), ["union all", "inserted_at", "order by", "limit"]},
      {"T009", query_t009(), ["date_trunc('day'", "sum", "group by", "order by"]},
      {"T010", query_t010(), ["date_trunc('day'", "status", "count", "group by"]},
      {"T011", query_t011(), ["lag(", "partition by", "customer_id", "order by"]},
      {"T012", query_t012(), ["lead(", "partition by", "customer_id", "order by"]},
      {"CA001", query_ca001(), ["min", "customer_id", "group by", "order by"]},
      {"CA002", query_ca002(), ["date_trunc('month'", "count", "group by", "order by"]},
      {"CA003", query_ca003(), ["first_order_cohorts", "left join", "status", "group by"]},
      {"CA004", query_ca004(), ["row_number", "partition by", "cohort_start", "order by"]},
      {"G001", query_g001(), ["st_dwithin", "where", "order by", "from locations"]},
      {"G002", query_g002(), ["exists (", "st_intersects", "where", "from locations"]},
      {"G003", query_g003(), ["st_contains", "st_geomfromtext", "where", "from locations"]},
      {"G004", query_g004(), ["&&", "st_makeenvelope", "where", "from locations"]},
      {"G005", query_g005(), ["st_buffer", "st_intersects", "where", "from locations"]},
      {"G006", query_g006(), ["st_distance", "order by", "limit", "from locations"]},
      {"G007", query_g007(), ["st_geometrytype", "count", "group by", "order by"]},
      {"G008", query_g008(), ["exists (", "st_intersects", "$1", "from locations"]},
      {"C001", query_c001(), ["with", "select", "left join", "where"]},
      {"C002", query_c002(), ["with recursive", "union all", "left join", "select"]},
      {"C003", query_c003(), ["with", "order_totals", "customer_spend", "left join"]},
      {"C004", query_c004(), ["with status_labels", "values", "left join", "select"]},
      {"C005", query_c005(), ["with", "order_totals", "left join", "select"]},
      {"C006", query_c006(), ["with status_labels", "values", "left join", "select"]},
      {"C007", query_c007(), ["with recursive", "union all", "left join", "select"]},
      {"C008", query_c008(), ["with status_labels", "values", "left join", "select"]}
    ]
  end

  def run do
    verify_domain_root!()
    examples = examples()

    Enum.each(examples, fn {id, query, fragments} ->
      Enum.each(@adapters, fn adapter ->
        case render_adapter_output(id, query, fragments, adapter) do
          %{status: :ok} ->
            IO.puts("PASS #{id} #{adapter.key}")

          %{status: :unsupported, error: error} ->
            IO.puts("SKIP #{id} #{adapter.key} #{error}")
        end
      end)
    end)

    run_validation_sensitive_examples!()

    IO.puts("Verified #{length(examples)} pattern examples across #{length(@adapters)} adapters")
  end

  def dump_sql_markdown(output_path \\ "patterns/SELECTO_YIELDED_SQL.md") do
    body =
      examples()
      |> Enum.map(fn {id, query, fragments} ->
        outputs = adapter_outputs_for_example(id, query, fragments)

        [
          "## ",
          id,
          "\n\n",
          Enum.map(@adapters, fn adapter ->
            format_markdown_adapter_output(adapter, Map.fetch!(outputs, adapter.key))
          end)
        ]
      end)

    content = [
      "# Selecto Yielded SQL\n\n",
      "Generated from `Selecto.to_sql/1` for every example in this repository.\n\n",
      body
    ]

    File.write!(output_path, IO.iodata_to_binary(content))
    IO.puts("Wrote #{output_path}")
  end

  def dump_adapter_json(output_path \\ "patterns/SELECTO_ADAPTER_OUTPUTS.json") do
    payload = %{
      generated_at: DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601(),
      adapters: Enum.map(@adapters, &Map.take(&1, [:key, :label])),
      patterns: adapter_outputs()
    }

    File.write!(output_path, Jason.encode_to_iodata!(payload, pretty: true))
    IO.puts("Wrote #{output_path}")
  end

  def dump_expr_json(output_path \\ "patterns/SELECTO_EXPR_EXAMPLES.json") do
    payload = %{
      generated_at: DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_iso8601(),
      patterns: expr_examples()
    }

    File.write!(output_path, Jason.encode_to_iodata!(payload, pretty: true))
    IO.puts("Wrote #{output_path}")
  end

  def adapter_outputs do
    examples()
    |> Enum.into(%{}, fn {id, query, fragments} ->
      {id, adapter_outputs_for_example(id, query, fragments)}
    end)
  end

  def expr_examples do
    source = File.read!(@source_file)

    examples()
    |> Enum.map(fn {id, _query, _fragments} ->
      {id, source |> extract_expr_source!(id) |> to_runtime_expr_source!()}
    end)
    |> Map.new()
  end

  defp extract_expr_source!(source, id) do
    function_name = "query_" <> String.downcase(id)

    regex = ~r/^  defp #{function_name} do\n(?<body>[\s\S]*?)^  end$/m

    case Regex.named_captures(regex, source) do
      %{"body" => body} ->
        body
        |> String.split("\n")
        |> Enum.map(fn line -> String.replace_prefix(line, "    ", "") end)
        |> Enum.join("\n")
        |> String.trim()

      _ ->
        raise "Could not extract Expr source for #{id}"
    end
  end

  defp to_runtime_expr_source!(source) do
    ast = Code.string_to_quoted!(source)

    ast
    |> expand_expr_macros()
    |> rewrite_classic_runtime_expr_ast()
    |> unqualify_expr_calls()
    |> simplify_runtime_expr_ast()
    |> Macro.to_string()
    |> Code.format_string!()
    |> IO.iodata_to_binary()
    |> String.trim()
  end

  defp expand_expr_macros(ast) do
    Macro.postwalk(ast, fn
      {:where, _meta, [expression]} ->
        Selecto.ExprCompiler.compile_filter!(expression)

      {:select, _meta, [expression]} ->
        Selecto.ExprCompiler.compile_select!(expression)

      {:order_by, _meta, [expression]} ->
        Selecto.ExprCompiler.compile_order!(expression)

      other ->
        other
    end)
  end

  defp unqualify_expr_calls(ast) do
    Macro.postwalk(ast, fn
      {:apply, meta, [{:__aliases__, _alias_meta, [:Selecto, :Expr]}, fun_name, args]}
      when is_atom(fun_name) and is_list(args) ->
        {fun_name, meta, args}

      {:apply, meta, [{:__aliases__, _alias_meta, [:X]}, fun_name, args]}
      when is_atom(fun_name) and is_list(args) ->
        {fun_name, meta, args}

      {{:., _dot_meta, [{:__aliases__, _alias_meta, [:Selecto, :Expr]}, fun]}, meta, args} ->
        {fun, meta, args}

      {{:., _dot_meta, [{:__aliases__, _alias_meta, [:X]}, fun]}, meta, args} ->
        {fun, meta, args}

      other ->
        other
    end)
  end

  defp rewrite_classic_runtime_expr_ast(ast) do
    Macro.postwalk(ast, fn
      {:{}, _meta, [field, value]} when is_binary(field) ->
        rewrite_runtime_filter(field, value)

      {:{}, _meta, [:and, filters]} when is_list(filters) ->
        {:compact_and, [], [filters]}

      {:{}, _meta, [:or, filters]} when is_list(filters) ->
        {:compact_or, [], [filters]}

      {:{}, _meta, [:field, expr, alias_name]} ->
        {:as, [], [expr, alias_name]}

      {:{}, _meta, [:func, function_name, [value], opts]}
      when is_binary(function_name) and is_list(opts) ->
        rewrite_runtime_func(function_name, value, opts)

      {:{}, _meta, [:count, "*"]} ->
        {:count, [], []}

      {:count, meta, ["*"]} ->
        {:count, meta, []}

      {:count, meta, [:*]} ->
        {:count, meta, []}

      {field, value} when is_binary(field) ->
        rewrite_runtime_filter(field, value)

      {:and, filters} when is_list(filters) ->
        {:compact_and, [], [filters]}

      {:or, filters} when is_list(filters) ->
        {:compact_or, [], [filters]}

      {:field, expr, alias_name} ->
        {:as, [], [expr, alias_name]}

      {:func, function_name, [value], opts} when is_binary(function_name) and is_list(opts) ->
        rewrite_runtime_func(function_name, value, opts)

      other ->
        other
    end)
  end

  defp rewrite_runtime_filter(field, {:gt, value}), do: {:gt, [], [field, value]}
  defp rewrite_runtime_filter(field, {:gte, value}), do: {:gte, [], [field, value]}
  defp rewrite_runtime_filter(field, {:lt, value}), do: {:lt, [], [field, value]}
  defp rewrite_runtime_filter(field, {:lte, value}), do: {:lte, [], [field, value]}
  defp rewrite_runtime_filter(field, {:ne, value}), do: {:neq, [], [field, value]}
  defp rewrite_runtime_filter(field, {:like, value}), do: {:like, [], [field, value]}

  defp rewrite_runtime_filter(field, {:case_insensitive_like, value}),
    do: {:case_insensitive_like, [], [field, value]}

  defp rewrite_runtime_filter(field, {:contains, value}), do: {:contains, [], [field, value]}
  defp rewrite_runtime_filter(field, {:between, min, max}), do: {:between, [], [field, min, max]}
  defp rewrite_runtime_filter(field, {:in, values}), do: {:in, [], [field, values]}
  defp rewrite_runtime_filter(field, {:not_in, values}), do: {:not_in, [], [field, values]}
  defp rewrite_runtime_filter(field, :not_null), do: {:not_null, [], [field]}
  defp rewrite_runtime_filter(field, nil), do: {:is_null, [], [field]}
  defp rewrite_runtime_filter(field, :asc), do: {:asc, [], [field]}
  defp rewrite_runtime_filter(field, :desc), do: {:desc, [], [field]}
  defp rewrite_runtime_filter(field, value), do: {:eq, [], [field, value]}

  defp rewrite_runtime_func(function_name, value, opts) do
    expr =
      case String.upcase(function_name) do
        "SUM" -> {:sum, [], [value]}
        "AVG" -> {:avg, [], [value]}
        "MIN" -> {:min, [], [value]}
        "MAX" -> {:max, [], [value]}
        "COUNT" -> {:count, [], [value]}
        _ -> {:func, [], [function_name, [value]]}
      end

    case Keyword.fetch(opts, :as) do
      {:ok, alias_name} -> {:as, [], [expr, alias_name]}
      :error -> expr
    end
  end

  defp simplify_runtime_expr_ast(ast) do
    Macro.postwalk(ast, fn
      {:field, _meta, [value]} when is_binary(value) ->
        value

      other ->
        other
    end)
  end

  defp adapter_outputs_for_example(id, query, fragments) do
    @adapters
    |> Enum.map(fn adapter ->
      {adapter.key, render_adapter_output(id, query, fragments, adapter)}
    end)
    |> Map.new()
  end

  defp render_adapter_output(id, query, fragments, adapter) do
    query = retarget_runtime(query, %{adapter: adapter.module})
    previous_adapter = Process.put(:selecto_sql_patterns_adapter, adapter.module)

    try do
      {sql, params} = Selecto.to_sql(query)
      normalized = normalize_sql(sql)
      assert_sql_sanity!(id, normalized)
      assert_domain_root!(id, normalized, query)

      if adapter.verify == :strict do
        assert_fragments!(id, normalized, fragments)
      end

      %{
        status: :ok,
        sql: String.trim(sql),
        params: params
      }
    rescue
      error ->
        %{
          status: :unsupported,
          error: Exception.message(error)
        }
    after
      if previous_adapter do
        Process.put(:selecto_sql_patterns_adapter, previous_adapter)
      else
        Process.delete(:selecto_sql_patterns_adapter)
      end
    end
  end

  def retarget_runtime(query, runtime) when is_map(runtime) do
    set_operations =
      query.set
      |> Map.get(:set_operations, [])
      |> Enum.map(fn operation ->
        %{
          operation
          | left_query: retarget_runtime(operation.left_query, runtime),
            right_query: retarget_runtime(operation.right_query, runtime)
        }
      end)

    adapter = Map.get(runtime, :adapter, query.adapter)
    connection = Map.get(runtime, :connection, query.connection)

    query
    |> Map.merge(%{adapter: adapter, connection: connection})
    |> Map.put(:runtime, Selecto.Runtime.Context.new(adapter, connection))
    |> put_in([Access.key!(:set), :set_operations], set_operations)
  end

  defp format_markdown_adapter_output(adapter, %{status: :ok, sql: sql, params: params}) do
    sql = trim_trailing_line_whitespace(sql)

    [
      "### ",
      adapter.label,
      "\n\n",
      "```sql\n",
      sql,
      "\n```\n\n",
      "**Params:** `",
      inspect(params),
      "`\n\n"
    ]
  end

  defp format_markdown_adapter_output(adapter, %{status: :unsupported, error: error}) do
    [
      "### ",
      adapter.label,
      "\n\n",
      "_Unavailable:_ `",
      error,
      "`\n\n"
    ]
  end

  defp normalize_sql(sql) do
    sql
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> String.downcase()
  end

  defp trim_trailing_line_whitespace(sql) do
    sql
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.trim_trailing/1)
    |> Enum.join("\n")
  end

  defp assert_fragments!(id, sql, fragments) do
    Enum.each(fragments, fn fragment ->
      if not String.contains?(sql, fragment) do
        raise "#{id} failed: expected SQL to include '#{fragment}'. SQL was: #{sql}"
      end
    end)
  end

  defp assert_sql_sanity!(id, sql) do
    if String.contains?(sql, "nil.") do
      raise "#{id} failed: SQL contained invalid nil-qualified selector. SQL was: #{sql}"
    end
  end

  defp assert_domain_root!(id, sql, query) do
    root = query |> Selecto.source_table() |> to_string() |> String.downcase()
    escaped = Regex.escape(root)

    unless Regex.match?(~r/\bfrom\s+(?:["`\[])?#{escaped}(?:["`\]])?(?:\s|$)/, sql) do
      raise "#{id} failed: SQL root did not come from domain source #{inspect(root)}. SQL was: #{sql}"
    end
  end

  def verify_domain_root! do
    source = File.read!(@source_file)

    if Regex.match?(~r/Selecto\.from\s*\(/, source) do
      raise "query examples must not call a root-level Selecto.from operation"
    end

    Enum.each(@adapters, fn adapter ->
      query =
        configure(
          %{
            name: "Domain root contract",
            source: %{
              source_table: "selecto_domain_root_contract",
              primary_key: :id,
              fields: [:id],
              redact_fields: [],
              columns: %{id: %{type: :integer}},
              associations: %{}
            },
            schemas: %{},
            joins: %{}
          },
          :compile_only,
          adapter: adapter.module,
          validate: false
        )
        |> Selecto.select(["id"])

      case render_adapter_output("ROOT", query, ["select"], adapter) do
        %{status: :ok} ->
          IO.puts("PASS ROOT #{adapter.key}")

        %{status: :unsupported, error: error} ->
          raise "ROOT failed for #{adapter.key}: #{error}"
      end
    end)
  end

  defp run_validation_sensitive_examples! do
    validation_examples = [
      {"EV001", validation_query_unnest_registered_field(),
       ["cross join lateral unnest", "product_tag"]},
      {"EV002", validation_query_cte_registered_field(),
       ["with active_orders", "active_orders.status"]}
    ]

    Enum.each(validation_examples, fn {id, query, fragments} ->
      case render_adapter_output(id, query, fragments, hd(@adapters)) do
        %{status: :ok} -> IO.puts("PASS #{id} #{hd(@adapters).key}")
        %{status: :unsupported, error: error} -> raise "#{id} failed for validation run: #{error}"
      end
    end)

    published_view_examples = [
      {"PV001", order_domain_with_published_views(), :order_rollup,
       ["select", "status", "from orders"], "CREATE VIEW \"reporting\".\"order_rollup\" AS"},
      {"PV002", order_domain_with_published_views(), :recent_order_snapshot,
       ["select", "status", "inserted_at"],
       "CREATE MATERIALIZED VIEW \"reporting\".\"recent_order_snapshot\" AS"}
    ]

    Enum.each(published_view_examples, fn {id, domain, spec_key, sql_fragments, ddl_fragment} ->
      spec = Map.put(domain.published_views[spec_key], :adapter, SelectoDBPostgreSQL.Adapter)

      case Selecto.ViewPublisher.build_sql(domain, spec) do
        {:ok, result} ->
          normalized_sql = normalize_sql(result.sql)
          assert_sql_sanity!(id, normalized_sql)
          assert_fragments!(id, normalized_sql, sql_fragments)

          unless String.contains?(result.ddl, ddl_fragment) do
            raise "#{id} failed: expected DDL to include '#{ddl_fragment}'. DDL was: #{result.ddl}"
          end

          IO.puts("PASS #{id} published_view")

        {:error, errors} ->
          raise "#{id} failed for published view build: #{Enum.join(errors, "; ")}"
      end
    end)

    if Selecto.ViewPublisher.refresh_sql(
         SelectoDBPostgreSQL.Adapter,
         "reporting.recent_order_snapshot",
         concurrently: true
       ) !=
         "REFRESH MATERIALIZED VIEW CONCURRENTLY \"reporting\".\"recent_order_snapshot\";" do
      raise "PV003 failed: concurrent refresh SQL did not match expected output"
    end

    IO.puts("PASS PV003 published_view_refresh")
  end

  defp employee_domain do
    %{
      name: "Employees",
      source: %{
        source_table: "employees",
        primary_key: :id,
        fields: [:id, :first_name, :department, :salary, :active],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          first_name: %{type: :string},
          department: %{type: :string},
          salary: %{type: :decimal},
          active: %{type: :boolean}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp employee_domain_with_manager_join do
    %{
      name: "Employees",
      source: %{
        source_table: "employees",
        primary_key: :id,
        fields: [:id, :first_name, :manager_id],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          first_name: %{type: :string},
          manager_id: %{type: :integer}
        },
        associations: %{
          manager: %{
            field: :manager,
            queryable: :managers,
            owner_key: :manager_id,
            related_key: :id
          }
        }
      },
      schemas: %{
        managers: %{
          source_table: "employees",
          primary_key: :id,
          fields: [:id, :first_name],
          redact_fields: [],
          columns: %{
            id: %{type: :integer},
            first_name: %{type: :string}
          }
        }
      },
      joins: %{
        manager: %{
          name: "Manager",
          type: :left,
          source: "employees",
          on: [%{left: "manager_id", right: "id"}],
          fields: %{
            id: %{type: :integer},
            first_name: %{type: :string}
          }
        }
      }
    }
  end

  defp product_domain do
    %{
      name: "Products",
      source: %{
        source_table: "products",
        primary_key: :id,
        fields: [:id, :name, :sku, :price, :active, :tags, :metadata],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          name: %{type: :string},
          sku: %{type: :string},
          price: %{type: :decimal},
          active: %{type: :boolean},
          tags: %{type: {:array, :string}},
          metadata: %{type: :json}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp product_domain_with_reviews_join do
    %{
      name: "Products",
      source: %{
        source_table: "products",
        primary_key: :id,
        fields: [:id, :name, :sku, :price, :active, :tags],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          name: %{type: :string},
          sku: %{type: :string},
          price: %{type: :decimal},
          active: %{type: :boolean},
          tags: %{type: {:array, :string}}
        },
        associations: %{
          reviews: %{
            field: :reviews,
            queryable: :reviews,
            owner_key: :id,
            related_key: :product_id
          }
        }
      },
      schemas: %{
        reviews: %{
          source_table: "reviews",
          primary_key: :id,
          fields: [:id, :product_id, :rating],
          redact_fields: [],
          columns: %{
            id: %{type: :integer},
            product_id: %{type: :integer},
            rating: %{type: :integer}
          }
        }
      },
      joins: %{
        reviews: %{
          name: "Reviews",
          type: :left,
          source: "reviews",
          on: [%{left: "id", right: "product_id"}],
          fields: %{
            id: %{type: :integer},
            product_id: %{type: :integer},
            rating: %{type: :integer}
          }
        }
      }
    }
  end

  defp order_domain do
    %{
      name: "Orders",
      source: %{
        source_table: "orders",
        primary_key: :id,
        fields: [:id, :order_number, :status, :total],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          order_number: %{type: :string},
          status: %{type: :string},
          total: %{type: :decimal}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp order_timeseries_domain do
    %{
      name: "OrderEvents",
      source: %{
        source_table: "orders",
        primary_key: :id,
        fields: [:id, :order_number, :status, :total, :customer_id, :inserted_at],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          order_number: %{type: :string},
          status: %{type: :string},
          total: %{type: :decimal},
          customer_id: %{type: :integer},
          inserted_at: %{type: :naive_datetime}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp customer_domain do
    %{
      name: "Customers",
      source: %{
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
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp vendor_domain do
    %{
      name: "Vendors",
      source: %{
        source_table: "vendors",
        primary_key: :id,
        fields: [:id, :name, :tier],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          name: %{type: :string},
          tier: %{type: :string}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp vendor_contact_domain do
    %{
      name: "VendorContacts",
      source: %{
        source_table: "vendor_contacts",
        primary_key: :id,
        fields: [:id, :company_name, :segment],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          company_name: %{type: :string},
          segment: %{type: :string}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp archived_order_domain do
    %{
      name: "ArchivedOrders",
      source: %{
        source_table: "archived_orders",
        primary_key: :id,
        fields: [:id, :order_number, :total],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          order_number: %{type: :string},
          total: %{type: :decimal}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp premium_customer_domain do
    %{
      name: "PremiumCustomers",
      source: %{
        source_table: "premium_customers",
        primary_key: :id,
        fields: [:id, :name],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          name: %{type: :string}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp active_customer_domain do
    %{
      name: "ActiveCustomers",
      source: %{
        source_table: "active_customers",
        primary_key: :id,
        fields: [:id, :name],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          name: %{type: :string}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp active_customer_view_domain do
    %{
      name: "ActiveCustomerView",
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

  defmodule OrderCustomerOverlay do
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

  defp order_domain_for_overlay do
    %{
      name: "Orders",
      source: %{
        source_table: "orders",
        primary_key: :id,
        fields: [:id, :order_number, :status, :customer_id],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          order_number: %{type: :string},
          status: %{type: :string},
          customer_id: %{type: :integer}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp order_domain_with_overlay_customer_join do
    Selecto.Config.Overlay.merge(order_domain_for_overlay(), OrderCustomerOverlay.overlay())
  end

  defp order_domain_with_published_views do
    %{
      name: "Orders",
      source: %{
        source_table: "orders",
        primary_key: :id,
        fields: [:id, :status, :inserted_at],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          status: %{type: :string},
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
          query: fn selecto ->
            selecto
            |> Selecto.select(select([as(id, "order_id"), as(status, "status")]))
          end,
          columns: %{
            order_id: %{type: :integer},
            status: %{type: :string}
          }
        },
        recent_order_snapshot: %{
          database_name: "reporting.recent_order_snapshot",
          kind: :materialized_view,
          query: fn selecto ->
            selecto
            |> Selecto.select(
              select([as(id, "order_id"), as(status, "status"), as(inserted_at, "inserted_at")])
            )
          end,
          columns: %{
            order_id: %{type: :integer},
            status: %{type: :string},
            inserted_at: %{type: :naive_datetime}
          }
        }
      }
    }
  end

  defp blocked_customer_domain do
    %{
      name: "BlockedCustomers",
      source: %{
        source_table: "blocked_customers",
        primary_key: :id,
        fields: [:id, :name],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          name: %{type: :string}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp attendee_domain_with_orders_join do
    %{
      source: %{
        source_table: "attendees",
        primary_key: :attendee_id,
        fields: [:attendee_id, :event_id, :name, :email],
        redact_fields: [],
        columns: %{
          attendee_id: %{type: :integer},
          event_id: %{type: :integer},
          name: %{type: :string},
          email: %{type: :string}
        },
        associations: %{
          orders: %{
            queryable: :orders,
            field: :orders,
            owner_key: :attendee_id,
            related_key: :attendee_id
          }
        }
      },
      schemas: %{
        orders: %{
          source_table: "orders",
          primary_key: :order_id,
          fields: [:order_id, :attendee_id, :product_name, :quantity, :price],
          redact_fields: [],
          columns: %{
            order_id: %{type: :integer},
            attendee_id: %{type: :integer},
            product_name: %{type: :string},
            quantity: %{type: :integer},
            price: %{type: :decimal}
          },
          associations: %{
            order_items: %{
              queryable: :order_items,
              field: :order_items,
              owner_key: :order_id,
              related_key: :order_id
            }
          }
        },
        order_items: %{
          source_table: "order_items",
          primary_key: :order_item_id,
          fields: [:order_item_id, :order_id, :sku, :quantity],
          redact_fields: [],
          columns: %{
            order_item_id: %{type: :integer},
            order_id: %{type: :integer},
            sku: %{type: :string},
            quantity: %{type: :integer}
          },
          associations: %{}
        }
      },
      name: "Attendee",
      joins: %{
        orders: %{type: :left, name: "orders"}
      }
    }
  end

  defp event_retarget_domain do
    %{
      source: %{
        source_table: "events",
        primary_key: :event_id,
        fields: [:event_id, :name, :date],
        redact_fields: [],
        columns: %{
          event_id: %{type: :integer},
          name: %{type: :string},
          date: %{type: :date}
        },
        associations: %{
          attendees: %{
            queryable: :attendees,
            field: :attendees,
            owner_key: :event_id,
            related_key: :event_id
          }
        }
      },
      schemas: %{
        attendees: %{
          source_table: "attendees",
          primary_key: :attendee_id,
          fields: [:attendee_id, :event_id, :name, :email],
          redact_fields: [],
          columns: %{
            attendee_id: %{type: :integer},
            event_id: %{type: :integer},
            name: %{type: :string},
            email: %{type: :string}
          },
          associations: %{
            orders: %{
              queryable: :orders,
              field: :orders,
              owner_key: :attendee_id,
              related_key: :attendee_id
            }
          }
        },
        orders: %{
          source_table: "orders",
          primary_key: :order_id,
          fields: [:order_id, :attendee_id, :product_name, :quantity],
          redact_fields: [],
          columns: %{
            order_id: %{type: :integer},
            attendee_id: %{type: :integer},
            product_name: %{type: :string},
            quantity: %{type: :integer}
          },
          associations: %{}
        }
      },
      name: "Event",
      joins: %{
        attendees: %{
          type: :left,
          name: "attendees",
          joins: %{
            orders: %{type: :left, name: "orders"}
          }
        }
      }
    }
  end

  defp location_domain do
    %{
      name: "Locations",
      source: %{
        source_table: "locations",
        primary_key: :id,
        fields: [:id, :name, :geom],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          name: %{type: :string},
          geom: %{type: :geometry}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp archived_order_timeseries_domain do
    %{
      name: "ArchivedOrderEvents",
      source: %{
        source_table: "archived_orders",
        primary_key: :id,
        fields: [:id, :order_number, :inserted_at, :total],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          order_number: %{type: :string},
          inserted_at: %{type: :naive_datetime},
          total: %{type: :decimal}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp first_order_cohort_domain do
    %{
      name: "FirstOrderCohorts",
      source: %{
        source_table: "first_order_cohorts",
        primary_key: :customer_id,
        source_kind: :view,
        readonly: true,
        fields: [:customer_id, :cohort_start],
        redact_fields: [],
        columns: %{
          customer_id: %{type: :integer},
          cohort_start: %{type: :naive_datetime}
        },
        associations: %{
          orders: %{
            queryable: :orders,
            field: :orders,
            owner_key: :customer_id,
            related_key: :customer_id
          }
        }
      },
      schemas: %{
        orders: %{
          source_table: "orders",
          primary_key: :id,
          fields: [:id, :order_number, :customer_id, :status, :total, :inserted_at],
          redact_fields: [],
          columns: %{
            id: %{type: :integer},
            order_number: %{type: :string},
            customer_id: %{type: :integer},
            status: %{type: :string},
            total: %{type: :decimal},
            inserted_at: %{type: :naive_datetime}
          },
          associations: %{}
        }
      },
      joins: %{
        orders: %{
          name: "Orders",
          type: :left,
          source: "orders",
          on: [%{left: "customer_id", right: "customer_id"}],
          fields: %{
            id: %{type: :integer},
            order_number: %{type: :string},
            customer_id: %{type: :integer},
            status: %{type: :string},
            total: %{type: :decimal},
            inserted_at: %{type: :naive_datetime}
          }
        }
      }
    }
  end

  defp customer_domain_with_shape_members do
    domain = customer_domain()

    query_members = %{
      ctes: %{},
      values: %{},
      subqueries: %{
        processing_orders_member: %{
          query: fn _selecto ->
            configure(order_domain_with_customer_join(), :mock_connection, validate: false)
            |> Selecto.select(["customer_id", "order_number", "total"])
            |> Selecto.filter({"status", "processing"})
          end,
          type: :left,
          on: [%{left: "id", right: "customer_id"}]
        }
      }
    }

    Map.put(domain, :query_members, query_members)
  end

  defp order_domain_with_shape_members do
    domain = order_domain_with_customer_join()

    query_members = %{
      ctes: %{
        delivered_totals: %{
          query: fn _selecto ->
            configure(order_domain_with_customer_join(), :mock_connection, validate: false)
            |> Selecto.select(["id", "total"])
            |> Selecto.filter({"status", "delivered"})
          end,
          columns: ["id", "total"],
          join: [owner_key: :id, related_key: :id, fields: :infer]
        }
      },
      values: %{},
      subqueries: %{}
    }

    Map.put(domain, :query_members, query_members)
  end

  defp review_domain do
    %{
      name: "Reviews",
      source: %{
        source_table: "reviews",
        primary_key: :id,
        fields: [:id, :product_id, :rating],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          product_id: %{type: :integer},
          rating: %{type: :integer}
        },
        associations: %{}
      },
      schemas: %{},
      joins: %{}
    }
  end

  defp order_domain_with_customer_join do
    %{
      name: "Orders",
      source: %{
        source_table: "orders",
        primary_key: :id,
        fields: [:id, :order_number, :status, :total, :customer_id],
        redact_fields: [],
        columns: %{
          id: %{type: :integer},
          order_number: %{type: :string},
          status: %{type: :string},
          total: %{type: :decimal},
          customer_id: %{type: :integer}
        },
        associations: %{
          customer: %{
            field: :customer,
            queryable: :customers,
            owner_key: :customer_id,
            related_key: :id
          }
        }
      },
      schemas: %{
        customers: %{
          source_table: "customers",
          primary_key: :id,
          fields: [:id, :name, :tier],
          redact_fields: [],
          columns: %{
            id: %{type: :integer},
            name: %{type: :string},
            tier: %{type: :string}
          }
        }
      },
      joins: %{
        customer: %{
          name: "Customer",
          type: :left,
          source: "customers",
          on: [%{left: "customer_id", right: "id"}],
          fields: %{
            name: %{type: :string},
            tier: %{type: :string}
          }
        }
      }
    }
  end

  defp order_domain_with_customer_join_filter do
    order_domain_with_customer_join()
    |> put_in([:joins, :customer, :filters], %{"tier" => %{type: "string"}})
  end

  defp query_j001 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, customer.name]))
    |> Selecto.filter(where(customer.id != nil))
    |> Selecto.filter(where(status == "delivered"))
    |> Selecto.order_by(order_by([asc(order_number)]))
  end

  defp query_j002 do
    configure(product_domain_with_reviews_join(), :mock_connection, validate: false)
    |> Selecto.select(select([name, count(reviews.id)]))
    |> Selecto.group_by(["name"])
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_j003 do
    high_value_delivered_orders =
      configure(order_domain_with_customer_join(), :mock_connection, validate: false)
      |> Selecto.select(["customer_id", "order_number", "total"])
      |> Selecto.filter(where(status == "delivered" and total > 1000))

    configure(customer_domain(), :mock_connection, validate: false)
    |> Selecto.join_subquery(:high_value_delivered, high_value_delivered_orders,
      type: :inner,
      on: [%{left: "id", right: "customer_id"}]
    )
    |> Selecto.select(
      select([name, tier, high_value_delivered.order_number, high_value_delivered.total])
    )
  end

  defp query_j004 do
    configure(employee_domain_with_manager_join(), :mock_connection, validate: false)
    |> Selecto.select(select([first_name, manager.first_name]))
    |> Selecto.order_by(order_by([asc(first_name)]))
  end

  defp query_j005 do
    configure(product_domain_with_reviews_join(), :mock_connection, validate: false)
    |> Selecto.select(select([name]))
    |> Selecto.filter(where(reviews.id == nil))
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_j006 do
    configure(order_domain_with_customer_join_filter(), :mock_connection, validate: false)
    |> Selecto.join_parameterize(:customer, "tier_premium", tier: "premium")
    |> Selecto.join_parameterize(:customer, "tier_standard", tier: "standard")
    |> Selecto.select([
      "order_number",
      "customer:tier_premium.name",
      "customer:tier_standard.name"
    ])
  end

  defp query_j007 do
    subquery_query =
      configure(order_domain(), :mock_connection, validate: false)
      |> Selecto.select([{:count, "*"}])
      |> Selecto.filter({"status", "delivered"})

    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select([
      "name",
      {:field, {:raw_sql, "delivered_stats.count"}, "delivered_order_count"}
    ])
    |> Selecto.lateral_join(:left, fn _ -> subquery_query end, "delivered_stats")
  end

  defp query_j008 do
    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.unnest("tags", as: "product_tag")
    |> Selecto.select([
      "name",
      "product_tag"
    ])
    |> Selecto.filter(X.eq("active", true))
  end

  defp query_j009 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.join_parameterize(:customer, "alias_a")
    |> Selecto.join_parameterize(:customer, "alias_b")
    |> Selecto.select(["order_number", "customer:alias_a.name", "customer:alias_b.tier"])
  end

  defp validation_query_unnest_registered_field do
    configure(product_domain(), :mock_connection)
    |> Selecto.unnest("tags", as: "product_tag")
    |> Selecto.select(["name", "product_tag"])
    |> Selecto.filter({"active", true})
  end

  defp validation_query_cte_registered_field do
    configure(order_domain(), :mock_connection)
    |> Selecto.with_cte(
      "active_orders",
      fn ->
        configure(order_domain(), :mock_connection)
        |> Selecto.select(["id", "status"])
        |> Selecto.filter({"status", "processing"})
      end,
      columns: ["id", "status"],
      join: true
    )
    |> Selecto.select(["order_number", "active_orders.status"])
  end

  defp query_j010 do
    star_domain =
      order_domain_with_customer_join()
      |> put_in([:joins, :customer, :type], :star_dimension)

    configure(star_domain, :mock_connection, validate: false)
    |> Selecto.select(select([customer.name, count()]))
    |> Selecto.group_by(["customer.name"])
    |> Selecto.order_by(order_by([asc(customer.name)]))
  end

  defp query_j011 do
    gold_customers =
      configure(customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name", "tier"])
      |> Selecto.filter(where(tier == "gold"))

    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.join_subquery(:gold_customers, gold_customers,
      type: :inner,
      on: [%{left: "customer_id", right: "id"}]
    )
    |> Selecto.select(["order_number", "gold_customers.name", "total"])
    |> Selecto.order_by(order_by([asc(order_number)]))
  end

  defp query_j012 do
    processing_orders =
      configure(order_domain_with_customer_join(), :mock_connection, validate: false)
      |> Selecto.select(["customer_id", "order_number"])
      |> Selecto.filter(where(status == "processing"))

    configure(customer_domain(), :mock_connection, validate: false)
    |> Selecto.join_subquery(:processing_orders, processing_orders,
      type: :left,
      on: [%{left: "id", right: "customer_id"}]
    )
    |> Selecto.select(["name", "tier", "processing_orders.order_number"])
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_a001 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([status, count()]))
    |> Selecto.group_by(["status"])
    |> Selecto.order_by(order_by([asc(status)]))
  end

  defp query_a002 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([customer_id, as(sum(total), "total_spend")]))
    |> Selecto.filter(where(status == "delivered"))
    |> Selecto.group_by(["customer_id"])
    |> Selecto.order_by(order_by([asc(customer_id)]))
  end

  defp query_a003 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([status, as(avg(total), "avg_total")]))
    |> Selecto.group_by(["status"])
    |> Selecto.order_by(order_by([asc(status)]))
  end

  defp query_a004 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([customer.name, count()]))
    |> Selecto.group_by(["customer.name"])
    |> Selecto.order_by(order_by([asc(customer.name)]))
  end

  defp query_a005 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([customer.tier, as(sum(total), "tier_total")]))
    |> Selecto.group_by(["customer.tier"])
    |> Selecto.order_by(order_by([asc(customer.tier)]))
  end

  defp query_a006 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([customer.tier, count()]))
    |> Selecto.filter(where(status == "delivered"))
    |> Selecto.group_by(["customer.tier"])
    |> Selecto.order_by(order_by([asc(customer.tier)]))
  end

  defp query_a007 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([status, as(sum(total), "total_amount"), count()]))
    |> Selecto.group_by(["status"])
    |> Selecto.order_by(order_by([asc(status)]))
  end

  defp query_a008 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([customer.tier, as(avg(total), "avg_delivered_total")]))
    |> Selecto.filter(where(status == "delivered"))
    |> Selecto.group_by(["customer.tier"])
    |> Selecto.order_by(order_by([asc(customer.tier)]))
  end

  defp query_a009 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([status, as(min(total), "min_total"), as(max(total), "max_total")]))
    |> Selecto.group_by(["status"])
    |> Selecto.order_by(order_by([asc(status)]))
  end

  defp query_a010 do
    configure(product_domain_with_reviews_join(), :mock_connection, validate: false)
    |> Selecto.select(select([name, count(reviews.id), as(avg(reviews.rating), "avg_rating")]))
    |> Selecto.group_by(["name"])
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_e001 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(
      select([
        order_number,
        status,
        as(
          case_when(
            [
              {status == "processing", "Open"},
              {status == "shipped", "In Transit"},
              {status == "delivered", "Closed"}
            ],
            "Other"
          ),
          "status_bucket"
        )
      ])
    )
    |> Selecto.order_by(order_by([asc(order_number)]))
  end

  defp query_e002 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(
      select([
        order_number,
        as(coalesce(customer.name, lit("Unassigned")), "customer_name"),
        as(nullif(status, lit("processing")), "non_processing_status")
      ])
    )
    |> Selecto.order_by(order_by([asc(order_number)]))
  end

  defp query_e003 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(
      select([
        status,
        as(count_distinct(customer_id), "distinct_customer_count"),
        as(stddev(total), "stddev_total"),
        as(variance(total), "variance_total")
      ])
    )
    |> Selecto.group_by(["status"])
    |> Selecto.order_by(order_by([asc(status)]))
  end

  defp query_e004 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([customer.tier, status, as(count(), "order_count")]))
    |> Selecto.group_by(group_by([rollup([customer.tier, status])]))
    |> Selecto.order_by(order_by([asc(customer.tier), asc(status)]))
  end

  defp query_w001 do
    configure(employee_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([first_name, department, salary]))
    |> Selecto.window_function(:row_number, [],
      over: [partition_by: ["department"], order_by: order_by([desc(salary)])],
      as: "department_salary_rank"
    )
  end

  defp query_w002 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([id, customer_id, total]))
    |> Selecto.window_function(:sum, ["total"],
      over: [partition_by: ["customer_id"], order_by: order_by([asc(id)])],
      as: "running_total"
    )
  end

  defp query_w003 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([id, customer_id, total]))
    |> Selecto.window_function(:lag, ["total", 1],
      over: [partition_by: ["customer_id"], order_by: order_by([asc(id)])],
      as: "prev_total"
    )
  end

  defp query_w004 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, total]))
    |> Selecto.window_function(:dense_rank, [],
      over: [order_by: order_by([desc(total)])],
      as: "total_rank"
    )
  end

  defp query_w005 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([id, total]))
    |> Selecto.window_function(:avg, ["total"],
      over: [
        order_by: order_by([asc(id)]),
        frame: {:rows, :unbounded_preceding, :current_row}
      ],
      as: "moving_avg_total"
    )
  end

  defp query_w006 do
    configure(employee_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([first_name, department, salary]))
    |> Selecto.window_function(:rank, [],
      over: [partition_by: ["department"], order_by: order_by([desc(salary)])],
      as: "department_rank"
    )
  end

  defp query_w007 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([id, customer_id, total]))
    |> Selecto.window_function(:lead, ["total", 1],
      over: [partition_by: ["customer_id"], order_by: order_by([asc(id)])],
      as: "next_total"
    )
  end

  defp query_w008 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, status, total]))
    |> Selecto.window_function(:max, ["total"],
      over: [partition_by: ["status"]],
      as: "status_max_total"
    )
  end

  defp query_w009 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, total]))
    |> Selecto.window_function(:percent_rank, [],
      over: [order_by: order_by([desc(total)])],
      as: "total_percent_rank"
    )
  end

  defp query_w010 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([id, customer_id, total]))
    |> Selecto.window_function(:count, ["*"],
      over: [partition_by: ["customer_id"]],
      as: "customer_order_count"
    )
  end

  defp customer_id_subquery_by_tier(tier) do
    configure(customer_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([id]))
    |> Selecto.filter(where(tier == ^tier))
  end

  defp order_total_subquery_by_status(status) do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([total]))
    |> Selecto.filter(where(status == ^status))
  end

  defp query_s001 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, customer_id, status, total]))
    |> Selecto.filter({"customer_id", {:subquery, :in, customer_id_subquery_by_tier("gold")}})
    |> Selecto.order_by(order_by([desc(total)]))
  end

  defp query_s002 do
    delivered_orders =
      configure(order_domain_with_customer_join(), :mock_connection, validate: false)
      |> Selecto.select(["customer_id", "order_number", "total"])
      |> Selecto.filter({"status", "delivered"})

    configure(customer_domain(), :mock_connection, validate: false)
    |> Selecto.join_subquery(:delivered_orders, delivered_orders,
      type: :left,
      on: [%{left: "id", right: "customer_id"}]
    )
    |> Selecto.select(select([name, delivered_orders.order_number, delivered_orders.total]))
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_s003 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, status, total]))
    |> Selecto.filter({
      :exists,
      "SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = 'gold'"
    })
    |> Selecto.order_by(order_by([desc(total)]))
  end

  defp query_s004 do
    reviewed_products =
      configure(review_domain(), :mock_connection, validate: false)
      |> Selecto.select(["product_id"])
      |> Selecto.group_by(["product_id"])

    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([name]))
    |> Selecto.join_subquery(:reviewed_products, reviewed_products,
      type: :left,
      on: [%{left: "id", right: "product_id"}]
    )
    |> Selecto.filter(where(reviewed_products.product_id == nil))
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_s005 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, customer_id, total]))
    |> Selecto.filter({"customer_id", {:subquery, :in, customer_id_subquery_by_tier("silver")}})
    |> Selecto.order_by(order_by([desc(total)]))
  end

  defp query_s006 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, status, total]))
    |> Selecto.filter({
      :exists,
      [
        "SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = ",
        {:param, "gold"}
      ]
    })
    |> Selecto.order_by(order_by([desc(total)]))
  end

  defp query_s007 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, customer_id, total]))
    |> Selecto.filter({"customer_id", {:subquery, :in, customer_id_subquery_by_tier("gold")}})
    |> Selecto.filter(where(status == "delivered"))
    |> Selecto.order_by(order_by([desc(total)]))
  end

  defp query_s008 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, status, total]))
    |> Selecto.filter(
      {"total", :>, {:subquery, :all, order_total_subquery_by_status("returned")}}
    )
    |> Selecto.order_by(order_by([desc(total)]))
  end

  defp query_s009 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, status, total]))
    |> Selecto.filter(
      {"total", :<, {:subquery, :any, order_total_subquery_by_status("delivered")}}
    )
    |> Selecto.order_by(order_by([asc(total)]))
  end

  defp query_s010 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, customer_id, total]))
    |> Selecto.filter(where(status == "processing"))
    |> Selecto.filter({
      :not,
      {:exists,
       [
         "SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = ",
         {:param, "suspended"}
       ]}
    })
    |> Selecto.order_by(order_by([desc(total)]))
  end

  defp query_so001 do
    customers =
      configure(customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["name", "tier"])

    vendors =
      configure(vendor_domain(), :mock_connection, validate: false)
      |> Selecto.select(["name", "tier"])

    Selecto.union(customers, vendors)
  end

  defp query_so002 do
    current_orders =
      configure(order_domain(), :mock_connection, validate: false)
      |> Selecto.select(["order_number", "total"])

    archived_orders =
      configure(archived_order_domain(), :mock_connection, validate: false)
      |> Selecto.select(["order_number", "total"])

    Selecto.union(current_orders, archived_orders, all: true)
  end

  defp query_so003 do
    premium_customers =
      configure(premium_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    active_customers =
      configure(active_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    Selecto.intersect(premium_customers, active_customers)
  end

  defp query_so004 do
    all_customers =
      configure(customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    blocked_customers =
      configure(blocked_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    Selecto.except(all_customers, blocked_customers)
  end

  defp query_so005 do
    premium_customers =
      configure(premium_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    active_customers =
      configure(active_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    all_customers =
      configure(customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    premium_or_active = Selecto.union(premium_customers, active_customers)

    Selecto.intersect(premium_or_active, all_customers)
  end

  defp query_so006 do
    premium_customers =
      configure(premium_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    active_customers =
      configure(active_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    Selecto.intersect(premium_customers, active_customers, all: true)
  end

  defp query_so007 do
    all_customers =
      configure(customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    blocked_customers =
      configure(blocked_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    Selecto.except(all_customers, blocked_customers, all: true)
  end

  defp query_so008 do
    customers =
      configure(customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["name", "tier"])

    vendor_contacts =
      configure(vendor_contact_domain(), :mock_connection, validate: false)
      |> Selecto.select(["company_name", "segment"])

    Selecto.union(customers, vendor_contacts,
      column_mapping: [
        {"name", "company_name"},
        {"tier", "segment"}
      ]
    )
  end

  defp query_f001 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, customer.name, status]))
    |> Selecto.filter(where(customer.id != nil))
    |> Selecto.filter(where(not_in(status, ["cancelled", "returned"])))
    |> Selecto.order_by(order_by([asc(order_number)]))
  end

  defp query_f002 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, status, total]))
    |> Selecto.filter(where((status == "processing" or status == "shipped") and total > 100))
    |> Selecto.order_by(order_by([desc(total)]))
  end

  defp query_f003 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, status, total]))
    |> Selecto.filter(where(between(total, 100, 500)))
    |> Selecto.filter(X.in("status", ["processing", "shipped", "delivered"]))
    |> Selecto.order_by(order_by([asc(order_number)]))
  end

  defp query_f004 do
    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([name, sku]))
    |> Selecto.filter(where(text_search(name, "wireless charger")))
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_f005 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, status, total]))
    |> Selecto.filter(where(not (status == "cancelled")))
    |> Selecto.filter(where(total > 50))
    |> Selecto.order_by(order_by([desc(total)]))
  end

  defp query_f006 do
    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([name, tags]))
    |> Selecto.filter(where(array_contains(tags, ["featured"])))
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_f007 do
    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([name, metadata.warehouse.zone]))
    |> Selecto.filter(where(field_exists(metadata.warehouse.zone)))
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_f008 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, customer_id, total]))
    |> Selecto.filter({"customer_id", {:subquery, :in, customer_id_subquery_by_tier("platinum")}})
    |> Selecto.filter(where(status == "processing"))
    |> Selecto.order_by(order_by([desc(total)]))
  end

  defp query_p001 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(["id", "order_number", "total"])
    |> Selecto.order_by({"id", :asc})
    |> Selecto.limit(25)
    |> Selecto.offset(50)
  end

  defp query_p002 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([id, order_number, total]))
    |> Selecto.filter(where(id > 1000))
    |> Selecto.order_by(order_by([asc(id)]))
    |> Selecto.limit(25)
  end

  defp query_p003 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([id, order_number, total]))
    |> Selecto.filter(where(id < 5000))
    |> Selecto.order_by(order_by([desc(id)]))
    |> Selecto.limit(20)
  end

  defp query_p004 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, customer.name, total]))
    |> Selecto.order_by(order_by([asc(customer.name)]))
    |> Selecto.order_by(order_by([asc(order_number)]))
    |> Selecto.limit(15)
    |> Selecto.offset(30)
  end

  defp query_p005 do
    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([id, order_number, inserted_at, total]))
    |> Selecto.filter(where(inserted_at > ~N[2024-01-15 00:00:00]))
    |> Selecto.order_by(order_by([asc(inserted_at)]))
    |> Selecto.order_by(order_by([asc(id)]))
    |> Selecto.limit(25)
  end

  defp query_p006 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([id, order_number, total]))
    |> Selecto.order_by(order_by([desc(total)]))
    |> Selecto.order_by(order_by([desc(id)]))
    |> Selecto.limit(20)
    |> Selecto.offset(40)
  end

  defp query_p007 do
    current_orders =
      configure(order_domain(), :mock_connection, validate: false)
      |> Selecto.select(["order_number", "total"])

    archived_orders =
      configure(archived_order_domain(), :mock_connection, validate: false)
      |> Selecto.select(["order_number", "total"])

    Selecto.union(current_orders, archived_orders, all: true)
    |> Selecto.order_by({"order_number", :asc})
    |> Selecto.limit(20)
    |> Selecto.offset(20)
  end

  defp query_p008 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([id, order_number, total]))
    |> Selecto.filter(where(total < 1000 or (total == 1000 and id < 500)))
    |> Selecto.order_by(order_by([desc(total)]))
    |> Selecto.order_by(order_by([desc(id)]))
    |> Selecto.limit(20)
  end

  defp query_ja001 do
    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([name, sku]))
    |> Selecto.json_select([X.json_extract_text("metadata", "$.price_band", as: "price_band")])
    |> Selecto.json_filter({:json_contains, "metadata", %{"price_band" => "premium"}})
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_ja002 do
    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([name, metadata.warehouse.zone]))
    |> Selecto.filter({"metadata.warehouse.zone", :exists})
    |> Selecto.filter(where(metadata.warehouse.zone == "A1"))
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_ja003 do
    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([name, tags]))
    |> Selecto.filter(where(array_overlap(tags, ["featured", "clearance"])))
    |> Selecto.filter(where(active == true))
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_ja004 do
    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([name]))
    |> Selecto.json_select([
      X.json_extract_text("metadata", "$.stock.quantity", as: "stock_quantity")
    ])
    |> Selecto.json_filter({:json_path_exists, "metadata", "$.stock.quantity"})
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_ja005 do
    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([name, sku]))
    |> Selecto.json_select([
      X.json_extract_text("metadata", "$.warehouse.zone", as: "warehouse_zone")
    ])
    |> Selecto.json_order_by(X.json_extract_text("metadata", "$.warehouse.zone", :asc))
  end

  defp query_ja006 do
    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([name, tags]))
    |> Selecto.filter(where(array_contains(tags, ["featured", "clearance"])))
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_ja007 do
    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([name, sku, metadata.warehouse.zone]))
    |> Selecto.filter(where(metadata.warehouse.zone == "A1"))
    |> Selecto.filter(where(active == true))
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_ja008 do
    configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([name, sku]))
    |> Selecto.json_select([
      X.json_extract_text("metadata", "$.warehouse.zone", as: "warehouse_zone"),
      X.json_extract_text("metadata", "$.stock.quantity", as: "stock_quantity")
    ])
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_q001 do
    configure(attendee_domain_with_orders_join(), :mock_connection, validate: false)
    |> Selecto.select(select([name, email]))
    |> Selecto.subselect([
      %{
        fields: ["product_name", "quantity"],
        target_schema: :orders,
        format: :json_agg,
        alias: "order_items"
      }
    ])
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_q002 do
    configure(event_retarget_domain(), :mock_connection, validate: false)
    |> Selecto.filter(where(event_id == 1000))
    |> Selecto.select(select([orders.product_name, orders.quantity]))
    |> Selecto.retarget(:orders, subquery_strategy: :exists)
  end

  defp query_q003 do
    configure(event_retarget_domain(), :mock_connection, validate: false)
    |> Selecto.filter(where(event_id == 2000))
    |> Selecto.select(select([orders.product_name, orders.quantity]))
    |> Selecto.retarget(:orders, subquery_strategy: :in)
  end

  defp query_q004 do
    configure(attendee_domain_with_orders_join(), :mock_connection, validate: false)
    |> Selecto.select(select([name, email]))
    |> Selecto.subselect([
      %{
        fields: ["product_name"],
        target_schema: :orders,
        format: :json_agg,
        alias: "products"
      },
      %{
        fields: ["quantity"],
        target_schema: :orders,
        format: :array_agg,
        alias: "quantities"
      }
    ])
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_q005 do
    configure(attendee_domain_with_orders_join(), :mock_connection, validate: false)
    |> Selecto.select(select([name, email]))
    |> Selecto.subselect([
      %{
        fields: ["order_id"],
        target_schema: :orders,
        format: :count,
        alias: "order_count"
      }
    ])
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_q006 do
    configure(customer_domain_with_shape_members(), :mock_connection, validate: false)
    |> Selecto.with_subquery(:processing_orders_member)
    |> Selecto.select(select([name, tier, processing_orders_member.order_number]))
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_q007 do
    configure(order_domain_with_shape_members(), :mock_connection, validate: false)
    |> Selecto.with_cte(:delivered_totals)
    |> Selecto.select(select([order_number, customer.name, delivered_totals.total]))
    |> Selecto.order_by(order_by([asc(order_number)]))
  end

  defp query_q008 do
    current_orders =
      configure(order_domain(), :mock_connection, validate: false)
      |> Selecto.select(select([order_number, total]))

    archived_orders =
      configure(archived_order_domain(), :mock_connection, validate: false)
      |> Selecto.select(select([order_number, total]))

    merged_orders = Selecto.union(current_orders, archived_orders, all: true)

    Selecto.except(merged_orders, archived_orders)
  end

  defp query_q009 do
    customer_tier = "premium"

    configure(active_customer_view_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([customer_id, name, tier]))
    |> Selecto.filter(~SELECTO"tier == ^customer_tier")
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_q010 do
    configure(order_domain_with_overlay_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, status, customer.name]))
    |> Selecto.order_by(order_by([asc(order_number)]))
  end

  defp query_q011 do
    configure(attendee_domain_with_orders_join(), :mock_connection, validate: false)
    |> Selecto.select(select([name, email]))
    |> Selecto.subselect([
      %{
        fields: ["product_name"],
        target_schema: :orders,
        format: :json_agg,
        alias: "orders",
        join_path: [:orders],
        nested: [
          %{
            key: "items",
            fields: ["sku", "quantity"],
            target_schema: :order_items,
            format: :json_agg,
            join_path: [:orders, :order_items]
          }
        ]
      }
    ])
    |> Selecto.order_by(order_by([asc(name)]))
  end

  defp query_t001 do
    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, inserted_at, total]))
    |> Selecto.filter(
      where(between(inserted_at, ~N[2024-01-01 00:00:00], ~N[2024-02-01 00:00:00]))
    )
    |> Selecto.order_by(order_by([asc(inserted_at)]))
  end

  defp query_t002 do
    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, inserted_at, total]))
    |> Selecto.window_function(:sum, ["total"],
      over: [order_by: order_by([asc(inserted_at)])],
      as: "running_total"
    )
    |> Selecto.order_by(order_by([asc(inserted_at)]))
  end

  defp query_t003 do
    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select([
      X.field("order_number"),
      {:field, {:raw_sql, "date_trunc('day', selecto_root.inserted_at)"}, "day_bucket"},
      X.field("total")
    ])
    |> Selecto.order_by(order_by([asc(inserted_at)]))
  end

  defp query_t004 do
    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, inserted_at, total]))
    |> Selecto.window_function(:avg, ["total"],
      over: [
        order_by: order_by([asc(inserted_at)]),
        frame: {:rows, {:preceding, 2}, :current_row}
      ],
      as: "trailing_avg_total"
    )
    |> Selecto.order_by(order_by([asc(inserted_at)]))
  end

  defp query_t005 do
    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, inserted_at, total]))
    |> Selecto.window_function(:lag, ["total", 1],
      over: [order_by: order_by([asc(inserted_at)])],
      as: "previous_total"
    )
    |> Selecto.order_by(order_by([asc(inserted_at)]))
  end

  defp query_t006 do
    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([order_number, status, inserted_at, total]))
    |> Selecto.window_function(:sum, ["total"],
      over: [partition_by: ["status"], order_by: order_by([asc(inserted_at)])],
      as: "status_running_total"
    )
    |> Selecto.order_by(order_by([asc(inserted_at)]))
  end

  defp query_t007 do
    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([id, order_number, inserted_at, total]))
    |> Selecto.filter(
      where(
        inserted_at < ~N[2024-02-01 00:00:00] or
          (inserted_at == ~N[2024-02-01 00:00:00] and id < 2000)
      )
    )
    |> Selecto.order_by(order_by([desc(inserted_at), desc(id)]))
    |> Selecto.limit(25)
  end

  defp query_t008 do
    current_events =
      configure(order_timeseries_domain(), :mock_connection, validate: false)
      |> Selecto.select(select([order_number, inserted_at, total]))

    archived_events =
      configure(archived_order_timeseries_domain(), :mock_connection, validate: false)
      |> Selecto.select(select([order_number, inserted_at, total]))

    Selecto.union(current_events, archived_events, all: true)
    |> Selecto.order_by(order_by([desc(inserted_at)]))
    |> Selecto.limit(50)
  end

  defp query_t009 do
    day_bucket = "date_trunc('day', selecto_root.inserted_at)"

    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select([
      {:field, {:raw_sql, day_bucket}, "day_bucket"},
      {:field, {:func, "SUM", ["total"]}, "daily_total"},
      {:count, "*"}
    ])
    |> Selecto.group_by([{:raw_sql, day_bucket}])
    |> Selecto.order_by({{:raw_sql, day_bucket}, :asc})
  end

  defp query_t010 do
    day_bucket = "date_trunc('day', selecto_root.inserted_at)"

    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select([
      {:field, {:raw_sql, day_bucket}, "day_bucket"},
      "status",
      {:count, "*"}
    ])
    |> Selecto.group_by([{:raw_sql, day_bucket}, "status"])
    |> Selecto.order_by([{{:raw_sql, day_bucket}, :asc}, {"status", :asc}])
  end

  defp query_t011 do
    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([customer_id, order_number, inserted_at]))
    |> Selecto.filter(where(customer_id != nil))
    |> Selecto.window_function(:lag, ["inserted_at", 1],
      over: [partition_by: ["customer_id"], order_by: order_by([asc(inserted_at)])],
      as: "previous_order_at"
    )
    |> Selecto.order_by(order_by([asc(customer_id), asc(inserted_at)]))
  end

  defp query_t012 do
    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([customer_id, order_number, inserted_at]))
    |> Selecto.filter(where(customer_id != nil))
    |> Selecto.window_function(:lead, ["inserted_at", 1],
      over: [partition_by: ["customer_id"], order_by: order_by([asc(inserted_at)])],
      as: "next_order_at"
    )
    |> Selecto.order_by(order_by([asc(customer_id), asc(inserted_at)]))
  end

  defp query_ca001 do
    configure(order_timeseries_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([customer_id, as(min(inserted_at), "cohort_start")]))
    |> Selecto.filter(where(customer_id != nil))
    |> Selecto.group_by(["customer_id"])
    |> Selecto.order_by(order_by([asc(customer_id)]))
  end

  defp query_ca002 do
    cohort_month = "date_trunc('month', selecto_root.cohort_start)"

    configure(first_order_cohort_domain(), :mock_connection, validate: false)
    |> Selecto.select([
      {:field, {:raw_sql, cohort_month}, "cohort_month"},
      {:count, "*"}
    ])
    |> Selecto.group_by([{:raw_sql, cohort_month}])
    |> Selecto.order_by({{:raw_sql, cohort_month}, :asc})
  end

  defp query_ca003 do
    configure(first_order_cohort_domain(), :mock_connection, validate: false)
    |> Selecto.select(select([cohort_start, orders.status, count(orders.id)]))
    |> Selecto.group_by(["cohort_start", "orders.status"])
    |> Selecto.order_by(order_by([asc(cohort_start), asc(orders.status)]))
  end

  defp query_ca004 do
    configure(first_order_cohort_domain(), :mock_connection, validate: false)
    |> Selecto.select(
      select([customer_id, cohort_start, orders.order_number, orders.inserted_at])
    )
    |> Selecto.window_function(:row_number, [],
      over: [partition_by: ["customer_id"], order_by: order_by([asc(orders.inserted_at)])],
      as: "cohort_order_number"
    )
    |> Selecto.order_by(order_by([asc(customer_id), asc(orders.inserted_at)]))
  end

  defp query_g001 do
    configure(location_domain(), :mock_connection, validate: false)
    |> Selecto.select(["id", "name"])
    |> Selecto.filter({
      :raw_sql_filter,
      "ST_DWithin(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326), 1000)"
    })
    |> Selecto.order_by({"id", :asc})
  end

  defp query_g002 do
    configure(location_domain(), :mock_connection, validate: false)
    |> Selecto.select(["id", "name"])
    |> Selecto.filter(
      {:exists, "SELECT 1 FROM regions r WHERE ST_Intersects(selecto_root.geom, r.geom)"}
    )
    |> Selecto.order_by({"id", :asc})
  end

  defp query_g003 do
    configure(location_domain(), :mock_connection, validate: false)
    |> Selecto.select(["id", "name"])
    |> Selecto.filter({
      :raw_sql_filter,
      "ST_Contains(ST_GeomFromText('POLYGON((-74.02 40.70, -73.95 40.70, -73.95 40.78, -74.02 40.78, -74.02 40.70))', 4326), selecto_root.geom)"
    })
    |> Selecto.order_by({"id", :asc})
  end

  defp query_g004 do
    configure(location_domain(), :mock_connection, validate: false)
    |> Selecto.select(["id", "name"])
    |> Selecto.filter({
      :raw_sql_filter,
      "selecto_root.geom && ST_MakeEnvelope(-74.05, 40.68, -73.90, 40.82, 4326)"
    })
    |> Selecto.order_by({"id", :asc})
  end

  defp query_g005 do
    configure(location_domain(), :mock_connection, validate: false)
    |> Selecto.select(["id", "name"])
    |> Selecto.filter({
      :raw_sql_filter,
      "ST_Intersects(selecto_root.geom, ST_Buffer(ST_SetSRID(ST_MakePoint(-73.98, 40.75), 4326), 0.01))"
    })
    |> Selecto.order_by({"id", :asc})
  end

  defp query_g006 do
    distance_expr =
      "ST_Distance(selecto_root.geom, ST_SetSRID(ST_MakePoint(-73.9857, 40.7484), 4326))"

    configure(location_domain(), :mock_connection, validate: false)
    |> Selecto.select([
      "id",
      "name",
      {:field, {:raw_sql, distance_expr}, "distance"}
    ])
    |> Selecto.order_by({{:raw_sql, distance_expr}, :asc})
    |> Selecto.limit(10)
  end

  defp query_g007 do
    geom_type_expr = "ST_GeometryType(selecto_root.geom)"

    configure(location_domain(), :mock_connection, validate: false)
    |> Selecto.select([
      {:field, {:raw_sql, geom_type_expr}, "geom_type"},
      {:count, "*"}
    ])
    |> Selecto.group_by([{:raw_sql, geom_type_expr}])
    |> Selecto.order_by({{:raw_sql, geom_type_expr}, :asc})
  end

  defp query_g008 do
    configure(location_domain(), :mock_connection, validate: false)
    |> Selecto.select(["id", "name"])
    |> Selecto.filter({
      :exists,
      "SELECT 1 FROM regions r WHERE ST_Intersects(selecto_root.geom, r.geom) AND r.kind = $1",
      ["delivery"]
    })
    |> Selecto.order_by({"id", :asc})
  end

  defp query_c001 do
    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.with_cte(
      "order_totals",
      fn ->
        configure(order_domain_with_customer_join(), :mock_connection, validate: false)
        |> Selecto.select(select([id, total]))
        |> Selecto.filter(where(status == "delivered"))
      end,
      columns: ["id", "total"],
      join: true
    )
    |> Selecto.select(select([order_number, order_totals.total]))
  end

  defp query_c002 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.with_recursive_cte("order_chain",
      base_query: fn ->
        configure(order_domain(), :mock_connection, validate: false)
        |> Selecto.select(select([id, status]))
        |> Selecto.filter(where(status == "processing"))
      end,
      recursive_query: fn _cte_ref ->
        configure(order_domain(), :mock_connection, validate: false)
        |> Selecto.select(select([id, status]))
      end,
      columns: ["id", "status"],
      join: true
    )
    |> Selecto.select(select([order_number, order_chain.status]))
  end

  defp query_c003 do
    order_totals_cte =
      Selecto.Advanced.CTE.create_cte(
        "order_totals",
        fn ->
          configure(order_domain_with_customer_join(), :mock_connection, validate: false)
          |> Selecto.select(select([id, total]))
        end,
        columns: ["id", "total"]
      )

    customer_spend_cte =
      Selecto.Advanced.CTE.create_cte(
        "customer_spend",
        fn ->
          configure(order_domain_with_customer_join(), :mock_connection, validate: false)
          |> Selecto.select(select([customer_id, total]))
        end,
        columns: ["customer_id", "total"]
      )

    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.with_ctes([order_totals_cte, customer_spend_cte], joins: true)
    |> Selecto.select(select([order_number, order_totals.total, customer_spend.total]))
  end

  defp query_c004 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.with_values(
      [
        ["processing", "In Progress"],
        ["shipped", "In Transit"],
        ["delivered", "Completed"]
      ],
      columns: ["status", "status_label"],
      as: "status_labels",
      join: [owner_key: :status, related_key: :status]
    )
    |> Selecto.select(select([order_number, status_labels.status_label]))
  end

  defp query_c005 do
    order_totals_cte =
      Selecto.Advanced.CTE.create_cte(
        "order_totals",
        fn ->
          configure(order_domain_with_customer_join(), :mock_connection, validate: false)
          |> Selecto.select(select([id, total]))
        end,
        columns: ["id", "total"]
      )

    configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.with_ctes([order_totals_cte], joins: true)
    |> Selecto.select(select([order_number, order_totals.total]))
  end

  defp query_c006 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.with_values(
      [
        ["processing", "In Progress"],
        ["shipped", "In Transit"]
      ],
      columns: ["status", "status_label"],
      as: "status_labels",
      join: true
    )
    |> Selecto.select(select([order_number, status_labels.status_label]))
  end

  defp query_c007 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.with_recursive_cte(
      "order_chain",
      fn ->
        configure(order_domain(), :mock_connection, validate: false)
        |> Selecto.select(select([id, status]))
        |> Selecto.filter(where(status == "processing"))
      end,
      fn _cte_ref ->
        configure(order_domain(), :mock_connection, validate: false)
        |> Selecto.select(select([id, status]))
      end,
      columns: ["id", "status"],
      join: true
    )
    |> Selecto.select(select([order_number, order_chain.status]))
  end

  defp query_c008 do
    configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.with_values(
      [
        ["processing", "In Progress"],
        ["shipped", "In Transit"],
        ["delivered", "Completed"]
      ],
      columns: ["status", "status_label"],
      as: "status_labels"
    )
    |> Selecto.join(:status_labels,
      source: "status_labels",
      type: :left,
      owner_key: :status,
      related_key: :status,
      fields: %{
        status: %{type: :string},
        status_label: %{type: :string}
      }
    )
    |> Selecto.select(select([order_number, status, status_labels.status_label]))
  end
end

unless System.get_env("SELECTO_SQL_PATTERNS_NO_AUTO") == "1" do
  case System.argv() do
    ["--verify-domain-root"] ->
      SelectoSqlPatterns.VerifyExamples.verify_domain_root!()

    ["--dump-sql", output_path] ->
      SelectoSqlPatterns.VerifyExamples.dump_sql_markdown(output_path)

    ["--dump-sql"] ->
      SelectoSqlPatterns.VerifyExamples.dump_sql_markdown()

    ["--dump-adapter-json", output_path] ->
      SelectoSqlPatterns.VerifyExamples.dump_adapter_json(output_path)

    ["--dump-adapter-json"] ->
      SelectoSqlPatterns.VerifyExamples.dump_adapter_json()

    ["--dump-expr-json", output_path] ->
      SelectoSqlPatterns.VerifyExamples.dump_expr_json(output_path)

    ["--dump-expr-json"] ->
      SelectoSqlPatterns.VerifyExamples.dump_expr_json()

    ["--dump-all", markdown_path, json_path, expr_path] ->
      SelectoSqlPatterns.VerifyExamples.dump_sql_markdown(markdown_path)
      SelectoSqlPatterns.VerifyExamples.dump_adapter_json(json_path)

      SelectoSqlPatterns.VerifyExamples.dump_expr_json(expr_path)

    ["--dump-all"] ->
      SelectoSqlPatterns.VerifyExamples.dump_sql_markdown()
      SelectoSqlPatterns.VerifyExamples.dump_adapter_json()
      SelectoSqlPatterns.VerifyExamples.dump_expr_json()

    _ ->
      SelectoSqlPatterns.VerifyExamples.run()
  end
end
