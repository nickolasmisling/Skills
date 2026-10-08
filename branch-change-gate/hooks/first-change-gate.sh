#!/usr/bin/env bash
# PreToolUse hook for the branch-change-gate skill.
#
# Blocks the first call in each session that would change the git branch and
# tells Claude to run the skill first. Claude then drops the change or
# re-issues the call; every later call in the session goes through. Invoking
# the skill itself also opens the gate, so a first change that Claude has
# already gated is not blocked a second time.
#
# Matcher: Edit|Write|MultiEdit|NotebookEdit|Bash|Skill|mcp__github__.*
# Needs bash and git; uses jq when installed, a sed fallback otherwise.

input=$(cat)

# A string field from the hook input, top level or under tool_input.
field() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r --arg k "$1" '(.[$k] // .tool_input[$k] // empty) | strings' 2>/dev/null
  else
    printf '%s' "$input" | sed -nE "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"(([^\"\\\\]|\\\\.)*)\".*/\1/p" | head -n 1
  fi
}

session=$(field session_id | tr -cd 'A-Za-z0-9_-')
[ -n "$session" ] || exit 0
cwd=$(field cwd)
[ -n "$cwd" ] || cwd=$PWD

state=${TMPDIR:-/tmp}/branch-change-gate
mkdir -p "$state" 2>/dev/null || exit 0

# git commands that change the branch, and in-place edits by sed or perl.
git_re='(^|[^[:alnum:]_.-])git[[:space:]]([^;&|]*[[:space:]])?(commit|push|merge|rebase|reset|revert|cherry-pick|am|apply|rm|mv)([[:space:]";|&)]|$)'
inplace_re='(^|[^[:alnum:]_.-])(sed|perl)[[:space:]]([^;&|]*[[:space:]])?-(-in-place|[[:alpha:]]*i)'

tool=$(field tool_name)
case $tool in
  Skill)
    case $(field skill) in
      branch-change-gate|*:branch-change-gate) mkdir -p "$state/$session" ;;
    esac
    exit 0
    ;;
  Edit|Write|MultiEdit|NotebookEdit)
    path=$(field file_path)
    [ -n "$path" ] || path=$(field notebook_path)
    [ -n "$path" ] || exit 0
    case $path in /*) ;; *) path=$cwd/$path ;; esac
    dir=$(dirname -- "$path")
    while [ ! -d "$dir" ]; do dir=$(dirname -- "$dir"); done
    # Only files in a work tree count: not .git internals, not gitignored files.
    [ "$(git -C "$dir" rev-parse --is-inside-work-tree 2>/dev/null)" = true ] || exit 0
    git -C "$dir" check-ignore -q -- "$path" 2>/dev/null && exit 0
    ;;
  Bash)
    git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
    # Without jq the command is still JSON-escaped: turn \n, \t, and \" into separators.
    cmd=$(field command | sed 's/\\[nt]/; /g; s/\\"/ /g')
    printf '%s\n' "$cmd" | grep -Eq -e "$git_re" -e "$inplace_re" || exit 0
    ;;
  mcp__*create_or_update_file|mcp__*push_files|mcp__*delete_file|mcp__*create_branch) ;;
  *) exit 0 ;;
esac

# mkdir is atomic: only the first change-making call in a session gets here.
mkdir "$state/$session" 2>/dev/null || exit 0

cat >&2 <<'EOF'
branch-change-gate: this would be your first change to the branch in this session, so it was blocked once and did not run.
Invoke the branch-change-gate skill and follow it before changing anything. In short: if the user's request can be fully met without touching the repository (an answer, a proposed diff, a file in your scratchpad), do that and leave the branch as it is. If the change is genuinely required, re-issue the call; the gate is open for the rest of the session.
EOF
exit 2
