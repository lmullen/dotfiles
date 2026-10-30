# PostgreSQL 18 + pgvector (from the base image) + PostGIS and hypopg from the
# PGDG apt repo, which ships arm64 builds. The official postgis/postgis image
# has no arm64 build for 18, which is why we start from pgvector instead.
#
# Built automatically by `docker compose up -d`. Rebuild after editing with
# `docker compose build --pull`.
FROM pgvector/pgvector:pg18

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      postgresql-18-postgis-3 \
      postgresql-18-postgis-3-scripts \
      postgresql-18-hypopg \
 && rm -rf /var/lib/apt/lists/*
