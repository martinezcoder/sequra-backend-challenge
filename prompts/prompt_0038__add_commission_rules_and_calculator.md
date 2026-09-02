# Prompt 0038 — Add commission rules and calculator

Replace the temporary fixed 1% commission with the challenge's amount-based commission rules.

## Context

The current merchant disbursement processor calculates every order fee as a fixed 1%.

The challenge defines:

- 1.00% for orders below €50
- 0.95% for orders from €50 up to €300
- 0.85% for orders of €300 or more

Every monetary result must be rounded up to two decimal places.

The project already represents money in integer cents.

## Goal

Introduce a small commission calculation boundary that keeps the business rules separate from disbursement processing.

Use two clear responsibilities:

- a rules component that resolves which commission rule applies to an amount,
- a calculator that applies that rule and returns the resulting fee in cents.

Keep `ProcessMerchantDisbursement` focused on disbursement processing rather than embedding commission thresholds and rates directly.

## Commission rules

Introduce a class such as:

    CommissionRules

with an interface such as:

    CommissionRules.rule_for(amount_cents)

Represent the current rules as simple in-code configuration, preferably through a constant collection.

The rules should express the three thresholds explicitly in cents.

Keep the source of the rules behind this class. The current implementation may use a constant, while preserving a clear boundary so the rules could later come from another source without changing commission consumers.

Document this design intent briefly near the rules definition. Do not introduce external configuration or database persistence for commission rules in this step.

## Commission calculator

Introduce a class such as:

    CommissionCalculator

with an interface such as:

    CommissionCalculator.call(amount_cents)

It should:

- resolve the applicable rule through `CommissionRules`,
- calculate the fee using integer-safe arithmetic,
- round the result upward to the nearest cent,
- return the fee as integer cents.

Avoid floating-point arithmetic.

## Rule boundaries

Implement the exact challenge boundaries:

    amount < €50       => 1.00%
    €50 <= amount < €300 => 0.95%
    amount >= €300     => 0.85%

Be especially careful with orders exactly at €50 and exactly at €300.

## Disbursement processing

Update `ProcessMerchantDisbursement` to use `CommissionCalculator` instead of the temporary fixed 1% calculation.

Keep fee persistence unchanged:

    fee_cents

Do not move commission-rule knowledge back into the processor.

## Tests

Add focused specs for the rules and calculator.

Cover at least:

- an amount below €50,
- exactly €50,
- an amount between €50 and €300,
- exactly €300,
- an amount above €300,
- upward rounding when the percentage produces a fractional cent.

Keep tests explicit around the threshold boundaries.

Update merchant disbursement processing specs so they verify that the calculated fee follows the real commission rules rather than the temporary 1% rule.

## Documentation

Update the README to state that commissions are now calculated per order using the challenge's three amount-based rates.

Briefly document that commission-rule lookup is isolated from fee calculation so the current in-code rules can evolve to another configuration source without changing the disbursement processing logic.
