# Prompt 0010 — Add PostgreSQL persistence foundation

After the first evaluation of the challenge requirements, we have concluded that persistence is needed from the beginning.

The challenge explicitly requires us to:

- design and implement the necessary data structures,
- persist data,
- calculate and store disbursements,
- ensure orders are disbursed exactly once,
- keep the orders, amounts, and fees included in each disbursement identifiable for reporting purposes,
- and remain ready to process new orders.

Because of these requirements, persistence is not considered speculative infrastructure anymore.

## Goal

Introduce the minimal persistence foundation for the project using PostgreSQL and ActiveRecord.

Do not implement any challenge domain models yet.

## PostgreSQL

Add PostgreSQL as the database used by the application.

SQLite could provide a lighter persistence solution, but the project already uses Docker as its official runtime environment. Because PostgreSQL can therefore be provided to reviewers without requiring any additional local installation, we do not need to optimize for an embedded database purely for setup convenience.

Keep the PostgreSQL setup as small as possible.

Update Docker Compose to add a PostgreSQL service and configure the application service to connect to it.

The reviewer should still only need Docker and the existing Makefile interface.

## ActiveRecord

Add ActiveRecord as the persistence layer.

Use ActiveRecord directly; do not introduce Rails.

ActiveRecord is intended to remove unnecessary persistence boilerplate and provide a conventional Ruby interface for:

- database-backed domain objects,
- migrations,
- associations,
- constraints,
- transactions,
- querying.

Do not introduce repository abstractions or additional persistence layers unless a concrete later requirement justifies them.

Add only the gems required for ActiveRecord and PostgreSQL support.

## Rake and database tasks

Add Rake and configure the project so conventional ActiveRecord database tasks can be used without Rails.

At minimum, support:

- `bundle exec rake db:create`
- `bundle exec rake db:migrate`
- `bundle exec rake db:rollback`

Keep the `Rakefile` and database task setup minimal and conventional.

Do not manually reimplement migration behavior if ActiveRecord already provides the necessary functionality.

## Database structure

Set up the minimum conventional ActiveRecord database infrastructure required for future migrations.

Do not create `Merchant`, `Order`, `Disbursement`, or any other challenge-specific tables or models in this task.

The goal is only to establish and verify the persistence foundation.

## Makefile

Preserve the existing commands and keep the Makefile as the main reviewer-facing interface.

Update `make setup` if appropriate so that, after setting up the project, the database is ready to use.

Add only the minimal database-related targets that are useful for development.

Any new user-facing Makefile target must appear in the Makefile help output, according to the existing `AGENTS.md` rule.

The reviewer should not need to know the underlying Rake commands just to set up and run the project.

## README

Update the README to explain the persistence decision concisely.

Document that:

- after evaluating the challenge requirements, persistence is needed from the first domain iteration,
- PostgreSQL was selected instead of a lighter option such as SQLite,
- Docker removes most of the setup-cost advantage SQLite would otherwise provide,
- ActiveRecord is used directly without Rails,
- ActiveRecord provides conventional persistence functionality without requiring custom database/repository infrastructure,
- database schema changes are managed through ActiveRecord migrations.

Do not claim that any domain models or disbursement logic have been implemented yet.

Keep the explanation reviewer-focused and concise.

## Verification

Verify that:

- the Docker environment builds successfully,
- PostgreSQL starts successfully,
- the application can establish a database connection through ActiveRecord,
- `bundle exec rake db:create` works,
- `bundle exec rake db:migrate` works,
- `bundle exec rake db:rollback` is available and correctly configured,
- the documented Makefile setup leaves the database ready to use,
- `make test` still passes,
- `make lint` still passes,
- `make run` still works.

Do not implement domain models or business logic.

Do not commit or push.
