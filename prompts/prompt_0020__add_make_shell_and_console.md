# Prompt 0020 — Add Make shell and console commands

Add two developer-facing Makefile commands for interacting with the application environment.

## Commands

Add:

- `make shell` — opens an interactive shell inside the application container.
- `make console` — opens an interactive Ruby console with the application environment loaded, including ActiveRecord configuration and project classes.

The console should allow direct interaction with domain objects, for example querying `Merchant` records or using `Money`, without manually requiring project files.

Use the existing Docker Compose application service rather than introducing new services or scripts unless necessary.

Keep both commands simple and consistent with the existing Docker-based development workflow.

## Help

Include both commands in the existing Makefile help output with concise descriptions.

## Documentation

Update the README only if these commands belong naturally in the existing reviewer/developer usage instructions.
