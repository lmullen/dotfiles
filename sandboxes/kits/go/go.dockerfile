# syntax=docker/dockerfile:1.7
# The go kit as an overlay: the official Go release tarball, unpacked at
# /usr/local/go on any base.
#
# The Go tarball is a self-contained tree with nothing create-time in it, so it
# builds once, digest-checked, and ships as content. (Compare the sibling psql
# kit, whose apt package is not copyable content and so stays an install hook.)
#
# /usr/local/go is where the official install instructions put Go and where the
# claude workload already looks: its PATH carries /usr/local/go/bin, so nothing
# here has to touch profile.d or the environment.
#
# The download needs a glibc userland with curl, a CA store and a shell that can
# run the unpacked binary to check its version, so it gets the template base
# Docker's own baked overlays use.
ARG BASE_IMAGE=docker/sandbox-templates:shell-docker
FROM ${BASE_IMAGE} AS fetch

# THE PIN. go.yaml's `version` arg carries `buildArg: GO_VERSION`, so the
# frontend hands this build `--build-arg GO_VERSION=<pin>`, and the same value
# expands into the descriptor's `provides` and `version`. No default here,
# deliberately: a second place for the version to live is a place for it to
# drift, and an empty value fails the guard below rather than fetching
# something unintended.
ARG GO_VERSION
ARG TARGETARCH

USER root

# TARGETARCH rather than `uname -m` or `dpkg --print-architecture`: buildx sets
# it per platform, so `--platform linux/amd64,linux/arm64` resolves each leg to
# its own tarball, and Go names its tarballs in the same vocabulary.
#
# The digest table pins the kit's default release for both architectures. The
# values are the ones dl.google.com publishes in the .sha256 sidecar next to
# each tarball, cross-checked against docker-library/golang's versions.json.
# A release not in the table (someone passed `--kit-arg version=...`) is checked
# against the sidecar fetched over TLS from the same host, which guards against
# a corrupt or truncated download though not against the host itself; the
# build says so. TO BUMP THE DEFAULT: add the new release's two digests here
# and change the default in go.yaml together.
RUN set -eu; \
    [ -n "${GO_VERSION}" ] || { echo "GO_VERSION must be set" >&2; exit 1; }; \
    case "${TARGETARCH}" in \
      amd64|arm64) ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH} (expected amd64 or arm64)" >&2; exit 1 ;; \
    esac; \
    tarball="go${GO_VERSION}.linux-${TARGETARCH}.tar.gz"; \
    url="https://dl.google.com/go/${tarball}"; \
    case "${GO_VERSION}-${TARGETARCH}" in \
      1.26.10-amd64) sha256=ccfe7ae822d2c2f41f4fe7c956199967a4dac22d0ee0d2b2bfdb440aab3b20c5 ;; \
      1.26.10-arm64) sha256=3f4227ce7b206a513e794f1393adb473a07b46e94d18bd15d1c684bbb7319797 ;; \
      *) \
        echo "no pinned digest for go${GO_VERSION} ${TARGETARCH}; trusting the .sha256 sidecar from dl.google.com" >&2; \
        sha256="$(curl --proto '=https' --tlsv1.2 -fsSL "${url}.sha256")"; \
        case "${sha256}" in \
          [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]*) ;; \
          *) echo "sidecar did not yield a digest: '${sha256}'" >&2; exit 1 ;; \
        esac ;; \
    esac; \
    curl --proto '=https' --tlsv1.2 -fsSL -o /tmp/go.tar.gz "${url}"; \
    echo "${sha256}  /tmp/go.tar.gz" | sha256sum -c -; \
    mkdir -p /out/usr/local; \
    tar -C /out/usr/local -xzf /tmp/go.tar.gz; \
    rm -f /tmp/go.tar.gz; \
    # The tarball records its publisher's uid and tar preserves it; as image
    # content on an unknown base that id may be a real account. /usr/local is
    # root on any base, so root is what the tree should be here too. Numeric,
    # because `scratch` carries no /etc/passwd for a name to resolve against.
    chown -R 0:0 /out/usr/local/go; \
    # The pin's own check, and the reason the provide can be trusted: what is
    # asserted is the tarball's payload, not the name it was downloaded under.
    banner="$(/out/usr/local/go/bin/go version)"; \
    echo "go version: ${banner}"; \
    case "${banner}" in \
      "go version go${GO_VERSION} "*) ;; \
      *) echo "pin mismatch: kit declares ${GO_VERSION}, go reports '${banner}'" >&2; exit 1 ;; \
    esac

# The overlay: the Go tree at /usr/local/go, root-owned, landing on any base.
# Nothing is staged under the agent's home, which may be a mounted volume. No
# ENTRYPOINT: the base workload's launch command stays.
FROM scratch
COPY --from=fetch /out /
