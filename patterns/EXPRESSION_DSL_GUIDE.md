# Expression DSL Guide

This repository now supports authoring examples with Selecto's expression DSL as
well as the older raw tuple forms.

## Recommended Style

- use `Selecto.Expr` for data-first, runtime-built examples
- use `Selecto.ExprMacros` for readable example code in `scripts/verify_examples.exs`
- keep raw tuple forms when they are still the clearest way to demonstrate an
  edge case or unsupported niche surface

## Preferred Imports

```elixir
import Selecto.ExprMacros
alias Selecto.Expr, as: X
```

## Good Fits for Macros

- boolean filters with `where(...)`
- selector lists with `select([...])`
- ordering with `order_by([...])`
- dotted field references like `customer.name`
- window ordering fragments like `order_by([desc(total)])`

## Good Fits for `Selecto.Expr`

- conditional query assembly
- reusable fragments shared across patterns
- helper-heavy examples where the underlying AST should stay visible

## Keep Tuple Forms When

- a pattern is intentionally documenting a raw Selecto AST shape
- a feature has no macro surface yet
- a raw SQL escape hatch is the point of the example

## Current Migration Direction

The goal is not to rewrite every example into macros immediately.

Instead:

1. convert representative examples in each category
2. prefer the DSL in new examples where it improves readability
3. keep tuple-heavy forms where they still best explain the underlying feature

## Related

- `../README.md`
- `../scripts/verify_examples.exs`
