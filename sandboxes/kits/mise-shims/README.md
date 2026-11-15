# mise-shims

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/)
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 3,
`kind: mixin`) that makes Docker's official
[`mise`](https://github.com/docker/sbx-kits-contrib/tree/v3/mise) kit work in
Claude Code's Bash tool. It names no tools: each project lists what it needs in
its own `mise.toml` / `.mise.toml`, and this kit installs that at sandbox
create.

```text
mise-shims/
├── mise-shims.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── mise-shims-context.md    # the agent-context body
└── README.md
```

It is declaration-only: there is no dockerfile, so nothing is built.

## Why the official kit is not enough on its own

The official kit ships `mise` and adds `mise activate bash` to `~/.bashrc`.
Claude's Bash tool runs non-interactive shells from a snapshot of `~/.bashrc`
taken when the session starts, which keeps functions and PATH but drops other
variables. Reproducing that setup in a container with only the official kit:

| Problem | Seen |
|---|---|
| A session that started before tools were installed never finds them | `hugo: command not found`, even after `mise install`, until Claude restarts. mise's not-found handler cannot help: it does not know which tool provides `hugo` until that tool is installed. |
| `cd` into another project keeps the first project's versions | Hugo 0.161.1 ran in a project pinning 0.169.0. |
| Project configs are refused | "Config files in …/.mise.toml are not trusted": the snapshot drops `MISE_TRUSTED_CONFIG_PATHS`. Setting it in `sbxenv.yaml`'s `env:` would fix only this one. |

What this kit adds:

- **Shims first on PATH.** A line appended to `~/.bashrc`, after the official
  kit's `mise activate`, puts `~/.local/share/mise/shims` ahead of the
  directories activate adds. That is where it has to go: the Bash tool replays
  the snapshot's PATH after sourcing `/etc/sandbox-persistent.sh`, so PATH
  changes there are overridden (checked in a live session). The shims also go
  in `/etc/sandbox-persistent.sh` and `/etc/profile.d/mise-shims.sh` for other
  shells. A shim picks the version for the directory it runs in, and installs a
  pinned version that is missing on first use. With shims, all three cases
  above work.
- **Trust.** `MISE_TRUSTED_CONFIG_PATHS=/` in `/etc/sandbox-persistent.sh`,
  which the Bash tool sources before every command (variables other than PATH
  survive the snapshot), and in `/etc/profile.d/mise-shims.sh`.
- **Install at create.** `mise install` in the workspace, as the agent user, so
  the project's tools and their shims exist before the agent starts. It is
  best-effort; on failure the agent can rerun it.
- **Network.** The hosts mise downloads Go, Node and GitHub-hosted tools from,
  and the Go and npm registries; see the comments in `mise-shims.yaml`.

## Use

List it after the official kit:

```yaml
kits:
  - docker.io/sbx/mise:latest
  - /Users/lmullen/github/lmullen/dotfiles/sandboxes/kits/mise-shims
```

Then pin tools in the project, not here: `mise use <tool>@<version>` in the
checkout, committed with it. See mise's docs for
[`mise use`](https://mise.jdx.dev/cli/use.html),
[configuration](https://mise.jdx.dev/configuration.html),
[shims](https://mise.jdx.dev/dev-tools/shims.html) and the
[registry](https://mise.jdx.dev/registry.html) of tool names.

Only the primary workspace is installed at create. In an additional workspace,
a tool whose shim already exists installs that project's pinned version on
first use; a tool no other project uses needs a `mise install` there first.

Kits apply when a sandbox is created, so an existing sandbox must be recreated
(`sbx rm <name>`, then `make sandboxes` from the dotfiles root) to pick up a
change. Needs Docker Sandboxes v0.51.0 or later.

## Verify inside a sandbox

```bash
mise ls              # tools, versions and the config that asked for each
which hugo           # ~/.local/share/mise/shims/hugo
```

To check the descriptor without `sbx`, from inside this directory:

```console
docker buildx build . -f mise-shims.yaml --output type=cacheonly
```
