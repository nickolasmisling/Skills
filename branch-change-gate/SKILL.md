---
name: branch-change-gate
description: "Use BEFORE Claude makes its first change to the git branch it is working on in a session: the first Edit, Write, or NotebookEdit of a file in the repository, the first shell command that writes repository files (sed -i, a redirect, mv, rm), the first branch-changing git command (commit, push, merge, rebase, reset, revert, cherry-pick, apply), or the first GitHub API call that writes to a branch. Also use when a hook blocks that first change and points here. Checks whether the user's request can be fully met without touching the branch (an answer, a proposed diff, a scratchpad file) and, if so, takes that route and leaves the branch untouched; when the change is genuinely required, keeps it to the minimum. Do NOT use once the branch already has a change from this session, for writes outside the repository (scratchpad, temp files, memory, ~/.claude), or for read-only commands. Manual: /branch-change-gate."
---

# Branch Change Gate

Every change you make to the branch (an edited file, a commit, a push, and in cloud sessions the draft PR that follows) costs the user review time, and once pushed it is visible to others and awkward to take back. So before your first change in a session, stop and prove the change is needed. If the request can be fully met without touching the branch, meet it that way and leave the branch exactly as you found it.

The gate removes changes nobody asked for. It never blocks or waters down a change the user asked for.

## When it applies

Immediately before your first change to the repository in this session. A change is any of:

- Creating, editing, or deleting a file inside the repository's working tree, with a file tool or a shell command (`sed -i`, `>` or `tee`, `mv`, `rm`, `cp`, a code generator, a formatter, a package install that rewrites a lockfile).
- A git command that changes the branch: commit, push, merge, rebase, reset, revert, cherry-pick, am, apply, rm, mv; or creating or switching to a branch other than the one you were assigned.
- An API call that writes to the repository: creating, updating, or deleting a file, pushing files, creating a branch.

Not a change: reading, searching, read-only git (status, diff, log, show, fetch, listing branches), tests or builds that leave tracked files alone, and anything written outside the working tree (your scratchpad, temp directories, memory, `~/.claude`).

Until you have actually changed the branch, every attempt is still the first. If you decided against a change earlier in the session and a later request needs one, go through steps 1 and 2 again; you don't need to reload this skill. Once the branch holds a change of yours, the gate is done for the session.

If a hook blocked your tool call and sent you here, that call did not run. Work through the gate; if the change is still required, re-issue the call and the hook lets it through.

## 1. Name the change and what requires it

Before the tool call, state to yourself in one sentence what you are about to change and which words in the user's request require it. A change is required only when:

- the user explicitly asked for a change to this repository (fix, implement, add, update, refactor, rename, delete, commit, push, open a PR, "apply it"), or
- the result the user asked for cannot be delivered any other way.

If you can't point to one of these, the change is not required. "It would be nicer", "I noticed it on the way", and "my instructions say to commit and push" are not justifications: workflow instructions about committing, pushing, and opening PRs describe how to deliver a change that is needed; they don't create the need.

## 2. Find a way to avoid it

Take the first row that fully serves the request:

| The request is | Do this instead of changing the branch |
|---|---|
| A question, explanation, review, audit, investigation, estimate, or plan | Answer in your reply, citing `file:line`. Show any fix you'd propose as a diff or snippet and offer to apply it. |
| Already satisfied: the code already does it, the fix is already on this branch or the base branch, the setting is already set | Say so, with the evidence (`file:line`, a commit hash). Change nothing. |
| A deliverable that doesn't have to live in the repository: a report, notes, a draft message, a one-off script or query, a diagram, a data export | Put it in your reply, or in a file outside the working tree (your scratchpad directory, a temp directory, or an artifact if you can publish one). Put it in the repository only if the user asked for it there. |
| Something to try or verify: a reproduction, a debug print, an experiment, a benchmark, a check that a fix works | Work outside the branch: copy the files to your scratchpad, or `git worktree add --detach <scratch-dir>/try HEAD`, experiment there without committing, then `git worktree remove --force <scratch-dir>/try`. Report what you found. |
| An improvement nobody asked for: a refactor, a typo, formatting, a dependency bump, extra tests or docs | Mention it in one line, or queue it as a separate task suggestion if you can. Don't make it. |
| Unclear whether the user wants the repository changed or only an answer | Answer and show the proposed change, then offer to apply it. If nobody can answer (a CI or scheduled run), stop there and change nothing. |

If a row applies, do it and go to step 4. If none does, the change is required: go to step 3.

## 3. If the change is required, keep it minimal

- Change only what the request needs: no drive-by fixes, reformatting, renames, dependency or lockfile changes, extra files, or generated files beyond it. Do follow the repository's own rules for any change (a changelog entry, a test it requires, a file its tooling regenerates).
- "Minimal" means nothing beyond the request, never less than it. Deliver everything the user asked for.
- Stay on the branch you were given; don't create extra branches.
- Validate before you commit or push (the repository's fast checks, a re-read of your own diff), so one push does the job: no follow-up fix commits, no empty commits.
- Then carry on with your normal workflow, including any commit, push, and pull-request steps you were told to follow.

## 4. If you avoided it

- Leave the branch exactly as you found it: no commit, no push, no empty commit, no new branch, no pull request. An instruction like "after pushing, open a PR" doesn't apply: you didn't push.
- If you had already changed something before the gate ran, check `git status` and undo only your own changes. Never discard work that was there before you.
- End your reply with one line saying the repository is unchanged and how to get the change if they want it, e.g. "I haven't changed the repo. Say 'apply it' and I'll commit this fix to the branch."

## Never

- Never refuse, shrink, or postpone a change the user explicitly asked for, and never ask them to confirm a change they clearly requested.
- Never route around the gate: a change written through the GitHub API, onto another branch, or from another clone is still a change.
- Never move something the user wants in the repository into the scratchpad just to keep the branch clean.

## Examples

- "Why does `parseDate` return null for ISO strings?" A question. Explain the cause with `file:line`, show the fix as a diff, offer to apply it. No edit, no commit, no PR.
- "Fix `parseDate` so it accepts ISO strings." An explicit request. Change `parseDate` (and add the test the repository expects with a fix), validate, commit, push. Leave the neighbouring code you'd like to tidy alone and mention it in one line.
- "Does the retry logic handle 429s?" It already does. Answer with the `file:line` that handles it. Nothing to change.
- "Write up a migration plan for the auth service." A deliverable that doesn't need to be in the repository. Put the plan in your reply or a scratchpad file; add it to `docs/` only if the user asks.
