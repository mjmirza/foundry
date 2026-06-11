#!/bin/bash
set -euo pipefail
target="$CLAUDE_TOOL_INPUT"
echo "$target" | grep -E '\s+\d+'
cfg="$PWD/.config"
echo "$cfg"
