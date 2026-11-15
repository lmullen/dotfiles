## apt packages

Some command-line tools in this sandbox came from Debian's apt sources at
sandbox create; the list is in the `APT_PACKAGES` environment variable. Among
the ones these sandboxes use:

- `postgresql-client`: `psql`, `pg_dump`, `pg_restore`. No PostgreSQL server
  runs here; `psql` connects to whatever the project's connection string names,
  and reaching that host is up to the sandbox's network policy.
- `poppler-utils`: `pdftotext`, `pdftoppm`, `pdfinfo`, `pdfimages`. To look at
  a PDF page, `pdftoppm -png -r 100 -f N -l N in.pdf page` and read the PNG.
- `librsvg2-bin`: `rsvg-convert`, which renders SVG to PNG or PDF.
- `tzdata`: the time zone database in `/usr/share/zoneinfo`, which Hugo needs
  for a named `timeZone` such as `America/New_York`.

Language toolchains come from mise, not apt.
