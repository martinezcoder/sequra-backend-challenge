# Prompt 0034 — Orchestrate daily and weekly disbursements

Introduce the application-level entry point for processing all disbursements for a given business date.

## Goal

Provide one clear public interface that processes the complete disbursement workload for a date.

The process should execute both currently supported scheduling modes:

- DAILY disbursements,
- WEEKLY disbursements.

Use an interface such as:

    ProcessDisbursements.call(date)

## Orchestration

`ProcessDisbursements` should remain a small orchestration class.

For the requested date, execute:

    ProcessDailyDisbursements.call(date)
    ProcessWeeklyDisbursements.call(date)

Keep the existing DAILY and WEEKLY processors responsible for their own merchant selection and merchant-level processing.

Do not move their business logic into the new orchestrator.

## Execution order

Execute DAILY and WEEKLY processing sequentially.

This is an intentional execution strategy for the current requirements. The DAILY and WEEKLY flows remain independent, so the orchestration mechanism can evolve to execute them concurrently or distribute their work in the future without changing their core processing logic.

There is currently no requirement that justifies introducing concurrency.

## Error behavior

Keep failure behavior simple and explicit.

Do not add retry infrastructure, background processing, scheduling infrastructure, or cross-flow transaction handling in this step.

The new class should coordinate the existing flows rather than introduce a new transactional boundary around the complete day's processing.

## Tests

Add focused orchestration specs verifying that:

- DAILY processing is invoked for the requested date,
- WEEKLY processing is invoked for the same requested date,
- both flows are executed through the single `ProcessDisbursements.call(date)` entry point.

Keep detailed DAILY and WEEKLY behavior in their existing specs rather than duplicating it here.

## Documentation

Update the README to present `ProcessDisbursements.call(date)` as the application-level entry point for processing disbursements for a business date.

Document that DAILY and WEEKLY flows are currently executed sequentially and that their merchant-level processing remains independently transactional and idempotent.
