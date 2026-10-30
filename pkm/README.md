# PKM: personal knowledge management

Tools for managing research alongside the Obsidian vault. The vault stays the
home for prose notes; this directory holds structured data and the services
that work on it. The first piece is a PostgreSQL database that Claude Desktop
(and anything else) can read and write.

## Layout

| Path | Purpose |
| --- | --- |
| `compose.yaml` | PostgreSQL 18 in Docker: data in a named volume, backups bind-mounted from the host |
| `Dockerfile` | The image definition: official `postgres:18`, with a place to add non-bundled extensions |
| `init/*.sql` | Runs once when the data volume is first created (enables extensions) |
| `../bin/backup-pkm.sh` | Nightly dump and retention, run by `../launchd/com.lmullen.backup-pkm.plist` |

## Decisions

- **PostgreSQL 18**, built by `Dockerfile` from the official `postgres:18`
  image with nothing added yet. Version 18 brings native `uuidv7()`, virtual
  generated columns, and async I/O.
- **Two extensions enabled at first start** (`init/01-extensions.sql`), both
  bundled with the image: `pg_trgm` and `unaccent`, for fuzzy and
  accent-insensitive matching of names and titles across sources. Other
  bundled extensions (`citext`, `fuzzystrmatch`, `btree_gist`, `ltree`,
  `pg_stat_statements`) are one `CREATE EXTENSION` away. Anything not bundled,
  such as pgvector or PostGIS, is an `apt-get install` line in the Dockerfile
  (the commented example there shows the package names) plus a
  `CREATE EXTENSION`.
- **Host port 5678**, bound to `127.0.0.1` only. Homebrew's `postgresql@17`
  keeps 5432 free for itself, and nothing on the LAN can reach the container.
- **Named Docker volume** `pkm_pgdata`. Reliable on Docker Desktop for Mac;
  survives `docker compose down` and container recreation. Deleted only by
  `docker compose down -v`.
- **Configuration lives in the shell environment**, not in a file in the repo.
  `docker compose` reads the variables from whatever shell runs it, so
  stopping, starting, or inspecting the stack must happen from a shell that
  has them. The backup script is deliberately independent of them.
- **Remote access via `tailscale serve`**, not by binding to other interfaces.

## Prerequisites

Docker Desktop (in `homebrew/Gaustad.Brewfile`). For remote access, Tailscale (`tailscale-app`
cask, also in the Brewfile). Homebrew's `postgresql@18` provides `psql` on the
host. Backups nonetheless use the container's own `pg_dump`, so client and
server versions can never drift apart.

## Quick start

Compose expects these variables in the environment. Put them wherever you keep
secrets for your shell; for fish, something like:

```fish
set -gx PKM_POSTGRES_PASSWORD ...        # required; generate with: openssl rand -base64 24
set -gx PKM_POSTGRES_USER pkm            # default: pkm
set -gx PKM_POSTGRES_DB pkm              # default: pkm
set -gx PKM_PG_PORT 5678                 # default: 5678, host port on 127.0.0.1
set -gx PKM_BACKUP_DIR /Users/lmullen/backups/pkm   # default shown
```

All variables carry the `PKM_` prefix so they cannot collide with another
Postgres service on the machine. Only `PKM_POSTGRES_PASSWORD` is required;
compose refuses to start without it.
If you change `PKM_BACKUP_DIR`, change it in
`launchd/com.lmullen.backup-pkm.plist` as well, since launchd does not see
your shell.

```sh
cd ~/github/lmullen/dotfiles/pkm
docker compose up -d           # first run builds the image
docker compose ps              # wait for "healthy"
```

Connection string (DSN):

```
postgresql://pkm:<password>@localhost:5678/pkm
```

From the host with the Homebrew client:

```sh
psql postgresql://pkm:<password>@localhost:5678/pkm
```

Or with no password on the command line (works from any shell, since it
addresses the container by name rather than through compose):

```sh
docker exec -it pkm-db psql -U pkm pkm
```

Postico: host `localhost`, port `5678`, user `pkm`, database `pkm`.

Day to day:

```sh
docker compose up -d       # start (also restarts automatically with Docker Desktop)
docker compose down        # stop, keep data
docker compose logs -f db  # watch the server log
docker compose build --pull && docker compose up -d   # update to the latest 18.x
```

## Claude Desktop

Two routes. Both run the MCP server in a container so nothing is installed on
the host. Inside a container the Mac is `host.docker.internal`, not
`localhost`.

### Route A: Postgres MCP Pro via `docker run` (recommended)

