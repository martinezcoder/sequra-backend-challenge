Create an AGENTS.md file at the root of this repository to define the working rules for this coding challenge.

The AGENTS.md should reflect the following principles:

## Language and communication

- The project is written in Ruby.
- Prefer simple, idiomatic, readable Ruby.
- I may communicate with you in Spanish, but all project content must be written in English.
- This includes source code, comments, documentation, README content, test descriptions, commit messages, filenames, identifiers, and any other text that becomes part of the repository.
- You may communicate with me in Spanish.

## Engineering principles

- Avoid overengineering.
- Prefer the simplest solution that correctly satisfies the challenge requirements.
- Do not introduce abstractions, architectural patterns, layers, dependencies, services, or infrastructure unless they provide a clear benefit.
- Code should be easy to understand, maintain, and explain during a technical interview.
- Do not optimize prematurely.
- Respect the existing structure and style of the repository unless there is a clear reason to change them.
- Do not make unrelated changes.

## Development environment

- The project should be straightforward for reviewers to run locally.
- Prefer Docker and Docker Compose so reviewers do not need to install Ruby or project dependencies directly on their machines.
- Provide a small Makefile as a convenient interface for common development operations such as setup, running tests, and running the application.
- Keep the Docker, Docker Compose, and Makefile setup minimal and appropriate for a coding challenge.
- Do not introduce unnecessary infrastructure.

## Change management

- Do not modify, create, rename, or delete project files without my explicit approval.
- Before making any change, explain what you intend to change and why.
- Wait for my explicit approval before applying the change.
- Approval for one change does not imply approval for unrelated or subsequent changes.
- Do not create Git commits unless I explicitly ask you to.
- Never push changes unless I explicitly ask you to.
- Do not rewrite Git history.

Keep AGENTS.md concise and practical. It should contain working rules, not detailed implementation decisions that have not been made yet.

For now, do NOT create or modify any files.

First, show me the exact AGENTS.md content you propose. Then wait for my approval.

## Prompt workflow

- The `prompts/` directory contains numbered instructions used to guide the development of this challenge.
- Prompt files follow the naming convention `prompt_XXXX_description.md`.
- When instructed to `Proceed with prompt_XXXX`, locate the file whose name starts with that number and read it completely before taking any action.
- Follow the instructions in the prompt while respecting all rules defined in this `AGENTS.md`.
- Do not execute prompt files unless explicitly instructed to do so.
- A prompt may define the scope of a task, but it does not override the approval requirements defined in this file.
