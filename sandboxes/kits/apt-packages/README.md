# apt-packages

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/)
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 3,
`kind: mixin`) that installs the Debian packages a sandbox names, from the
claude image's apt sources (Debian trixie on `deb.debian.org` and Docker
Hardened Images on `dhi.io`), at sandbox create.

```text
apt-packages/
├── apt-packages.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── apt-packages-context.md    # the agent-context body
└── README.md
```

It is declaration-only: there is no dockerfile, so nothing is built. It
replaces the `psql` and `pdf-tools` kits, which were the same hook with a fixed
package list.

## When to use apt rather than mise

Language toolchains (Go, Node, Hugo, Python, ...) go through
[mise](../mise-shims): per-project versions, and the pins live in the
project's own `mise.toml`. apt is for the rest, where mise has nothing good to
offer:

| Package | Why apt |
|---|---|
| `postgresql-client` | mise's `postgres` plugin builds the whole server from source; Debian ships the client prebuilt. |
| `poppler-utils`, `librsvg2-bin` | Not in mise's registry; they are C programs with a long tail of shared libraries apt already resolves. |

## Use

```yaml
kits:
  - source: /Users/lmullen/github/lmullen/dotfiles/sandboxes/kits/apt-packages
    args:
      packages: "postgresql-client poppler-utils librsvg2-bin"
```

`packages` is required. The hook runs `apt-get update` and
`apt-get install --no-install-recommends` as root, with the apt hosts open only
during the install phase; a package that does not exist fails sandbox creation.
Inside the sandbox the list is in `$APT_PACKAGES`.

Kits apply when a sandbox is created, so an existing sandbox must be recreated
(`sbx rm <name>`, then `make sandboxes` from the dotfiles root) to pick up a
change. Needs Docker Sandboxes v0.51.0 or later.

## Verify inside a sandbox

```bash
echo "$APT_PACKAGES"
psql --version; pdftotext -v; rsvg-convert --version
```
