# claude-statusline

A one-line [Claude Code status line](https://docs.claude.com/en/docs/claude-code/statusline)
for [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/), packaged as a
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 2,
`kind: mixin`) in the layout of Docker's
[claude-sbx-statusline](https://github.com/docker/sbx-kits-contrib/tree/main/claude-sbx-statusline)
kit. It is the legal-modernism repository's `.claude/statusline.sh`, which that
project's `.claude/settings.json` registers for sessions in its checkout, made
portable so every sandbox gets it, whatever project is checked out there.
Compose the mixin onto the built-in `claude` agent and every session shows:

```
sbx: legal-modernism  ·  Opus 4.1  ·  legal-modernism/fix-linker  ·  session (resets 3h12m): 24% used / 36% over
```

- **sandbox** (yellow), from `SANDBOX_NAME`, which Docker Sandboxes export.
  Omitted when the variable is unset, so the script also reports correctly on a
  host installation of Claude Code.
- **model** (cyan).
- **project/branch** (magenta). The project is the name of git's main worktree,
  so a session that has entered a linked worktree still shows as
  `<project>/<branch>` and not as the worktree folder. Long branch names are
  truncated. Outside a git repository the folder name is shown alone.
- **session**, coloured green, yellow or red by how much of the 5-hour quota is
  used, with the time until it resets and how far through the window it is.

The kit ships the script to `~/.claude/statusline.sh` and registers it under
`statusLine` in `~/.claude/settings.json`, **merging** into the file so the
claude base image's other settings are preserved. Only the `statusLine` key is
written; if the file already had one, it is replaced with this kit's script
(that's the point of installing the kit), and every other key is left as-is.

## Quick start

With a local copy of this directory:

```console
sbx run claude --kit ./claude-statusline .
```

From a git repository that holds it (adjust the URL and `dir=`):

```console
sbx run claude --kit "git+https://github.com/<owner>/<repo>.git#dir=claude-statusline" .
```

`sbx kit validate ./claude-statusline/` checks the spec.

## How it works

- **`files/home/.claude/statusline.sh`** is copied to `~/.claude/statusline.sh`
  at sandbox start (`files/home/<rel>` lands at `/home/agent/<rel>`). The copy's
  mode is not guaranteed to keep the executable bit, so the install hook below
  `chmod +x`es it: without that, Claude Code silently renders no status line.
  The script receives the session JSON on stdin and prints the line.
- **The `install` hook** (run as root, once, when the sandbox is created)
  merges the `statusLine` block into `~/.claude/settings.json` with `jq`:

  ```json
  {
    "statusLine": { "type": "command", "command": "~/.claude/statusline.sh", "padding": 0 }
  }
  ```

  It creates the file if missing and leaves every other key untouched (only
  `statusLine` is set, replacing a prior one if present), then `chown`s back to
  the `agent` user exactly the paths it touched: `~/.claude`,
  `~/.claude/settings.json`, and `~/.claude/statusline.sh`. The chown is
  deliberately **not** recursive, because `~/.claude` holds runtime-managed
  content this kit doesn't own. Re-running is idempotent. The temp file is
  created inside `~/.claude` so the final `mv` is an atomic same-filesystem
  rename rather than a cross-device copy.
- **`agentInstructions`** adds a short note to the agent's context so Claude
  knows what the status line shows.
- The kit declares no `permissions.network`: the script opens no socket.
- A project's `.claude/settings.json` overrides the user-level
  `~/.claude/settings.json`, so in a sandbox on a repository that registers
  its own `statusLine` the checkout's wins. The kit is for every other sandbox.

## Requirements

The script and the install merge both use `jq`, which is present on the
`claude-code` base image. The script also uses `git`, `date`, `sed` and
`basename`, all standard on the base image.
