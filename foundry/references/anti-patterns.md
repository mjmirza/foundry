# Anti-patterns

The mistakes AI assistants actually make when building agentic tooling, each with the fix. This is the centerpiece. Every item here is a real, observed error, drawn from the issue trackers of the top agent tooling repos. Flag these. Do not restyle working code beyond them.

## Hooks

Hook with `set -e` that also tries to block.

```bash
# Bad. set -e makes the shell exit on the first non-zero status,
# so an intended `exit 2` block can be swallowed and never reach the model.
set -euo pipefail

# Good. Never use -e in a hook. Keep -u and -o pipefail only.
set -uo pipefail
```

Reading the removed env var instead of stdin.

```bash
# Bad. $CLAUDE_TOOL_INPUT no longer exists.
file="$CLAUDE_TOOL_INPUT"

# Good. Parse the event payload from stdin as JSON.
payload="$(cat)"
file="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')"
```

PCRE escapes that fail on macOS.

```bash
# Bad. \s and \d silently fail on BSD grep and sed.
grep -E '\s+\d+'

# Good. POSIX character classes work on both BSD and GNU.
grep -E '[[:space:]]+[[:digit:]]+'
```

Over broad destructive command match.

```bash
# Bad. This blocks any command whose text contains rm, including safe paths
# like ./warm-cache or a file named "form.rm".
case "$cmd" in *rm*) exit 2 ;; esac

# Good. Match the actual command and dangerous flags, anchored.
if printf '%s' "$cmd" | grep -Eq '(^|[[:space:];&|])rm[[:space:]]+(-[a-zA-Z]*f|-[a-zA-Z]*r)'; then exit 2; fi
```

Hook anchored on the wrong directory.

```bash
# Bad. $PWD is the directory the command was invoked from, not the project root.
# Nested or subdirectory invocations then run against the wrong tree.
cfg="$PWD/.config"

# Good. Anchor on the project root the client provides.
cfg="${CLAUDE_PROJECT_DIR:-$PWD}/.config"
```

Other hook mistakes to flag.
- Writing to stderr on a successful exit 0. Some clients then label the hook as an error. Route diagnostics to a log file, not stderr, on success.
- Relying on PostToolUse to post process subagent output. PostToolUse does not fire for the Agent or Task tool completion. Use a different surface.
- Appending to the session env file without a guard. The client does not truncate it per session, so re runs accumulate duplicate lines. Grep before you append.
- Assuming one PreToolUse hook sees another's rewritten input. Multi hook ordering and visibility are unspecified. Design each hook to stand alone.
- Assuming the hook runs from its own directory. It runs from the project root. Resolve script paths absolutely.

## Skills

Vague description that never auto triggers.

```text
Bad frontmatter. The description reads like a title, so the router never fires it.
  description: A helpful SwiftUI assistant.

Good frontmatter. Third person, concrete triggers, an explicit when to use.
  description: Reviews and builds Claude Code hooks. Use when writing, editing, or
  debugging a hook, or when a hook fails to fire or blocks the wrong command.
```

Other skill mistakes to flag.
- A SKILL.md with no tools layer. A skill is three layers. The description that decides invocation, the body that is the playbook, and the scripts plus references plus assets it calls to do the work. A body with no tools is a fancy prompt.
- A `name` that does not match the directory, or a missing `name` or `description`. Either makes the skill invisible to the loader.
- Hardcoding `~/.claude/skills/...` inside the skill. Use the skill relative variable the client provides, because user, project, and plugin install paths all differ.
- Assuming a marketplace installed skill shows up in slash autocomplete. It loads but may not appear in the menu. Document the direct invocation path too.
- One monster SKILL.md that holds every detail. Split detail into reference files and load them on demand. Keep the entry file lean.
- Silently dropping a skill when its YAML frontmatter fails to parse. Fail loud and name the offending file.

## MCP servers

Registering in the wrong file.

```text
Bad. Adding the server only to the editor settings block when the client reads
elsewhere. Claude Code reads MCP config from ~/.claude.json, not from the
settings.json mcpServers key, so the server is silently invisible.

Good. Register with the client's own command, then verify it appears with the
client's list command. Never assume the file from memory. Confirm against the
live client.
```

Other MCP mistakes to flag.
- A huge tool surface exposed at once. Every tool schema costs on the order of a thousand tokens per session and fills the context window. Keep the surface small or load tools lazily.
- Generic tool names like `create` or `search`. Name tools as service then action then resource, so calls route correctly.
- A tool description that does not start with a verb, omits parameter constraints, or does not state the return shape. Precise descriptions cut misrouted calls sharply.
- Trusting a tool description at install and never again. Descriptions are model visible and UI hidden, which is the tool poisoning vector. Re scan on every update.
- Leaving server identity and instructions optional. Declare a stable identity.

## Packaging and portability

Installing to the universal path without the per assistant symlink.

```text
Bad. Writing the skill to .agents/skills/<name> and stopping. The assistant that
reads .claude/skills then reports "skill not found".

Good. Write the universal copy and also create the assistant specific symlink, so
both lookup paths resolve to one set of files.
```

Other packaging mistakes to flag.
- Hand maintaining divergent copies of the same skill across .cursor, .claude, and .github. Keep one source and generate the rest.
- Storing lockfile or source paths as absolute paths, or mismatching file name casing. Both break portability and updates. Store relative, preserve casing.
- Shipping one build for a skill that has per assistant variants.
- A sync or install that overwrites or deletes user files. Writes are atomic, keep a backup, and respect the user's ignore files. Never clobber an existing rules file. Append or section instead.
- Stripping Unix file permissions when packing on Windows, and using backslash paths in a bash command. Use forward slashes.

## Settings, subagents, and commands

- Assuming a subagent or skill inherits the user's settings permissions. It does not. Re declare the needed allow rules or the subagent re prompts.
- A slash command with no `description` in its frontmatter. It will not appear in autocomplete. Add the description, and an argument hint where useful.
- Defaulting a marketplace clone to SSH. Default to HTTPS so it does not trigger a key prompt or fail in a non interactive run.

## Documentation hygiene

Markdown rots the same way code does, and the rot is invisible because a broken doc still renders.

- A markdown link to a file that was moved or renamed. It renders as a link and 404s on click. Resolve every local link target to a real file. `check-docs.sh` does this.
- A heading anchor link, `[x](guide.md#section)`, that points at a heading the target no longer has. Slugify the target's headings and confirm the anchor exists.
- An orphan doc. A markdown file that no other doc links to or references. It is the docs equivalent of dead code, and a reader never finds it. Every doc must be reachable from another doc, by a markdown link or a referenced path. If a file is intentionally standalone, an entry point or a convention file, record it in `.docs-orphan-allow` rather than leaving it unreferenced.
- Leave alone. Test fixtures and generated docs hold deliberately broken or unreferenced markdown. Exclude them with `.check-docs-ignore` so the hygiene check does not fight your fixtures.

## The meta mistakes

- Confident wrong guidance. A real reference repo once shipped advice that was backwards. Verify before you assert.
- A rule with no leave alone clause. It will over fire and degrade working code. Every rule names when not to apply it.
- A heavy entry file. It eats the context budget and lowers adherence. Measure and trim.
