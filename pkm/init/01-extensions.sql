-- Runs once when the data volume is first initialized.
-- To apply to an existing database, run these by hand with psql.

-- Embeddings and similarity search over notes, sources, passages.
CREATE EXTENSION IF NOT EXISTS vector;

-- Geometry/geography. Also installed but not enabled: postgis_topology,
-- postgis_raster, postgis_tiger_geocoder, address_standardizer.
CREATE EXTENSION IF NOT EXISTS postgis;

-- Text matching on names, titles, tags.
CREATE EXTENSION IF NOT EXISTS pg_trgm;        -- trigram similarity and LIKE indexes
CREATE EXTENSION IF NOT EXISTS unaccent;       -- accent-insensitive search
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;  -- soundex, metaphone, levenshtein
CREATE EXTENSION IF NOT EXISTS citext;         -- case-insensitive text type

-- Structure.
CREATE EXTENSION IF NOT EXISTS btree_gist;     -- exclusion constraints, range indexes
CREATE EXTENSION IF NOT EXISTS ltree;          -- hierarchical labels (taxonomies)

-- Query analysis, used by Postgres MCP Pro for index recommendations.
-- pg_stat_statements is preloaded via the compose command line.
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
CREATE EXTENSION IF NOT EXISTS hypopg;
