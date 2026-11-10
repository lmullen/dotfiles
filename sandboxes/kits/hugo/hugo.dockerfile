# syntax=docker/dockerfile:1.7
# The hugo kit as an overlay: the official Hugo extended release binary at
# /usr/local/bin/hugo, on any glibc base.
#
# The download needs curl, a CA store and a userland that can run the binary
# to check its version, so it uses the template base Docker's own baked
# overlays use.
ARG BASE_IMAGE=docker/sandbox-templates:shell-docker
FROM ${BASE_IMAGE} AS fetch

# hugo.yaml's required `version` arg carries `buildArg: HUGO_VERSION`. No
# default here, so an empty value fails the guard below.
ARG HUGO_VERSION
ARG TARGETARCH

USER root

# Hugo publishes one checksums file per release covering every asset. It is
# fetched over TLS from the same release, which guards against a corrupt or
# truncated download though not against the host itself. TARGETARCH (amd64,
# arm64) matches Hugo's asset naming, so each buildx platform gets its own
# tarball.
RUN set -eu; \
    [ -n "${HUGO_VERSION}" ] || { echo "HUGO_VERSION must be set" >&2; exit 1; }; \
    case "${TARGETARCH}" in \
      amd64|arm64) ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH} (expected amd64 or arm64)" >&2; exit 1 ;; \
    esac; \
    base="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}"; \
    tarball="hugo_extended_${HUGO_VERSION}_linux-${TARGETARCH}.tar.gz"; \
    cd /tmp; \
    curl --proto '=https' --tlsv1.2 -fsSL -o checksums.txt "${base}/hugo_${HUGO_VERSION}_checksums.txt"; \
    curl --proto '=https' --tlsv1.2 -fsSL -o "${tarball}" "${base}/${tarball}"; \
    grep " ${tarball}\$" checksums.txt > want.txt || { echo "no checksum for ${tarball}" >&2; exit 1; }; \
    sha256sum -c want.txt; \
    mkdir -p /out/usr/local/bin; \
    tar -C /out/usr/local/bin -xzf "${tarball}" hugo; \
    chown 0:0 /out/usr/local/bin/hugo; \
    chmod 0755 /out/usr/local/bin/hugo; \
    rm -f checksums.txt want.txt "${tarball}"; \
    # Assert the binary's own report, not the name it was downloaded under.
    banner="$(/out/usr/local/bin/hugo version)"; \
    echo "${banner}"; \
    case "${banner}" in \
      "hugo v${HUGO_VERSION}-"*"+extended "*) ;; \
      *) echo "pin mismatch: kit declares ${HUGO_VERSION} extended, hugo reports '${banner}'" >&2; exit 1 ;; \
    esac

# The overlay: one root-owned binary on PATH. No ENTRYPOINT: the base
# workload's launch command stays.
FROM scratch
COPY --from=fetch /out /
