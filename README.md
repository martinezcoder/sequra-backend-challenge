# SeQura Coding Challenge

This repository contains a solution developed incrementally for the SeQura coding challenge. This document summarizes the current development approach and technical direction for reviewers; it will evolve as the implementation does.

## Development workflow

Development uses two complementary AI-assisted tools. ChatGPT is a collaborative space where the developer discusses the problem, explores and challenges alternatives, and decides how to proceed. Once a concrete task is defined, ChatGPT helps formulate a focused prompt for Codex CLI. These prompts are stored sequentially in [`prompts/`](prompts/), and Codex CLI is instructed to execute a specific numbered prompt. The developer remains responsible for all decisions and reviews every resulting change with Git before committing it.

## Development strategy

The implementation follows a baby-steps approach: start with the simplest useful representation of the problem and add complexity only when requirements justify it. Each step should be small, understandable, testable, and easy to evolve. Infrastructure and abstractions common in a mature production system may therefore be deliberately absent from early iterations.

## Development environment

A minimal Docker-based environment isolates the Ruby runtime and project dependencies, so reviewers only need Docker with Docker Compose rather than a local Ruby installation.

Run `make` to list the available commands.

The following commands provide the complete current reviewer workflow:

```sh
make setup
make db-migrate
make db-rollback
make test
make lint
make load-merchants FILE=input_data/merchants.csv
make run
```

`make setup` builds the development image and prepares the database. `make db-migrate` applies pending migrations, `make db-rollback` reverts the latest migration, `make test` runs the complete RSpec suite, `make lint` checks Ruby and RSpec style with RuboCop, `make load-merchants FILE=path/to/merchants.csv` imports merchant data, and `make run` executes the example Ruby program.

### Ruby version

Ruby 3.4.10 is pinned exactly for a reproducible, modern environment. Ruby 4 was considered and is not being avoided as unstable or unsuitable; the developer has not yet used it enough to justify adding a new major runtime version as another variable in a time-bounded challenge. Ruby 3.4.10 provides a current environment while keeping that variable out of scope.

## Architecture

The current direction favors low coupling and high cohesion. Dependency injection will be used where it keeps components independent, testable, and replaceable, but neither injection nor abstractions will be introduced solely for architectural purity.

After evaluating the challenge requirements, persistence is needed from the first domain iteration. PostgreSQL was selected instead of a lighter option such as SQLite because Docker removes most of SQLite's setup-cost advantage for reviewers. ActiveRecord is used directly without Rails, providing conventional migrations, associations, transactions, constraints, and querying without custom repository infrastructure. Schema changes are managed through ActiveRecord migrations.

Merchants are persisted before their orders so orders can later reference a merchant instead of duplicating merchant information. A merchant uses the conventional ActiveRecord/PostgreSQL internal identifier; there is currently no requirement that justifies an internal UUID. The source merchant `id` is retained separately as the unique `external_id`, while its unique `reference` is retained because that is how the orders dataset identifies merchants. Disbursement frequency is stored as supplied by the source data; its behavior will be implemented separately.

Merchant imports synchronize records by `external_id`, creating missing merchants and updating existing ones. Each complete CSV is imported atomically because partially synchronized reference data would be misleading. A failure aborts the import and reports its row rather than introducing partial-success recovery infrastructure. Explicit locking is also omitted because concurrent imports are not currently required. Monetary CSV values are converted through `Money` and persisted as integer cents.

Boundaries should not unnecessarily prevent future concurrent execution or distribution across processes. Operations that could later run as background jobs should be idempotent when appropriate, so retries do not create duplicate effects or irreversible inconsistencies. Concurrency, distributed execution, and background processing are not currently implemented.

## Monetary values

Monetary values are represented by a small project-owned `Money` value object. Ruby has no `Money` class in its standard library, and an external money dependency is not justified at this stage.

`Money` and persisted monetary values use integer cents as their only numeric representation. Monetary calculations remain in cents rather than exposing floating-point or decimal values, while `Money#to_s` provides a euro-denominated string solely for presentation. Additional behavior, including commission calculations, will be introduced only when required.

This keeps money explicit in the domain while introducing only the behavior needed at each step.

## Decisions and evolution

This README records the developer's current decisions and will evolve with the solution. Relevant technical decisions will be documented when they arise, while keeping this document concise and focused on reviewer needs. No web framework, background processor, or concurrency strategy has been selected yet.
