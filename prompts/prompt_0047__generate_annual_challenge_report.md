# Prompt 0047 — Generate annual challenge report

Implement the annual reporting required by the challenge using the data already persisted by the application.

## Goal

Generate the following metrics grouped by calendar year:

    Year
    Number of disbursements
    Amount disbursed to merchants
    Amount of order fees
    Number of monthly fees charged
    Amount of monthly fees charged

The report must be derived from the existing persisted sources of truth. Do not introduce duplicated aggregate fields solely for reporting.

## Reporting semantics

Use `Disbursement#disbursed_on` to attribute disbursement-related amounts to a year.

For each year:

### Number of disbursements

Count the disbursements completed during that year.

### Amount disbursed to merchants

Calculate the net amount actually disbursed to merchants from orders belonging to disbursements completed during that year:

    sum(order amount_cents) - sum(order fee_cents)

Monthly minimum fees must not be subtracted from this amount because the challenge explicitly states that charging them is outside scope and they are not subtracted from disbursement commissions.

### Amount of order fees

Sum the persisted `MerchantOrder#fee_cents` values for orders belonging to disbursements completed during that year.

Use the persisted historical commissions rather than recalculating commissions from current rules.

### Number of monthly fees charged

Use `MonthlyFee#period` to attribute monthly fees to a year.

Count only `MonthlyFee` records whose:

    amount_cents > 0

A zero-value `MonthlyFee` represents a merchant/month that was evaluated but required no additional charge and therefore must not count as a monthly fee charged.

### Amount of monthly fees charged

Sum `MonthlyFee#amount_cents` for the year.

Zero-value records naturally contribute nothing to this amount.

## Design

Introduce a small reporting component under an appropriate reporting-oriented namespace and file structure consistent with the project's current organization.

Keep reporting separate from disbursement and monthly fee processing. It should consume persisted data without modifying it.

Prefer database aggregation where it keeps the implementation simple and avoids loading large numbers of orders into Ruby memory.

Keep all monetary calculations in integer cents internally.

Convert amounts to a readable euro representation only when presenting the final report, using the project's existing money representation where appropriate.

## Command-line interface

Expose the annual report through:

    make report

Add a thin executable under `bin/` following the project's existing command conventions.

Add the new target to `make help`.

The command must output the report as a valid Markdown table using exactly the columns required by the challenge:

    Year
    Number of disbursements
    Amount disbursed to merchants
    Amount of order fees
    Number of monthly fees charged
    Amount of monthly fees charged

The output should be directly copyable into the README and should also support redirection to a Markdown file, for example:

    make report > report.md

Do not add a table-formatting dependency. Keep the presentation simple and deterministic.

## Years included

Derive the report years from the persisted historical data rather than hardcoding years from the provided dataset.

The report should work with the current challenge dataset and remain valid when future years are added.

## Tests

Add focused specs covering the reporting calculations.

Cover at least:

- disbursements are counted in the year of `disbursed_on`,
- merchant disbursement amount is gross order amount minus persisted order fees,
- order fees use persisted `fee_cents`,
- monthly fees are attributed using `MonthlyFee#period`,
- zero-value monthly fee evaluations are not counted as monthly fees charged,
- positive monthly fees are counted,
- monthly fee amounts are summed correctly,
- monthly fees do not reduce the amount disbursed to merchants,
- data from different years is reported independently.

Keep presentation tests focused on useful observable behavior rather than exact whitespace unless formatting itself is part of the contract.

## Documentation

Update the README with the final reporting workflow and the reviewer-facing:

    make report

Document the reporting semantics that result from the design decisions made during the challenge, especially:

- disbursement counts, merchant amounts, and order fees are attributed using `Disbursement#disbursed_on`;
- merchant amounts are reported net of order commissions;
- monthly minimum fees are not subtracted from merchant disbursements;
- monthly fees are attributed using their evaluated `period`;
- persisted zero-value `MonthlyFee` records represent completed evaluations but are not counted as fees charged;
- persisted order commissions are used for historical reporting rather than recalculating them from potentially newer commission rules.

Keep the README focused on non-obvious reporting semantics and their rationale rather than implementation details.

## Verification

Run the full test suite and RuboCop.

Run the report against the fully processed challenge dataset and verify that it produces the annual rows required to complete the challenge's reporting table.
