#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

VERSION="${1:-7.2.0}"
PLATFORM="${PLATFORM:-linux/arm64}"
RUN_TESTS="${RUN_TESTS:-0}"
TEST_IMAGE="minarca-client-arm64:${VERSION}-test"

usage() {
  cat <<EOF
Usage: ./build.sh [VERSION]

Build and smoke-test the Minarca client arm64 .deb locally via Docker.

  VERSION   Upstream git tag to build (default: 7.2.0)

Environment:
  PLATFORM   Docker platform (default: linux/arm64)
  SKIP_TEST  Set to 1 to only export the .deb without running the install smoke-test
  RUN_TESTS  Set to 1 to also run upstream unit tests during the package build
             (default: 0; disk discovery fails in most containers)

Examples:
  ./build.sh
  ./build.sh 7.2.0
  SKIP_TEST=1 ./build.sh 7.2.0
  RUN_TESTS=1 ./build.sh 7.2.0
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

mkdir -p dist

echo "==> Building minarca-client ${VERSION} (${PLATFORM})"
echo "==> Exporting .deb to ./dist"
docker buildx build \
  --platform "${PLATFORM}" \
  --build-arg "MINARCA_VERSION=${VERSION}" \
  --build-arg "RUN_TESTS=${RUN_TESTS}" \
  --target export \
  -o "type=local,dest=./dist" \
  .

DEB="dist/minarca-client_${VERSION}_arm64.deb"
if [[ ! -f "${DEB}" ]]; then
  echo "Expected package not found: ${DEB}" >&2
  ls -la dist || true
  exit 1
fi

echo "==> Built ${DEB}"
ls -lh "${DEB}"

if [[ "${SKIP_TEST:-0}" == "1" ]]; then
  echo "==> Skipping install smoke-test (SKIP_TEST=1)"
  exit 0
fi

echo "==> Building and running install smoke-test image"
docker buildx build \
  --platform "${PLATFORM}" \
  --build-arg "MINARCA_VERSION=${VERSION}" \
  --build-arg "RUN_TESTS=${RUN_TESTS}" \
  --target test \
  --load \
  -t "${TEST_IMAGE}" \
  .

docker run --rm "${TEST_IMAGE}"
echo "==> Smoke-test passed"
