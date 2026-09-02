# Prompt 0021 — Load the complete application environment in console

The current application console does not load all project classes automatically.

For example, using `LoadMerchants` currently requires manually requiring its file first. This makes the console unnecessarily inconvenient.

## Goal

Create or improve a single application environment/bootstrap entry point that loads the complete application code.

`make console` must load this environment automatically.

After opening the console, project classes should be immediately available without manual `require` calls, including at least:

- `Merchant`
- `Money`
- `LoadMerchants`

## Application environment

Prefer a single explicit application environment file that is responsible for:

- loading required standard-library and gem dependencies,
- establishing/configuring ActiveRecord as currently required,
- loading the project's application classes.

Avoid duplicating require lists independently across the console, executable scripts, tests, and other entry points where they can share the same application bootstrap.

Keep the loading mechanism appropriate for the current small plain-Ruby application. Do not introduce Rails-style autoloading infrastructure or another dependency just to solve this.

## Console

Ensure `make console` starts an interactive Ruby console with the complete application environment already loaded.

A developer should be able to open it and immediately execute calls such as:

    Merchant.count

    Money.from_euros("15.00")

    LoadMerchants.call("path/to/merchants.csv")

without any manual `require`.

## Existing entry points

Review existing executable entry points, including the merchant loader, and reuse the common application environment where appropriate instead of maintaining duplicate bootstrapping logic.

Keep command-specific behavior in the corresponding executable; only common application loading belongs in the shared environment.

## Tests

Adapt the RSpec setup to use the shared application environment where appropriate, avoiding duplicated application-loading configuration.

Preserve the existing test isolation behavior.

## Verification

Verify that `make console` exposes the project's application classes immediately and that existing commands and tests continue to work.
