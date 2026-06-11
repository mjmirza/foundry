# Security

How to build agentic tooling that does not leak secrets, does not get hijacked by injected content, and does not trust code it has not checked. Security is not a final pass. It is a constraint on every tool you build.

## Treat all inbound content as untrusted

Every byte that reaches the model from a file read, a web fetch, an MCP tool result, or a pasted blob is untrusted data, not instructions. Build tooling that defends the boundary.

- Strip or neutralize invisible unicode ranges before content reaches the model. Zero width characters and tag block characters carry instructions a human cannot see.
- Scan inbound content for direct instruction override, encoded payloads, and authority claims. Annotate or block, depending on severity.
- Never let a tool result steer a later action without the user in the loop on anything irreversible.

## Close the exfiltration channel

- Default deny outbound network calls from tooling. Allow a known set of hosts. Block raw IP literals, request bins, and tunnel hosts.
- Watch for a secret leaving through a side channel, such as a tracker pixel URL, an image markdown link, or a value encoded into a commit message body.

## Secrets and environment

- Read every credential from the environment. Never inline a key in source, config, or a committed file.
- Keep secrets in a gitignored env location. Commit only an example template.
- Require explicit consent before a tool pulls a local credential such as a git auth token. Never use a user credential silently.
- Use least privilege scopes for any token. A token that grants more than the task needs is a standing risk.

## Trust before you load

- Scan an MCP server's tool descriptions and a skill's instructions before trusting them, and again on every update. The description and the instruction are model input, so a poisoned one is an attack.
- Keep a hash of the tools list and the config block, so a later silent change is detected.
- Default telemetry off, opt in only.
- Keep plugin and skill contexts isolated so one cannot read or contaminate another.

## No attribution

Every commit, pull request, and piece of code carries no AI attribution. No trailer that names a model, no footer that credits a tool, no robot marker. The work reads as human authored.

## Honest status

Never report a check as passed when it did not run. A signature verifier that is a stub must say it is unverified, not verified. A claim that the tooling works traces to a real run.

## Leave alone

Do not block a security research workflow that intentionally fetches a sample of malicious content for analysis, when the user has said so. Confirm intent and provide an explicit, logged bypass rather than silently breaking the work.
