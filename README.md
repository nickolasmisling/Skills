# Skills

Agent Skills for Claude. Each skill is a folder with a `SKILL.md` inside.

| Skill | What it does | Works in |
|---|---|---|
| [`frustration-recovery`](frustration-recovery/SKILL.md) | When you get irritated with Claude (swearing, ALL CAPS, "I already told you"), it stops, finds the real mistake, fixes and verifies it, replies without groveling, and saves the lesson to memory so the mistake doesn't happen again. Triggers on its own; in Claude Code you can also run `/frustration-recovery`. | Claude Code, claude.ai, desktop app, Cowork |
| [`subagents-mode`](subagents-mode/SKILL.md) | Manual-only mode that hands all tool work to subagents so the main session never hits context compaction. | Claude Code |

## Installing a skill

**Claude Code (terminal, IDE, desktop):** copy or symlink the skill folder into `~/.claude/skills/` for all projects, or `.claude/skills/` inside one project.

```sh
git clone https://github.com/nickolasmisling/Skills.git ~/src/Skills
mkdir -p ~/.claude/skills
ln -s ~/src/Skills/frustration-recovery ~/.claude/skills/frustration-recovery
```

**claude.ai, the desktop app, and Cowork:** zip the skill folder so the archive contains `frustration-recovery/SKILL.md`, then upload it in Settings → Capabilities → Skills (code execution must be turned on). A skill enabled on your claude.ai account is also available in Cowork and in Claude Code cloud sessions.

```sh
cd ~/src/Skills && zip -r frustration-recovery.zip frustration-recovery
```
