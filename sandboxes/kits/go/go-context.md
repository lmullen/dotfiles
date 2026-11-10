## Go toolchain

This sandbox has Go 1.27 (latest patch release when the sandbox was created),
installed from apt: `go` and `gofmt` are in /usr/bin and GOROOT is /usr/lib/go.
Run `go version` to see the release. The Go module proxy (proxy.golang.org)
and checksum database (sum.golang.org) are allowed by network policy, so
`go mod download`, `go build` and `go test ./...` can fetch dependencies
without further setup. Binaries from `go install` land in
`$(go env GOPATH)/bin`, which is ~/go/bin and is not on PATH by default.
