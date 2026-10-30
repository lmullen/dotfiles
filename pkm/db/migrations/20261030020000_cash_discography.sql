-- migrate:up

-- Johnny Cash discography, crawled from https://www.johnnycash.com/releases/
-- (the official Sony/Legacy site). The site exposes four kinds of page:
--
--   /music/<slug>/   a release: album, compilation, soundtrack, or an album
--                    on which Cash is a guest. Has a tracklist, description,
--                    credits, chart stats, videos, buy/stream links.
--   /track/<slug>/   a track page: one recording as it appears on one release.
--                    Has date, parent release, songwriter, lyrics, videos.
--                    Singles and single-track guest appearances in the site's
--                    release list point at track pages, not /music/ pages.
--   /releases/song-list/      every track with its release and date
--   /releases/chart-history/  Billboard 200 and Hot 100 entries
--
-- The schema mirrors that: `release` and `track` are the two crawled
-- entities; `release_track` is the tracklist; `song` is a derived work-level
-- table (the site has no work identity, so it is filled by normalizing
-- track titles and can be corrected by hand). JSONB is used only for the
-- buy/stream link lists and for a `raw` copy of each parsed page, kept so
-- the tables can be rebuilt without re-crawling.

CREATE SCHEMA cash_discography;

GRANT USAGE ON SCHEMA cash_discography TO pkm_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA cash_discography
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO pkm_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA cash_discography
  GRANT USAGE, SELECT ON SEQUENCES TO pkm_app;

SET search_path TO cash_discography, public;

-- updated_at maintenance ----------------------------------------------------

CREATE FUNCTION set_updated_at() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

-- Lookups --------------------------------------------------------------------

-- The release-list filters on the site. The first five are mutually exclusive
-- types; the rest are genre/occasion tags that can combine with a type.
CREATE TABLE tag (
  slug        text PRIMARY KEY,
  label       text NOT NULL,
  is_type     boolean NOT NULL DEFAULT false
);

INSERT INTO tag (slug, label, is_type) VALUES
  ('albums',            'Albums',            true),
  ('compilations',      'Compilations',      true),
  ('singles',           'Singles',           true),
  ('guest-appearances', 'Guest Appearances', true),
  ('soundtracks',       'Soundtracks',       true),
  ('country',           'Country',           false),
  ('gospel',            'Gospel',            false),
  ('live',              'Live',              false),
  ('christmas',         'Christmas',         false),
  ('childrens-music',   'Children''s Music', false);

CREATE TABLE chart (
  slug        text PRIMARY KEY,          -- as used by the site's chart selector
  name        text NOT NULL,
  country     text NOT NULL DEFAULT 'United States',
  chart_kind  text NOT NULL CHECK (chart_kind IN ('album', 'song'))
);

INSERT INTO chart (slug, name, chart_kind) VALUES
  ('us-billboard-200',     'Billboard 200',     'album'),
  ('us-billboard-hot-100', 'Billboard Hot 100', 'song');

-- People named in credits (producers, songwriters). Names are kept exactly as
-- the site prints them; merge variants by hand if needed.
CREATE TABLE person (
  id          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name        text NOT NULL UNIQUE,
  notes       text
);

-- Songs as works, derived from track titles ------------------------------

