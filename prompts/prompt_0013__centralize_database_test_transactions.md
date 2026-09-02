# Prompt 0013 — Centralize database test transactions

The current `Merchant` model spec contains database transaction cleanup logic directly inside the spec:

    around do |example|
      described_class.transaction do
        example.run
        raise ActiveRecord::Rollback
      end
    end

This is test infrastructure rather than Merchant-specific behavior and should not live in an individual model spec.

## Goal

Move the database transaction isolation logic to the shared RSpec configuration so all database-backed specs benefit from the same behavior.

Keep the solution minimal and appropriate for the current plain Ruby + ActiveRecord + RSpec setup.

## Shared transaction handling

Configure RSpec so each example runs inside an ActiveRecord transaction that is rolled back after the example finishes.

Use `ActiveRecord::Base.transaction` rather than `described_class.transaction`, because this behavior belongs to the database test environment as a whole rather than to the model currently under test.

The intended behavior is:

- each example starts from a clean database state,
- records created during an example are rolled back afterwards,
- individual model specs do not need to repeat transaction cleanup code.

Do not introduce DatabaseCleaner or any additional dependency at this stage.

## Spec organization

Remove the Merchant-specific `around` block from `merchant_spec.rb`.

Place the shared behavior in the existing common RSpec configuration, such as `spec_helper.rb`, unless the current project structure already has a more appropriate shared ActiveRecord-specific helper.

Avoid introducing additional helper files unless they materially improve the existing structure.

## Scope

Do not change application behavior.

Do not modify Merchant model behavior or factory behavior unless required by this refactor.

Do not introduce support for threads, multiple database connections, system tests, or other scenarios that the project does not currently have.

## Verification

Verify that:

- `merchant_spec.rb` no longer contains database transaction cleanup logic,
- persisted records created by one example do not leak into another example,
- the shared transaction wrapper works for ActiveRecord-backed specs,
- `make test` passes,
- `make lint` passes.

Do not commit or push.
