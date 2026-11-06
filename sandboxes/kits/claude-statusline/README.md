# claude-statusline

A one-line [Claude Code status line](https://docs.claude.com/en/docs/claude-code/statusline)
for [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/), packaged as a
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 3,
`kind: mixin`) in the layout of Docker's
[claude-sbx-statusline](https://github.com/docker/sbx-kits-contrib/tree/v3/claude-sbx-statusline)
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

The kit ships the script as `/usr/local/bin/claude-statusline` and registers it
under `statusLine` in `~/.claude/settings.json`, **merging** into the file so
the claude base image's other settings are preserved. Only the `statusLine` key
is written; if the file already had one, it is replaced with this kit's script
(that's the point of installing the kit), and every other key is left as-is.

```text
claude-statusline/
├── claude-statusline.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── claude-statusline.dockerfile    # the overlay recipe, paired by filename stem
├── claude-statusline-context.md    # the agent-context body
├── files/statusline.sh             # the script the recipe COPYs in
└── README.md
```

## Quick start

With a local copy of this directory:

```console
sbx run claude --kit ./claude-statusline .
```

From a git repository that holds it (adjust the URL and `dir=`):

```console
sbx run claude --kit "git+https://github.com/<owner>/<repo>.git#dir=claude-statusline" .
```

`sbx kit inspect ./claude-statusline` reads back what the kit resolves to.
(`sbx kit validate` does not accept v3 source kits.) To check the descriptor
and recipe build without `sbx`, from inside this directory:

```console
docker buildx build . -f claude-statusline.yaml --output type=cacheonly
```

## How it works

- **`claude-statusline.dockerfile`** is a `FROM scratch` overlay that copies
  `files/statusline.sh` to `/usr/local/bin/claude-statusline` with mode 0755.
  It lands outside the agent's home on purpose: an overlay that shipped
  `/home/agent/.claude/...` would have to reproduce the ownership of every
  parent directory, and a volume mounted over `/home/agent` would hide it.
  Without the executable bit Claude Code silently renders no status line,
  which is why the mode is set at build time. The script receives the session
  JSON on stdin and prints the line.
- **The `install` hook** (a `lifecycle@1` hook, run as root when the sandbox is
  created) merges the `statusLine` block into `~/.claude/settings.json` with
  `jq`:

  ```json
  {
    "statusLine": { "type": "command", "command": "/usr/local/bin/claude-statusline", "padding": 0 }
  }
  ```

  It creates the file if missing and leaves every other key untouched (only
  `statusLine` is set, replacing a prior one if present), then `chown`s back to
  the `agent` user exactly the paths it touched: `~/.claude` and
  `~/.claude/settings.json`. The chown is deliberately **not** recursive,
  because `~/.claude` holds runtime-managed content this kit doesn't own.
  Re-running is idempotent. The temp file is created inside `~/.claude` so the
  final `mv` is an atomic same-filesystem rename rather than a cross-device
  copy.
- **`agent-context@1`** adds a short note (`claude-statusline-context.md`) to
  the agent's context so Claude knows what the status line shows.
- The kit declares no `network-policy@1`: the script opens no socket.
- A project's `.claude/settings.json` overrides the user-level
  `~/.claude/settings.json`, so in a sandbox on a repository that registers
  its own `statusLine` the checkout's wins. The kit is for every other sandbox.

## Requirements

The kit `requires: ["claude", "deb/jq"]`: the install hook runs `jq`, and both
are provided by Docker's `claude` workload. The script also uses `git`, `date`,
`sed` and `basename`, all standard on the base image.

Kit v3 needs Docker Sandboxes v0.51.0 or later, which resolves the built-in
`claude` agent to a published v3 kit and will not compose it with v1 or v2
mixins.
