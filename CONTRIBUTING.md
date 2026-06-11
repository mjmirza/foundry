# Contributing to Foundry

New checks, sharper rules, and fixes are all welcome. Foundry is only as good as the mistakes it encodes, so a single well grounded rule that catches a real error is a strong contribution.

## The bar for a rule

1. It is true on the live tool. Verify a path, a flag, a config key, or an exit code against the real client before you add it. Correctness over confidence. A rule that is plausible but wrong is worse than no rule.
2. It catches a mistake that happens in practice. Prefer edge cases, surprises, soft deprecations, and the errors assistants actually make. Do not restate what the model already knows.
3. It carries a leave alone clause. Say when the rule should not fire, so it does not flag intentional, working code.
4. It respects the token budget. Every line is loaded into a real session. Keep it dense. Trim filler.

## The bar for a linter change

A linter rule needs a fixture. Add a good fixture that must pass and a bad fixture that must be caught, then run the harness.

```bash
bash foundry/evals/run-evals.sh
```

The harness must report zero failures before you open a pull request. Build any secret shaped fixture at runtime, never commit a secret.

## Style

- No em dashes and no stray colons in reference prose. Use periods and tables. Code blocks are exempt.
- Keep manifest versions in sync across the marketplace manifest, the plugin manifest, and both SKILL.md files.
- Commits and pull requests carry no AI attribution.
- Use a clear conventional commit subject that explains why, not only what.

## Where things live

The reference files are under `foundry/references/`. The linters are under `foundry/scripts/`. The harness and its fixtures are under `foundry/evals/`. The packaging is described in `docs/ARCHITECTURE.md`.

## License

All contributions are under the MIT license so the work benefits the most people.
