-- migrate:up

-- Extensions bundled with the official image.
CREATE EXTENSION IF NOT EXISTS pg_trgm;   -- trigram similarity, LIKE/ILIKE indexes
CREATE EXTENSION IF NOT EXISTS unaccent;  -- accent-insensitive matching

-- Restricted role for Claude Desktop (and any other app). It can read and
-- write rows in every table that migrations create, but it cannot create,
-- alter, or drop anything: schema changes happen only through dbmate, run
-- as the owning role. It has no password until one is set out of band:
--   docker exec pkm-db psql -U pkm -c "ALTER ROLE pkm_app PASSWORD '...'"
CREATE ROLE pkm_app LOGIN;
GRANT USAGE ON SCHEMA public TO pkm_app;

-- Tables and sequences created by future migrations (run as the owning role)
-- are automatically usable by pkm_app. dbmate's own schema_migrations table
-- predates this and is deliberately not covered.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO pkm_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  GRANT USAGE, SELECT ON SEQUENCES TO pkm_app;

-- migrate:down

ALTER DEFAULT PRIVILEGES IN SCHEMA public
  REVOKE USAGE, SELECT ON SEQUENCES FROM pkm_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
  REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLES FROM pkm_app;
DROP OWNED BY pkm_app;
DROP ROLE pkm_app;

DROP EXTENSION IF EXISTS unaccent;
DROP EXTENSION IF EXISTS pg_trgm;
