#!/bin/bash
# Setup script for Claude Code cloud environments (claude.ai/code).
#
# Paste this file into the environment's "Setup script" field, or have the
# field fetch it from GitHub:
#
#   curl -fsSL https://raw.githubusercontent.com/lmullen/dotfiles/main/sandboxes/cloud/setup.sh | bash
#
# See README.md in this directory for the environment variables (env.txt)
# and allowed domains (allowed-domains.txt) that go with it.
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
#   1. Installs mise (https://mise.jdx.dev), pinned and checksum-verified, at
#      /usr/local/bin/mise. Toolchains come from each project's own mise
#      config, as in the Docker sandboxes; nothing here names a tool.
#   2. Puts mise's shims first on PATH at the end of ~/.bashrc, which is where
#      the PATH of Claude's Bash tool comes from. A shim picks the version the
#      current directory's mise config pins, and installs it if missing.
#   3. Installs ~/.claude/hooks/mise-install.sh, which runs `mise install` in
#      the session's project, and runs it here for the checkout being set up.
#   4. Installs ~/.claude/hooks/strip-claude-identity.sh, which removes the
#      default `Claude <noreply@anthropic.com>` git identity from every git
#      config file that carries it (system, global, XDG, local), and runs it.
#   5. Registers both scripts as SessionStart hooks: the cloud writes the git
#      identity after this script runs, and a session may be on a different
#      repository, or a newer pin, than the cached setup saw.
#   6. Appends the lmullen-agent attribution rules to ~/.claude/CLAUDE.md.
#   7. Appends instructions for working with mise to ~/.claude/CLAUDE.md.

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
MISE_HOOK="$HOME/.claude/hooks/mise-install.sh"

# ---------------------------------------------------------------------------
# 1. mise, pinned and checksum-verified
# ---------------------------------------------------------------------------
# The same release and digests as Docker's official mise kit
# (docker/sbx-kits-contrib, mise/mise.dockerfile), so the cloud and the Docker
# sandboxes run the same mise. To bump: change the version and both digests
# together, from the release's SHASUMS256.txt.
MISE_VERSION=2026.5.2
install_mise() {
  local slug sha256 tmp bindir
  case "$(uname -m)" in
    x86_64 | amd64)
      slug=x64
      sha256=cdf616b3d8554bece574cb1a5c0f19cc0f551dffbecf66037df1cc06569a42ef ;;
    aarch64 | arm64)
      slug=arm64
      sha256=a746ad85fe8a7b62a6c72939da5fb4231074fd16c482f6334a598bd92926f41e ;;
    *) warn "unsupported architecture $(uname -m); skipping mise"; return 1 ;;
  esac

  tmp=$(mktemp -d)
  if ! curl -fsSL -o "$tmp/mise.tgz" \
    "https://github.com/jdx/mise/releases/download/v${MISE_VERSION}/mise-v${MISE_VERSION}-linux-${slug}.tar.gz"; then
    warn "could not download mise ${MISE_VERSION}; skipping mise"
    rm -rf "$tmp"; return 1
  fi
  if ! echo "${sha256}  $tmp/mise.tgz" | sha256sum -c - >/dev/null; then
    warn "mise ${MISE_VERSION} failed its checksum; skipping mise"
    rm -rf "$tmp"; return 1
  fi
  tar -xzf "$tmp/mise.tgz" -C "$tmp" mise/bin/mise || { warn "could not unpack mise"; rm -rf "$tmp"; return 1; }

  # Prefer a system-wide install; fall back to ~/.local/bin without root.
  bindir=/usr/local/bin
  if ! { [ "$(id -u)" -eq 0 ] || [ -n "$SUDO" ]; } || ! $SUDO install -m 0755 "$tmp/mise/bin/mise" "$bindir/mise"; then
    bindir="$HOME/.local/bin"
    mkdir -p "$bindir" && install -m 0755 "$tmp/mise/bin/mise" "$bindir/mise" \
      || { warn "could not install mise"; rm -rf "$tmp"; return 1; }
  fi
  rm -rf "$tmp"
  export PATH="$bindir:$PATH"
  info "installed $(mise --version 2>/dev/null | head -n1) to $bindir"
}

