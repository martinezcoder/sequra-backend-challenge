# Prompt 0037 — Enforce orders disbursed exactly once

Review and strengthen the current disbursement flow so the challenge requirement that every order is disbursed exactly once is explicitly guaranteed.

## Context

The current processing is idempotent for a merchant and processing date:

- the same merchant/date resolves to the same disbursement,
- reprocessing recalculates the same fee,
- the same logical orders remain associated with that disbursement.

However, a persisted `MerchantOrder` can currently be reassigned to a different `disbursement_id`.

The challenge explicitly requires:

    Ensure all orders are disbursed exactly once.

## Goal

Make this invariant explicit in the implementation and tests.

An order that has already been assigned to a disbursement must not later be silently reassigned to another disbursement.

At the same time, retrying the same logical processing operation must remain idempotent.

## Expected behavior

For an eligible order:

- if it has no disbursement yet, process and assign it normally,
- if it is already associated with the same logical disbursement, reprocessing should remain safe and idempotent,
- if it is already associated with a different disbursement, processing must not overwrite that association.

Treat the last case as an invariant violation rather than silently moving the order between disbursements.

## Design

Review the current persistence model and `ProcessMerchantDisbursement` implementation and choose the simplest appropriate way to enforce this invariant.

Prefer an explicit domain/persistence guarantee over relying on the current scheduling windows accidentally not overlapping.

Keep the existing merchant-level transaction boundary.

Do not weaken the current idempotency behavior.

## Tests

Add focused coverage proving that:

- a previously undistributed order is assigned to its disbursement,
- reprocessing the same merchant/date keeps the order associated with the same disbursement,
- an order already associated with another disbursement is not reassigned,
- the conflicting merchant processing fails atomically rather than leaving a partial result.

Keep the tests focused on the observable exactly-once invariant.

## Documentation

Update the README where appropriate to state that an order may belong to at most one disbursement and that retries of the same logical processing remain idempotent.

Document the guarantee that prevents an already-disbursed order from being moved to another disbursement.
