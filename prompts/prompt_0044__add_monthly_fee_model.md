# Prompt 0044 — Add MonthlyFee persistence model

Add persistence for monthly minimum fee calculations.

## Goal

Introduce a `MonthlyFee` model representing the result of evaluating one merchant's minimum monthly fee for one calendar month.

This prompt is only about persistence and model relationships. Do not implement the monthly fee calculation yet.

## Schema

Create a `monthly_fees` table with:

    merchant_id
    period
    amount_cents

Requirements:

- `merchant_id` must reference `merchants`.
- `period` must be a `date`.
- `amount_cents` must be an integer and must not be null.
- Add a unique database constraint/index on:

    merchant_id + period

This uniqueness represents the invariant that a merchant can have only one monthly fee evaluation for a given month.

## Period semantics

`period` represents the calendar month being evaluated.

Store it normalized to the first day of that month, for example:

    2026-01-01
    2026-02-01

Do not add separate `year` or `month` columns.

Do not add derived fields such as total commissions or the merchant minimum monthly fee. Those values already have their own sources of truth and can be derived when needed.

## Model relationships

Add:

    Merchant has_many :monthly_fees
    MonthlyFee belongs_to :merchant

Keep the existing association conventions used elsewhere in the project.

## Zero-value records

`amount_cents` may be zero.

A persisted record with:

    amount_cents = 0

means that the merchant/month was evaluated and the configured minimum monthly fee was already reached through order commissions.

This distinction will later allow the reporting layer to differentiate between:

- a month that was evaluated and required no additional fee,
- and a month that has not been processed.

## Tests

Add focused model/persistence specs covering the new relationship and the merchant/month uniqueness guarantee.

Add or update FactoryBot factories if appropriate for the existing test setup.

## Documentation

Update the README with the relevant design decisions introduced by this model, especially where the challenge does not prescribe a specific representation.

Document that:

- `MonthlyFee#period` represents the evaluated calendar month and is stored as the first day of that month.
- A `MonthlyFee` record is persisted even when `amount_cents` is zero. This distinguishes a merchant/month that was evaluated and required no additional fee from one that has not been processed yet.
- `MonthlyFee` stores only the resulting amount. Commission totals and configured minimum fees are not duplicated because they can be obtained from their existing sources of truth.

Keep the documentation focused on these design decisions and their rationale rather than describing straightforward schema or ActiveRecord implementation details.

Do not document calculation or processing behavior that has not been implemented yet.

## Verification

Run the full test suite and RuboCop.
