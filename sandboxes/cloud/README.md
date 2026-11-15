# Claude Code cloud environment

Configuration for a [Claude Code cloud environment](https://code.claude.com/docs/en/cloud-environments)
(claude.ai/code), the counterpart of the Docker sandboxes in `../env` and
`../kits`. Three files go into the environment's settings dialog:

| File | Field | What it does |
|---|---|---|
| `setup.sh` | **Setup script** | Installs mise, puts its shims on PATH, installs the project's tools, and sets up the lmullen-agent git identity. See the comments at the top of the script. |
| `env.txt` | **Environment variables** | The lmullen-agent commit identity, and `MISE_TRUSTED_CONFIG_PATHS=/` so mise reads project configs without a trust prompt. |
| `allowed-domains.txt` | **Allowed domains**, with **Network access** set to **Limited** and **Allow package managers** checked | Hosts mise needs that the default allowlist leaves out. |

The setup script can also be fetched instead of pasted:

```bash
curl -fsSL https://raw.githubusercontent.com/lmullen/dotfiles/main/sandboxes/cloud/setup.sh | bash
```

## Tools through mise

As in the Docker sandboxes, each project pins its toolchains in its own
`mise.toml` / `.mise.toml`; nothing here names a tool. The setup script
installs mise (the release Docker's official mise kit uses, checksum-verified)
and runs `mise install` in the checkout, so the tools land in the cached
environment. A SessionStart hook runs `mise install` again in every session,
which covers a different repository, or a newer pin, than the cache saw.

Claude's Bash tool takes its PATH from a snapshot of `~/.bashrc` made at
session start and keeps no other variables from it. So the script puts mise's
shims first on PATH at the end of `~/.bashrc`, and the trust variable comes
from `env.txt` instead.

### Projects need a mise.lock

In a cloud session, GitHub traffic goes through Anthropic's GitHub proxy,
which refuses API requests for repositories not attached to the session. To
install a GitHub-hosted tool such as Hugo or dbmate, mise first looks the
release up through `api.github.com`, so without a lockfile the install fails.
A `mise.lock` records each tool's download URL and checksum, and mise
downloads from it directly. Generate it in the project with:

```bash
mise lock --platform linux-x64,linux-arm64,macos-arm64
```

and refresh it whenever a pin changes. lincolnmullen.com and legal-modernism
have one.

### Allowed domains

With **Allow package managers** checked, the default allowlist already
covers GitHub's release-asset hosts, nodejs.org, the Go module proxy and the
npm registry. `allowed-domains.txt` adds:

- `dl.google.com`, where Go releases (and the URLs in a lockfile's Go entries)
  are downloaded from.
- `mise-versions.jdx.dev`, mise's version lists, which it uses to resolve a
  fuzzy version (`node = "22"`) that has no lockfile entry yet.

Changing the allowed domains or the setup script rebuilds the environment's
cache.
