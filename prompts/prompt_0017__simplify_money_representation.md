# Prompt 0017 — Simplify Money representation

The current `Money` implementation exposes euro values using `BigDecimal`, but that is not the intended design.

The intended model is simpler:

- all monetary calculations should use integer cents,
- `Money` should keep cents as its only numeric representation,
- converting money for display should produce a string,
- callers should not receive decimal monetary values for arithmetic.

## Goal

Refactor `Money` so it no longer exposes `BigDecimal` as part of its public API.

Keep integer cents as the source of truth.

Replace the current euro conversion API with a presentation-oriented string representation.

## Public API

Keep:

`Money.from_euros("102.29").cents`

returning:

`10229`

Add or adapt:

`Money.from_euros("102.29").to_s`

returning:

`"102.29"`

The string representation should be derived from integer cents and should not use floating-point arithmetic.

Values with whole euros must still render with two decimal places, for example:

- `0` cents -> `"0.00"`
- `1500` cents -> `"15.00"`
- `10229` cents -> `"102.29"`

## Design decision

The application should not use decimal euro values for monetary calculations.

Future calculations, including commission calculations, should operate using integer cents and evolve the `Money` value object when additional behavior is required.

`to_s` exists only to represent the monetary value for output or reporting.

Remove `BigDecimal` from the public representation of `Money` if it is no longer needed.

Do not introduce another decimal numeric representation in its place.

## Tests

Adapt the existing Money specs to reflect the intended behavior.

Remove tests that expect `to_euros` to return a decimal numeric value.

Add focused coverage for `to_s`, including zero, whole-euro values, and values containing cents.

Preserve the existing tests for exact conversion from euro input into integer cents.

## Documentation

Update the Money documentation and README where necessary so they accurately state that:

- integer cents are the numeric representation used by the application,
- monetary calculations should remain in cents,
- `to_s` is used only for presentation,
- the project deliberately avoids exposing floating-point or decimal monetary values for calculations.
