# go

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/)
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 3,
`kind: mixin`) that gives a sandbox a **Go toolchain** (Go 1.27, latest patch
release) from the Docker Hardened Images apt repository.

```text
go/
├── go.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── go-context.md    # the agent-context body
└── README.md
```

There is no official Go kit in
[docker/sbx-kits-contrib](https://github.com/docker/sbx-kits-contrib); Docker
points to its `mise` kit for language toolchains, which these sandboxes no
longer use.

## What it installs

| Setting | How | Value |
|---|---|---|
| `go`, `gofmt` | `lifecycle@1` install hook running `apt-get install golang-1.27` as root at sandbox create | the newest 1.27.x on `dhi.io`; tree at `/usr/lib/go`, links in `/usr/bin` |
| Network, install | `network-policy@1` | `deb.debian.org`, `dhi.io` (the claude image's apt sources) |
| Network, runtime | `network-policy@1` | `proxy.golang.org`, `sum.golang.org` |
| Agent instructions | `agent-context@1` (`go-context.md`) | where Go is and what it can reach |

`dhi.io` publishes one package per Go minor line (`golang-1.26`,
`golang-1.27`, ...), each updated to that line's latest patch, so the patch
release is whatever is current when the sandbox is created. To move to a new
minor line, change `golang-1.27` in the hook and `go@1.27` in `provides`.

Earlier versions of this kit downloaded a pinned release tarball from
dl.google.com into an overlay at `/usr/local/go`.

## Use

```yaml
kits:
  - /Users/lmullen/github/lmullen/dotfiles/sandboxes/kits/go
```

Kits apply when a sandbox is created, so an existing sandbox must be recreated
to pick this up. Needs Docker Sandboxes v0.51.0 or later.

## Verify inside a sandbox

```bash
go version    # go version go1.27.x linux/arm64
which go      # /usr/bin/go
```

To check the descriptor without `sbx`, from inside this directory:

```console
docker buildx build . -f go.yaml --output type=cacheonly
```
