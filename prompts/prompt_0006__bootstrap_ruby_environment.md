Bootstrap the first executable version of the challenge project.

This is intentionally a very small first iteration. Follow the existing `AGENTS.md` and keep the solution minimal.

The goal of this iteration is only to establish a working Ruby development environment with Docker, Docker Compose, RSpec, a trivial piece of Ruby code, and a small Makefile.

Do not start implementing the actual challenge domain yet.

## Ruby version

Use Ruby 3.4.10.

- Pin Ruby to exactly version 3.4.10 in the Docker image.
- Use the same Ruby version consistently anywhere the project declares its runtime version.
- Do not use a floating Ruby version such as `3.4`, `latest`, or an unspecified version.

This is an intentional project decision.

Ruby 4 is already available, but the developer is not yet familiar enough with that major version to justify introducing it into this coding challenge.

The goal is not to avoid Ruby 4 because it is considered unstable or unsuitable. The goal is simply to avoid introducing an unnecessary variable and potential source of complexity into the challenge.

Ruby 3.4.10 is deliberately chosen as a modern Ruby version the developer is comfortable working with.

## Docker

- Add a minimal `Dockerfile` using the official Ruby 3.4.10 image.
- Prefer an appropriate minimal/slim variant when practical.
- Keep the image and build steps simple.
- Do not add application infrastructure that is not required yet.
- Do not add a database, Redis, Sidekiq, Rails, or any other service.

## Docker Compose

- Add a minimal Docker Compose configuration.
- It should provide a single application service sufficient to run the Ruby code and the test suite.
- Mount the project source when appropriate for local development.
- Keep the configuration easy for reviewers to understand and use.
- Do not introduce additional services.

## Ruby project

- Create the minimum Ruby project structure necessary to run code and tests.
- Add a `Gemfile`.
- Include only the dependencies needed for this iteration.
- Add RSpec as the testing framework.
- Do not introduce Rails, another web framework, or unnecessary libraries.

## Example code

- Add one very small Ruby class or object that proves the project can execute Ruby code successfully.
- Keep it deliberately trivial.
- This code exists only to validate the initial project infrastructure, not to model the challenge domain.
- Add a simple executable entry point that exercises this code.

## RSpec

- Configure RSpec with the minimum required setup.
- Add one simple spec covering the example Ruby code.
- The test should demonstrate that RSpec works correctly inside the Docker environment.
- Do not introduce additional testing libraries unless they are actually necessary.

## Makefile

Add a small `Makefile` as the main interface for reviewers.

At minimum, provide commands for:

- preparing/building the development environment;
- running the Ruby application/example code;
- running the complete test suite.

Prefer simple and obvious targets:

    make setup
    make run
    make test

The Makefile should delegate execution to Docker Compose.

A reviewer should not need Ruby, Bundler, or project gems installed locally. Docker should be the only significant local requirement.

Keep the Makefile small. Do not add commands that are not useful yet.

## Reviewer experience

After this iteration, a reviewer should be able to clone the repository and run approximately:

    make setup
    make test
    make run

without having to understand or reproduce the developer's local Ruby environment.

The exact commands must correspond to functionality that actually exists after this task is completed.

## README

Review and update `README.md` according to the existing `AGENTS.md` rules.

In addition to documenting the now-implemented Docker and Makefile workflow, explicitly document the Ruby version decision.

Briefly explain that:

- Ruby 3.4.10 is intentionally pinned for reproducibility.
- Ruby 4 was considered.
- Ruby 4 is not being avoided because of an assumption that it is unstable or unsuitable.
- The developer has not yet worked enough with Ruby 4 to justify introducing a new major runtime version into a time-bounded coding challenge.
- Ruby 3.4.10 therefore removes an unnecessary variable while still providing a modern Ruby environment.

Keep this explanation concise and natural. It should read as a pragmatic engineering decision, not as a warning about Ruby 4.

Also update the README so that:

- Docker is described as implemented rather than planned.
- The actual Makefile commands available to reviewers are documented.
- No planned infrastructure is presented as already implemented.
- Documentation reflects the actual resulting project.

Do not duplicate general working rules already documented in `AGENTS.md`.

## Verification

Before finishing:

1. Build/prepare the Docker environment using the Makefile.
2. Run the example Ruby code using the Makefile.
3. Run the complete RSpec suite using the Makefile.
4. Fix any issue that prevents those commands from working.

The final expected reviewer workflow should be:

    make setup
    make test
    make run

At the end, summarize:

- which files were created or changed;
- the Docker/Ruby setup that was created;
- the available Makefile commands;
- the verification results;
- any relevant implementation decision you had to make that was not explicitly defined by this prompt.

Do not create a Git commit.
Do not push anything.
