Mix.install([
  {:selecto, path: "../selecto"}
])

defmodule SelectoSqlPatterns.VerifyExamples do
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
      {"A001", query_a001(), ["select", "count", "group by", "order by"]},
      {"A002", query_a002(), ["select", "sum", "where", "group by"]},
      {"A003", query_a003(), ["select", "avg", "group by", "order by"]},
      {"A004", query_a004(), ["select", "count", "left join", "group by"]},
      {"A005", query_a005(), ["select", "sum", "left join", "group by"]},
      {"A006", query_a006(), ["select", "count", "where", "group by"]},
      {"A007", query_a007(), ["select", "sum", "count", "group by"]},
      {"A008", query_a008(), ["select", "avg", "where", "group by"]},
      {"W001", query_w001(), ["select", "row_number", "over", "partition by"]},
      {"W002", query_w002(), ["select", "sum", "over", "order by"]},
      {"W003", query_w003(), ["select", "lag", "over", "partition by"]},
      {"W004", query_w004(), ["select", "dense_rank", "over", "order by"]},
      {"W005", query_w005(), ["select", "avg", "rows", "current row"]},
      {"W006", query_w006(), ["select", "rank", "partition by", "order by"]},
      {"W007", query_w007(), ["select", "lead", "over", "partition by"]},
      {"W008", query_w008(), ["select", "max", "over", "partition by"]},
      {"S001", query_s001(), ["select", " in (", "from customers", "order by"]},
      {"S002", query_s002(), ["select", "left join", "where", "order by"]},
      {"S003", query_s003(), ["select", "exists (", "from customers", "order by"]},
      {"S004", query_s004(), ["select", "left join", "is null", "order by"]},
      {"S005", query_s005(), ["select", " in (", "$1", "order by"]},
      {"S006", query_s006(), ["select", "exists (", "$1", "order by"]},
      {"S007", query_s007(), ["select", " in (", "where", " and "]},
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
    examples = examples()

    Enum.each(examples, fn {id, query, fragments} ->
      {sql, _params} = Selecto.to_sql(query)
      normalized = normalize_sql(sql)
      assert_fragments!(id, normalized, fragments)
      IO.puts("PASS #{id}")
    end)

    IO.puts("Verified #{length(examples)} pattern examples with Selecto.to_sql/1")
  end

  def dump_sql_markdown(output_path \\ "patterns/SELECTO_YIELDED_SQL.md") do
    body =
      examples()
      |> Enum.map(fn {id, query, _fragments} ->
        {sql, params} = Selecto.to_sql(query)

        [
          "## ",
          id,
          "\n\n",
          "```sql\n",
          String.trim(sql),
          "\n```\n\n",
          "**Params:** `",
          inspect(params),
          "`\n\n"
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

  defp normalize_sql(sql) do
    sql
    |> String.replace(~r/\s+/, " ")
    |> String.trim()
    |> String.downcase()
  end

  defp assert_fragments!(id, sql, fragments) do
    Enum.each(fragments, fn fragment ->
      if not String.contains?(sql, fragment) do
        raise "#{id} failed: expected SQL to include '#{fragment}'. SQL was: #{sql}"
      end
    end)
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
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["order_number", "customer.name"])
    |> Selecto.filter({"customer.id", :not_null})
    |> Selecto.filter({"status", "delivered"})
    |> Selecto.order_by({"order_number", :asc})
  end

  defp query_j002 do
    Selecto.configure(product_domain_with_reviews_join(), :mock_connection, validate: false)
    |> Selecto.select(["name", {:count, "reviews.id"}])
    |> Selecto.group_by(["name"])
    |> Selecto.order_by({"name", :asc})
  end

  defp query_j003 do
    high_value_delivered_orders =
      Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
      |> Selecto.select(["customer_id", "order_number", "total"])
      |> Selecto.filter({:and, [{"status", "delivered"}, {"total", {:>, 1000}}]})

    Selecto.configure(customer_domain(), :mock_connection, validate: false)
    |> Selecto.join_subquery(:high_value_delivered, high_value_delivered_orders,
      type: :inner,
      on: [%{left: "id", right: "customer_id"}]
    )
    |> Selecto.select([
      "name",
      "tier",
      "high_value_delivered.order_number",
      "high_value_delivered.total"
    ])
  end

  defp query_j004 do
    Selecto.configure(employee_domain_with_manager_join(), :mock_connection, validate: false)
    |> Selecto.select(["first_name", "manager.first_name"])
    |> Selecto.order_by({"first_name", :asc})
  end

  defp query_j005 do
    Selecto.configure(product_domain_with_reviews_join(), :mock_connection, validate: false)
    |> Selecto.select(["name"])
    |> Selecto.filter({"reviews.id", nil})
    |> Selecto.order_by({"name", :asc})
  end

  defp query_j006 do
    Selecto.configure(order_domain_with_customer_join_filter(), :mock_connection, validate: false)
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
      Selecto.configure(order_domain(), :mock_connection, validate: false)
      |> Selecto.select([{:count, "*"}])
      |> Selecto.filter({"status", "delivered"})

    Selecto.configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select([
      "name",
      {:field, {:raw_sql, "delivered_stats.count"}, "delivered_order_count"}
    ])
    |> Selecto.lateral_join(:left, fn _ -> subquery_query end, "delivered_stats")
  end

  defp query_j008 do
    Selecto.configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.unnest("tags", as: "product_tag")
    |> Selecto.select([
      "name",
      "product_tag"
    ])
    |> Selecto.filter({"active", true})
  end

  defp query_j009 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.join_parameterize(:customer, "alias_a")
    |> Selecto.join_parameterize(:customer, "alias_b")
    |> Selecto.select(["order_number", "customer:alias_a.name", "customer:alias_b.tier"])
  end

  defp query_j010 do
    star_domain =
      order_domain_with_customer_join()
      |> put_in([:joins, :customer, :type], :star_dimension)

    Selecto.configure(star_domain, :mock_connection, validate: false)
    |> Selecto.select(["customer.name", {:count, "*"}])
    |> Selecto.group_by(["customer.name"])
    |> Selecto.order_by({"customer.name", :asc})
  end

  defp query_a001 do
    Selecto.configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(["status", {:count, "*"}])
    |> Selecto.group_by(["status"])
    |> Selecto.order_by({"status", :asc})
  end

  defp query_a002 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["customer_id", {:func, "SUM", ["total"], as: "total_spend"}])
    |> Selecto.filter({"status", "delivered"})
    |> Selecto.group_by(["customer_id"])
    |> Selecto.order_by({"customer_id", :asc})
  end

  defp query_a003 do
    Selecto.configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(["status", {:func, "AVG", ["total"], as: "avg_total"}])
    |> Selecto.group_by(["status"])
    |> Selecto.order_by({"status", :asc})
  end

  defp query_a004 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["customer.name", {:count, "*"}])
    |> Selecto.group_by(["customer.name"])
    |> Selecto.order_by({"customer.name", :asc})
  end

  defp query_a005 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["customer.tier", {:func, "SUM", ["total"], as: "tier_total"}])
    |> Selecto.group_by(["customer.tier"])
    |> Selecto.order_by({"customer.tier", :asc})
  end

  defp query_a006 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["customer.tier", {:count, "*"}])
    |> Selecto.filter({"status", "delivered"})
    |> Selecto.group_by(["customer.tier"])
    |> Selecto.order_by({"customer.tier", :asc})
  end

  defp query_a007 do
    Selecto.configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select([
      "status",
      {:func, "SUM", ["total"], as: "total_amount"},
      {:count, "*"}
    ])
    |> Selecto.group_by(["status"])
    |> Selecto.order_by({"status", :asc})
  end

  defp query_a008 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["customer.tier", {:func, "AVG", ["total"], as: "avg_delivered_total"}])
    |> Selecto.filter({"status", "delivered"})
    |> Selecto.group_by(["customer.tier"])
    |> Selecto.order_by({"customer.tier", :asc})
  end

  defp query_w001 do
    Selecto.configure(employee_domain(), :mock_connection, validate: false)
    |> Selecto.select(["first_name", "department", "salary"])
    |> Selecto.window_function(:row_number, [],
      over: [partition_by: ["department"], order_by: [{"salary", :desc}]],
      as: "department_salary_rank"
    )
  end

  defp query_w002 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["id", "customer_id", "total"])
    |> Selecto.window_function(:sum, ["total"],
      over: [partition_by: ["customer_id"], order_by: ["id"]],
      as: "running_total"
    )
  end

  defp query_w003 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["id", "customer_id", "total"])
    |> Selecto.window_function(:lag, ["total", 1],
      over: [partition_by: ["customer_id"], order_by: ["id"]],
      as: "prev_total"
    )
  end

  defp query_w004 do
    Selecto.configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(["order_number", "total"])
    |> Selecto.window_function(:dense_rank, [],
      over: [order_by: [{"total", :desc}]],
      as: "total_rank"
    )
  end

  defp query_w005 do
    Selecto.configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(["id", "total"])
    |> Selecto.window_function(:avg, ["total"],
      over: [
        order_by: ["id"],
        frame: {:rows, :unbounded_preceding, :current_row}
      ],
      as: "moving_avg_total"
    )
  end

  defp query_w006 do
    Selecto.configure(employee_domain(), :mock_connection, validate: false)
    |> Selecto.select(["first_name", "department", "salary"])
    |> Selecto.window_function(:rank, [],
      over: [partition_by: ["department"], order_by: [{"salary", :desc}]],
      as: "department_rank"
    )
  end

  defp query_w007 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["id", "customer_id", "total"])
    |> Selecto.window_function(:lead, ["total", 1],
      over: [partition_by: ["customer_id"], order_by: ["id"]],
      as: "next_total"
    )
  end

  defp query_w008 do
    Selecto.configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.select(["order_number", "status", "total"])
    |> Selecto.window_function(:max, ["total"],
      over: [partition_by: ["status"]],
      as: "status_max_total"
    )
  end

  defp query_s001 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["order_number", "customer_id", "status", "total"])
    |> Selecto.filter(
      {"customer_id", {:subquery, :in, "SELECT id FROM customers WHERE tier = 'gold'", []}}
    )
    |> Selecto.order_by({"total", :desc})
  end

  defp query_s002 do
    delivered_orders =
      Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
      |> Selecto.select(["customer_id", "order_number", "total"])
      |> Selecto.filter({"status", "delivered"})

    Selecto.configure(customer_domain(), :mock_connection, validate: false)
    |> Selecto.join_subquery(:delivered_orders, delivered_orders,
      type: :left,
      on: [%{left: "id", right: "customer_id"}]
    )
    |> Selecto.select(["name", "delivered_orders.order_number", "delivered_orders.total"])
    |> Selecto.order_by({"name", :asc})
  end

  defp query_s003 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["order_number", "status", "total"])
    |> Selecto.filter({
      :exists,
      "SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = 'gold'"
    })
    |> Selecto.order_by({"total", :desc})
  end

  defp query_s004 do
    reviewed_products =
      Selecto.configure(review_domain(), :mock_connection, validate: false)
      |> Selecto.select(["product_id"])
      |> Selecto.group_by(["product_id"])

    Selecto.configure(product_domain(), :mock_connection, validate: false)
    |> Selecto.select(["name"])
    |> Selecto.join_subquery(:reviewed_products, reviewed_products,
      type: :left,
      on: [%{left: "id", right: "product_id"}]
    )
    |> Selecto.filter({"reviewed_products.product_id", nil})
    |> Selecto.order_by({"name", :asc})
  end

  defp query_s005 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["order_number", "customer_id", "total"])
    |> Selecto.filter(
      {"customer_id", {:subquery, :in, "SELECT id FROM customers WHERE tier = $1", ["silver"]}}
    )
    |> Selecto.order_by({"total", :desc})
  end

  defp query_s006 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["order_number", "status", "total"])
    |> Selecto.filter({
      :exists,
      "SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = $1",
      ["gold"]
    })
    |> Selecto.order_by({"total", :desc})
  end

  defp query_s007 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.select(["order_number", "customer_id", "total"])
    |> Selecto.filter(
      {"customer_id", {:subquery, :in, "SELECT id FROM customers WHERE tier = 'gold'", []}}
    )
    |> Selecto.filter({"status", "delivered"})
    |> Selecto.order_by({"total", :desc})
  end

  defp query_so001 do
    customers =
      Selecto.configure(customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["name", "tier"])

    vendors =
      Selecto.configure(vendor_domain(), :mock_connection, validate: false)
      |> Selecto.select(["name", "tier"])

    Selecto.union(customers, vendors)
  end

  defp query_so002 do
    current_orders =
      Selecto.configure(order_domain(), :mock_connection, validate: false)
      |> Selecto.select(["order_number", "total"])

    archived_orders =
      Selecto.configure(archived_order_domain(), :mock_connection, validate: false)
      |> Selecto.select(["order_number", "total"])

    Selecto.union(current_orders, archived_orders, all: true)
  end

  defp query_so003 do
    premium_customers =
      Selecto.configure(premium_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    active_customers =
      Selecto.configure(active_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    Selecto.intersect(premium_customers, active_customers)
  end

  defp query_so004 do
    all_customers =
      Selecto.configure(customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    blocked_customers =
      Selecto.configure(blocked_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    Selecto.except(all_customers, blocked_customers)
  end

  defp query_so005 do
    premium_customers =
      Selecto.configure(premium_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    active_customers =
      Selecto.configure(active_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    all_customers =
      Selecto.configure(customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    premium_or_active = Selecto.union(premium_customers, active_customers)

    Selecto.intersect(premium_or_active, all_customers)
  end

  defp query_so006 do
    premium_customers =
      Selecto.configure(premium_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    active_customers =
      Selecto.configure(active_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    Selecto.intersect(premium_customers, active_customers, all: true)
  end

  defp query_so007 do
    all_customers =
      Selecto.configure(customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    blocked_customers =
      Selecto.configure(blocked_customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["id", "name"])

    Selecto.except(all_customers, blocked_customers, all: true)
  end

  defp query_so008 do
    customers =
      Selecto.configure(customer_domain(), :mock_connection, validate: false)
      |> Selecto.select(["name", "tier"])

    vendor_contacts =
      Selecto.configure(vendor_contact_domain(), :mock_connection, validate: false)
      |> Selecto.select(["company_name", "segment"])

    Selecto.union(customers, vendor_contacts,
      column_mapping: [
        {"name", "company_name"},
        {"tier", "segment"}
      ]
    )
  end

  defp query_c001 do
    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.with_cte(
      "order_totals",
      fn ->
        Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
        |> Selecto.select(["id", "total"])
        |> Selecto.filter({"status", "delivered"})
      end,
      columns: ["id", "total"],
      join: true
    )
    |> Selecto.select(["order_number", "order_totals.total"])
  end

  defp query_c002 do
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
  end

  defp query_c003 do
    order_totals_cte =
      Selecto.Advanced.CTE.create_cte(
        "order_totals",
        fn ->
          Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
          |> Selecto.select(["id", "total"])
        end,
        columns: ["id", "total"]
      )

    customer_spend_cte =
      Selecto.Advanced.CTE.create_cte(
        "customer_spend",
        fn ->
          Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
          |> Selecto.select(["customer_id", "total"])
        end,
        columns: ["customer_id", "total"]
      )

    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.with_ctes([order_totals_cte, customer_spend_cte], joins: true)
    |> Selecto.select(["order_number", "order_totals.total", "customer_spend.total"])
  end

  defp query_c004 do
    Selecto.configure(order_domain(), :mock_connection, validate: false)
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
    |> Selecto.select(["order_number", "status_labels.status_label"])
  end

  defp query_c005 do
    order_totals_cte =
      Selecto.Advanced.CTE.create_cte(
        "order_totals",
        fn ->
          Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
          |> Selecto.select(["id", "total"])
        end,
        columns: ["id", "total"]
      )

    Selecto.configure(order_domain_with_customer_join(), :mock_connection, validate: false)
    |> Selecto.with_ctes([order_totals_cte], joins: true)
    |> Selecto.select(["order_number", "order_totals.total"])
  end

  defp query_c006 do
    Selecto.configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.with_values(
      [
        ["processing", "In Progress"],
        ["shipped", "In Transit"]
      ],
      columns: ["status", "status_label"],
      as: "status_labels",
      join: true
    )
    |> Selecto.select(["order_number", "status_labels.status_label"])
  end

  defp query_c007 do
    Selecto.configure(order_domain(), :mock_connection, validate: false)
    |> Selecto.with_recursive_cte(
      "order_chain",
      fn ->
        Selecto.configure(order_domain(), :mock_connection, validate: false)
        |> Selecto.select(["id", "status"])
        |> Selecto.filter({"status", "processing"})
      end,
      fn _cte_ref ->
        Selecto.configure(order_domain(), :mock_connection, validate: false)
        |> Selecto.select(["id", "status"])
      end,
      columns: ["id", "status"],
      join: true
    )
    |> Selecto.select(["order_number", "order_chain.status"])
  end

  defp query_c008 do
    Selecto.configure(order_domain(), :mock_connection, validate: false)
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
    |> Selecto.select(["order_number", "status", "status_labels.status_label"])
  end
end

case System.argv() do
  ["--dump-sql", output_path] ->
    SelectoSqlPatterns.VerifyExamples.dump_sql_markdown(output_path)

  ["--dump-sql"] ->
    SelectoSqlPatterns.VerifyExamples.dump_sql_markdown()

  _ ->
    SelectoSqlPatterns.VerifyExamples.run()
end
