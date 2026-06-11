# Context engineering

How to manage what the assistant can see, because the quality of the answer falls as the context fills. Managing the input is as much of the job as writing the tooling.

## Keep the working context lean

- Point exploration at specific files or patterns, not whole directories. Read the lines you need, not the tree.
- Compact or start a fresh session before a new unrelated task. Stale context from earlier work degrades current reasoning.
- Use a subagent for a large read whose detail you do not need to keep. The detail stays in the subagent's context and only the conclusion returns.

## Index, do not paste

A rule or instruction file should point the agent at where to look, not paste file contents into the prompt. Ship globs, paths, and a ripgrep command, and let the agent fetch on demand. Pasted file bodies go stale and cost tokens on every prompt.

## Keep the root instruction file light

The root instruction file is loaded on every prompt of every session, so every line is a standing cost. Keep it to session level direction and point to detail that loads on demand. The nearest instruction to the edited file should win, so a deep rule overrides a general one. A bloated root file lowers adherence and pushes the session toward compaction sooner.

## Measure the budget

Treat the token cost of your rules and context as a number to watch, not an afterthought. A heavy context set causes a request too long failure and weakens how well the agent follows any single rule. When a rule set grows, measure it and trim the lowest value parts.

## Persist what matters

- For multi step work, track progress in a task list. It survives compaction and keeps the work on course as earlier messages are compressed.
- Keep a short lessons file the agent updates when it is corrected, and have it read that file before planning, so a corrected mistake is not repeated. Keep this memory lean and portable rather than tied to one client.

## Leave alone

Do not strip a rule file down so far that it loses a real constraint. Lean does not mean empty. Trim filler and pasted content, keep the hard rules.
