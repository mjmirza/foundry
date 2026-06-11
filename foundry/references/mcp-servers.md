# MCP servers

How to build and register an MCP server that routes calls correctly, stays cheap on tokens, and is safe to trust. MCP is the one cross assistant standard, so these rules apply on every client.

## Register in the correct file, then verify

The most common reason a server is invisible is that it was registered in the wrong place. Each client reads its MCP config from a specific file. Claude Code reads from `~/.claude.json`, not from the `settings.json` mcpServers key. Register with the client's own command, then run the client's list command and confirm the server and its tools appear. Never assume the file from memory. Confirm against the live client.

## Name and describe tools so calls route

- Name tools as service then action then resource. `linear_list_issues`, not `create` or `search`. Generic names misroute calls.
- Start every tool description with a verb. State the parameter constraints. State the return shape, for example returns a JSON array of objects with id, name, and email. Precise descriptions cut misrouted calls sharply.
- Treat the input schema as the first line of defense. Use enums instead of free strings. Brand identifiers. Allow list URL hosts. The schema is what stops a bad call before it runs.

## Keep the tool surface small

Every tool schema costs on the order of a thousand tokens per session, and a large tool list fills the context window before any work starts. Expose the smallest useful set. Load tools lazily where the client supports it. A server that dumps fifty tools into every session is a token tax on every prompt.

## Transports

- A stdio server is the default for local use. A stateful stdio server shared across conversations is a safety hazard, because state from one conversation can bleed into another. Keep stdio servers stateless or scope state per connection.
- An HTTP or SSE server is for remote or shared use. It needs real auth. Plan for auth in non browser and non interactive cases, not only the browser OAuth flow.

## Declare identity and version

- Declare a stable server identity and instructions. Do not leave identity optional. A client cannot trust or pin a server with no identity.
- Pin the runtime and engine version and expose package metadata, so an install is reproducible rather than floating.

## Onboarding

A server a stranger installs is judged in its first run. Ship one guided setup command that verifies the user's credentials live against the real service before it saves them, writes the client config for the user rather than asking them to hand edit JSON, merges and backs up any existing config, and ends with one concrete next step. State plainly where the credential is stored and that it stays local.

## Secrets and consent

- Read secrets from the environment. Never inline a key in the config or the source.
- Require explicit consent before pulling a local credential such as a git auth token. Never silently use a user credential.
- Use least privilege scopes for any publish or write token. A broad token that grants more than the task needs is a footgun.

## Supply chain

- A tool description is model input. Scan tool descriptions at install and again on every update, because a poisoned description is the tool poisoning vector and it is hidden from the UI.
- Lock the tools list and the config block by hash, so a later silent change to either is detected.
- Bound any decompression when extracting a bundle to stop a zip bomb, and never display a secret in plain text.
- Never claim a signature is verified when the verifier is a stub. Surface the honest status.

## Leave alone

Do not flag a deliberately small single tool server, or a server whose broad scope the user has confirmed is required for an internal admin task. Confirm intent before narrowing a working server.
