Add static code style and quality checks to the project using RuboCop and RuboCop RSpec.

Follow the existing rules in `AGENTS.md` and keep this iteration small.

The goal is to establish consistent Ruby and RSpec style rules before starting the actual domain implementation.

## Dependencies

Add the following development dependencies:

- RuboCop
- RuboCop RSpec

Use current versions compatible with the project's Ruby 3.4.10 environment.

Do not add other RuboCop extensions unless they solve an actual current need.

In particular, do not add Rails-specific plugins because this is currently a plain Ruby project.

## RuboCop configuration

Add a minimal RuboCop configuration.

Requirements:

- Enable the RuboCop RSpec plugin correctly using the current RuboCop plugin configuration mechanism.
- Target Ruby 3.4.
- Prefer RuboCop's sensible defaults instead of creating a large custom configuration.
- Do not generate a RuboCop TODO file.
- Do not disable cops merely to make existing code pass.
- Do not introduce arbitrary style rules unless explicitly requested.
- Keep the configuration short and easy to understand.

### String quotes

This project deliberately prefers double-quoted strings in Ruby code.

Configure RuboCop accordingly.

- Prefer double quotes for normal string literals.
- Do not rewrite existing double-quoted strings to single quotes.
- Do not create large formatting-only diffs changing quote styles.
- Apply this preference consistently to Ruby source files, specs, Gemfile, and other Ruby DSL files where RuboCop applies.
- This is an intentional project style decision, not an exception made only for the current code.

## Linting behavior

`make lint` must only check the code.

It must NOT automatically modify project files.

Do not use RuboCop auto-correction as part of the normal `make lint` command.

If RuboCop reports offenses:

- inspect them individually;
- fix reasonable offenses manually when appropriate;
- do not perform broad automatic rewrites of the repository;
- do not make unrelated formatting changes.

The purpose of introducing RuboCop is to catch issues and maintain consistency, not to generate a large style-only diff.

## Makefile

Add a Makefile target:

    make lint

It should run RuboCop against the project through the existing Docker Compose development environment.

The reviewer should not need RuboCop or Ruby installed locally.

Keep the existing Makefile commands working:

    make setup
    make run
    make test

## Existing code

Run RuboCop against the existing project.

Fix reasonable offenses where doing so does not change intended behavior.

Keep changes minimal.

In particular:

- do not rewrite existing double quotes to single quotes;
- do not perform repository-wide auto-correction;
- do not refactor unrelated code;
- do not introduce new abstractions as part of this task.

## README

Review `README.md` according to the existing `AGENTS.md` rules.

If appropriate, document:

    make lint

alongside the existing reviewer commands.

Keep the documentation concise and do not duplicate information from `AGENTS.md`.

## Verification

Before finishing:

1. Build or update the Docker environment as necessary.
2. Run `make test`.
3. Run `make lint`.
4. Run `make run`.
5. Ensure all three commands succeed.
6. Confirm that `make lint` does not modify any files.

At the end, summarize:

- dependencies added;
- RuboCop configuration added;
- project-specific style decisions configured;
- any existing code changed to satisfy RuboCop;
- Makefile changes;
- README changes, if any;
- test and lint results.

Do not create a Git commit.
Do not push anything.
