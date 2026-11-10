## Go toolchain

This sandbox has the most recent stable Go release (as of when the sandbox
was created) at /usr/local/go. It is on PATH, so `go` and `gofmt` work
directly; run `go version` to see the release. The Go module proxy
(proxy.golang.org) and checksum database (sum.golang.org) are allowed by
network policy, so `go mod download`, `go build` and `go test ./...` can fetch
dependencies without further setup. Binaries from `go install` land in
`$(go env GOPATH)/bin`, which is ~/go/bin and is not on PATH by default.
