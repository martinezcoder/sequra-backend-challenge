# Prompt 0042 — Organize domain classes with namespaces

Reorganize the classes currently living directly under `lib/` into domain-oriented namespaces.

This is a structural refactor only. Preserve the existing behavior.

## Target structure

Organize commission-related classes under:

    lib/
      commissions/
        calculator.rb
        rules.rb

With:

    Commissions::Calculator
    Commissions::Rules

Organize disbursement-related classes under:

    lib/
      disbursements/
        backfill.rb
        process.rb
        process_daily.rb
        process_weekly.rb
        process_merchant.rb

With:

    Disbursements::Backfill
    Disbursements::Process
    Disbursements::ProcessDaily
    Disbursements::ProcessWeekly
    Disbursements::ProcessMerchant

Keep general-purpose domain/value objects such as `Money` directly under `lib/`.

The resulting structure should therefore be approximately:

    lib/
      commissions/
        calculator.rb
        rules.rb
      disbursements/
        backfill.rb
        process.rb
        process_daily.rb
        process_weekly.rb
        process_merchant.rb
      money.rb

Remove `lib/greeting.rb` if it is still present and is only leftover bootstrap/example code.

## Update references

Update all application code, executables, requires, specs, and other references to use the new namespaces and file locations.

For example:

    CommissionCalculator
    -> Commissions::Calculator

    CommissionRules
    -> Commissions::Rules

    ProcessDisbursements
    -> Disbursements::Process

    ProcessDailyDisbursements
    -> Disbursements::ProcessDaily

    ProcessWeeklyDisbursements
    -> Disbursements::ProcessWeekly

    ProcessMerchantDisbursement
    -> Disbursements::ProcessMerchant

    BackfillDisbursements
    -> Disbursements::Backfill

Preserve the current explicit application loading approach rather than introducing a new autoloading dependency as part of this refactor.

## Documentation

Update README references to the renamed classes where necessary, including the performance and scalability section that currently refers to `ProcessMerchantDisbursement`.

## Verification

Run the complete test suite and RuboCop after the refactor.

Existing behavior, public commands, Make targets, persistence rules, idempotence guarantees, commission calculations, DAILY/WEEKLY processing, and historical backfill behavior must remain unchanged.
