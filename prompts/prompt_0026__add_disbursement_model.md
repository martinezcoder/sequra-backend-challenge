# Prompt 0026 — Add Disbursement persistence model

Introduce the minimal persistence model needed to represent merchant disbursements.

## Goal

Add a `Disbursement` model and the minimum associations required to represent that a merchant receives one disbursement for a given processing date.

This prompt should only establish persistence and relationships.

## Disbursement model

Create a `disbursements` table and `Disbursement` ActiveRecord model.

Persist:

- `reference`
- `merchant_id`
- the date represented by the disbursement

Use a clear domain-oriented name for the date column, such as `disbursed_on`.

Do not rely on `created_at` to represent the business date.

## Reference

A disbursement must have a unique alphanumerical `reference`.

Add a unique database index for `reference`.

## Associations

Add:

    Merchant has_many :disbursements

and:

    Disbursement belongs_to :merchant

## Uniqueness of merchant and date

The system is being designed so repeated processing of the same merchant and date can remain idempotent.

Add a database-level unique constraint for the combination:

    merchant_id + disbursed_on

This represents the invariant that a merchant can have at most one disbursement for a given disbursement date.

Do not implement processing logic around this constraint yet.

## Tests

Add focused model/persistence specs covering:

- the Merchant association,
- the disbursement date,
- unique `reference`,
- uniqueness of `merchant_id + disbursed_on` at the database level where appropriate.

Follow the established RSpec structure and keep the tests focused on persistence behavior.

## Documentation

Update the README only as needed to reflect that `Disbursement` is now part of the persisted domain model.

Do not document future processing behavior as if it were already implemented.

## Scope

Keep this step limited to establishing the `Disbursement` persistence model and its core uniqueness guarantees.
