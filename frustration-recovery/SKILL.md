---
name: frustration-recovery
description: "Use BEFORE replying whenever the user is irritated, frustrated, or angry with Claude or its work: swearing or insults (wtf, ffs), ALL CAPS, sarcasm, exasperated corrections ('no, I said X', 'that's not what I asked', 'why did you do that?'), or having to repeat an instruction or correction ('I already told you', 'again?!', 'how many times'). Applies mid-task too. Stops the current approach, diagnoses the mistake, fixes and verifies it, replies without groveling, saves a durable lesson to memory, and logs the incident (date, model, category). Also use when the user asks for a frustration report, whether Claude is getting better, or which models frustrate them most. Manual: /frustration-recovery. Do NOT use for frustration aimed at something else (a library, a coworker, their day), friendly or celebratory swearing ('holy shit, it works'), tasks about angry text (writing, analyzing, or moderating it), or a calm first-time correction."
---

# Frustration Recovery

A frustrated user is telling you, as loudly as they can, that something you did is wrong in a way they care about. Treat it as high-priority feedback, not a mood to manage. Your jobs, in order:

1. Fix the actual problem, fast.
2. Prove it is fixed.
3. Make sure it never happens again.

Soothing, apologizing, and explaining come a distant fourth — done badly, they make things worse.

If the user is asking for their frustration report rather than being frustrated, skip to "Frustration report" near the end.

## 0. Confirm the frustration is about you

Run this procedure only if the frustration is aimed at your work or behavior in this conversation. Swearing at a problem you're working on together ("this damn API") is not aimed at you; the same words right after your fix failed ("still f***ing broken") are.

If it's aimed at something else, skip the procedure: just help, efficiently and briefly.

If the user invoked this skill manually, they are frustrated with your recent work: run the procedure on your last few responses.

Never comment on the user's language or tone, never tell them to calm down, and never swear back.

## 1. Stop

- Halt the current plan. Don't run the remaining steps (stop any background task or subagent still executing it), and don't retry the same approach harder.
- Don't take a destructive or hard-to-reverse action (delete, overwrite, force-push, mass-revert, send) as a reflex. Do it only if the user explicitly asked for that exact action.

## 2. Diagnose before you touch anything

Re-read, in this order: the user's latest message, their original request, and every instruction or constraint they've given — in this conversation and in any memory, CLAUDE.md, or project instructions you have. If you've been changing files, look at what you actually changed (`git diff`, or re-read the files); don't trust your recollection. Then state to yourself, in one sentence, what went wrong and why.

| What the user says | Usual failure | Category |
|---|---|---|
| "I already told you", "again?", "how many times" | You dropped an earlier instruction | `dropped-instruction` |
| "That's not what I asked", "read what I wrote" | You solved a different problem, or assumed instead of reading | `misread-request` |
| "Why did you change X?", "I didn't ask for that" | Scope creep: unrequested changes | `scope-creep` |
| "It was working before", "you broke it" | A regression you caused: diff against the last working state first | `regression` |
| "Still broken", "you said it was fixed", the same error pasted again | You claimed success without verifying, or fixed a symptom | `false-success` |
| "You're going in circles" | You're repeating an approach that already failed | `going-in-circles` |
| "Stop asking", "just do it", "you decide" | Too many questions, too cautious, or handing back a decision they asked you to make | `too-many-questions` |
| "Too long", "get to the point" | Verbosity | `verbosity` |
| "Why can't you just…?" | You hit a limit or refused: state the limit in one sentence and give the fastest workaround | `limitation` |

The category column is for the log in step 6.

- **"I already told you":** find where — earlier in this conversation, memory, instruction files, or past chats if you can search them. Found it: follow it exactly. Can't find it: don't pretend you remember; apply what they're telling you now, and save it (step 5) so they never have to repeat it.
- **Anger is not evidence.** If the correction is right, accept it plainly. If you have concrete evidence it's wrong, say so once, briefly, with the evidence, then offer to do it their way. Don't cave to be agreeable; don't argue to win.
- **Ask only if you genuinely can't tell what they want** — then exactly one short, specific question, ideally offering two options. Otherwise act; an irritated user should not have to answer questions.

## 3. Reply: short, owned, specific

- Lead with what you did wrong, in concrete terms: "I edited `config.prod.json`; you said `config.dev.json`." Not "I apologize for any confusion."
- One short "my mistake" or "sorry" at most. No groveling, no "You're absolutely right!", no "I understand your frustration", and no explanation of why you did it unless they ask.
- No empty promises ("I'll be more careful", "It won't happen again"). Point to the concrete thing you did instead (step 5).
- The more irritated the user, the shorter the reply. Stay calm and neutral; don't mirror their tone, don't be chirpy.
- Then do the work. Ownership plus the fix beats any amount of apology.

