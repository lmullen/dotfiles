# The PKM database image. Currently the official image with nothing added;
# this file exists so that extensions or tools not bundled with Postgres have
# a place to go. Compose builds it automatically on `up`.
#
# Rebuild after editing, or to pick up a new 18.x release:
#   docker compose build --pull && docker compose up -d
#
# Examples of what would go here when needed (all from the PGDG apt repo the
# base image already has configured):
#   RUN apt-get update \
#    && apt-get install -y --no-install-recommends \
#         postgresql-18-pgvector \
#         postgresql-18-postgis-3 postgresql-18-postgis-3-scripts \
#    && rm -rf /var/lib/apt/lists/*
FROM postgres:18
