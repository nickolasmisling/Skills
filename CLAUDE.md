# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A collection of Claude Code Skills — each skill is a directory containing a `SKILL.md` that packages instructions Claude Code loads on demand (via the `Skill` tool / `/<skill-name>` slash command). There is no build, lint, or test tooling; the repository's content is skill definitions in Markdown, plus the occasional helper script a skill bundles (e.g. `branch-change-gate/hooks/first-change-gate.sh`).

## Repository structure

Each skill lives in its own top-level directory named after the skill, containing at minimum a `SKILL.md`:

```
<skill-name>/SKILL.md
```

`SKILL.md` starts with YAML frontmatter (`name`, `description`) followed by the skill's instructions in Markdown. The `description` field controls when/how the skill is triggered — read it carefully, since it often encodes strict triggering rules (e.g. "manual invocation only," specific trigger phrases to match or avoid).

## Adding or editing a skill

- Create a new directory named after the skill; add `SKILL.md` with `name` and `description` frontmatter.
- Write the `description` precisely: it is the only signal Claude Code uses to decide when to auto-trigger (or, for manual-only skills, when to refuse to auto-trigger) the skill. State explicitly whether the skill is manual-only, and list exact invocation phrases if so.
- Keep instructions in the body imperative and unambiguous — this text is injected directly into a future Claude Code session's context to steer its behavior, not documentation for a human reader.
- No code to compile or tests to run — validate a new/edited skill by reading it back and checking the frontmatter is valid YAML and the description matches the intended triggering behavior described in this file.
- If a skill bundles a script, keep it executable (`chmod +x`) and exercise it by hand with sample input before committing; for a hook script, pipe it sample hook JSON and check the exit code.

## Cross-surface skills

Some skills (e.g. `frustration-recovery`) are meant to work in Claude Code, claude.ai chat, the desktop app, and Cowork. When editing one of these, keep it portable:

- Frontmatter: only `name` and `description` (the open Agent Skills format also allows `license`, `compatibility`, `metadata`, and `allowed-tools`). Claude Code-only keys such as `disable-model-invocation`, `user-invocable`, or `context` make the claude.ai upload fail with "Unexpected key(s) in SKILL.md frontmatter".
- `name`: lowercase letters, digits, and hyphens; at most 64 characters; must match the directory name; must not contain "claude" or "anthropic".
- `description`: at most 1024 characters; no angle brackets (`<` or `>`); written in the third person ("Claude", not "you").
- Body: don't assume Claude Code tools. Describe capabilities ("if you can edit files…", "if you have a memory tool…") and put surface-specific steps in clearly labeled branches. Don't use Claude Code-only syntax (`!` shell-injection lines, `$ARGUMENTS`, `${CLAUDE_*}` variables).

`subagents-mode` is Claude Code-only by design (it depends on the Agent and Task tools), and so is `branch-change-gate` (it gates changes to the git branch Claude Code works on, and its optional hook is a Claude Code `PreToolUse` hook).
