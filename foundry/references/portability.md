# Portability

How to make one piece of tooling install and run across every AI coding assistant. This is the most requested and least solved problem in this space. Most repos claim cross assistant support by copying the same markdown into many folders. Foundry maps the real paths and the real differences.

## The install path matrix

This table is a starting map. Paths and read support change between client versions, so confirm each one against the live client before you rely on it. Treat any entry you cannot confirm as unverified.

| Assistant | Project skills path | Reads AGENTS.md | Rules file |
|---|---|---|---|
| Claude Code | `.claude/skills/` | via an AGENTS.md import | `CLAUDE.md` and the rules directory |
| Codex | `.agents/skills/` | yes, native | `AGENTS.md` |
| Gemini CLI | `.agents/skills/` | yes | `GEMINI.md` |
| Cursor | `.agents/skills/`, also `.cursor/skills/` | yes | `.cursor/rules/` |
| Cline | `.agents/skills/` | partial | `.clinerules/` |
| Copilot | none, an instructions file only | yes, the root file only | `.github/copilot-instructions.md` |
| Continue | source controlled rules | yes | rules under version control |

The shape is simple. Every client reads the universal `.agents/skills/` path at project scope except Claude Code, which reads `.claude/skills/`, and Copilot, which uses an instructions file rather than the skill format. The user level paths follow the same shape with the home directory in front of the project path. Verify these too. The machine readable version of this map lives at `data/install-paths.json`, so the installer and the docs do not drift.

## AGENTS.md is the widest standard

A large and growing set of tools reads AGENTS.md at the repo root, including Codex, Gemini CLI, Cursor, Copilot, Aider, goose, opencode, Zed, Warp, Jules, Amp, RooCode, Windsurf, and more. The nearest AGENTS.md in the tree wins, and an explicit chat prompt overrides the file. Nesting is not honored everywhere. Copilot reads only the root file. Document the per client caveat rather than assuming uniform behavior.

## Write once, install everywhere, with the right symlink

The single most reported portability bug is installing to one path and leaving the other client unable to find the skill. Write the universal copy under the `.agents/skills/` convention, which Codex, Gemini, Cursor, and Cline all read directly, and add one symlink at `.claude/skills/` for Claude Code, the one client that does not read the universal path. That is exactly what Foundry's own `install.sh` does. Do not create a symlink at a path a client does not read, that is the defect in reverse, and do not install only the universal copy and leave Claude with a skill not found.

## Keep one source, generate the rest

Do not hand maintain divergent copies of the same skill or rule across `.cursor`, `.claude`, and `.github`. Keep one source and generate the per client outputs from it. Diverging copies drift and the agent then obeys a stale one.

## Non destructive install and merge

- Give a user who already has a rules file a merge story. Append or add a section. Never clobber an existing `.windsurfrules`, `.clinerules`, or `.cursorrules`.
- Writes are atomic and keep a backup of the prior content. Respect the user's ignore files. Never delete a user file. A sync that deletes user work is the worst possible failure.

## Lockfile and packaging hygiene

- Store lockfile and source paths as relative paths and preserve file name casing. Absolute paths break portability, and a casing mismatch silently fails an update.
- Ship per assistant variants when a skill genuinely differs by client. Do not ship one build and call it universal when it is not.
- Default any marketplace clone to HTTPS, not SSH, so it does not trigger a key prompt or fail in a non interactive run.

## Translate the capability, not only the file

Copying markdown is not portability. Different clients express the same idea differently. A Claude Code blocking hook that exits 2 maps to a different mechanism on a client that has no hook layer, sometimes a rule phrased as a hard constraint. When you port tooling, map the capability to the target client's real mechanism, and say plainly where a capability has no equivalent rather than pretending it carried over.

## Leave alone

Do not rewrite a user's working single client setup into a portable one unless they asked for portability. Confirm the target clients first.
