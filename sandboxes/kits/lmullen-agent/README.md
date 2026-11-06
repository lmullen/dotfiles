# agent-kit: run as `lmullen-agent`

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) kit (schema v3 mixin) that makes
whatever agent runs in a sandbox act as the GitHub machine account **`lmullen-agent`**: commits
are authored and committed by it, and `gh` and HTTPS `git` authenticate as it. It packages the
settings the legal-modernism sandbox carries by hand so they can be applied to any sandbox.

```text
lmullen-agent/
├── lmullen-agent.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── lmullen-agent-context.md    # the agent-context body
└── README.md                   # this file
```

It is declaration-only: there is no `lmullen-agent.dockerfile`, so nothing is built.

## What it sets

| Setting | How | Value |
|---|---|---|
| `GIT_AUTHOR_NAME`, `GIT_COMMITTER_NAME` | `lifecycle@1` install hook writing shell exports | `lmullen-agent` |
| `GIT_AUTHOR_EMAIL`, `GIT_COMMITTER_EMAIL` | `lifecycle@1` install hook writing shell exports | `lincoln+agent@lincolnmullen.com` |
| GitHub token for `gh` and HTTPS git | `credential@1` binding of the `github` secret (runtime phase, required), injected by the proxy | the token you store with `sbx secret set github` |
| Network | `network-policy@1`, runtime phase | `github.com`, `api.github.com`, `codeload.github.com`, `raw.githubusercontent.com` |
| Agent instructions | `agent-context@1` (`lmullen-agent-context.md`) | the attribution rules from CLAUDE.md |

Environment variables outrank every git config file, so the host's `~/.gitconfig` (which names
the repository owner) is untouched and the owner's own commits keep their name. The real token
never enters the container: `GH_TOKEN` inside is the `proxy-managed` sentinel and the sandbox
proxy swaps the stored secret in as an `Authorization: Bearer` header for requests to
`api.github.com` and `github.com`, the same injection Docker's own v3 kits use for the `github`
service.

Kit v3 has no `environment.variables` for a mixin, so the four exports are written by an install
hook instead: to `/etc/profile.d/lmullen-agent-env.sh`, which login shells source, and, on the
Claude workload, appended to `/etc/sandbox-persistent.sh`, which that workload sources before
every command (`BASH_ENV` and `CLAUDE_ENV_FILE` point at it). Claude's Bash tool, and so every
`git commit` it runs, picks them up from there. The step is idempotent and skips the persistent
file on images without one. Unlike v2, the variables are not in the container's own environment,
so a process that starts no shell (Claude Code itself, `sbx exec` without `bash -l`) does not
see them.

## One-time setup on the host

Store **lmullen-agent's** token as the `github` secret. It must be the machine account's token,
not your own: `gh auth token` with your normal login would make the sandbox act as you.

```bash
# if gh on the host is logged into both accounts:
sbx secret set github -t "$(gh auth token --user lmullen-agent)"

# otherwise paste a token for lmullen-agent (repo, workflow and read:org scopes as needed):
sbx secret set github -t "<lmullen-agent token>"
```

Add `--sandbox <name>` to scope the secret to one sandbox instead of all future ones.

## Use

Kits are applied when a sandbox is created. Pass this directory with `--kit`, alongside any other
kits you use:

```bash
# from the legal-modernism checkout
sbx run claude --name my-project --kit ./agent-kit

# any other base agent works too
sbx run codex --name my-project --kit ./agent-kit
```

Or declare it once in an `sbxenv.yaml` next to a project and start with `sbx env run`:

```yaml
schemaVersion: "1"
name: my-project
agent: claude
workspace: .
kits:
  - ../legal-modernism/agent-kit   # relative to this file
```

Kit v3 needs Docker Sandboxes v0.51.0 or later. Sandboxes created from older releases, or with
the v2 version of this kit, must be recreated (`sbx rm <name>` then `sbx run ...`): v1 and v2
kits cannot be combined with the v3 kits the built-in agents now resolve to.

To use it from another machine without a checkout, point at the repository once this directory is
committed and pushed:

```bash
sbx run claude --name my-project \
  --kit "git+https://github.com/chnm/legal-modernism.git#ref=main&dir=agent-kit"
```

## Verify inside a sandbox

```bash
git var GIT_AUTHOR_IDENT        # lmullen-agent <lincoln+agent@lincolnmullen.com> ...
git var GIT_COMMITTER_IDENT     # same
gh api user --jq .login         # lmullen-agent
gh auth status                  # says "not logged in": expected, the proxy holds the token
```

## Format

The kit follows the v3 kit descriptor
([SPEC-v3](https://github.com/docker/sandbox-kit-spec/blob/main/docs/spec/SPEC-v3.md)), the
version the built-in agents resolve to as of Docker Sandboxes v0.51.0. The
[v3 contribution guide](https://github.com/docker/sbx-kits-contrib/blob/v3/CONTRIBUTING.md) maps
each v2 field to its v3 capability. The `github` credential is the same shape as the one in
Docker's v3 [`copilot`](https://github.com/docker/sbx-kits-contrib/tree/v3/copilot) kit. Deltas
from the v2 kit are marked `MIGRATION NOTE` in `lmullen-agent.yaml`.

`sbx kit inspect ./lmullen-agent` reads back what the kit resolves to; `sbx kit validate` does not
accept v3 source kits.