# ---------------------------------------------------------------------------
# 2. Shims first on PATH for Claude's Bash tool
# ---------------------------------------------------------------------------
# Claude's Bash tool replays the PATH of a snapshot taken from ~/.bashrc when
# the session starts, so that is where the shims go, at the end so nothing
# later puts other tool directories ahead of them. The snapshot keeps no other
# variables, so MISE_TRUSTED_CONFIG_PATHS comes from env.txt for the session;
# it is set here too for interactive and login shells.
configure_shells() {
  local rc="$HOME/.bashrc"
  grep -qF '# mise (dotfiles cloud setup)' "$rc" 2>/dev/null && return 0
  cat >>"$rc" <<'EOF'

# mise (dotfiles cloud setup): shims first on PATH, so tools resolve to the
# versions the current directory's mise config pins. Trust project configs.
export MISE_TRUSTED_CONFIG_PATHS="/"
export PATH="$HOME/.local/share/mise/shims:$PATH"
EOF
  info "put mise shims on PATH in $rc"
}

# ---------------------------------------------------------------------------
# 3. Script that installs the project's mise tools
# ---------------------------------------------------------------------------
install_mise_hook() {
  mkdir -p "$(dirname "$MISE_HOOK")"
  cat >"$MISE_HOOK" <<'EOF'
#!/bin/bash
# Install the tools the project's mise config pins. Run as a SessionStart hook
# with CLAUDE_PROJECT_DIR set, or by hand from a checkout. Quiet on success;
# on failure, what it prints reaches Claude as session context.
command -v mise >/dev/null 2>&1 || exit 0
dir="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$dir" 2>/dev/null || exit 0
export MISE_TRUSTED_CONFIG_PATHS=/
if ! out=$(mise install 2>&1); then
  echo "mise install failed in $dir, so tools its mise config pins may be missing. Last lines:"
  printf '%s\n' "$out" | tail -n 5
fi
exit 0
EOF
  chmod 0755 "$MISE_HOOK"
  # The repository is cloned before this script runs. If this is its
  # checkout, install now so the tools land in the cached environment.
  "$MISE_HOOK"
}

# ---------------------------------------------------------------------------
# 4. Script that removes the default Claude git identity (only that identity)
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
# 5. SessionStart hooks that run both scripts in every session
# ---------------------------------------------------------------------------
add_session_hooks() {
  command -v python3 >/dev/null 2>&1 || { warn "python3 not found; skipping SessionStart hooks"; return 1; }
  HOOK="$HOOK" MISE_HOOK="$MISE_HOOK" python3 - <<'PY'
import json, os, sys
p = os.path.expanduser("~/.claude/settings.json")
hooks = [
    {"type": "command", "command": os.environ["HOOK"]},
    # Downloads toolchains on a cold session; mise skips what is installed.
    {"type": "command", "command": os.environ["MISE_HOOK"], "timeout": 300},
]
try:
    s = json.load(open(p)) if os.path.exists(p) else {}
except Exception as e:
    print(f"setup.sh: WARNING: could not parse {p}: {e}; skipping hooks", file=sys.stderr)
    sys.exit(0)
starts = s.setdefault("hooks", {}).setdefault("SessionStart", [])
# Drop entries from earlier versions of this script, then add the current ones.
ours = [h["command"] for h in hooks]
starts[:] = [e for e in starts
             if not any("noreply@anthropic.com" in h.get("command", "") or h.get("command") in ours
                        for h in e.get("hooks", []))]
starts.append({"hooks": hooks})
os.makedirs(os.path.dirname(p), exist_ok=True)
with open(p, "w") as f:
    json.dump(s, f, indent=2)
print(f"setup.sh: SessionStart hooks in {p} run {', '.join(ours)}")
PY
}

# ---------------------------------------------------------------------------
# 6. Attribution rules for Claude
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

# ---------------------------------------------------------------------------
# 7. Tool instructions for Claude
# ---------------------------------------------------------------------------
add_claude_md_tools() {
  local f="$HOME/.claude/CLAUDE.md"
  mkdir -p "$HOME/.claude"
  grep -q '^## Tools (mise)' "$f" 2>/dev/null && return 0
  cat >>"$f" <<'EOF'

## Tools (mise)

Toolchains a project pins (Go, Node, Hugo, ...) come from mise, configured in
the project's `mise.toml` / `.mise.toml` and locked in its `mise.lock`. mise's
shims are first on PATH and pick the pinned version for the current directory.
If a pinned tool is missing, run `mise install` in the project. To add or
change a tool, use `mise use <tool>@<version>` in the project and then
`mise lock --platform linux-x64,linux-arm64,macos-arm64`: without a lockfile
entry, mise has to look GitHub-hosted releases up through the GitHub API,
which the GitHub proxy refuses for repositories not attached to the session.
EOF
  info "added mise rules to $f"
}

install_mise         || true
configure_shells     || true
install_mise_hook    || true
install_strip_script || true
add_session_hooks    || true
add_claude_md        || true
add_claude_md_tools  || true

exit 0
