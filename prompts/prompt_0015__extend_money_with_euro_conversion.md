# Prompt 0015 — Extend Money with euro conversion

The `Money` value object already represents monetary values internally as integer cents and can be created from euro-denominated strings.

We now want to complete this minimal representation with the inverse conversion: exposing the monetary amount in euros.

This is still part of the same small value object and does not introduce broader monetary behavior.

## Goal

Extend `Money` so it can return its value in euros.

The public API should support a simple usage such as:

    Money.from_euros("15.0").to_euros

and return an exact decimal representation of:

    15.0

Do not use Float.

## Representation

Keep integer cents as the internal source of truth.

`to_euros` must derive its value from the stored cents.

Use an exact Ruby decimal representation appropriate for monetary values.

Prefer returning a numeric decimal value rather than a formatted/localized string.

Do not introduce currency symbols or presentation formatting.

## Expected behavior

Examples should behave conceptually as follows:

    Money.from_euros("0.0").to_euros
    # => exact decimal representation of 0.0

    Money.from_euros("15.0").to_euros
    # => exact decimal representation of 15.0

    Money.from_euros("102.29").to_euros
    # => exact decimal representation of 102.29

The round trip between euros and cents must preserve the monetary value exactly for the challenge precision.

For example:

    Money.from_euros("102.29").cents
    # => 10229

and converting that Money object back to euros must represent exactly `102.29`.

## Scope

Keep the class intentionally small.

Do not add:

- arithmetic between Money objects,
- percentage calculations,
- commission rules,
- comparisons,
- currency conversion,
- multiple currencies,
- localization,
- formatted currency strings,
- ActiveRecord integration.

Those behaviors should still be introduced only when required by the challenge.

## Tests

Extend the Money specs to cover `to_euros`.

At minimum verify:

- zero cents converts correctly to euros,
- 1500 cents represents exactly 15 euros,
- 10229 cents represents exactly 102.29 euros,
- euro-to-cents-to-euros round trips preserve the value,
- `to_euros` does not rely on floating-point arithmetic.

Keep the existing Money tests.

## Documentation

Update the Money class documentation so its current responsibility is clear:

- Money stores integer cents internally,
- it can convert from euro input into cents,
- it can expose the same value as an exact euro decimal,
- it deliberately does not yet implement broader monetary operations.

Update the README only if the existing Money documentation would otherwise become inaccurate.

Do not add unnecessary documentation for this small extension.

## Verification

Verify that:

- all Money specs pass,
- `to_euros` uses exact decimal arithmetic,
- no Float-based monetary conversion has been introduced,
- `make test` passes,
- `make lint` passes.

Do not modify unrelated domain behavior.

Do not commit or push.
