# Skills

How to author a skill that auto triggers, stays portable, and earns its token cost. A skill is a folder, not a prompt.

## The three layers

Every real skill has all three. A skill with only the first two is a fancy prompt.

1. Description. The frontmatter line that decides when the skill is invoked. This is a router, not a summary.
2. Instructions. The SKILL.md body. The step by step playbook the model follows once the skill is selected.
3. Tools. The `scripts/`, `references/`, and `assets/` the skill calls. Deterministic code beats token burning prose. Save a script the second time you would write the same logic.

## The description is a router

The single most common reason a skill never fires is a weak description. Write it third person. Start with concrete trigger verbs and nouns. State an explicit when to use.

```text
Weak. Never fires.
  description: A helpful assistant for hooks.

Strong. Fires on the right prompts.
  description: Reviews and builds Claude Code hooks. Use when writing, editing, or
  debugging a hook, when a hook does not fire, or when a hook blocks the wrong command.
```

## Frontmatter

```yaml
---
name: foundry              # lowercase hyphenated, must match the directory name
description: ...            # the router, see above
license: MIT
argument-hint: "[focus]"    # shown to the user when they invoke with an argument
metadata:
  author: Your Name
  version: "0.1.0"          # keep in sync across every manifest in the repo
---
```

- A missing or blank `name` or `description` makes the skill invisible to the loader.
- The `name` must match the directory name.
- Keep the `version` identical in the skill frontmatter, the plugin manifest, and the marketplace manifest. Version drift across manifests is a real, reported bug.
- A `files` allowlist controls what ships in the package, so internal notes do not leak into the tarball.

## Invocation flags

Default is open to both the user and the model. Set a flag only when the skill warrants the lock.

- `user_invocable: false` hides the skill from the slash menu. The model can still call it. Use for internal helper skills other skills compose with.
- `disable_model_invocation: true` lets only the user call it. Use for higher risk deploy or send skills.

## Skill relative paths

Reference files with the client provided skill directory variable, never a hardcoded home path.

```text
Bad.  references/api.md            (works for one layout only)
Bad.  ~/.claude/skills/foundry/... (wrong on project and plugin installs)
Good. ${CLAUDE_SKILL_DIR}/references/api.md
```

The same skill installs to different roots. A user install, a project install, and a plugin bundled install all differ. The variable resolves correctly in each.

## Keep the entry file lean

The body is loaded on every invocation, so every line costs tokens on every use. Put detail in reference files and load them on demand. A monster SKILL.md that holds everything degrades adherence and can break the request. Measure the entry file and trim.

## Structure and packaging

- The canonical layout is `skills/<name>/SKILL.md`. An installer should find every nested skill, not only the first. A single skill installed when the repo ships many is the top packaging bug.
- Never silently drop a skill when its YAML frontmatter fails to parse. Fail loud and name the offending file.
- Keep one source of the skill and generate any per assistant outputs. Do not hand maintain divergent copies across `.cursor`, `.claude`, and `.github`.

## Lifecycle

- A growing skill library accumulates duplicates and stale skills. Periodically dedupe, merge, and retire. Treat skill sprawl as a real cost, not a free addition.
- Record a short provenance and a version so a consumer can tell where a skill came from and whether it changed.

## Leave alone

Do not flag a small private helper that sits next to the body it serves just to force it into its own file. Do not flag a deliberately minimal skill that is meant to be a thin router to other skills. Confirm intent before restructuring a working skill.
