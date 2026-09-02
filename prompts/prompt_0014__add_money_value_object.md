# Prompt 0014 — Add the Money value object

We have reached the first concrete domain requirement involving monetary values.

Merchant data provides `minimum_monthly_fee` in euros, while our persistence decision is to store monetary values as integer cents.

Instead of placing euro-to-cents conversion logic inside the future CSV loader, introduce a small project-owned `Money` value object responsible for representing monetary amounts.

Keep this implementation deliberately minimal.

## Goal

Add a `Money` value object that:

- represents money internally using integer cents,
- can be created from a euro value supplied as a string,
- exposes its value in cents.

The immediate use case is converting CSV values such as `"15.0"` into `1500` cents before persistence.

Do not implement functionality that is not yet required.

## Location

Place `Money` in an appropriate domain-oriented location consistent with the current project structure.

Do not introduce a larger domain framework, namespace hierarchy, or architectural layer solely for this class.

## Internal representation

Represent monetary values internally as integer cents.

Expose the cents value through a simple reader.

A usage such as the following should be possible:

    Money.from_euros("15.0").cents

and should return:

    1500

The object should not expose or depend on floating-point monetary representation.

## Euro conversion

Add a simple constructor or factory method for creating Money from a euro-denominated string.

The conversion must be exact and must not use `Float`.

Use an appropriate Ruby standard-library mechanism for decimal parsing if necessary.

Support the monetary input formats currently required by the challenge dataset, including values such as:

- `"0.0"`
- `"15.0"`
- `"102.29"`

Do not build a general-purpose money parser beyond the formats required by the challenge.

## Scope

At this stage, Money only needs to:

- represent integer cents,
- be created from a euro string,
- expose cents.

Do not implement yet:

- commission calculations,
- percentage operations,
- arithmetic between Money objects,
- comparisons,
- formatting,
- currency conversion,
- exchange rates,
- multiple currencies,
- localization,
- serialization,
- ActiveRecord integration.

These behaviors should only be added when a concrete challenge requirement needs them.

## Validation

Handle invalid monetary input in a simple and explicit way.

Do not silently convert malformed values into zero or another fallback value.

Avoid introducing a complex custom error hierarchy unless it is genuinely useful for this small value object.

## Tests

Add focused unit tests for Money.

At minimum verify:

- `"0.0"` becomes `0` cents,
- `"15.0"` becomes `1500` cents,
- `"102.29"` becomes `10229` cents,
- conversion does not rely on floating-point arithmetic,
- invalid monetary input is rejected rather than silently accepted.

Keep the tests deterministic and focused on Money behavior.

Do not test Ruby standard-library behavior itself.

## Documentation

Document the class concisely.

Explain the important design decision: monetary values are represented as integer cents to avoid floating-point precision problems and to match the persistence representation chosen for the project.

Do not over-document obvious implementation details.

## README

Update the existing monetary-value decision in the README now that `Money` is actually implemented.

Document concisely that:

- the project uses a small project-owned `Money` value object,
- Money internally represents values as integer cents,
- persisted monetary values therefore also use integer cents,
- the value object currently implements only the behavior required by the challenge so far,
- additional monetary behavior, such as commission calculations, will be introduced only when required.

Do not describe functionality that Money does not yet implement.

## Verification

Verify that:

- the Money unit tests pass,
- monetary conversion does not use Float,
- no unnecessary money-related functionality has been introduced,
- `make test` passes,
- `make lint` passes.

Do not modify Merchant behavior.
Do not implement CSV loading yet.
Do not implement merchant orders.
Do not implement disbursements.
Do not implement commission calculations yet.

Do not add an external money gem.

Do not commit or push.
