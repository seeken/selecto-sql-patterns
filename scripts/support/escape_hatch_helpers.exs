defmodule SelectoSqlPatterns.EscapeHatchHelpers do
  @moduledoc false

  def raw_field(sql_ref, as_alias) when is_binary(sql_ref) and is_binary(as_alias) do
    {:field, {:raw_sql, sql_ref}, as_alias}
  end

  def lateral_alias_field(alias_name, field_name, as_alias)
      when is_binary(alias_name) and is_binary(field_name) and is_binary(as_alias) do
    raw_field("#{alias_name}.#{field_name}", as_alias)
  end

  def exists_gold_customer_sql do
    "SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = 'gold'"
  end

  def exists_customer_tier_sql do
    "SELECT 1 FROM customers c WHERE c.id = selecto_root.customer_id AND c.tier = $1"
  end

  def not_exists_reviews_sql do
    "SELECT 1 FROM reviews r WHERE r.product_id = selecto_root.id"
  end

  def in_gold_customer_ids_sql do
    "SELECT id FROM customers WHERE tier = 'gold'"
  end

  def in_customer_tier_ids_sql do
    "SELECT id FROM customers WHERE tier = $1"
  end
end
