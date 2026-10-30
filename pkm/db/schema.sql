\restrict dbmate

-- Dumped from database version 18.6 (Debian 18.6-1.pgdg12+2)
-- Dumped by pg_dump version 18.6 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: cash_discography; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA cash_discography;


--
-- Name: sys_admin; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA sys_admin;


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: unaccent; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS unaccent WITH SCHEMA public;


--
-- Name: EXTENSION unaccent; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION unaccent IS 'text search dictionary that removes accents';


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: cash_discography; Owner: -
--

CREATE FUNCTION cash_discography.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: chart; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.chart (
    slug text NOT NULL,
    name text NOT NULL,
    country text DEFAULT 'United States'::text NOT NULL,
    chart_kind text NOT NULL,
    CONSTRAINT chart_chart_kind_check CHECK ((chart_kind = ANY (ARRAY['album'::text, 'song'::text])))
);


--
-- Name: chart_entry; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.chart_entry (
    id integer NOT NULL,
    chart text NOT NULL,
    title text NOT NULL,
    release_title text,
    release_id integer,
    track_id integer,
    weeks_on_chart smallint,
    peak_position smallint,
    peak_date date
);


--
-- Name: chart_entry_id_seq; Type: SEQUENCE; Schema: cash_discography; Owner: -
--

ALTER TABLE cash_discography.chart_entry ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME cash_discography.chart_entry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: crawl_page; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.crawl_page (
    url text NOT NULL,
    page_kind text NOT NULL,
    http_status smallint,
    content_hash text,
    fetched_at timestamp with time zone DEFAULT now() NOT NULL,
    parsed_at timestamp with time zone,
    error text
);


--
-- Name: person; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.person (
    id integer NOT NULL,
    name text NOT NULL,
    notes text
);


--
-- Name: person_id_seq; Type: SEQUENCE; Schema: cash_discography; Owner: -
--

