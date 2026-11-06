# psql

A [Docker Sandboxes](https://docs.docker.com/ai/sandboxes/)
[kit](https://docs.docker.com/ai/sandboxes/customize/kits/) (schemaVersion 3,
`kind: mixin`) that gives a sandbox the **PostgreSQL command-line client**:
`psql`, `pg_dump`, `pg_restore` and the rest of Debian's `postgresql-client`.
Its sibling [`go`](../go) adds a Go toolchain; the legal-modernism sandbox uses
both.

```text
psql/
├── psql.yaml          # the descriptor (# syntax=docker/sandbox-kit:3)
├── psql-context.md    # the agent-context body
└── README.md
```

It is declaration-only: there is no `psql.dockerfile`, so nothing is built.

## What it installs

| Setting | How | Value |
|---|---|---|
| `psql`, `pg_dump`, `pg_restore`, ... | `lifecycle@1` install hook running `apt-get install postgresql-client` as root at sandbox create | whatever the base's apt resolves (PostgreSQL 17 on Debian trixie) |
| Network | `network-policy@1`, install phase only | `deb.debian.org`, `dhi.io` (the claude image's apt sources) |
| Agent instructions | `agent-context@1` (`psql-context.md`) | a note that the client is present |

An apt package cannot travel in a kit overlay: it needs the composed base's
dpkg database and a shared-library closure (libpq5, libreadline, ...) that an
overlay cannot carry. So the install is a hook that runs against the base's
own apt, the same route Docker's
[playwright](https://github.com/docker/sbx-kits-contrib/tree/v3/playwright)
and
[packages-through-sfw](https://github.com/docker/sbx-kits-contrib/tree/v3/packages-through-sfw)
kits take for their apt packages. The cost is one `apt-get` run per sandbox
create; the apt hosts are open only during that install phase.

The kit starts no PostgreSQL server and grants no runtime network access.
`psql` connects to whatever the project's connection string names, and
reaching that host is the project's policy to allow.

## Use

Declared in an `sbxenv.yaml`:

```yaml
kits:
  - /Users/lmullen/github/lmullen/dotfiles/sandboxes/kits/psql
```

or on the command line:

```console
sbx run claude --kit ./psql .
```

Kits apply when a sandbox is created, so an existing sandbox must be recreated
(`sbx rm <name>`, then `sbx env create` or `make sandboxes` from the dotfiles
root) to pick this up.

## Verify inside a sandbox

```bash
psql --version    # psql (PostgreSQL) 17.x
which psql        # /usr/bin/psql
```

To check the descriptor without `sbx`, from inside this directory:

```console
docker buildx build . -f psql.yaml --output type=cacheonly
```

`sbx kit inspect ./psql` reads back what the kit resolves to. Kit v3 needs
Docker Sandboxes v0.51.0 or later.
