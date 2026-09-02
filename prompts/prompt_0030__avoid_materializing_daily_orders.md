# Prompt 0030 — Avoid materializing daily merchant orders

Review the DAILY merchant disbursement processing to avoid loading all eligible orders into memory at once.

## Context

`ProcessDailyMerchantDisbursement` currently selects eligible orders with:

    MerchantOrder.where(
      merchant: @merchant,
      created_at: @date...@date.next_day
    ).to_a

The resulting array is then checked for emptiness and iterated to process every order.

A merchant may have a large number of orders on a given day, so materializing the complete relation before processing creates an unnecessary memory dependency on the merchant's daily order volume.

## Goal

Keep `eligible_orders` as an ActiveRecord relation and process its records without loading the entire result set into memory at once.

Use idiomatic ActiveRecord batching where appropriate.

Preserve the current behavior:

- no disbursement is created when there are no eligible orders,
- all eligible orders are processed,
- processing remains atomic for the merchant,
- repeated processing remains idempotent,
- the merchant/date transaction remains the unit of work.

## Query behavior

Avoid executing the complete eligible-order query merely to determine whether orders exist.

Use an efficient existence check before creating the disbursement.

Then process the eligible relation in batches so memory usage does not grow with the total number of orders for that merchant and date.

## Tests

Preserve the existing behavioral coverage.

Add or adjust a focused test only if needed to establish that processing does not depend on `eligible_orders` being an Array.

The tests should continue to focus primarily on observable processing behavior rather than ActiveRecord implementation details.

## Documentation

Remove the existing FIXME once the issue has been addressed.

Update the README only if this change represents a reviewer-relevant implementation decision.
