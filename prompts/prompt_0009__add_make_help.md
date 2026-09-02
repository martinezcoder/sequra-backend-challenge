Improve the Makefile developer experience by adding a default help command.

Requirements:

- Running `make` without arguments should display the available Makefile commands.
- Show each relevant command together with a short description.
- Keep the output simple and readable.
- The help output must include the existing commands such as `setup`, `run`, `test`, and `lint`.
- Make the help mechanism easy to maintain as new commands are added.

Also update `AGENTS.md` with a concise rule stating that whenever a new user-facing Makefile target is introduced, it must also be included in the Makefile help output.

Do not add unnecessary Makefile complexity or external dependencies.

Verify that:

    make
    make setup
    make test
    make lint
    make run

continue to work as expected.

Review `README.md` according to the existing `AGENTS.md` rules and update it only if necessary.

Do not create a Git commit.
Do not push anything.
