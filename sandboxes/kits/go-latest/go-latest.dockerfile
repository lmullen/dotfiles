# syntax=docker/dockerfile:1.7
# The go-latest kit as an overlay: the newest stable Go release, unpacked at
# /usr/local/go on any glibc base.
#
# Same shape as the go kit's go.dockerfile, except the release and its digest
# come from go.dev's release index instead of a pin. The template base has
# curl, jq and a CA store.
ARG BASE_IMAGE=docker/sandbox-templates:shell-docker
FROM ${BASE_IMAGE} AS fetch

ARG TARGETARCH

USER root

# ADD of a URL is re-fetched and compared on every build, so this layer (and
# everything after it) rebuilds whenever go.dev publishes a release. A RUN
# that curled the index would be cached forever and freeze "latest".
ADD https://go.dev/dl/?mode=json /tmp/go-releases.json

# The index lists releases newest first; `stable` excludes betas and RCs. The
# digest comes from the same TLS-served index as the tarball's name, which
# guards against a corrupt or truncated download though not against go.dev
# itself.
RUN set -eu; \
    case "${TARGETARCH}" in \
      amd64|arm64) ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH} (expected amd64 or arm64)" >&2; exit 1 ;; \
    esac; \
    filter='[.[] | select(.stable)][0] as $r | {version: $r.version, file: ($r.files[] | select(.os == "linux" and .arch == $arch and .kind == "archive"))}'; \
    rel="$(jq -c --arg arch "${TARGETARCH}" "${filter}" /tmp/go-releases.json)"; \
    version="$(echo "${rel}" | jq -r .version)"; \
    filename="$(echo "${rel}" | jq -r .file.filename)"; \
    sha256="$(echo "${rel}" | jq -r .file.sha256)"; \
    case "${version}" in go1.*) ;; *) echo "bad version from index: '${version}'" >&2; exit 1 ;; esac; \
    echo "latest stable: ${version} (${filename})"; \
    curl --proto '=https' --tlsv1.2 -fsSL -o /tmp/go.tar.gz "https://dl.google.com/go/${filename}"; \
    echo "${sha256}  /tmp/go.tar.gz" | sha256sum -c -; \
    mkdir -p /out/usr/local; \
    tar -C /out/usr/local -xzf /tmp/go.tar.gz; \
    rm -f /tmp/go.tar.gz /tmp/go-releases.json; \
    # Root-owned, numerically, as in the go kit: the tarball records its
    # publisher's uid, and `scratch` has no /etc/passwd.
    chown -R 0:0 /out/usr/local/go; \
    banner="$(/out/usr/local/go/bin/go version)"; \
    echo "${banner}"; \
    case "${banner}" in \
      "go version ${version} "*) ;; \
      *) echo "mismatch: index says ${version}, go reports '${banner}'" >&2; exit 1 ;; \
    esac

FROM scratch
COPY --from=fetch /out /
