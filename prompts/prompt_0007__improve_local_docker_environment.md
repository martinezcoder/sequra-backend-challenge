Improve the local Docker development environment with two small changes:

1. Add an appropriate `.gitignore`.
2. Prevent Docker from creating project files owned by `root` on the host.

Follow the existing rules in `AGENTS.md` and keep the solution minimal.

## .gitignore

Create a minimal `.gitignore` appropriate for the current Ruby project.

It should ignore local development artifacts that must not be committed, including at least:

    .bundle/
    vendor/bundle/

These directories may be used by developers who install the project's gems locally for editor/tooling support even though Docker remains the official project execution environment.

Also include other standard Ruby or local development artifacts only if they are relevant to the project in its current state.

Do not add speculative entries for frameworks, databases, IDEs, operating systems, or tools that the project does not currently use.

Do not ignore:

- Gemfile.lock
- mise.toml
- Docker configuration
- Makefile
- project source code or tests

## Docker file ownership

Review the current Dockerfile, Docker Compose configuration, and Makefile.

The current setup can result in files created from inside the container being owned by `root` on the host. This causes problems when the same repository is also accessed directly from the developer's WSL environment.

Adjust the Docker development setup so commands executed through Docker Compose do not create project files owned by `root` on the host.

Requirements:

- Keep the solution simple and portable.
- Do not hardcode a specific developer UID or GID.
- Prefer using the host user's UID/GID when running development commands inside the container.
- The normal reviewer workflow through the Makefile should remain simple.
- Do not require reviewers to manually edit Docker configuration with their UID/GID.
- Do not introduce custom scripts or additional infrastructure unless genuinely necessary.
- Do not weaken container or host permissions with approaches such as `chmod 777`.
- Do not recursively change ownership of files as part of normal container startup.
- Existing project commands such as `make setup`, `make run`, and `make test` must continue to work.

If there are multiple reasonable ways to handle UID/GID mapping, choose the smallest solution appropriate for this coding challenge.

## Local Ruby tooling

Docker remains the official and documented environment for running the project.

However, developers may optionally use the same Ruby version locally through mise and install gems locally in order to support development tools such as Ruby LSP.

The repository must allow this without committing local Bundler configuration or locally installed gems.

Do not make local Ruby or mise a requirement for reviewers.

## README

Review `README.md` according to the existing `AGENTS.md` rules.

Only update it if these changes affect information that is useful to reviewers.

Do not document developer-specific Neovim, LazyVim, Ruby LSP, WSL, or local Bundler setup. Those are local development details and are not part of the challenge's reviewer workflow.

## Verification

After implementing the changes:

1. Verify the Docker environment still builds successfully.
2. Verify `make test` works.
3. Verify `make run` works.
4. Verify the Docker Compose application process runs using the intended non-root UID/GID strategy.
5. Check that the resulting setup does not require a reviewer to know or manually configure their UID/GID.

Do not modify existing file ownership on the host as part of this task. The developer will fix any files that were already created as root separately.

At the end, summarize:

- the `.gitignore` entries added;
- how UID/GID handling was implemented;
- whether README.md required any change;
- the verification results.

Do not create a Git commit.
Do not push anything.
