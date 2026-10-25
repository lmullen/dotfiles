# agent-kit: run as `lmullen-agent`

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/) kit (schema v2 mixin) that makes
whatever agent runs in a sandbox act as the GitHub machine account **`lmullen-agent`**: commits
are authored and committed by it, and `gh` and HTTPS `git` authenticate as it. It packages the
settings the legal-modernism sandbox carries by hand so they can be applied to any sandbox.

```text
agent-kit/
├── spec.yaml   # the kit
└── README.md   # this file
```

## What it sets

| Setting | How | Value |
|---|---|---|
| `GIT_AUTHOR_NAME`, `GIT_COMMITTER_NAME` | `environment.variables` | `lmullen-agent` |
| `GIT_AUTHOR_EMAIL`, `GIT_COMMITTER_EMAIL` | `environment.variables` | `lincoln+agent@lincolnmullen.com` |
| GitHub token for `gh` and HTTPS git | `credentials` binding of the `github` secret, injected by the proxy | the token you store with `sbx secret set github` |
| Network | `permissions.network.allow` | `github.com`, `api.github.com`, `codeload.github.com`, `raw.githubusercontent.com` |
| Agent instructions | `agentInstructions` | the attribution rules from CLAUDE.md |

Environment variables outrank every git config file, so the host's `~/.gitconfig` (which names
the repository owner) is untouched and the owner's own commits keep their name. The real token
never enters the container: `GH_TOKEN` inside is the `proxy-managed` sentinel and the sandbox
proxy swaps the stored secret in for requests to `api.github.com` (bearer) and `github.com`
(HTTP basic as `x-access-token`).

On the Claude template the kit also appends the four exports to `/etc/sandbox-persistent.sh`,
which that template sources before every command. The step is idempotent and skipped on images
without the file.

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

Because the kit declares a credential and agent instructions, it cannot be added to a running
sandbox with `sbx kit add`; recreate the sandbox instead (`sbx rm <name>` then `sbx run ...`).

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

The kit follows Docker's [Kits v2](https://docs.docker.com/ai/sandboxes/customize/kits-v2/)
grammar, the version the built-in `claude` and `codex` agents use. Field meanings are in the
[kit reference](https://docs.docker.com/ai/sandboxes/customize/kit-reference/) and the normative
[SPEC-v2.md](https://github.com/docker/sbx-kits-contrib/blob/main/spec/SPEC-v2.md). The `github`
credential block is the same shape as the community
[`github-clone`](https://github.com/docker/sbx-kits-contrib/tree/main/github-clone) kit, so it
composes with the built-in agents the same way that kit does.
