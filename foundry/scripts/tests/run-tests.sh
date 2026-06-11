#!/usr/bin/env bash
# run-tests.sh. Thin wrapper that runs the Foundry eval harness, so the linter
# tests live where the spec promised them, under scripts/tests.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
exec bash "$here/../../evals/run-evals.sh"
