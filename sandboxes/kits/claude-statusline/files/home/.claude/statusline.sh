#!/bin/bash
# Claude Code status line: [sandbox ·] model · project/branch · 5-hour session usage
# Reads the status-line JSON object from stdin.
#
# This is the status line kept in the legal-modernism repository at
# .claude/statusline.sh, packaged as a Docker Sandbox kit (see the README.md two
# directories up) so it can be used in any sandbox, whatever project is checked
# out there. The kit copies files/home/<rel> to /home/agent/<rel>.
#
# Sandbox: when SANDBOX_NAME is set (Docker Sandboxes export it), the line opens
# with the sandbox's name, so sessions in different sandboxes can be told apart.
# Without it the segment is omitted, so the script also reports correctly on a
# host installation of Claude Code.
#
# Git worktrees: a session that has entered a worktree (.claude/worktrees/<name>)
# reports the worktree as workspace.current_dir, while workspace.project_dir stays
# the directory Claude was launched from. So the branch is read from current_dir
# (the checkout actually being edited), and the project name is taken from git's
# main worktree, so a worktree shows as "<project>/<branch>" rather than
# "<worktree-folder>/<main-checkout-branch>".

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "unknown"')
proj_dir=$(printf '%s' "$input" | jq -r '.workspace.project_dir // .cwd // empty')
cur_dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // .workspace.project_dir // empty')
usage=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
resets_at=$(printf '%s' "$input" | jq -r '
  .rate_limits.five_hour.resets_at
  // .rate_limits.five_hour.reset_at
  // .rate_limits.five_hour.resetsAt
  // empty')

# ANSI colors
cyan=$'\033[36m'
magenta=$'\033[35m'
yellow=$'\033[33m'
gray=$'\033[90m'
reset=$'\033[0m'

# Resolve a reset value to epoch seconds. Claude Code sends a Unix epoch
# integer; also tolerate an ISO-8601 string (GNU date, then BSD date fallback).
to_epoch() {
  case "$1" in
    ''|*[!0-9]*)
      date -d "$1" +%s 2>/dev/null && return
      date -j -f "%Y-%m-%dT%H:%M:%S%z" "${1/Z/+0000}" +%s 2>/dev/null
      ;;
    *) printf '%s' "$1" ;;   # already an epoch integer
  esac
}

WINDOW=18000  # five hours in seconds

# --- Sandbox name --------------------------------------------------------
sandbox_segment=""
if [ -n "$SANDBOX_NAME" ]; then
  sandbox_segment="${yellow}sbx: ${SANDBOX_NAME}${reset}  ·  "
fi

# --- Project root + git branch -------------------------------------------
proj_segment=""
[ -z "$cur_dir" ] && cur_dir=$proj_dir
if [ -n "$cur_dir" ] || [ -n "$proj_dir" ]; then
  # Project name: the main worktree's directory, which is the same whether the
  # session is in the main checkout or in a linked worktree. `git worktree list`
  # always prints the main worktree first. Fall back to the folder name when
  # the directory is not a git repo.
  main_root=$(git -C "$cur_dir" worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')
  if [ -n "$main_root" ]; then
    proj_name=$(basename "$main_root")
  else
    proj_name=$(basename "${proj_dir:-$cur_dir}")
  fi

  # Branch of the checkout the session is actually working in.
  branch=$(git -C "$cur_dir" branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cur_dir" rev-parse --short HEAD 2>/dev/null)
  # Truncate long branch names with an ellipsis.
  MAX_BRANCH=25
  if [ "${#branch}" -gt "$MAX_BRANCH" ]; then
    branch="${branch:0:$((MAX_BRANCH - 1))}…"
  fi
  if [ -n "$branch" ]; then
    proj_segment="${magenta}${proj_name}/${branch}${reset}  ·  "
  else
    proj_segment="${magenta}${proj_name}${reset}  ·  "
  fi
fi

# --- Session usage -------------------------------------------------------
if [ -n "$usage" ]; then
  pct_used=$(printf '%.0f' "$usage")

  # Color the whole segment by how much of the quota is consumed.
  if   [ "$pct_used" -ge 90 ]; then col=$'\033[31m'   # red
  elif [ "$pct_used" -ge 70 ]; then col=$'\033[33m'   # yellow
  else                              col=$'\033[32m'   # green
  fi

  resets_prefix=""
  over_suffix=""
  if [ -n "$resets_at" ]; then
    reset_epoch=$(to_epoch "$resets_at")
    if [ -n "$reset_epoch" ]; then
      now=$(date +%s)
      left=$(( reset_epoch - now ))
      [ "$left" -lt 0 ] && left=0
      [ "$left" -gt "$WINDOW" ] && left=$WINDOW
      h=$(( left / 3600 ))
      m=$(( (left % 3600) / 60 ))
      resets_prefix=" (resets ${h}h${m}m)"
      pct_over=$(( (WINDOW - left) * 100 / WINDOW ))
      over_suffix=" / ${pct_over}% over"
    fi
  fi

  session_segment="${col}session${resets_prefix}: ${pct_used}% used${over_suffix}${reset}"
else
  session_segment="${gray}session: n/a${reset}"
fi

printf "%b%s%s%s  ·  %b%b" "$sandbox_segment" "$cyan" "$model" "$reset" "$proj_segment" "$session_segment"
