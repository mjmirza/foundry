#!/usr/bin/env bash
# run-tests.sh. Run the full Foundry test suite. The unit eval harness, then the
# deep end to end integration test. This lives where the spec promised tests,
# under scripts/tests.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
evals="$here/../../evals"
rc=0
bash "$evals/run-evals.sh" || rc=1
bash "$evals/integration.sh" || rc=1
exit "$rc"
