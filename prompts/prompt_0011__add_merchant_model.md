# Prompt 0011 — Add the Merchant persistence model

We are starting the domain implementation with `Merchant`.

The challenge provides merchant data through a CSV dataset, but this task is only about introducing the persistence model and its database migration. CSV importing will be implemented separately.

## Goal

Add an ActiveRecord `Merchant` model backed by a `merchants` table.

Keep the implementation minimal and limited to the merchant data currently required by the challenge.

## Merchant model

Persist the following information:

- internal application identifier,
- external merchant identifier,
- merchant reference,
- email,
- live-on date,
- disbursement frequency,
- minimum monthly fee.

The source CSV contains the fields `id`, `reference`, `email`, `live_on`, `disbursement_frequency`, and `minimum_monthly_fee`.

Map the source CSV `id` to an `external_id` attribute in our model.

Do not use the external identifier as the table primary key.

Use the conventional ActiveRecord/PostgreSQL internal primary key for `Merchant`.

The external identifier belongs to the source system, while the internal primary key belongs to this application. Keeping them separate avoids coupling our persistence identity to an external dataset.

Do not introduce an internal UUID unless a concrete requirement justifies it.

## External identifier

Persist the source merchant identifier as `external_id`.

It must be unique.

Add an appropriate database constraint or unique index so the same external merchant cannot be persisted more than once.

Choose an appropriate database type for the supplied external identifier.

## Merchant reference

The merchant `reference` is used by the orders dataset to identify the merchant.

It must therefore be persisted and uniquely identify a merchant.

Add the appropriate database constraint or unique index to prevent duplicate merchant references.

## Disbursement frequency

Persist the disbursement frequency provided by the input data.

The currently known values are `DAILY` and `WEEKLY`.

Keep the implementation simple.

Do not introduce additional scheduling behavior or disbursement processing in this task.

Avoid speculative abstractions around frequency handling until the processing requirements are implemented.

## Money representation

Persist `minimum_monthly_fee` in the smallest currency unit, cents, using an integer database column named `minimum_monthly_fee_cents`.

For example, a source value of `15.0` euros will eventually be imported as `1500` cents.

Do not use floating-point or decimal database columns for monetary values.

This representation is intentional and prepares the persistence layer for the future introduction of the project-owned `Money` value object.

The future `Money` object should also represent monetary amounts internally using the smallest currency unit, allowing persisted integer values to be passed to the domain without requiring a database schema change.

Do not implement the `Money` value object in this task.

The conversion from the CSV euro representation to cents belongs to the future CSV importing step and must not be implemented in this task.

## Constraints

Add only constraints already justified by the known input and domain requirements.

At minimum:

- `external_id` must not be duplicated,
- `reference` must not be duplicated.

Do not introduce speculative constraints.

## README

Update the README with the relevant modeling decisions.

Document concisely that:

- merchants are persisted before merchant orders so orders can later reference a merchant instead of duplicating merchant information,
- the source merchant `id` is stored as `external_id`,
- the external identifier is intentionally kept separate from the application's internal primary key,
- the application uses the conventional ActiveRecord/PostgreSQL internal identifier because there is currently no requirement that justifies introducing internal UUIDs,
- the merchant reference from the source data is retained because it is the identifier used by the orders dataset,
- monetary values are persisted as integer cents rather than floating-point or decimal values,
- this monetary representation is intended to integrate naturally with the future project-owned `Money` value object,
- disbursement frequency is stored as provided by the source data and its behavior will be implemented separately.

Keep the explanation reviewer-focused and concise.

Do not document merchant CSV importing as implemented yet.

## Tests

Add focused model and persistence tests for the behavior introduced in this task.

Test meaningful constraints rather than ActiveRecord itself.

## Verification

Verify that:

- the migration runs successfully,
- a `Merchant` can be persisted,
- the source merchant identifier is stored as `external_id`,
- `minimum_monthly_fee_cents` is persisted as an integer,
- duplicate `external_id` values are rejected by the database,
- duplicate merchant references are rejected by the database,
- `make test` passes,
- `make lint` passes.

Do not implement CSV loading yet.
Do not implement merchant orders yet.
Do not implement disbursements yet.
Do not implement commission calculations yet.
Do not implement the `Money` value object yet.

Do not commit or push.
