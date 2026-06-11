# Hooks

How to write a hook that fires, blocks correctly, and never breaks unrelated work. Hooks are the highest footgun surface in agent tooling. Most of the rules here come from real bugs in the top hook repos.

## The seven authoring requirements

Every hook satisfies all seven.

1. First line is exactly `#!/usr/bin/env bash`. Not `#!/bin/sh`, not a missing shebang.
2. Within the first lines, `set -uo pipefail`. Never `set -e`. The `-e` flag exits on the first non-zero status and swallows an intended `exit 2` block.
3. Parse the event payload from stdin as JSON. The legacy `$CLAUDE_TOOL_INPUT` env var is gone. Read `tool_name` and `tool_input` from stdin with jq.
4. Use POSIX character classes in every regex. `[[:space:]]`, `[[:digit:]]`, `[[:alnum:]]`. Never `\s`, `\d`, `\w`. The PCRE escapes fail silently on macOS BSD grep and sed.
5. Fail open. A hook that hits its own error exits 0 and never blocks unrelated work. Only an intentional policy violation exits 2.
6. Route errors to a log file, not to stderr on success. Some clients label a hook as failed if it writes to stderr even on exit 0.
7. Ship a matching test that covers positive cases, negative cases, and the stress cases. Empty input, very large input, malformed JSON, special regex characters, CRLF line endings, and a byte order mark.

## The exit code contract

```text
exit 0   allow. The tool runs.
exit 2   block. PreToolUse denies the tool and feeds stderr to the model.
         PostToolUse feeds the reason back so the model can correct course.
other    non blocking error. The action proceeds, the error is logged.
```

## The events

| Event | Fires | Common use |
|---|---|---|
| PreToolUse | before a tool runs | block or rewrite a tool call |
| PostToolUse | after a tool succeeds | lint, format, surface a reminder |
| PostToolUseFailure | after a tool fails | diagnose a failed tool |
| UserPromptSubmit | on each user prompt | inject context, detect a trigger |
| SessionStart | at session start | surface state, set up |
| Stop | when the turn ends | summarize, speak, check tasks |
| SubagentStop | when a subagent ends | collect subagent output |
| PreCompact | before compaction | back up the transcript |

## Parsing the payload

```bash
#!/usr/bin/env bash
set -uo pipefail
payload="$(cat)"
tool="$(printf '%s' "$payload" | jq -r '.tool_name // empty')"
file="$(printf '%s' "$payload" | jq -r '.tool_input.file_path // empty')"
[ -z "$file" ] && exit 0   # fail open when the field is absent
```

## Anchoring and the environment

- Anchor every path on the project root the client provides, `${CLAUDE_PROJECT_DIR:-$PWD}`, never bare `$PWD`. Nested and subdirectory invocations otherwise run against the wrong tree.
- The hook runs from the project root, not from its own directory. Resolve script paths absolutely.
- Skip the hook body when it runs inside a tool spawned or nested agent session, to avoid recursive hook loops.
- When you append to the session env file, grep guard before the append. The client does not truncate it per session, so re runs accumulate duplicate lines.
- Keep SessionStart output terse. Its stdout can be truncated, so a long banner is cut off.

## Newer affordances to prefer

- An `mcp_tool` hook type calls an MCP tool directly with no subshell. Use it when the hook's whole job is calling one MCP tool.
- The `args` exec form spawns the command directly with no shell. No word splitting, no quote bugs, no command injection through an interpolated path. Prefer it for any hook that takes a file path.
- `continueOnBlock: true` on a PostToolUse hook feeds the rejection back in context and lets the turn continue. Use it for soft blocks like a lint reminder. Keep hard blocks non continuing.
- Read `duration_ms` from the PostToolUse payload instead of timing the tool yourself.

## What a hook must not assume

- PostToolUse does not fire for the Agent or Task tool completion. Do not rely on it to post process subagent output.
- Multi hook PreToolUse ordering, and whether one hook sees another's rewritten input, are unspecified. Design each hook to stand alone.
- A subagent or skill does not inherit the user's settings permissions. Re declare the needed allow rules.

## Windows and portability

- Use forward slash paths in a bash command. Backslash paths break it.
- Do not spawn with a shell wrapper where the runtime forbids it. Recent Node versions warn or crash on a shelled spawn.

## Register and verify

A hook on disk that is not wired into the client config never runs. After writing a hook, register it in the client's hook config, then trigger the event and confirm it fired. A hook that was never observed firing is not done.

## Leave alone

Do not flag a hook that intentionally exits non zero to signal a non blocking state, or one that writes to stderr on purpose for a debug build the user marked as such. Confirm intent before rewriting a working hook.