ALTER TABLE cash_discography.person ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME cash_discography.person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: release; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.release (
    id integer NOT NULL,
    slug text NOT NULL,
    source_url text NOT NULL,
    title text NOT NULL,
    release_type text NOT NULL,
    release_date date,
    release_date_text text,
    cover_image_url text,
    description_html text,
    description_text text,
    riaa_certification text,
    spotify_uri text,
    apple_id text,
    deezer_id text,
    external_links jsonb DEFAULT '[]'::jsonb NOT NULL,
    raw jsonb,
    fetched_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: release_credit; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.release_credit (
    release_id integer NOT NULL,
    person_id integer NOT NULL,
    role text NOT NULL,
    "position" smallint DEFAULT 1 NOT NULL
);


--
-- Name: release_id_seq; Type: SEQUENCE; Schema: cash_discography; Owner: -
--

ALTER TABLE cash_discography.release ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME cash_discography.release_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: release_tag; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.release_tag (
    release_id integer NOT NULL,
    tag text NOT NULL
);


--
-- Name: release_track; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.release_track (
    release_id integer NOT NULL,
    disc_no smallint DEFAULT 1 NOT NULL,
    "position" smallint NOT NULL,
    track_id integer,
    title text NOT NULL,
    duration interval,
    released_as_single boolean DEFAULT false NOT NULL,
    has_video boolean DEFAULT false NOT NULL,
    spotify_uri text,
    apple_id text,
    site_track_id text,
    preview_url text
);


--
-- Name: release_video; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.release_video (
    release_id integer NOT NULL,
    video_id integer NOT NULL
);


--
-- Name: song; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.song (
    id integer NOT NULL,
    title text NOT NULL,
    canonical_title text NOT NULL,
    written_by_cash boolean,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: song_id_seq; Type: SEQUENCE; Schema: cash_discography; Owner: -
--

ALTER TABLE cash_discography.song ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME cash_discography.song_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: song_writer; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.song_writer (
    song_id integer NOT NULL,
    person_id integer NOT NULL,
    "position" smallint DEFAULT 1 NOT NULL
);


--
-- Name: tag; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.tag (
    slug text NOT NULL,
    label text NOT NULL,
    is_type boolean DEFAULT false NOT NULL
);


--
-- Name: track; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.track (
    id integer NOT NULL,
    slug text NOT NULL,
    source_url text NOT NULL,
    title text NOT NULL,
    song_id integer,
    release_id integer,
    from_text text,
    track_date date,
    track_date_text text,
    listed_as text,
    cover_image_url text,
    songwriter_text text,
    lyrics_html text,
    lyrics_text text,
    spotify_uri text,
    apple_id text,
    deezer_id text,
    external_links jsonb DEFAULT '[]'::jsonb NOT NULL,
    raw jsonb,
    fetched_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: track_credit; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.track_credit (
    track_id integer NOT NULL,
    person_id integer NOT NULL,
    role text NOT NULL,
    "position" smallint DEFAULT 1 NOT NULL
);


--
-- Name: track_id_seq; Type: SEQUENCE; Schema: cash_discography; Owner: -
--

ALTER TABLE cash_discography.track ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME cash_discography.track_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: track_video; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.track_video (
    track_id integer NOT NULL,
    video_id integer NOT NULL
);


--
-- Name: video; Type: TABLE; Schema: cash_discography; Owner: -
--

CREATE TABLE cash_discography.video (
    id integer NOT NULL,
    youtube_id text NOT NULL,
    title text NOT NULL,
    video_date date,
    video_date_text text,
    thumbnail_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: video_id_seq; Type: SEQUENCE; Schema: cash_discography; Owner: -
--

ALTER TABLE cash_discography.video ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME cash_discography.video_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: migrations_dbmate; Type: TABLE; Schema: sys_admin; Owner: -
--

CREATE TABLE sys_admin.migrations_dbmate (
    version character varying NOT NULL
);


--
-- Name: chart_entry chart_entry_chart_title_release_title_key; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.chart_entry
    ADD CONSTRAINT chart_entry_chart_title_release_title_key UNIQUE NULLS NOT DISTINCT (chart, title, release_title);


--
-- Name: chart_entry chart_entry_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.chart_entry
    ADD CONSTRAINT chart_entry_pkey PRIMARY KEY (id);


--
-- Name: chart chart_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.chart
    ADD CONSTRAINT chart_pkey PRIMARY KEY (slug);


--
-- Name: crawl_page crawl_page_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.crawl_page
    ADD CONSTRAINT crawl_page_pkey PRIMARY KEY (url);


--
-- Name: person person_name_key; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.person
    ADD CONSTRAINT person_name_key UNIQUE (name);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (id);


--
-- Name: release_credit release_credit_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release_credit
    ADD CONSTRAINT release_credit_pkey PRIMARY KEY (release_id, person_id, role);


--
-- Name: release release_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release
    ADD CONSTRAINT release_pkey PRIMARY KEY (id);


--
-- Name: release release_slug_key; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release
    ADD CONSTRAINT release_slug_key UNIQUE (slug);


--
-- Name: release release_source_url_key; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release
    ADD CONSTRAINT release_source_url_key UNIQUE (source_url);


--
-- Name: release_tag release_tag_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release_tag
    ADD CONSTRAINT release_tag_pkey PRIMARY KEY (release_id, tag);


--
-- Name: release_track release_track_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release_track
    ADD CONSTRAINT release_track_pkey PRIMARY KEY (release_id, disc_no, "position");


--
-- Name: release_video release_video_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release_video
    ADD CONSTRAINT release_video_pkey PRIMARY KEY (release_id, video_id);


--
-- Name: song song_canonical_title_key; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.song
    ADD CONSTRAINT song_canonical_title_key UNIQUE (canonical_title);


--
-- Name: song song_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.song
    ADD CONSTRAINT song_pkey PRIMARY KEY (id);


--
-- Name: song_writer song_writer_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.song_writer
    ADD CONSTRAINT song_writer_pkey PRIMARY KEY (song_id, person_id);


--
-- Name: tag tag_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.tag
    ADD CONSTRAINT tag_pkey PRIMARY KEY (slug);


--
-- Name: track_credit track_credit_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.track_credit
    ADD CONSTRAINT track_credit_pkey PRIMARY KEY (track_id, person_id, role);


--
-- Name: track track_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.track
    ADD CONSTRAINT track_pkey PRIMARY KEY (id);


--
-- Name: track track_slug_key; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.track
    ADD CONSTRAINT track_slug_key UNIQUE (slug);


--
-- Name: track track_source_url_key; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.track
    ADD CONSTRAINT track_source_url_key UNIQUE (source_url);


--
-- Name: track_video track_video_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.track_video
    ADD CONSTRAINT track_video_pkey PRIMARY KEY (track_id, video_id);


--
-- Name: video video_pkey; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.video
    ADD CONSTRAINT video_pkey PRIMARY KEY (id);


--
-- Name: video video_youtube_id_key; Type: CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.video
    ADD CONSTRAINT video_youtube_id_key UNIQUE (youtube_id);


--
-- Name: migrations_dbmate migrations_dbmate_pkey; Type: CONSTRAINT; Schema: sys_admin; Owner: -
--

ALTER TABLE ONLY sys_admin.migrations_dbmate
    ADD CONSTRAINT migrations_dbmate_pkey PRIMARY KEY (version);


--
-- Name: chart_entry_release_id_idx; Type: INDEX; Schema: cash_discography; Owner: -
--

CREATE INDEX chart_entry_release_id_idx ON cash_discography.chart_entry USING btree (release_id);


--
-- Name: chart_entry_track_id_idx; Type: INDEX; Schema: cash_discography; Owner: -
--

CREATE INDEX chart_entry_track_id_idx ON cash_discography.chart_entry USING btree (track_id);


--
-- Name: release_release_date_idx; Type: INDEX; Schema: cash_discography; Owner: -
--

CREATE INDEX release_release_date_idx ON cash_discography.release USING btree (release_date);


--
-- Name: release_title_trgm; Type: INDEX; Schema: cash_discography; Owner: -
--

CREATE INDEX release_title_trgm ON cash_discography.release USING gin (title public.gin_trgm_ops);


--
-- Name: release_track_track_id_idx; Type: INDEX; Schema: cash_discography; Owner: -
--

CREATE INDEX release_track_track_id_idx ON cash_discography.release_track USING btree (track_id);


--
-- Name: song_canonical_title_trgm; Type: INDEX; Schema: cash_discography; Owner: -
--

CREATE INDEX song_canonical_title_trgm ON cash_discography.song USING gin (canonical_title public.gin_trgm_ops);


--
-- Name: track_release_id_idx; Type: INDEX; Schema: cash_discography; Owner: -
--

CREATE INDEX track_release_id_idx ON cash_discography.track USING btree (release_id);


--
-- Name: track_song_id_idx; Type: INDEX; Schema: cash_discography; Owner: -
--

CREATE INDEX track_song_id_idx ON cash_discography.track USING btree (song_id);


--
-- Name: track_title_trgm; Type: INDEX; Schema: cash_discography; Owner: -
--

CREATE INDEX track_title_trgm ON cash_discography.track USING gin (title public.gin_trgm_ops);


--
-- Name: track_track_date_idx; Type: INDEX; Schema: cash_discography; Owner: -
--

CREATE INDEX track_track_date_idx ON cash_discography.track USING btree (track_date);


--
-- Name: release release_updated_at; Type: TRIGGER; Schema: cash_discography; Owner: -
--

CREATE TRIGGER release_updated_at BEFORE UPDATE ON cash_discography.release FOR EACH ROW EXECUTE FUNCTION cash_discography.set_updated_at();


--
-- Name: track track_updated_at; Type: TRIGGER; Schema: cash_discography; Owner: -
--

CREATE TRIGGER track_updated_at BEFORE UPDATE ON cash_discography.track FOR EACH ROW EXECUTE FUNCTION cash_discography.set_updated_at();


--
-- Name: chart_entry chart_entry_chart_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.chart_entry
    ADD CONSTRAINT chart_entry_chart_fkey FOREIGN KEY (chart) REFERENCES cash_discography.chart(slug);


--
-- Name: chart_entry chart_entry_release_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.chart_entry
    ADD CONSTRAINT chart_entry_release_id_fkey FOREIGN KEY (release_id) REFERENCES cash_discography.release(id) ON DELETE SET NULL;


--
-- Name: chart_entry chart_entry_track_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.chart_entry
    ADD CONSTRAINT chart_entry_track_id_fkey FOREIGN KEY (track_id) REFERENCES cash_discography.track(id) ON DELETE SET NULL;


--
-- Name: release_credit release_credit_person_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release_credit
    ADD CONSTRAINT release_credit_person_id_fkey FOREIGN KEY (person_id) REFERENCES cash_discography.person(id) ON DELETE RESTRICT;


--
-- Name: release_credit release_credit_release_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release_credit
    ADD CONSTRAINT release_credit_release_id_fkey FOREIGN KEY (release_id) REFERENCES cash_discography.release(id) ON DELETE CASCADE;


--
-- Name: release release_release_type_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release
    ADD CONSTRAINT release_release_type_fkey FOREIGN KEY (release_type) REFERENCES cash_discography.tag(slug);


--
-- Name: release_tag release_tag_release_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release_tag
    ADD CONSTRAINT release_tag_release_id_fkey FOREIGN KEY (release_id) REFERENCES cash_discography.release(id) ON DELETE CASCADE;


--
-- Name: release_tag release_tag_tag_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release_tag
    ADD CONSTRAINT release_tag_tag_fkey FOREIGN KEY (tag) REFERENCES cash_discography.tag(slug);


--
-- Name: release_track release_track_release_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release_track
    ADD CONSTRAINT release_track_release_id_fkey FOREIGN KEY (release_id) REFERENCES cash_discography.release(id) ON DELETE CASCADE;


--
-- Name: release_track release_track_track_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release_track
    ADD CONSTRAINT release_track_track_id_fkey FOREIGN KEY (track_id) REFERENCES cash_discography.track(id) ON DELETE SET NULL;


--
-- Name: release_video release_video_release_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release_video
    ADD CONSTRAINT release_video_release_id_fkey FOREIGN KEY (release_id) REFERENCES cash_discography.release(id) ON DELETE CASCADE;


--
-- Name: release_video release_video_video_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.release_video
    ADD CONSTRAINT release_video_video_id_fkey FOREIGN KEY (video_id) REFERENCES cash_discography.video(id) ON DELETE CASCADE;


--
-- Name: song_writer song_writer_person_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.song_writer
    ADD CONSTRAINT song_writer_person_id_fkey FOREIGN KEY (person_id) REFERENCES cash_discography.person(id) ON DELETE RESTRICT;


--
-- Name: song_writer song_writer_song_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.song_writer
    ADD CONSTRAINT song_writer_song_id_fkey FOREIGN KEY (song_id) REFERENCES cash_discography.song(id) ON DELETE CASCADE;


--
-- Name: track_credit track_credit_person_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.track_credit
    ADD CONSTRAINT track_credit_person_id_fkey FOREIGN KEY (person_id) REFERENCES cash_discography.person(id) ON DELETE RESTRICT;


--
-- Name: track_credit track_credit_track_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.track_credit
    ADD CONSTRAINT track_credit_track_id_fkey FOREIGN KEY (track_id) REFERENCES cash_discography.track(id) ON DELETE CASCADE;


--
-- Name: track track_listed_as_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.track
    ADD CONSTRAINT track_listed_as_fkey FOREIGN KEY (listed_as) REFERENCES cash_discography.tag(slug);


--
-- Name: track track_release_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.track
    ADD CONSTRAINT track_release_id_fkey FOREIGN KEY (release_id) REFERENCES cash_discography.release(id) ON DELETE SET NULL;


--
-- Name: track track_song_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.track
    ADD CONSTRAINT track_song_id_fkey FOREIGN KEY (song_id) REFERENCES cash_discography.song(id) ON DELETE SET NULL;


--
-- Name: track_video track_video_track_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.track_video
    ADD CONSTRAINT track_video_track_id_fkey FOREIGN KEY (track_id) REFERENCES cash_discography.track(id) ON DELETE CASCADE;


--
-- Name: track_video track_video_video_id_fkey; Type: FK CONSTRAINT; Schema: cash_discography; Owner: -
--

ALTER TABLE ONLY cash_discography.track_video
    ADD CONSTRAINT track_video_video_id_fkey FOREIGN KEY (video_id) REFERENCES cash_discography.video(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict dbmate


--
-- Dbmate schema migrations
--

INSERT INTO sys_admin.migrations_dbmate (version) VALUES
    ('20261030000000'),
    ('20261030020000');
