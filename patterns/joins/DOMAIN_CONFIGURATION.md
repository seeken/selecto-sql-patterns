# Join Domain Configuration

Shared domain setup used by join patterns.

## Usage Map

- `J001`, `J006`, `J009`, `J010`: orders + customers join variants
- `J002`, `J005`: products + reviews join
- `J004`: employees self-join (manager)

`J001` uses this shared orders/customers domain, then applies a runtime inner-join override.

## Shared Setup

```elixir
defmodule SelectoSqlPatterns.JoinDomains do
  def order_domain_with_customer_join do
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
          customer: %{field: :customer, queryable: :customers, owner_key: :customer_id, related_key: :id}
        }
      },
      schemas: %{
        customers: %{
          source_table: "customers",
          primary_key: :id,
          fields: [:id, :name, :tier],
          redact_fields: [],
          columns: %{id: %{type: :integer}, name: %{type: :string}, tier: %{type: :string}}
        }
      },
      joins: %{
        customer: %{
          name: "Customer",
          type: :left,
          source: "customers",
          on: [%{left: "customer_id", right: "id"}],
          fields: %{name: %{type: :string}, tier: %{type: :string}}
        }
      }
    }
  end

  def order_domain_with_customer_join_filter do
    order_domain_with_customer_join()
    |> put_in([:joins, :customer, :filters], %{"tier" => %{type: "string"}})
  end

  def product_domain_with_reviews_join do
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
          reviews: %{field: :reviews, queryable: :reviews, owner_key: :id, related_key: :product_id}
        }
      },
      schemas: %{
        reviews: %{
          source_table: "reviews",
          primary_key: :id,
          fields: [:id, :product_id, :rating],
          redact_fields: [],
          columns: %{id: %{type: :integer}, product_id: %{type: :integer}, rating: %{type: :integer}}
        }
      },
      joins: %{
        reviews: %{
          name: "Reviews",
          type: :left,
          source: "reviews",
          on: [%{left: "id", right: "product_id"}],
          fields: %{id: %{type: :integer}, product_id: %{type: :integer}, rating: %{type: :integer}}
        }
      }
    }
  end

  def employee_domain_with_manager_join do
    %{
      name: "Employees",
      source: %{
        source_table: "employees",
        primary_key: :id,
        fields: [:id, :first_name, :manager_id],
        redact_fields: [],
        columns: %{id: %{type: :integer}, first_name: %{type: :string}, manager_id: %{type: :integer}},
        associations: %{
          manager: %{field: :manager, queryable: :managers, owner_key: :manager_id, related_key: :id}
        }
      },
      schemas: %{
        managers: %{
          source_table: "employees",
          primary_key: :id,
          fields: [:id, :first_name],
          redact_fields: [],
          columns: %{id: %{type: :integer}, first_name: %{type: :string}}
        }
      },
      joins: %{
        manager: %{
          name: "Manager",
          type: :left,
          source: "employees",
          on: [%{left: "manager_id", right: "id"}],
          fields: %{id: %{type: :integer}, first_name: %{type: :string}}
        }
      }
    }
  end
end
```
