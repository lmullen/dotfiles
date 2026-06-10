# Claude Code status line + notification setup

Saved reference for the custom status line and related config.

Status line renders:

```
Opus 4.8  ·  legal-modernism/main  ·  session (resets 2h0m): 1% used / 60% over
```

- **Model** — `model.display_name`
- **Project root / git branch** — basename of `workspace.project_dir` + current branch
  (short SHA if detached, folder name only if not a git repo; branch truncated to 25 chars)
- **Session usage** — 5-hour rate-limit: `% used`, `% over` (elapsed time in the window),
  and time until reset. Colored green / yellow / red at 70% / 90% used.

---

## 1. Status line script

Save as `~/.claude/statusline.sh` and `chmod +x ~/.claude/statusline.sh`.
Requires `jq`.

```bash
#!/bin/bash
# Claude Code status line: model | project/branch | 5-hour session usage
# Reads the status-line JSON object from stdin.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "unknown"')
proj_dir=$(printf '%s' "$input" | jq -r '.workspace.project_dir // .cwd // empty')
usage=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
resets_at=$(printf '%s' "$input" | jq -r '
  .rate_limits.five_hour.resets_at
  // .rate_limits.five_hour.reset_at
  // .rate_limits.five_hour.resetsAt
  // empty')

# ANSI colors
cyan=$'\033[36m'
magenta=$'\033[35m'
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

# --- Project root + git branch -------------------------------------------
proj_segment=""
if [ -n "$proj_dir" ]; then
  proj_name=$(basename "$proj_dir")
  branch=$(git -C "$proj_dir" branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$proj_dir" rev-parse --short HEAD 2>/dev/null)
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

printf "%s%s%s  ·  %b%b" "$cyan" "$model" "$reset" "$proj_segment" "$session_segment"
```

---

## 2. settings.json

In `~/.claude/settings.json`, the relevant keys:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0
  },
  "agentPushNotifEnabled": true,
  "inputNeededNotifEnabled": true
}
```

- `statusLine` — registers the script above.
- `agentPushNotifEnabled` / `inputNeededNotifEnabled` — Claude Code's built-in
  desktop/mobile notifications (fire when a task finishes or input is needed, while
  the terminal is unfocused). These route through the harness, so they work even from
  inside a sandbox — unlike shell-based approaches (`afplay`, terminal BEL / OSC escape
  sequences), which don't reach the host.

---

## 3. macOS notification settings (host-side, not in any config file)

For banners + sound (vs. silent Notification-Center-only):
**System Settings → Notifications →** *(the app shown on the notification — usually the
terminal app, sometimes "Script Editor")*:

- Alert style: **Banners** or **Alerts** (not None)
- **Play sound for notifications**: On
- Make sure no **Focus / Do Not Disturb** mode is suppressing them.

---

## Notes / knobs

- `MAX_BRANCH=25` — branch-name truncation length.
- `WINDOW=18000` — session window length in seconds (5 hours).
- Usage color thresholds: 70% (yellow), 90% (red).
- Data source: the JSON object Claude Code pipes to the status-line command on stdin.
  `rate_limits.five_hour` is generally only populated on Pro/Max plans; the script
  degrades to `session: n/a` if absent.
