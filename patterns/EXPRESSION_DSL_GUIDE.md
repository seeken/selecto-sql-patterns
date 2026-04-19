# Expression DSL Guide

This repository now supports authoring examples with Selecto's expression DSL as
well as the older raw tuple forms.

## Recommended Style

- use `Selecto.Expr` for data-first, runtime-built examples
- use `Selecto.ExprMacros` for readable example code in `scripts/verify_examples.exs`
- use `~SELECTO` for compact filter literals when the example is primarily about
  predicate readability
- keep raw tuple forms when they are still the clearest way to demonstrate an
  edge case or unsupported niche surface

## Preferred Imports

```elixir
import Selecto.ExprMacros
import Selecto.Sigil
alias Selecto.Expr, as: X
```

## Good Fits for Macros

- boolean filters with `where(...)`
- selector lists with `select([...])`
- ordering with `order_by([...])`
- grouping with `group_by([...])`
- dotted field references like `customer.name`
- window ordering fragments like `order_by([desc(total)])`

## Current Macro Surface

```elixir
import Selecto.ExprMacros

status = "active"
term = "wireless charger"

query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.select(select([name, as(count(), "product_count")]))
  |> Selecto.filter(where(text_search([name, description], ^term) and status == ^status))
  |> Selecto.group_by(group_by([status, rollup([status, category.name])]))
  |> Selecto.order_by(order_by([desc(name)]))
```

## Good Fits for `Selecto.Expr`

- conditional query assembly
- reusable fragments shared across patterns
- helper-heavy examples where the underlying AST should stay visible

## Use `~SELECTO` For Filter-Only Examples

```elixir
import Selecto.Sigil

term = "wireless charger"

query =
  Selecto.configure(product_domain(), :mock_connection, validate: false)
  |> Selecto.filter(~SELECTO"text_search([name, description], ^term) and field_exists(metadata.zone)")
```

`~SELECTO` currently compiles filter expressions only. Keep using
`Selecto.Expr` or `Selecto.ExprMacros` for select, order, and group examples.

## Keep Tuple Forms When

- a pattern is intentionally documenting a raw Selecto AST shape
- a feature has no macro surface yet
- a raw SQL escape hatch is the point of the example

## Practical Split

- prefer `Selecto.Expr` when examples need runtime composition or helper reuse
- prefer `Selecto.ExprMacros` when a static example reads better as Elixir
- prefer `~SELECTO` when the whole point of the snippet is a readable filter
  literal

## Current Migration Direction

The goal is not to rewrite every example into macros immediately.

Instead:

1. convert representative examples in each category
2. prefer the DSL in new examples where it improves readability
3. keep tuple-heavy forms where they still best explain the underlying feature

## Related

- `../README.md`
- `../scripts/verify_examples.exs`
- `./OVERLAY_DSL_GUIDE.md`
- `./PUBLISHED_VIEWS_GUIDE.md`
- `./VIEW_BACKED_DOMAINS_GUIDE.md`
