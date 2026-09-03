# Prompt 0043 — Silence expected importer errors in specs

The test suite currently prints importer error messages to the console for scenarios where failures are intentionally exercised and asserted.

Examples include expected failures such as:

    Merchant order import failed at CSV line ...
    Merchant import failed at CSV line ...

These messages are useful during real imports, but they make the RSpec output noisy when the errors are deliberately triggered by tests.

Adjust the specs or test setup so expected importer error output is suppressed during those examples while preserving the production/importer behavior.

Handle this centrally in `spec/spec_helper.rb` through opt-in RSpec metadata, so individual examples and contexts can be marked without repeating output matchers in every test. Do not silence `stderr` globally because unexpected errors must remain visible.

Apply the metadata at the broadest suitable context level. Examples that explicitly assert the importer error message must remain outside the silencing metadata so they continue to verify the real output.

Do not remove or weaken the importer logging itself.

Keep the assertions around the raised errors and importer behavior intact.

The normal test output should remain clean, with expected failure scenarios represented only by passing RSpec examples rather than console error messages.

Run the complete test suite and RuboCop after the change.
