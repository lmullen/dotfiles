## PostgreSQL client

This sandbox has the PostgreSQL client tools (`psql`, `pg_dump`,
`pg_restore`, ...) installed from the base image's apt packages. Nothing here
starts a PostgreSQL server; `psql` connects to whatever the project's
connection string names, and reaching that host is governed by the sandbox's
network policy.
