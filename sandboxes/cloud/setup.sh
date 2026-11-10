#!/bin/bash
# Setup script for Claude Code cloud environments (claude.ai/code).
#
# Paste this file into the environment's "Setup script" field, or have the
# field fetch it from GitHub:
#
#   curl -fsSL https://raw.githubusercontent.com/lmullen/dotfiles/main/sandboxes/cloud/setup.sh | bash
#
# The environment's GitHub connection is logged in as lmullen-agent, so
# Anthropic's GitHub proxy pushes and calls the API as that account. The
# environment variables in env.txt make lmullen-agent the commit author and
# committer too.
#
# It never fails the environment: each step reports a warning and moves on,
# so a network hiccup in one step does not block the session from starting.
#
# What it does:
#   1. Installs the latest Hugo (extended edition).
#   2. Installs ~/.claude/hooks/strip-claude-identity.sh, which removes the
#      default `Claude <noreply@anthropic.com>` git identity from every git
#      config file that carries it (system, global, XDG, local), and runs it.
#   3. Registers that script as a SessionStart hook, because the cloud writes
#      the identity after this script runs.
#   4. Appends the lmullen-agent attribution rules to ~/.claude/CLAUDE.md.

set -u

warn() { echo "setup.sh: WARNING: $*" >&2; }
info() { echo "setup.sh: $*"; }

if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
  SUDO="sudo -n"
else
  SUDO=""
fi

HOOK="$HOME/.claude/hooks/strip-claude-identity.sh"

# ---------------------------------------------------------------------------
# 1. Hugo (extended), latest release
# ---------------------------------------------------------------------------
install_hugo() {
  local version="" arch tmp bindir

  # The "latest" release page redirects to .../tag/vX.Y.Z; reading the
  # redirect avoids the GitHub API.
  version=$(curl -fsSL -o /dev/null -w '%{url_effective}' \
    https://github.com/gohugoio/hugo/releases/latest 2>/dev/null | sed -n 's#.*/tag/v##p')
  if [ -z "$version" ]; then
    version=$(curl -fsSL https://api.github.com/repos/gohugoio/hugo/releases/latest 2>/dev/null \
      | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p' | head -n1)
  fi
  if [ -z "$version" ]; then
    warn "could not look up the latest Hugo version; skipping Hugo"
    return 1
  fi

  case "$(uname -m)" in
    x86_64 | amd64) arch=amd64 ;;
    aarch64 | arm64) arch=arm64 ;;
    *) warn "unsupported architecture $(uname -m); skipping Hugo"; return 1 ;;
  esac

  tmp=$(mktemp -d)
  if ! curl -fsSL -o "$tmp/hugo.tar.gz" \
    "https://github.com/gohugoio/hugo/releases/download/v${version}/hugo_extended_${version}_linux-${arch}.tar.gz"; then
    warn "could not download Hugo ${version}; skipping Hugo"
    rm -rf "$tmp"
    return 1
  fi
  tar -xzf "$tmp/hugo.tar.gz" -C "$tmp" hugo || { warn "could not unpack Hugo"; rm -rf "$tmp"; return 1; }

  # Prefer a system-wide install; fall back to ~/.local/bin without root.
  bindir=/usr/local/bin
  if ! { [ "$(id -u)" -eq 0 ] || [ -n "$SUDO" ]; } || ! $SUDO install -m 0755 "$tmp/hugo" "$bindir/hugo"; then
    bindir="$HOME/.local/bin"
    mkdir -p "$bindir" && install -m 0755 "$tmp/hugo" "$bindir/hugo" \
      || { warn "could not install Hugo"; rm -rf "$tmp"; return 1; }
    case ":$PATH:" in *":$bindir:"*) ;; *) warn "$bindir is not on PATH; add it to use hugo" ;; esac
  fi
  rm -rf "$tmp"
  info "installed $("$bindir/hugo" version) to $bindir"
}