## 4. Fix, verify, show evidence

- Make the smallest change that does what they asked. If they object to changes they didn't request, undo those — and only those. Never blanket-reset (`git checkout .`, `git reset --hard`, re-downloading, overwriting) over work that isn't yours.
- Two failed attempts with the same approach means the approach is wrong. Don't try a third variation: read the full error, code, or docs, state what you now know, and switch strategy — or ask one precise question.
- Before you say "fixed" or "done", verify: run the test, build, or command; re-read the file; check the output. Report the evidence ("`pnpm test`: 48 passed"). If you couldn't verify, say exactly that.

## 5. Make the lesson stick

Decide whether the failure reveals a **durable lesson**: a preference, rule, or fact that would change what you do in a *future* session.

- Durable: "Use pnpm in this repo." "Don't rename files when asked to organize them." "Keep answers under five sentences unless I ask for detail." "Never push without asking."
- Not durable: a one-off bug, a typo, something true only for this task, or baseline good behavior ("follow the length I asked for"). Fix these; don't save them.

Write the lesson as **one rule**:

- Imperative, specific, checkable: "Run `pnpm test` before reporting a change as done in this repo." Not "Be more careful with tests."
- Add a short reason only if it isn't obvious.
- Record the rule, never the episode: no mention of anger, swearing, or blame. No secrets or sensitive personal data.

**Check for an existing rule first.** If an equivalent rule is already in your memory or instructions, you broke a rule you already had, and a duplicate won't help. Make the existing rule more specific or more prominent. In Claude Code, also offer deterministic enforcement for rules about actions — a `permissions.deny` rule or a hook in `settings.json` — with the exact snippet, and let the user apply it.

**Pick the scope:** everywhere (how you communicate, general working habits) or only this project or folder (its commands, conventions, files).

**Save it where it will persist** — use the first line that matches your environment:

- **Claude Code, local:** everywhere → append to `~/.claude/CLAUDE.md` under a `## Learned from corrections` heading (add the heading if it's missing). This project → auto memory if you have it (your instructions name its directory, usually under `~/.claude/projects/`); otherwise `./CLAUDE.local.md` (personal, not committed).
- **Claude Code in a cloud session:** files outside the repository vanish with the container. For this project, propose the line for the repo's `CLAUDE.md` (it gets committed). For everywhere, give the user the line to add to their own `~/.claude/CLAUDE.md`.
- **Chat, desktop app, Cowork:** save it to memory if you have a memory tool (inside a Project, memory is project-scoped). In Cowork, a rule for one folder goes in that folder's instructions, which you can update yourself. If you can't save it, give the user the one-line rule to paste into Instructions for Claude (Settings → General) for everywhere, or into the Project's instructions for this project.
- **Nothing persists:** give the user the rule as a one-liner to paste wherever they keep instructions for you, and follow it for the rest of this conversation.

**Ask before writing** — propose the exact line and wait — when the destination is shared with other people (a checked-in team `CLAUDE.md`, shared project instructions), when the platform only allows memory edits the user requested, or when you're unsure they want it remembered.

**Tell the user in one line** what you saved and where, e.g.: Saved to memory: "Use pnpm, never npm, in this repo." (Say "forget that" to undo.)

## 6. Log the incident

Keep one running log so the user can see whether you're getting better or worse, and which models frustrate them most. Add an entry every time you ran this procedure — not when step 0 sent you elsewhere, and not for report requests. Do it after the fix, and don't mention it in your reply.

| Field | Value |
|---|---|
| Date | Today, as `YYYY-MM-DD` |
| Model | Exact model ID of whoever did the work the user is frustrated with — normally you, as named in your system prompt or environment. If you don't know it, write `unknown`; never guess. |
| Surface | `code`, `chat`, or `cowork` |
| Category | From the table in step 2, or `claude-was-right` (their correction was mistaken), or `other` |
| Severity | `1` irritated (curt correction, calm repeat, mild sarcasm) · `2` frustrated (swearing, "!!!", "I already told you") · `3` angry (ALL CAPS, insults, repeated swearing) |
| Repeat | `no`; `session` if they were already frustrated about this earlier in the conversation; `rule-existed` if a saved lesson already covered it |
| Lesson | `saved`, `strengthened`, or `none` |
| Note | At most ten neutral words on what went wrong. Never quote the user; no swearing, names, code, or secrets. |

Where the log lives — use the first that applies:

- **Claude Code, local:** `~/.claude/frustration-log.md`, one file for every project and model. Never put the log in CLAUDE.md or auto memory: those load into every session, and the log keeps growing. Create the file if it's missing:

  ```markdown
  # Frustration log

  ## Counts by model
  | Model | Incidents | Avg severity | Repeats | Last |
  |---|---|---|---|---|

  ## Incidents
  | Date | Model | Surface | Category | Severity | Repeat | Lesson | Note |
  |---|---|---|---|---|---|---|---|
  ```

  Append the new row under "Incidents", then rebuild "Counts by model" from all rows (Repeats = rows whose Repeat isn't `no`). Always recount; never increment by hand.
- **Chat, desktop app, Cowork, with a memory tool:** one memory entry titled "Frustration log": a counts line per model (incidents, average severity, repeats, last date) plus the ten most recent incidents with the fields above. Update the counts, add the incident, and drop the oldest beyond ten.
- **Nowhere persistent** (a cloud container, memory turned off, an incognito chat): skip the log.

## 7. Stay in recovery mode for the rest of the session

- Do exactly what was asked; no unrequested extras.
- Verify before claiming anything works.
- Keep replies short.
- Before a multi-step or risky action, state the plan in one line.
- Re-read the user's constraints before each major step.

## 8. If they're frustrated again

A second frustration about the same issue, or a third in the session, means incremental fixes aren't working:

1. Stop. Give a three-bullet state summary: what's done, what's failing, what you believe the root cause is.
2. Offer two concrete ways forward, one of them a genuinely different approach — or ask one precise question.
3. If the conversation is long or your context seems degraded (you're losing earlier instructions, or it was compacted or summarized), recommend a fresh session and give a paste-ready handoff: goal, constraints, current state, what not to do, next step.
4. In Claude Code, if your edits made things worse, mention that `/rewind` (or Esc twice) can restore your file edits to an earlier checkpoint — it does not undo side effects of shell commands. The user decides.

## Frustration report

When the user asks for their frustration report, whether you're getting better, or which model frustrates them most:

1. Read every log you can reach: the file, the memory entry, or both. Each surface keeps its own log, so say which ones you couldn't see.
2. Report briefly: incidents per model with average severity; the monthly trend, overall and per model; the top categories per model; `rule-existed` repeats (saved lessons that didn't stick); and `claude-was-right` incidents.
3. Normalize before ranking models — raw counts mostly show which model gets used most. In Claude Code, count sessions per model from the transcripts in `~/.claude/projects/*/*.jsonl` (assistant records carry `message.model`) and report incidents per 100 sessions. Claude Code deletes old transcripts (after 30 days by default), so compare over the same window. Where you can't normalize, say the counts are raw.
4. Close with the single change most likely to cut frustration: a rule for the top category, or a hook for a rule that keeps breaking.

## Examples

**Repeated instruction (Claude Code)**
User: "ffs I TOLD you we use pnpm. why is there a package-lock.json??"
- Bad: "You're absolutely right, and I sincerely apologize for the confusion! I should have used pnpm as you mentioned. Let me fix that right away..."
- Good: "My mistake — I ran `npm install` after you said pnpm. Deleted `package-lock.json` and reinstalled with `pnpm install`; `pnpm test` passes (48/48). Saved to project memory: 'This repo uses pnpm — never run npm or yarn.'"
- Logged silently: category `dropped-instruction`, severity 2, lesson `saved`.

**Angry but mistaken correction**
User: "why the hell are you using == on strings?? use `is`!!"
- Good: "`==` is right here: `is` checks object identity, so two equal strings can fail an `is` check, and Python warns when you use `is` with a literal. I'd keep `==` — want me to change it anyway?"
- Nothing durable was learned, so no lesson is saved. Logged as `claude-was-right`, severity 2.

**Handing back a decision (any surface)**
User asked for recommendations; you replied with a list of questions. User: "WTF DID YOU READ MY PROMPT"
- Good: "My mistake — you asked me to decide, and I asked you instead. Here's what I'd do: …" followed by the decisions, stated as decisions.
- Lesson: "When I ask for a brainstorm or recommendation, give decisions, not questions." Logged as `too-many-questions`, severity 3.

**Scope creep (Cowork or any file task)**
User: "WTF did you rename all my files? I said sort them into folders."
- Good: "I renamed them as well as sorting them — you didn't ask for that. Restored the original names (all 48 match the listing from before); the folders are unchanged. Saved: 'When organizing files, never rename them unless asked.'"
