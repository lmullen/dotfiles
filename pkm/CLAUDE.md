# PKM database: rules for agents

This directory defines a PostgreSQL database (see README.md). Its schema is
managed exclusively with dbmate. Follow these rules whenever you touch it.

## Schema changes are migrations, nothing else

- Every change to tables, columns, indexes, types, functions, extensions,
  roles, or grants is a new file in `db/migrations/`, created with
  `bin/pkm-dbmate new <snake_case_name>`. Never run `CREATE`, `ALTER`, or
  `DROP` directly through psql, the MCP server, or any other path.
- A migration has a `-- migrate:up` section and a `-- migrate:down` section.
  The down section must genuinely reverse the up section. If a change cannot
  be reversed (dropping a column with data), say so in a comment and make the
  down section the closest safe approximation.
- Never edit a migration that has already been applied. Add a new one.
- Apply with `bin/pkm-dbmate up`. That also regenerates `db/schema.sql`.
  Commit the migration and the regenerated `db/schema.sql` together.
- `db/schema.sql` is generated. Never edit it by hand.
- Data corrections that must be reproducible are migrations too. One-off
  exploratory queries are not.

## Conventions

- Primary keys: `id uuid PRIMARY KEY DEFAULT uuidv7()`.
- Timestamps: `timestamptz`, with `created_at timestamptz NOT NULL DEFAULT now()`
  on every table.
- Names: snake_case, plural table names, singular column names.
- Text search on names and titles: `pg_trgm` and `unaccent` are enabled; use
  them rather than adding new extensions. Adding an extension that is not
  bundled with the official image also means editing `Dockerfile`.

## Roles

- `pkm` owns everything and is what dbmate connects as.
- `pkm_app` is the restricted role for Claude Desktop and other applications.
  It can read and write rows in every table but cannot change the schema.
  New tables created by migrations are covered automatically by default
  privileges; do not add per-table grants.

## Running things

- Compose and dbmate read `PKM_*` variables from the shell. If they are
  missing, stop and ask rather than inventing a `.env` file.
- The container is addressable as `pkm-db`: `docker exec -it pkm-db psql -U pkm pkm`.
- Backups: `bin/backup-pkm.sh`. Do not change the backup format or retention
  without asking.
