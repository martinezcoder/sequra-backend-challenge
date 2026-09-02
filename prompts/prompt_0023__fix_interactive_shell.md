# Prompt 0023 — Fix interactive shell behavior

The current `make shell` command opens a shell inside the application container, but the terminal interaction is broken.

For example, pressing the up arrow prints escape sequences such as `^[[A` instead of recalling the previous command.

## Goal

Make `make shell` provide a normal interactive shell experience inside the container.

It should support at least:

- command history with the up/down arrow keys,
- normal cursor movement with left/right arrows,
- standard terminal shortcuts,
- normal copy/paste behavior.

## Constraints

Keep the solution minimal.

Do not add a different shell or extra tooling unless necessary.

Prefer fixing the Docker Compose / Makefile invocation and/or using an appropriate interactive shell already available in the image.

Do not introduce zsh or shell customization just for this task.

## Review existing command

Inspect the current `make shell` implementation and the Docker Compose command it delegates to.

Adjust it so the shell runs with proper interactive TTY behavior.

Keep the existing container workflow unchanged outside this command.

## Verification

Verify manually that:

- `make shell` opens a shell inside the application container,
- running a command and pressing the up arrow recalls it,
- left/right arrow keys move the cursor normally,
- interactive terminal behavior works as expected.
