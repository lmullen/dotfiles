# go-latest

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/)
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 3,
`kind: mixin`) that gives a sandbox the **newest stable Go release**. Its
sibling [`go`](../go) pins a specific release instead; use one or the other,
not both, since both install to `/usr/local/go`.

```text
go-latest/
├── go-latest.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── go-latest.dockerfile    # the overlay recipe, paired by filename stem
├── go-latest-context.md    # the agent-context body
└── README.md
```

## What it installs

At build time the overlay recipe reads go.dev's release index
(`https://go.dev/dl/?mode=json`), takes the first stable release, downloads
`go<version>.linux-<arch>.tar.gz` from dl.google.com, checks it against the
SHA-256 in the index, and confirms `go version` reports that release. The tree
lands at `/usr/local/go`, already on the claude image's PATH.

The index is fetched with a Dockerfile `ADD`, which BuildKit re-checks on every
build, so a new Go release invalidates the cache and the next sandbox create
gets it. An existing sandbox keeps the Go it was created with until it is
recreated.

At runtime the kit allows `proxy.golang.org` and `sum.golang.org`, as the go
kit does.

## Use

```yaml
kits:
  - /Users/lmullen/github/lmullen/dotfiles/sandboxes/kits/go-latest
```

or `sbx run claude --kit ./go-latest .`

## Verify

Inside a sandbox:

```bash
go version    # the newest stable release
```

Without `sbx`, from inside this directory:

```console
docker buildx build . -f go-latest.yaml --output type=cacheonly
docker buildx build . -f go-latest.dockerfile
```
