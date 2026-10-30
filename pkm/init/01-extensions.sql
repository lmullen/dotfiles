-- Runs once when the data volume is first initialized.
-- To apply to an existing database, run these by hand with psql.
-- Both ship with the official image; nothing extra is installed.

CREATE EXTENSION IF NOT EXISTS pg_trgm;   -- trigram similarity and LIKE/ILIKE indexes
CREATE EXTENSION IF NOT EXISTS unaccent;  -- accent-insensitive matching on names and titles
