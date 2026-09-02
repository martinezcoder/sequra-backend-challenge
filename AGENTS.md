# Working Rules

## Language and communication

- This project is written in Ruby.
- Prefer simple, idiomatic, readable Ruby.
- The user may communicate in Spanish, and responses may be in Spanish.
- All repository content must be written in English, including source code, comments, documentation, README content, test descriptions, commit messages, filenames, and identifiers.

## Engineering principles

- Prefer the simplest solution that correctly satisfies the challenge requirements.
- Avoid overengineering and premature optimization.
- Introduce abstractions, patterns, layers, dependencies, services, or infrastructure only when they provide a clear benefit.
- Keep code easy to understand, maintain, and explain in a technical interview.
- Respect the repository's existing structure and style unless there is a clear reason to change them.
- Do not make unrelated changes.

## Development environment

- Keep the project straightforward for reviewers to run locally.
- Prefer a minimal Docker and Docker Compose setup so reviewers do not need Ruby or project dependencies installed locally.
- Provide a small Makefile for common operations such as setup, testing, and running the application.
- Do not introduce unnecessary infrastructure.

## Change management

- Do not create, modify, rename, or delete project files without the user's explicit approval.
- Before every change, explain exactly what will change and why, then wait for explicit approval.
- Approval applies only to the described change and does not authorize unrelated or subsequent changes.
- Do not create Git commits unless explicitly requested.
- Never push changes unless explicitly requested.
- Do not rewrite Git history.

## Prompt workflow

- The `prompts/` directory contains numbered instructions for developing this challenge.
- Prompt filenames follow the pattern `prompt_XXXX_description.md`.
- When instructed to `Proceed with prompt_XXXX`, locate the file whose name begins with that number and read it completely before acting.
- Follow the prompt while respecting all rules in this file.
- Do not execute a prompt unless explicitly instructed.
- A prompt defines task scope but does not override the change-approval requirements above.
