# Prompt 0016 — Consolidate recurring instructions in AGENTS.md

Our numbered prompts have started repeating several instructions that apply to almost every task.

We want `AGENTS.md` to be the source of truth for permanent AI working rules, while individual prompts should focus only on the specific goal, decisions, constraints, and verification relevant to that step.

## Goal

Review the existing numbered prompts and `AGENTS.md` to identify instructions that are repeatedly included in prompts but are actually global project rules.

Move or consolidate those recurring rules into `AGENTS.md`.

Do not mechanically copy every repeated sentence. Extract the underlying rules and express them once, clearly and concisely.

## Rules to consider

In particular, review recurring instructions around:

- never committing unless explicitly requested,
- never pushing unless explicitly requested,
- keeping changes within the requested task,
- avoiding unrelated modifications,
- preferring the simplest implementation that satisfies current requirements,
- avoiding speculative abstractions, dependencies, infrastructure, or behavior,
- not implementing future domain requirements prematurely,
- running the relevant test suite after changes,
- running lint after changes,
- keeping README documentation accurate,
- updating README only when a change introduces or modifies reviewer-relevant behavior or a documented technical decision,
- not documenting functionality as implemented before it actually exists.

Some of these rules may already exist in `AGENTS.md`. If so, improve or consolidate the existing wording rather than duplicating them.

## Prompt-writing guidance

Add a concise rule explaining the intended division of responsibility:

- `AGENTS.md` contains persistent project-wide instructions.
- numbered prompts contain only task-specific context, decisions, requirements, constraints, and verification.
- prompts should not repeat rules already established in `AGENTS.md` unless a particular task needs to override or emphasize them for a concrete reason.

The goal is to make future prompts shorter and easier to review without losing behavioral guarantees.

## Existing prompts

Do not rewrite the historical numbered prompts.

They represent the actual prompt history of the challenge and should remain unchanged.

This task only changes the guidance for future prompts.

## Keep AGENTS.md concise

Do not turn `AGENTS.md` into a large procedural manual.

Consolidate related rules where possible.

Preserve the existing principles and workflow decisions already documented there.

Avoid introducing new project policies that cannot be derived from the existing workflow or recurring prompt instructions.

## Verification

Review the resulting `AGENTS.md` and confirm that the common instructions currently repeated across prompts are covered clearly enough that future prompts no longer need to repeat them.
