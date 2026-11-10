# node

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/)
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 3,
`kind: mixin`) that gives a sandbox **Node.js 24 and npm**, from the Docker Hardened Images apt repository
(`dhi.io`) that the claude image already has configured. Debian trixie itself
ships only Node 20.

```text
node/
├── node.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── node-context.md    # the agent-context body
└── README.md
```

It is declaration-only: there is no dockerfile, so nothing is built. Like the
[`psql`](../psql) kit, it installs apt packages with a `lifecycle@1` install
hook run as root at sandbox create, because apt packages need the composed
base's dpkg database and cannot travel in an overlay. The apt hosts
(`deb.debian.org`, `dhi.io`) are open only during that install phase.

Docker's [sbx-kits-contrib](https://github.com/docker/sbx-kits-contrib) has
no official kit for this.
Docker's official
[`playwright`](https://github.com/docker/sbx-kits-contrib/tree/v3/playwright)
kit assumes the base image has Node, which the claude image does not; this kit
supplies it.

## What it installs

| Package | Source | Provides |
|---|---|---|
| `nodejs-24` | dhi.io | `/usr/bin/node` |
| `npm` | dhi.io | `/usr/bin/npm`, `npx` (depends on any versioned `nodejs-NN`, so Debian's `nodejs` is not pulled in) |

At runtime the kit allows `registry.npmjs.org` so `npm install` works. The
kit provides `node@24`; the point release is whatever dhi.io resolves at
create time.

## Use

```yaml
kits:
  - /Users/lmullen/github/lmullen/dotfiles/sandboxes/kits/node
```

Kits apply when a sandbox is created, so an existing sandbox must be recreated
(`sbx rm <name>`, then `make sandboxes` from the dotfiles root) to pick this
up. Needs Docker Sandboxes v0.51.0 or later.

## Verify inside a sandbox

```bash
node --version   # v24.x
npm --version
```
