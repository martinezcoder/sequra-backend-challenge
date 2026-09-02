# Prompt 0012 — Add FactoryBot for test data

We have reached the point where creating persisted test records manually is starting to add unnecessary noise to the specs.

Introduce FactoryBot as the test-data helper for the project.

## Goal

Add FactoryBot and use it in the existing `Merchant` specs.

Keep the setup minimal and limited to the current RSpec environment.

## Dependency

Add the appropriate FactoryBot gem for a plain Ruby / ActiveRecord project.

Do not add Rails-specific FactoryBot integration.

Do not introduce Faker or any other test-data dependency.

## RSpec integration

Configure FactoryBot so its syntax methods are available in RSpec examples.

The intended usage should allow concise calls such as:

`create(:merchant)`

without requiring `FactoryBot.` prefixes everywhere.

Keep the configuration minimal and conventional.

## Merchant factory

Add a factory for `Merchant`.

Provide sensible default values for the currently required persisted attributes.

Factory defaults should be valid and should not introduce unnecessary randomness.

Attributes that must be unique should generate deterministic or sequence-based unique values where appropriate.

Do not add traits unless a current test requires them.

## Merchant specs

Refactor the existing `merchant_spec.rb` to use FactoryBot for Merchant creation.

Preserve the intent and coverage of the existing tests.

Do not rewrite tests merely for style.

Continue testing meaningful persistence constraints, including the uniqueness behavior already covered by the spec.

Do not test FactoryBot itself.

## Project structure

Place factories in a conventional location for the existing RSpec setup.

Do not introduce Rails directories or Rails-specific configuration.

## README

Do not update the README unless FactoryBot is already part of a section that documents development or test tooling and the addition materially improves reviewer understanding.

Avoid documenting internal test implementation details unnecessarily.

## Verification

Verify that:

- FactoryBot is available in the test environment,
- `create(:merchant)` works,
- the Merchant specs use the new factory,
- the existing Merchant test behavior remains covered,
- `make test` passes,
- `make lint` passes.

Do not modify application domain behavior.

Do not commit or push.
