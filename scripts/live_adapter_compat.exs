defmodule SelectoDBMySQL.Adapter do
  @behaviour Selecto.DB.Adapter

  @missing_dependency {:adapter_dependency_missing, :myxql}

  def name, do: :mysql

  def connect(connection) when is_pid(connection) or is_atom(connection), do: {:ok, connection}
  def connect(opts) when is_map(opts), do: connect(Map.to_list(opts))

  def connect(opts) when is_list(opts) do
    if Code.ensure_loaded?(MyXQL) do
      MyXQL.start_link(opts)
    else
      {:error, @missing_dependency}
    end
  end

  def connect(other), do: {:error, {:invalid_connection_options, other}}

  def execute(connection, query, params, opts) do
    connection =
      if is_map(connection) and Map.has_key?(connection, :connection),
        do: Map.fetch!(connection, :connection),
        else: connection

    if Code.ensure_loaded?(MyXQL) do
      case MyXQL.query(connection, normalize_query(query), params || [], opts) do
        {:ok, result} -> {:ok, normalize_result(result)}
        {:error, reason} -> {:error, reason}
      end
    else
      {:error, @missing_dependency}
    end
  end

  def placeholder(_index), do: "?"

  def quote_identifier(identifier) do
    escaped = String.replace(to_string(identifier), "`", "``")
    "`#{escaped}`"
  end

  def supports?(:rollup_with_rollup), do: true
  def supports?(:json_table), do: true
  def supports?(:text_search), do: true
  def supports?(:text_search_multi_field), do: true
  def supports?(:text_search_boolean), do: true
  def supports?(:text_search_boolean_mode), do: true
  def supports?(:text_search_query_expansion), do: true
  def supports?(:text_search_query_expansion_mode), do: true
  def supports?(:match_against), do: true
  def supports?(:on_duplicate_key_update), do: true
  def supports?(_feature), do: false

  def rollup_sql(grouped_clauses), do: [grouped_clauses, " with rollup"]

  defp normalize_query(query) when is_binary(query), do: query
  defp normalize_query(query), do: IO.iodata_to_binary(query)

  defp normalize_result(%{columns: columns, rows: rows} = result) do
    %{
      columns: columns || [],
      rows: rows || [],
      num_rows: Map.get(result, :num_rows, length(rows || []))
    }
  end
end

defmodule SelectoDBSQLite.Adapter do
  @behaviour Selecto.DB.Adapter

  @missing_dependency {:adapter_dependency_missing, :exqlite}

  def name, do: :sqlite

  def connect(connection) when is_reference(connection), do: {:ok, connection}
  def connect(opts) when is_map(opts), do: connect(Map.to_list(opts))

  def connect(opts) when is_list(opts) do
    if Code.ensure_loaded?(Exqlite.Sqlite3) do
      database = Keyword.get(opts, :database, ":memory:")
      Exqlite.Sqlite3.open(database)
    else
      {:error, @missing_dependency}
    end
  end

  def connect(other), do: {:error, {:invalid_connection_options, other}}

  def execute(connection, query, params, opts) do
    connection =
      if is_map(connection) and Map.has_key?(connection, :connection),
        do: Map.fetch!(connection, :connection),
        else: connection

    if Code.ensure_loaded?(Exqlite.Sqlite3) do
      timeout = Keyword.get(opts, :timeout, 5_000)
      sqlite_query = query |> normalize_query() |> convert_parameters(params || [])

      with {:ok, statement} <- Exqlite.Sqlite3.prepare(connection, sqlite_query),
           :ok <- Exqlite.Sqlite3.bind(statement, params || []),
           {:ok, columns} <- Exqlite.Sqlite3.columns(connection, statement),
           {:ok, rows} <- fetch_all(connection, statement, timeout) do
        {:ok, %{columns: columns || [], rows: rows, num_rows: length(rows)}}
      end
    else
      {:error, @missing_dependency}
    end
  end

  def placeholder(_index), do: "?"

  def quote_identifier(identifier) do
    escaped = String.replace(to_string(identifier), "\"", "\"\"")
    "\"#{escaped}\""
  end

  def supports?(:json_rowset), do: true
  def supports?(_feature), do: false

  defp normalize_query(query) when is_binary(query), do: query
  defp normalize_query(query), do: IO.iodata_to_binary(query)

  defp fetch_all(db, statement, timeout) do
    task = Task.async(fn -> fetch_rows(db, statement, []) end)

    case Task.yield(task, timeout) || Task.shutdown(task) do
      {:ok, result} -> result
      nil -> {:error, :timeout}
    end
  end

  defp fetch_rows(db, statement, acc) do
    case Exqlite.Sqlite3.step(db, statement) do
      {:row, row} -> fetch_rows(db, statement, [row | acc])
      :done -> {:ok, Enum.reverse(acc)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp convert_parameters(query, []), do: query

  defp convert_parameters(query, params) do
    params
    |> Enum.with_index(1)
    |> Enum.reduce(query, fn {_param, index}, acc -> String.replace(acc, "$#{index}", "?") end)
  end
end
