# Skills

Agent Skills for Claude. Each skill is a folder with a `SKILL.md` inside.

| Skill | What it does | Works in |
|---|---|---|
| [`frustration-recovery`](frustration-recovery/SKILL.md) | When you get irritated with Claude (swearing, ALL CAPS, "I already told you"), it stops, finds the real mistake, fixes and verifies it, replies without groveling, and saves the lesson to memory so the mistake doesn't happen again. It also logs every incident, so you can ask which models frustrate you most and whether things are getting better. Triggers on its own; in Claude Code you can also run `/frustration-recovery`. | Claude Code, Chat, Cowork |
| [`subagents-mode`](subagents-mode/SKILL.md) | Manual-only mode that hands all tool work to subagents so the main session never hits context compaction. | Claude Code |

## Installing a skill

**Claude Code (terminal, IDE, desktop):** copy or symlink the skill folder into `~/.claude/skills/` for all projects, or `.claude/skills/` inside one project.

```sh
git clone https://github.com/nickolasmisling/Skills.git ~/src/Skills
mkdir -p ~/.claude/skills
ln -s ~/src/Skills/frustration-recovery ~/.claude/skills/frustration-recovery
```

**Chat (claude.ai and the desktop app) and Cowork:** zip the skill folder so the archive contains `frustration-recovery/SKILL.md`, then upload it: Customize → Skills → "+" → Create skill → Upload a skill. Skills need "Code execution and file creation" turned on (Settings → Capabilities; on Team and Enterprise plans an owner turns it on). Cowork and Claude Code cloud sessions use the skills enabled on your claude.ai account; Cowork ignores `~/.claude/skills`.

```sh
cd ~/src/Skills && zip -r frustration-recovery.zip frustration-recovery
```

## Frustration log

`frustration-recovery` records each incident: date, model, surface, what went wrong, how angry, and whether a saved lesson had already covered it. It never records what you said.

- **Claude Code:** `~/.claude/frustration-log.md`, one file for all projects and models. Cloud sessions can't keep it, because their container is discarded.
- **Chat and Cowork:** a memory entry named "Frustration log" with per-model counts and the ten latest incidents. It needs memory turned on.

Ask "show my frustration report" or "which model frustrates me most?" for a summary. Raw counts mostly reflect which model you use most. In Claude Code, the report divides incidents by the number of sessions each model ran, using your local transcripts.
