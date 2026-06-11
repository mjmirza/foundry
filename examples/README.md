# Examples

A real before and after, produced by Foundry's own linter.

## A hook that breaks its own block

`bad-hook.sh` is a hook with the common mistakes. Run the linter on it from the repo root.

```bash
bash foundry/scripts/check-hook.sh examples/bad-hook.sh
```

You get findings like these.

```
examples/bad-hook.sh:1  first line should be #!/usr/bin/env bash
examples/bad-hook.sh:2  uses set -e, which can swallow an exit 2 block. use set -uo pipefail
examples/bad-hook.sh:3  reads removed env var CLAUDE_TOOL_INPUT. parse the event payload from stdin as JSON
examples/bad-hook.sh:4  PCRE escape like backslash s or d. use a POSIX class such as [[:space:]] or [[:digit:]]
examples/bad-hook.sh:5  anchors on bare $PWD. use ${CLAUDE_PROJECT_DIR:-$PWD} for the project root
```

The linter exits 1 because it found problems.

## The fixed version

`good-hook.sh` applies every fix. It parses the payload from stdin, keeps `set -uo pipefail`, uses a POSIX class, and anchors on the project root.

```bash
bash foundry/scripts/check-hook.sh examples/good-hook.sh
```

The linter prints nothing and exits 0. That is the whole point. The same shape works for `check-skill.sh`, `check-mcp.sh`, and `check-command.sh`.
