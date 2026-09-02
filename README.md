# SeQura Coding Challenge

This repository contains a solution developed incrementally for the SeQura coding challenge. This document summarizes the current development approach and technical direction for reviewers; it will evolve as the implementation does.

## Development workflow

Development uses two complementary AI-assisted tools. ChatGPT is a collaborative space where the developer discusses the problem, explores and challenges alternatives, and decides how to proceed. Once a concrete task is defined, ChatGPT helps formulate a focused prompt for Codex CLI. These prompts are stored sequentially in [`prompts/`](prompts/), and Codex CLI is instructed to execute a specific numbered prompt. The developer remains responsible for all decisions and reviews every resulting change with Git before committing it.

## Development strategy

The implementation follows a baby-steps approach: start with the simplest useful representation of the problem and add complexity only when requirements justify it. Each step should be small, understandable, testable, and easy to evolve. Infrastructure and abstractions common in a mature production system may therefore be deliberately absent from early iterations.

## Development environment

A minimal Docker-based environment is planned to isolate runtime and infrastructure dependencies, including the Ruby version and any database services introduced later. It will also let reviewers set up and run the project without reproducing the developer's local environment.

A small Makefile is also planned as a simple interface for common reviewer operations, particularly setup, tests, and other necessary development commands. Docker and Makefile support have not been implemented yet; commands will be documented when they exist.

## Architecture

The current direction favors low coupling and high cohesion. Dependency injection will be used where it keeps components independent, testable, and replaceable, but neither injection nor abstractions will be introduced solely for architectural purity.

Persistence is intentionally excluded from the first implementation steps. A database will be added when the evolving solution requires it; no database or persistence library has been selected yet. Likewise, background-job infrastructure will not be introduced without a demonstrated need.

Boundaries should not unnecessarily prevent future concurrent execution or distribution across processes. Operations that could later run as background jobs should be idempotent when appropriate, so retries do not create duplicate effects or irreversible inconsistencies. Concurrency, distributed execution, and background processing are not currently implemented.

## Monetary values

Monetary values will be represented by a small project-owned `Money` value object when monetary behavior is first required. Ruby has no `Money` class in its standard library, and an external money dependency is not justified at this stage.

Amounts will be stored internally as integers in the smallest currency unit, such as cents for EUR; `Float` will not be used for monetary calculations. Arithmetic and comparison rules will remain encapsulated in `Money` rather than being scattered through the domain. Currency conversion, exchange rates, formatting systems, and complex multi-currency support will be added only if required.

This keeps money explicit in the domain while introducing only the behavior needed at each step.

## Decisions and evolution

This README records the developer's current decisions and will evolve with the solution. Relevant technical decisions will be documented when they arise, while keeping this document concise and focused on reviewer needs. No framework, database, persistence library, background processor, or concurrency strategy has been selected yet.
