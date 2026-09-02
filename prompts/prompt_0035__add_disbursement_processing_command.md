# Prompt 0035 — Add disbursement processing command

Expose the complete disbursement processing flow through a simple command-line entry point and Make target.

## Goal

Allow a reviewer or developer to process all disbursements for a specific business date with:

    make process-disbursements DATE=2026-09-03

This should invoke the existing application-level entry point:

    ProcessDisbursements.call(date)

## Executable

Add an executable under `bin/` for processing disbursements.

It should:

- load the application environment,
- require a business date as input,
- parse the supplied value as a calendar date,
- call `ProcessDisbursements` with that date,
- fail clearly when the date is missing or invalid.

Keep the executable thin. Business logic belongs in the existing processing classes.

## Makefile

Add a user-facing target:

    make process-disbursements DATE=2026-09-03

The target should execute the new command through the existing Docker application environment.

Keep the Make target as a thin wrapper around the executable.

Follow the existing Makefile conventions and include the new command in `make help`.

## Tests

Add focused coverage for the command-line boundary where useful, particularly input validation.

Do not duplicate the business behavior already covered by the disbursement processing specs.

## Documentation

Update the README reviewer workflow to include:

    make process-disbursements DATE=2026-09-03

Briefly explain that the command processes both DAILY and eligible WEEKLY disbursements for the supplied business date through the application's main disbursement processing entry point.
