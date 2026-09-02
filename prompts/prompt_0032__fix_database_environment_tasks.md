# Prompt 0032 — Fix database environment tasks

Fix the database task environment handling in this standalone ActiveRecord application.

## Context

This project uses ActiveRecord directly without Rails.

Running:

    make db-drop

currently fails with:

    ActiveRecord::EnvironmentMismatchError

ActiveRecord reports that the database was last run in the `development` environment while the current task is running in `default_env`.

The application and its database tasks should consistently identify the development environment without relying on Rails being present.

## Goal

Make the standalone ActiveRecord database task configuration consistent so destructive and non-destructive database tasks operate against the expected development environment.

The solution should fit naturally with the existing ActiveRecord configuration and avoid introducing Rails-specific application infrastructure.

Review the existing Rakefile, database configuration, and environment loading to determine the appropriate place to establish this behavior.

Ensure that this db-drop command is included in the help section of the Makefile.

## Database commands

Ensure the existing database workflow remains functional:

    make setup
    make db-migrate
    make db-rollback

Add and support:

    make db-drop

`make db-drop` should successfully drop the development database when invoked through the project's Docker environment.

## Makefile

Add `db-drop` consistently as a user-facing Make target.

It should appear in:

- `.PHONY`,
- `make help`.

Keep the Makefile focused on invoking the application's database tasks rather than duplicating environment configuration unnecessarily.

## Verification

Verify the database lifecycle through the existing Docker-based workflow, including dropping, recreating, and migrating the development database.

The final configuration should not produce an environment mismatch between the environment recorded by ActiveRecord and the environment used by its database tasks.
