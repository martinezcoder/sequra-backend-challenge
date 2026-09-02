# Prompt 0019 — Add code documentation guidelines

Add a concise code documentation guideline to `AGENTS.md`.

The project should document important behavior close to the code when that behavior is not obvious from the implementation itself.

The guideline should establish that comments are useful for explaining:

- non-obvious behavior,
- important method contracts,
- behavioral guarantees and invariants,
- significant implementation decisions,
- magic values whose meaning is not immediately clear.

Comments should primarily explain **why** something exists or clarify behavior that a developer needs to know when modifying the code.

Avoid comments that merely narrate self-explanatory code.

For example, a method whose important contract is that an entire operation is transactional and rolls back on the first failure may document that guarantee close to the method.

Similarly, a numeric value such as starting CSV row numbering at `2` may be commented when its meaning depends on the first row being a header.

Keep this as a general project guideline rather than documenting these specific examples as project rules.

Keep the addition concise and consistent with the existing `AGENTS.md` philosophy.
