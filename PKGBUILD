# Maintainer: SilverX <serainox@gmail.com>
pkgname=ada-agent-git
_repo=Assertion-Driven-Architecture
pkgver=r80.ef843f5
pkgrel=1
pkgdesc="ADA: assertion-driven main loop for LLM agents (CLI + interactive TUI)"
arch=('x86_64' 'aarch64')
url="https://github.com/Szmelc-INC/Assertion-Driven-Architecture"
license=('MIT')
makedepends=('git' 'go')
optdepends=('ollama: local model server for the agent')
provides=('ada-agent')
conflicts=('ada-agent')
options=('!debug')
source=("git+$url.git")
sha256sums=('SKIP')

pkgver() {
  cd "$_repo"
  ( set -o pipefail
    git describe --long --tags --abbrev=7 2>/dev/null | sed 's/^v//;s/\([^-]*-g\)/r\1/;s/-/./g' ||
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short=7 HEAD)" )
}

prepare() {
  cd "$_repo"
  export GOPATH="$srcdir/gopath" GOFLAGS="-modcacherw"
  go mod download
}

build() {
  cd "$_repo"
  export GOPATH="$srcdir/gopath" CGO_ENABLED=0 GOFLAGS="-trimpath -mod=readonly -modcacherw"
  go build -ldflags "-s -w -X main.version=$pkgver" -o ada ./cmd/adax
  go build -ldflags "-s -w" -o ada_agent ./cmd/ada
}

check() {
  cd "$_repo"
  export GOPATH="$srcdir/gopath" GOFLAGS="-mod=readonly -modcacherw"
  HOME="$srcdir" go test ./...
}

package() {
  cd "$_repo"
  install -Dm755 ada ada_agent -t "$pkgdir/usr/bin/"
  install -Dm644 README.md -t "$pkgdir/usr/share/doc/$pkgname/"
  cp -r benchmarks "$pkgdir/usr/share/doc/$pkgname/"
  install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