[crystaldba/postgres-mcp](https://github.com/crystaldba/postgres-mcp) is a
purpose-built Postgres server with schema inspection, SQL execution, explain
plans, and index advice. It has a `restricted` read-only mode and an
`unrestricted` mode; use `unrestricted` so Claude can record information.

Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "pkm-postgres": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "DATABASE_URI",
        "crystaldba/postgres-mcp",
        "--access-mode=unrestricted"
      ],
      "env": {
        "DATABASE_URI": "postgresql://pkm:<password>@host.docker.internal:5678/pkm"
      }
    }
  }
}
```

Restart Claude Desktop. Pull the image once ahead of time so the first launch
is not slow: `docker pull crystaldba/postgres-mcp`.

### Route B: Docker MCP Toolkit

Docker Desktop's MCP Toolkit has a catalog of servers and a one-click
connection to Claude Desktop. As of late 2026 the catalog has no official
Postgres server; the closest entry is **MCP Database Server**
(`database-server`, a third-party project that supports PostgreSQL, MySQL, and
SQLite). If you prefer the GUI workflow:

1. Docker Desktop, **MCP Toolkit**, **Catalog** tab. Add *MCP Database Server*.
2. In its **Configuration** tab set the database URL to
   `postgresql+asyncpg://pkm:<password>@host.docker.internal:5678/pkm`.
3. **Clients** tab, **Connect** next to Claude Desktop. Restart Claude Desktop.

Route A is the better-maintained server; Route B is less typing. Do not enable
both at once or Claude sees two overlapping toolsets.

## Access over Tailscale

The container listens only on loopback. To reach it from other devices on the
tailnet, have the Mac's Tailscale forward a tailnet port to the local one. Run
on the Mac:

```sh
tailscale serve --bg --tcp 5432 tcp://localhost:5678
```

Other tailnet devices then connect to port 5432 on the Mac's MagicDNS name:

```
postgresql://pkm:<password>@<mac-name>.<tailnet>.ts.net:5432/pkm
```

Traffic is encrypted by WireGuard and gated by your tailnet ACLs; nothing is
exposed to the LAN or the internet. Check and undo with:

```sh
tailscale serve status
tailscale serve --tcp 5432 off
```

Notes:

- Install Tailscale from the Homebrew cask (standalone build), not the Mac App
  Store build. The standalone build ships the `tailscale` CLI at
  `/Applications/Tailscale.app/Contents/MacOS/Tailscale`; symlink or alias it.
- `--bg` persists the forward across Tailscale restarts. Omit it to run in the
  foreground for a one-off session.
- Postgres still authenticates with the password. If you ever want
  certificate-based or IP-restricted auth, that is a `pg_hba.conf` change.

## Backups

`bin/backup-pkm.sh` writes one compressed **custom-format** dump per run
(`pg_dump -Fc --compress=zstd`) to `/Users/lmullen/backups/pkm/`, named
`pkm-<UTC timestamp>.dump`. Custom format is a single file that `pg_restore`
can restore selectively (one table, schema only, data only) and in parallel.
The dump is produced inside the container, so `pg_dump` always matches the
server, and lands directly on the host through the `/backups` bind mount. A
dump is written under a temporary name and renamed only on success. The
script uses `docker exec` on the container by name, so it needs none of the
compose variables and runs fine from launchd's bare environment.

**Retention**: the 30 newest dumps plus the earliest dump from each of the 12
most recent months. Older ones are deleted on each run.

**Schedule**: `launchd/com.lmullen.backup-pkm.plist` runs the script daily at
02:30; `make launchd` installs it next to the notes backup. Load it once with:

```sh
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.lmullen.backup-pkm.plist
```

If the container is not running when the job fires, the script logs that and
exits cleanly. Logs: `backup-pkm.log` and `backup-pkm.err` in the backup dir.

Run by hand any time:

```sh
~/github/lmullen/dotfiles/bin/backup-pkm.sh
~/github/lmullen/dotfiles/bin/backup-pkm.sh --prune-only
```

Inspect or restore a dump with the container's tools (the backup directory is
visible inside as `/backups`):

```sh
docker exec pkm-db pg_restore --list /backups/pkm-YYYY-MM-DDTHHMMSSZ.dump
# full restore into the (empty or to-be-replaced) pkm database
docker exec pkm-db pg_restore -U pkm -d pkm --clean --if-exists /backups/pkm-YYYY-MM-DDTHHMMSSZ.dump
# one table only
docker exec pkm-db pg_restore -U pkm -d pkm -t sources /backups/pkm-YYYY-MM-DDTHHMMSSZ.dump
```

Or from the host with Homebrew's `pg_restore` (needs version 18 or newer):

```sh
pg_restore -d postgresql://pkm:<password>@localhost:5678/pkm --clean --if-exists ~/backups/pkm/pkm-YYYY-MM-DDTHHMMSSZ.dump
```

A human-readable SQL copy of any dump, should you ever want one for the
archive, is `pg_restore -f pkm.sql pkm-....dump`; no database needed.

## Major version upgrades

Minor updates (18.1 to 18.2) are `docker compose build --pull && docker compose up -d`.
A major upgrade (18 to 19) needs either dump-and-restore into a fresh volume or
`pg_upgrade`; the volume is mounted at `/var/lib/postgresql` rather than the
old `/var/lib/postgresql/data` so that the official image's upgrade path works.
