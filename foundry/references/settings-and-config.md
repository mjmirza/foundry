# Settings and config

How to change a client's settings without breaking what the user already set. Config is shared, accumulated state. Treat it with care.

## Merge, never overwrite

- Read the existing config, add only the keys that are missing, and keep every local value as the source of truth. Never replace a settings file wholesale.
- Adding a new hook, a new key, or a new server is safe and additive. Removing a section, or changing an existing value, needs the user's confirmation.
- Back up the prior content before any write that changes a config file.

## Permissions are least privilege

- Grant the narrowest permission that lets the task run. A broad wildcard allow is a standing risk.
- A subagent or skill does not inherit the user's settings permissions. Re declare the allow rules it needs.
- Match each component of a compound command against the permission rules, not only the first word. A permission prompt that fires on the leading directory change instead of the real command is a known gap.

## Let a rule pin model and effort

A rule may pin the model and the reasoning effort for a task, and should allow a user defined provider and model so the rule is not locked to one vendor. Do not hardcode a single vendor into shared tooling.

## Per assistant config

- Each client has its own config file and its own keys. Write to the file the client actually reads, and verify against the live client.
- For a monorepo, support reading config from a parent directory so a nested package picks up the shared setup.
- Make every component installable and also uninstallable, with a record of what was installed, so a user can cleanly remove it.

## Marketplaces and updates

- Default a marketplace clone to HTTPS, not SSH.
- Make plugin and marketplace auto updating configurable, off or on by the user's choice.

## Secrets and env

- Keep secrets in a gitignored env location, never in the committed config. Commit an example template only.

## Leave alone

Do not tighten a permission the user deliberately set wide for their own workflow, and do not move a config value the user placed on purpose. Confirm before changing settings the user owns.