# ---------------------------------------------------------------------------
# 2. Script that removes the default Claude git identity (only that identity)
# ---------------------------------------------------------------------------
install_strip_script() {
  mkdir -p "$(dirname "$HOOK")"
  cat >"$HOOK" <<'EOF'
#!/bin/bash
# Remove `Claude <noreply@anthropic.com>` from every git config file that
# carries it: system, global (~/.gitconfig or $GIT_CONFIG_GLOBAL), XDG
# (~/.config/git/config) and the current repository. Other identities are
# left alone. Commits are attributed through GIT_AUTHOR_* / GIT_COMMITTER_*.
command -v git >/dev/null 2>&1 || exit 0
[ "$(id -u)" -eq 0 ] && SUDO="" || { sudo -n true 2>/dev/null && SUDO="sudo -n" || SUDO=""; }

git config --show-origin --get-all user.email 2>/dev/null |
  awk -F'\t' '$2 == "noreply@anthropic.com" && $1 ~ /^file:/ { sub(/^file:/, "", $1); print $1 }' |
  sort -u |
  while IFS= read -r f; do
    [ -e "$f" ] || continue
    run=""; [ -w "$f" ] || run="$SUDO"
    $run git config --file "$f" --unset-all user.email 2>/dev/null
    [ "$($run git config --file "$f" --get user.name 2>/dev/null)" = "Claude" ] &&
      $run git config --file "$f" --unset-all user.name 2>/dev/null
    if git config --file "$f" --get user.email >/dev/null 2>&1; then
      echo "strip-claude-identity: could not edit $f" >&2
    else
      echo "strip-claude-identity: removed Claude identity from $f" >&2
    fi
  done
exit 0
EOF
  chmod 0755 "$HOOK"
  "$HOOK"
}

# ---------------------------------------------------------------------------
# 3. SessionStart hook that runs the script in every session
# ---------------------------------------------------------------------------
add_session_hook() {
  command -v python3 >/dev/null 2>&1 || { warn "python3 not found; skipping SessionStart hook"; return 1; }
  HOOK="$HOOK" python3 - <<'PY'
import json, os, sys
p = os.path.expanduser("~/.claude/settings.json")
hook = os.environ["HOOK"]
try:
    s = json.load(open(p)) if os.path.exists(p) else {}
except Exception as e:
    print(f"setup.sh: WARNING: could not parse {p}: {e}; skipping hook", file=sys.stderr)
    sys.exit(0)
starts = s.setdefault("hooks", {}).setdefault("SessionStart", [])
# Drop entries from earlier versions of this script, then add the current one.
starts[:] = [e for e in starts
             if not any("noreply@anthropic.com" in h.get("command", "") or hook in h.get("command", "")
                        for h in e.get("hooks", []))]
starts.append({"hooks": [{"type": "command", "command": hook}]})
with open(p, "w") as f:
    json.dump(s, f, indent=2)
print(f"setup.sh: SessionStart hook in {p} runs {hook}")
PY
}

# ---------------------------------------------------------------------------
# 4. Attribution rules for Claude
# ---------------------------------------------------------------------------
add_claude_md() {
  local f="$HOME/.claude/CLAUDE.md"
  mkdir -p "$HOME/.claude"
  grep -q '^## Attribution (lmullen-agent)' "$f" 2>/dev/null && return 0
  cat >>"$f" <<'EOF'

## Attribution (lmullen-agent)

Work you do here is attributed to the GitHub machine account `lmullen-agent`.

- **Commits:** GIT_AUTHOR_* and GIT_COMMITTER_* environment variables make
  `lmullen-agent <lincoln+agent@lincolnmullen.com>` both author and committer,
  so commit without `--author`. Never set user.name or user.email in git config.
  A stale `Claude <noreply@anthropic.com>` identity in any git config file is
  not the user's: remove it (`~/.claude/hooks/strip-claude-identity.sh` does
  that). If `git var GIT_AUTHOR_IDENT` then names anyone but lmullen-agent,
  stop and tell the user rather than committing.
- **GitHub:** pushes and `gh` go through Anthropic's GitHub proxy, which is
  normally logged in as lmullen-agent. If `gh api user --jq .login` names
  another account, push and post anyway (the commit author is what matters),
  and say in your reply which account GitHub attributed the push and PR to.
  The proxy rejects GraphQL, so `gh pr create`, `gh pr view` and `gh issue` fail;
  use the REST API through `gh api` instead (for example
  `gh api repos/OWNER/REPO/pulls -f title=... -f head=BRANCH -f base=main -f body=...`).
EOF
  info "added attribution rules to $f"
}

install_hugo         || true
install_strip_script || true
add_session_hook     || true
add_claude_md        || true

exit 0
