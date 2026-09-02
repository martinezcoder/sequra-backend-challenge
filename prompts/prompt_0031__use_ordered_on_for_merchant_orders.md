# Prompt 0031 — Use ordered_on for merchant order dates

Refine how the source order date is represented in the domain.

## Context

The orders CSV provides `created_at` as a calendar date without a time or timezone.

The current persistence model stores this value as a `datetime` column named `created_at`.

This represents precision and semantics that the source data does not provide. It also makes DAILY disbursement processing unnecessarily reason about time ranges when the actual domain requirement is simply whether an order belongs to a given date.

The project is still being built from scratch and there is no production data or backward-compatibility requirement.

## Goal

Represent the source order date explicitly as a calendar date.

Rename the persisted MerchantOrder field:

    created_at

to:

    ordered_on

and change its database type from `datetime` to `date`.

`ordered_on` represents the date supplied by the source orders dataset, not the timestamp when the local ActiveRecord record was created.

## Migration

Add a normal ActiveRecord migration that changes the column name and type.

Keep the migration straightforward. There is no need to preserve or transform existing development data because the database can be recreated from the source CSV files.

Ensure the resulting schema defines:

    ordered_on

as a non-null `date`.

## Merchant order importer

The CSV column remains:

    created_at

Map that source field to the internal `ordered_on` attribute.

Parse it as a date rather than a timestamp.

The importer should continue to preserve the distinction between source-owned fields and internally calculated fields such as `fee_cents` and `disbursement_id`.

## DAILY disbursement processing

Update eligible-order selection to use the date directly.

The query should express the domain rule directly:

    MerchantOrder.where(
      merchant: @merchant,
      ordered_on: @date
    )

There should no longer be a need to construct a datetime range using the processing date and the following day.

## Tests

Update MerchantOrder factories and specs to use `ordered_on`.

Update importer specs to verify that the CSV `created_at` value is persisted as `ordered_on`.

Update DAILY disbursement processing specs to use the new date field while preserving the existing behavioral coverage.

Keep the tests focused on calendar-date semantics; do not introduce timezone or end-of-day behavior that is not present in the source data.

## Documentation

Update the README where necessary to reflect that the source order `created_at` value is represented internally as the calendar date `ordered_on`.

The documentation should make clear that this choice intentionally reflects the precision available in the source dataset.
