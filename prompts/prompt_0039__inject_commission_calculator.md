# Prompt 0039 — Inject commission calculator

Make `CommissionCalculator` an explicit dependency of `ProcessMerchantDisbursement`.

## Context

`ProcessMerchantDisbursement` currently calls the concrete calculator directly:

    CommissionCalculator.call(order.amount_cents)

Commission calculation is a separate domain responsibility and already has its own abstraction.

The merchant processor should coordinate disbursement processing without being tightly coupled to the concrete calculator constant.

## Goal

Inject the commission calculator into `ProcessMerchantDisbursement` while keeping the existing public usage simple.

The default behavior should continue to use `CommissionCalculator`.

Use an interface along these lines:

    ProcessMerchantDisbursement.call(
      merchant,
      date,
      commission_calculator: CommissionCalculator
    )

and pass that dependency into the instance.

The usual production call should remain valid:

    ProcessMerchantDisbursement.call(merchant, date)

## Processing

Use the injected dependency when calculating each order fee.

The processor should no longer reference `CommissionCalculator` directly inside `process_order`.

Preserve all existing commission behavior and persistence.

## Tests

Update the merchant processor specs to take advantage of the dependency boundary where useful.

Add focused coverage showing that the injected calculator is used to determine `fee_cents`.

Keep detailed commission-rule and rounding behavior in the existing `CommissionCalculator` specs rather than duplicating those rules in merchant-processing specs.

## Scope

Keep this change limited to making commission calculation an explicit dependency of `ProcessMerchantDisbursement`.

Do not introduce a dependency injection framework or additional abstractions.