-- The site has no notion of a song apart from its recordings. This table is
-- populated by normalizing track titles (stripping "(Live)", "(Mono)",
-- "– Live At ...", "(with June Carter Cash)", etc.) and may be corrected by
-- hand. `canonical_title` is the normalized form used for matching.
CREATE TABLE song (
  id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title            text NOT NULL,
  canonical_title  text NOT NULL UNIQUE,
  written_by_cash  boolean,                -- from the song list's "Written by Johnny Cash" filter
  notes            text,
  created_at       timestamptz NOT NULL DEFAULT now(),
  updated_at       timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX song_canonical_title_trgm ON song USING gin (canonical_title gin_trgm_ops);

CREATE TABLE song_writer (
  song_id     integer NOT NULL REFERENCES song ON DELETE CASCADE,
  person_id   integer NOT NULL REFERENCES person ON DELETE RESTRICT,
  position    smallint NOT NULL DEFAULT 1,
  PRIMARY KEY (song_id, person_id)
);

-- Releases (one row per /music/ page) ----------------------------------------

CREATE TABLE release (
  id                 integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  slug               text NOT NULL UNIQUE,     -- last path segment of the URL
  source_url         text NOT NULL UNIQUE,
  title              text NOT NULL,
  release_type       text NOT NULL REFERENCES tag (slug),  -- albums, compilations, soundtracks, guest-appearances
  release_date       date,
  release_date_text  text,                     -- as printed, e.g. "October 23, 2020 (U.S.)"
  cover_image_url    text,
  description_html   text,                     -- the site's blurb / liner notes, as HTML
  description_text   text,                     -- same, plain text
  riaa_certification text,                     -- e.g. "3x Platinum"
  spotify_uri        text,
  apple_id           text,
  deezer_id          text,
  -- buy and stream links: [{"group": "buy"|"listen", "label": "Amazon", "url": "..."}]
  external_links     jsonb NOT NULL DEFAULT '[]'::jsonb,
  raw                jsonb,                    -- full parsed page, for rebuilding
  fetched_at         timestamptz,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX release_release_date_idx ON release (release_date);
CREATE INDEX release_title_trgm ON release USING gin (title gin_trgm_ops);
CREATE TRIGGER release_updated_at BEFORE UPDATE ON release
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Genre/occasion tags from the release-list filters (country, gospel, live ...).
CREATE TABLE release_tag (
  release_id  integer NOT NULL REFERENCES release ON DELETE CASCADE,
  tag         text NOT NULL REFERENCES tag (slug),
  PRIMARY KEY (release_id, tag)
);

-- "Producers: Jeff Rosen, Steve Berkowitz" and similar credit lines.
CREATE TABLE release_credit (
  release_id  integer NOT NULL REFERENCES release ON DELETE CASCADE,
  person_id   integer NOT NULL REFERENCES person ON DELETE RESTRICT,
  role        text NOT NULL,                   -- as printed, singularized and lowercased: producer
  position    smallint NOT NULL DEFAULT 1,
  PRIMARY KEY (release_id, person_id, role)
);

-- Tracks (one row per /track/ page) -------------------------------------------

-- A track is one recording as it appears on one release. The same performance
-- reissued on a compilation gets a separate track page on the site, and so a
-- separate row here; `song_id` ties them together.
CREATE TABLE track (
  id                 integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  slug               text NOT NULL UNIQUE,
  source_url         text NOT NULL UNIQUE,
  title              text NOT NULL,
  song_id            integer REFERENCES song ON DELETE SET NULL,
  release_id         integer REFERENCES release ON DELETE SET NULL,  -- the "From:" release, when it is a /music/ page
  from_text          text,                     -- the "From:" line as printed, e.g. "Redemption Day (single)"
  track_date         date,                     -- date on the track page (release date of the track or its single)
  track_date_text    text,
  -- How the site's release list classifies this page, if it appears there:
  -- 'singles' or 'guest-appearances'. NULL for ordinary album tracks.
  listed_as          text REFERENCES tag (slug),
  cover_image_url    text,
  songwriter_text    text,                     -- "Songwriter:" line as printed
  lyrics_html        text,
  lyrics_text        text,
  spotify_uri        text,
  apple_id           text,
  deezer_id          text,
  external_links     jsonb NOT NULL DEFAULT '[]'::jsonb,
  raw                jsonb,
  fetched_at         timestamptz,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX track_song_id_idx ON track (song_id);
CREATE INDEX track_release_id_idx ON track (release_id);
CREATE INDEX track_track_date_idx ON track (track_date);
CREATE INDEX track_title_trgm ON track USING gin (title gin_trgm_ops);
CREATE TRIGGER track_updated_at BEFORE UPDATE ON track
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE track_credit (
  track_id    integer NOT NULL REFERENCES track ON DELETE CASCADE,
  person_id   integer NOT NULL REFERENCES person ON DELETE RESTRICT,
  role        text NOT NULL,                   -- songwriter, producer ...
  position    smallint NOT NULL DEFAULT 1,
  PRIMARY KEY (track_id, person_id, role)
);

-- Tracklists -------------------------------------------------------------------

-- One row per line of a release's tracklist. `track_id` is set when the
-- line links to a /track/ page (nearly always).
CREATE TABLE release_track (
  release_id      integer NOT NULL REFERENCES release ON DELETE CASCADE,
  disc_no         smallint NOT NULL DEFAULT 1,
  position        smallint NOT NULL,
  track_id        integer REFERENCES track ON DELETE SET NULL,
  title           text NOT NULL,               -- as listed on the release page
  duration        interval,                    -- from data-duration, e.g. 03:01
  released_as_single boolean NOT NULL DEFAULT false,
  has_video       boolean NOT NULL DEFAULT false,
  spotify_uri     text,
  apple_id        text,
  site_track_id   text,                        -- the site's internal data-track-id
  preview_url     text,                        -- 30-second preview mp3
  PRIMARY KEY (release_id, disc_no, position)
);
CREATE INDEX release_track_track_id_idx ON release_track (track_id);

-- Videos -----------------------------------------------------------------------

CREATE TABLE video (
  id            integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  youtube_id    text NOT NULL UNIQUE,
  title         text NOT NULL,
  video_date    date,
  video_date_text text,
  thumbnail_url text,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE release_video (
  release_id  integer NOT NULL REFERENCES release ON DELETE CASCADE,
  video_id    integer NOT NULL REFERENCES video ON DELETE CASCADE,
  PRIMARY KEY (release_id, video_id)
);

CREATE TABLE track_video (
  track_id    integer NOT NULL REFERENCES track ON DELETE CASCADE,
  video_id    integer NOT NULL REFERENCES video ON DELETE CASCADE,
  PRIMARY KEY (track_id, video_id)
);

-- Chart history ----------------------------------------------------------------

-- Rows from /releases/chart-history/ plus the chart block on release pages.
-- Album charts set release_id; song charts set track_id (and release_id for
-- the album the site attributes the song to). Titles are kept as printed
-- because not every row links to a page.
CREATE TABLE chart_entry (
  id              integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  chart           text NOT NULL REFERENCES chart (slug),
  title           text NOT NULL,               -- album title or song title as printed
  release_title   text,                        -- song charts only: the album column
  release_id      integer REFERENCES release ON DELETE SET NULL,
  track_id        integer REFERENCES track ON DELETE SET NULL,
  weeks_on_chart  smallint,
  peak_position   smallint,
  peak_date       date,
  UNIQUE NULLS NOT DISTINCT (chart, title, release_title)
);
CREATE INDEX chart_entry_release_id_idx ON chart_entry (release_id);
CREATE INDEX chart_entry_track_id_idx ON chart_entry (track_id);

-- Crawl log ----------------------------------------------------------------------

-- One row per fetched URL, so re-crawls can skip unchanged pages.
CREATE TABLE crawl_page (
  url           text PRIMARY KEY,
  page_kind     text NOT NULL,                 -- release, track, song-list, chart-history, release-list
  http_status   smallint,
  content_hash  text,                          -- sha256 of the response body
  fetched_at    timestamptz NOT NULL DEFAULT now(),
  parsed_at     timestamptz,
  error         text
);

RESET search_path;

-- migrate:down

DROP SCHEMA cash_discography CASCADE;
