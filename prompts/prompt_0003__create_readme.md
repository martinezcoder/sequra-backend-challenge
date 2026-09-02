Create a concise `README.md` intended primarily for the reviewers of this coding challenge.

Before writing it, read the current `AGENTS.md` and avoid repeating rules or general engineering principles that are already documented there.

The README should focus on explaining the development approach, the decisions made so far, and how a reviewer will eventually be able to run and evaluate the solution.

Include the following information.

## Development workflow

Briefly explain that the solution is being developed using an AI-assisted workflow involving two complementary tools:

- ChatGPT is used as a collaborative space where the developer discusses the problem, explores alternatives, challenges ideas, and decides how to move forward step by step.
- The developer remains responsible for the decisions and guides the process.
- Once a concrete task has been decided, ChatGPT helps formulate a focused prompt for Codex.
- These prompts are stored sequentially in the `prompts/` directory.
- Codex is then instructed to execute a specific numbered prompt.
- The resulting changes are reviewed by the developer using Git before being committed.

Keep this explanation short and factual. It should describe the workflow transparently without presenting AI as the author or decision-maker of the solution.

## Development strategy

Explain that the implementation intentionally follows a baby-steps approach.

The strategy is to start from the simplest useful representation of the problem and progressively introduce complexity only when the requirements justify it.

The goal is to make each step small, understandable, testable, and easy to evolve.

This means that some infrastructure or abstractions that would likely exist in a mature production system may deliberately not appear in the earliest iterations.

## Development environment

Explain the decision to provide a Docker-based development environment.

The motivation is twofold:

- isolate runtime and infrastructure dependencies such as the Ruby version and, when introduced, database services;
- make the project straightforward for reviewers to set up and run without requiring them to reproduce the developer's local environment.

Explain that a small Makefile will provide simple commands for the most common reviewer operations, particularly setup, running tests, and other necessary development commands.

Keep both Docker and the Makefile intentionally minimal.

Do not document commands that do not exist yet. If Docker or Makefile support has not been implemented yet, describe this as the intended development setup rather than pretending it is already available.

## Architecture

Explain the following current architectural direction:

- Favor low coupling and high cohesion.
- Use dependency injection where it helps components remain independent, testable, and easy to replace.
- Do not introduce dependency injection or abstractions merely for architectural purity.
- Persistence will not be introduced in the very first implementation steps.
- A database will be added as soon as the evolving solution actually requires persistence.
- Avoid introducing background-job infrastructure such as Sidekiq unless the problem demonstrates a real need for it.
- At the same time, design boundaries should avoid unnecessarily preventing the solution from later being executed concurrently or distributed across multiple processes.
- Operations that may eventually be executed as background jobs should be designed to be idempotent whenever appropriate.
- Repeating the same job should not cause duplicated effects or irreversible inconsistencies.
- Do not claim that concurrency, distributed execution, or background processing already exists when it has not yet been implemented.

## Monetary values

Document the decision to represent monetary values through a small `Money` value object rather than passing raw numeric values throughout the domain.

The initial approach should be deliberately simple:

- Ruby does not provide a `Money` class in its standard library.
- Do not introduce an external Money dependency at this stage.
- Implement a small project-owned `Money` value object when monetary behavior is first required.
- Store monetary amounts internally using the smallest currency unit as an Integer (for example, cents for EUR).
- Avoid using Float for monetary calculations.
- Keep monetary arithmetic and comparison behavior encapsulated in the `Money` object rather than spreading those rules across the domain.
- Do not implement speculative features such as currency conversion, exchange rates, formatting systems, or complex multi-currency support unless the challenge requires them.

Present this as an intentional application of the baby-steps approach: introduce only the monetary behavior currently required while keeping monetary concepts explicit in the domain.

## Decisions and evolution

Make it clear that this README represents the current state of the developer's decisions and may evolve together with the implementation.

Important technical decisions should be documented when they become relevant, but the README should remain concise and reviewer-focused.

Do not invent decisions that have not been made yet.

In particular, do not choose or document a specific database, persistence library, background processing system, framework, or concurrency strategy unless it has already been explicitly decided elsewhere in the repository.

Do not duplicate the contents of `AGENTS.md`.

Create or update only `README.md`.
