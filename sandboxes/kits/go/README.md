# go

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/)
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 3,
`kind: mixin`) that gives a sandbox a **Go toolchain** at a pinned release.
Its sibling [`psql`](../psql) adds the PostgreSQL client; the legal-modernism
sandbox uses both.
For the newest stable release instead of a pin, use
[`go-latest`](../go-latest) (not both: they install to the same place).

```text
go/
├── go.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── go.dockerfile    # the overlay recipe, paired by filename stem
├── go-context.md    # the agent-context body
└── README.md
```

## What it installs

| Setting | How | Value |
|---|---|---|
| `go`, `gofmt` at `/usr/local/go/bin` | overlay built by `go.dockerfile` from the official tarball on dl.google.com, digest-checked | the kit's `version` arg, default `1.26.10` |
| Network | `network-policy@1`, runtime phase | `proxy.golang.org`, `sum.golang.org` (module downloads and verification) |
| Agent instructions | `agent-context@1` (`go-context.md`) | a note that Go is present and where it lives |

The Go tarball is self-contained content, so it is built once into an overlay
in the way Docker's own
[neovim](https://github.com/docker/sbx-kits-contrib/tree/v3/neovim) kit
installs its release: no download at every sandbox create, a pinned release in
a scannable layer, and a bad release fails the build instead of a sandbox
creation. The kit declares no install-phase network grant because the
download happens on the builder, which the sandbox policy does not govern.

`/usr/local/go` is where the official Go instructions install it and the
`claude` workload's PATH already carries `/usr/local/go/bin`, so `go` is found
with no `profile.d` or environment plumbing. `go install` puts binaries in
`~/go/bin`, which is not on PATH.

## Use

Declared in an `sbxenv.yaml`:

```yaml
kits:
  - /Users/lmullen/github/lmullen/dotfiles/sandboxes/kits/go
```

or on the command line, with a different Go release if wanted:

```console
sbx run claude --kit ./go --kit-arg version=1.27.3 .
```

Kits apply when a sandbox is created, so an existing sandbox must be recreated
(`sbx rm <name>`, then `sbx env create` or `make sandboxes` from the dotfiles
root) to pick this up.

## Bumping the Go release

Pick the release on <https://go.dev/dl/>, then change together:

1. the `version` default in `go.yaml`;
2. the two digests (amd64 and arm64) in the pinned-digest table in
   `go.dockerfile`, copied from the `.sha256` files dl.google.com serves next
   to each tarball, e.g.
   `https://dl.google.com/go/go1.26.10.linux-arm64.tar.gz.sha256`.

A release passed with `--kit-arg version=...` that is not in the table is
checked against that sidecar at build time instead, which catches a corrupt
download but trusts the host; the build prints a note when it does so.

## Verify inside a sandbox

```bash
go version      # go version go1.26.10 linux/arm64 (or amd64)
which go        # /usr/local/go/bin/go
```

To check the recipe builds without `sbx`, from inside this directory:

```console
docker buildx build . -f go.yaml --output type=cacheonly
```

`sbx kit inspect ./go` reads back what the kit resolves to. Kit v3 needs
Docker Sandboxes v0.51.0 or later.
