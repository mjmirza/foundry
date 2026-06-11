# Testing and evals

How to prove a piece of agentic tooling actually works, rather than asserting it does. Works on my machine means nothing. The test is the only proof.

## The seven case test

Every hook, linter, or script ships with a test that covers all seven.

1. Positive. A real violation is caught.
2. Negative. Clean input passes and is not flagged. This is the case people skip, and it is where false alarms live.
3. Stress. Empty input, very large input, malformed JSON, special regex characters, CRLF line endings, and a byte order mark.
4. Boundary. One below, at, and one above any numeric threshold.
5. Performance. The hot path stays within its time budget.
6. Idempotency. Running it twice produces the same result, with no duplicate writes or double registration.
7. Fail open. A config error or a missing file ends in exit 0, never a block of unrelated work.

## How to eval each kind of tooling

- A skill. The real test is whether the description triggers it. Run a set of prompts that should fire it and a set that should not, and confirm the router selects it only on the first set. Then confirm its referenced files exist and its version matches across manifests.
- A hook. Feed it good and bad fixtures on stdin and assert the exit code and the stdout for each. A good fixture must exit 0. A bad fixture must exit 2.
- An MCP server. Register it, then assert the server and every tool it claims appear in the client's list command, and that a representative tool call returns the shape the description promised.

## Test the tooling, and test the tests

- A guard with only a positive case is half tested. Without a negative case you cannot tell it apart from a guard that blocks everything.
- Build fixtures from fragments joined at runtime, so a test file full of banned patterns does not trip a sibling guard.
- Run the tests in CI, not only locally. Validate the no operation case, a dry run, a missing source, and the config schema, so a broken release is caught before it ships.

## A release gate

Before tooling ships, the seven case test is green, the artifact has been observed firing against a real input, and any deferred gap is written down with a severity, not left implicit. A built artifact that was never run is not done.

## Leave alone

Do not demand a heavy eval suite for a one shot throwaway script the user marked as such. Match the test depth to the blast radius.
