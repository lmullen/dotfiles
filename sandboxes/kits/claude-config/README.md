# claude-config

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/)
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 3,
`kind: mixin`) with my Claude Code configuration for every sandbox. It
replaces three earlier kits: `claude-statusline`, `remote-control` and
`claude-light-theme`.

| Setting | Where | Value |
|---|---|---|
| Status line | `statusLine` in `~/.claude/settings.json` | `/usr/local/bin/claude-statusline`, shipped in the kit's overlay |
| Remote Control at startup | `remoteControlAtStartup` in `~/.claude/settings.json` | `true` |
| Theme | `theme` in `~/.claude.json` | `light` |

```text
claude-config/
├── claude-config.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── claude-config.dockerfile    # the overlay recipe, paired by filename stem
├── claude-config-context.md    # the agent-context body
├── files/statusline.sh         # the script the recipe COPYs in
└── README.md
```

## Use

```yaml
kits:
  - /Users/lmullen/github/lmullen/dotfiles/sandboxes/kits/claude-config
```

Kits apply when a sandbox is created, so an existing sandbox must be recreated
(`sbx rm <name>`, then `make sandboxes` from the dotfiles root) to pick up a
change. Needs Docker Sandboxes v0.51.0 or later, which resolves the built-in
`claude` agent to a v3 kit and will not compose it with v1 or v2 mixins.

## How it works

One `lifecycle@1` install hook, run as root when the sandbox is created,
merges the settings with `jq`. It sets only the keys above, creates either file
if it is missing, leaves every other key alone, and gives the files back to the
`agent` user. Re-running it is idempotent. An existing `statusLine` is
replaced, which is the point.

Two settings files, because Claude Code keeps them in different places:
`statusLine` and `remoteControlAtStartup` are user settings in
`~/.claude/settings.json` (Remote Control only counts at user scope; a
project's settings cannot turn it on), and the theme lives in
`~/.claude.json`.

### Status line

The script is the legal-modernism repository's `.claude/statusline.sh`, made
portable so every sandbox gets it:

```
sbx: legal-modernism  ·  Opus 4.1  ·  legal-modernism/fix-linker  ·  session (resets 3h12m): 24% used / 36% over  ·  context: 41%
```

- **sandbox** (yellow), from `SANDBOX_NAME`, which Docker Sandboxes export.
  Omitted when the variable is unset, so the script also works on a host
  installation of Claude Code.
- **model** (cyan).
- **project/branch** (magenta). The project is the name of git's main worktree,
  so a session in a linked worktree still shows as `<project>/<branch>`. Long
  branch names are truncated. Outside a git repository the folder name is
  shown alone.
- **session**, coloured green, yellow or red by how much of the 5-hour quota is
  used, with the time until it resets and how far through the window it is.
- **context**, how full the context window is, coloured the same way. It reads
  `n/a` until the session's first response.

`claude-config.dockerfile` is a `FROM scratch` overlay that copies
`files/statusline.sh` to `/usr/local/bin/claude-statusline` with mode 0755. It
lands outside the agent's home because an overlay under `/home/agent` would
have to reproduce the ownership of every parent directory, and a volume
mounted over `/home/agent` would hide it.

The hook also links `~/.claude/statusline.sh` to the script, unless a regular
file is already there. A project whose own `.claude/statusline.sh` calls
`~/.claude/statusline.sh` to print this line above its own keeps working;
without the link that first line comes out blank. A project's
`.claude/settings.json` that registers its own `statusLine` overrides this one.

### Theme

Claude Code's `auto` theme reads the terminal background from `COLORFGBG` or an
OSC 11 query. Neither reliably reaches Claude inside a sandbox, so it renders
dark in a light Ghostty. If a sandbox still comes up dark, run `/theme` once,
pick Light, and check what changed in `~/.claude.json` and
`~/.claude/settings.json`; Claude Code could also overwrite `~/.claude.json`
itself.

## Requirements

`requires: ["claude", "deb/jq"]`: the settings are Claude Code's and the hook
runs `jq`; Docker's `claude` workload provides both. The status line script
also uses `git`, `date`, `sed` and `basename`, standard on the base image. No
`network-policy@1`: the status line opens no socket, and Remote Control talks
to claude.ai, which the claude workload already allows.

## Verify inside a sandbox

```bash
jq '{statusLine, remoteControlAtStartup}' ~/.claude/settings.json
jq .theme ~/.claude.json            # "light"
ls -l ~/.claude/statusline.sh       # -> /usr/local/bin/claude-statusline
```

To check the descriptor and build the overlay without `sbx`, from inside this
directory:

```console
docker buildx build . -f claude-config.yaml --output type=cacheonly
```
