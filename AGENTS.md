# Working Rules

## Language and communication

- This project is written in Ruby.
- Prefer simple, idiomatic, readable Ruby.
- The user may communicate in Spanish, and responses may be in Spanish.
- All repository content must be written in English, including source code, comments, documentation, README content, test descriptions, commit messages, filenames, and identifiers.

## Engineering principles

- Follow a pragmatic "Best Simple System for Now" approach.
- Prefer the simplest solution that correctly satisfies the current challenge requirements while remaining easy to understand, maintain, and evolve.
- Avoid overengineering and premature optimization.
- Introduce abstractions, patterns, layers, dependencies, services, or infrastructure only when they provide a clear benefit.
- Treat the solution as production-quality challenge code, prioritizing clarity, correctness, maintainability, testing, and problem-solving over unnecessary sophistication.
- Design, develop, test, and document changes with the discipline expected from a real-world feature.
- Keep code easy to understand and explain in a technical interview.
- Respect the repository's existing structure and style unless there is a clear reason to change them.
- Do not make unrelated changes.

## Requirements and ambiguity

- Do not silently make significant assumptions about ambiguous challenge requirements.
- Point out material ambiguities that could affect the design or implementation before assuming an interpretation or proposing implementation changes.
- Do not make product or architectural decisions on the user's behalf when meaningful alternatives exist.

## Development environment

- Keep the project straightforward for reviewers to run locally.
- Prefer a minimal Docker and Docker Compose setup so reviewers do not need Ruby or project dependencies installed locally.
- Provide a small Makefile for common operations such as setup, testing, and running the application.
- Do not introduce unnecessary infrastructure.

## Change management

- Create, modify, rename, or delete files when necessary to complete a task the user has explicitly requested, without asking for prior approval.
- Keep all changes strictly within the scope of the requested task.
- Do not make unrelated changes.
- After completing a task, clearly summarize the changes so the user can review them using Git.
- Git is the review mechanism: the user will inspect the resulting diff and decide whether to keep, modify, or discard the changes.
- Do not create Git commits unless explicitly requested.
- Never push changes unless explicitly requested.
- Do not rewrite Git history.
- Do not discard or overwrite existing uncommitted changes that AI did not create without explicitly informing the user first.

## AI-assisted workflow

- AI acts as a development assistant; the developer remains responsible for all technical and product decisions.
- Review and adapt AI-generated suggestions to the actual requirements and project context rather than accepting them blindly.
- Preserve the `prompts/` directory as a transparent history of instructions given to AI during the challenge.
- Do not present AI-generated reasoning as the developer's own reasoning.
- Do not invent or automatically document decisions, alternatives, assumptions, trade-offs, limitations, or other reasoning that the challenge expects from the developer.

## Prompt workflow

- The `prompts/` directory contains numbered instructions for developing this challenge.
- Prompt filenames follow the pattern `prompt_XXXX_description.md`.
- When instructed to `Proceed with prompt_XXXX`, locate the file whose name begins with that number and read it completely before acting.
- Follow the prompt while respecting all rules in this file.
- Do not execute a prompt unless explicitly instructed.
- A prompt defines task scope but does not override the change-management rules above.
