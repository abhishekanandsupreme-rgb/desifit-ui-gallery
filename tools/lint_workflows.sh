#!/usr/bin/env bash
#
# Lint GitHub Actions workflow files locally with the same pinned actionlint
# binary and the same invocation CI uses (see the "Lint workflow files with
# actionlint" step in .github/workflows/android_release.yml). Running this
# before pushing catches workflow breakage that would otherwise fail CI with
# a silent zero-job run (an invalid workflow file produces no log at all).
#
# Usage:
#   bash tools/lint_workflows.sh        # from anywhere in the repo
#   make lint-workflows                 # equivalent
#
# Exit status: 0 if every workflow file passes; nonzero otherwise.
# The binary is cached at ~/.cache/actionlint, matching the CI cache path.

set -euo pipefail

ACL_VERSION="1.7.12"
CACHE_DIR="${HOME}/.cache/actionlint"

# Repo root = parent of the directory this script lives in. Lets the script
# run from any cwd.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# --- platform detection ------------------------------------------------------
OS="$(uname -s)"
MACH="$(uname -m)"

case "${OS}" in
  Linux)
    case "${MACH}" in
      x86_64|amd64)   ASSET="actionlint_${ACL_VERSION}_linux_amd64.tar.gz" ;;
      aarch64|arm64)  ASSET="actionlint_${ACL_VERSION}_linux_arm64.tar.gz" ;;
      *) echo "actionlint: unsupported architecture ${MACH}" >&2; exit 2 ;;
    esac
    BIN="actionlint"
    ;;
  Darwin)
    case "${MACH}" in
      x86_64|amd64)  ASSET="actionlint_${ACL_VERSION}_darwin_amd64.tar.gz" ;;
      arm64)         ASSET="actionlint_${ACL_VERSION}_darwin_arm64.tar.gz" ;;
      *) echo "actionlint: unsupported architecture ${MACH}" >&2; exit 2 ;;
    esac
    BIN="actionlint"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    # actionlint publishes a single Windows x86_64 zip.
    ASSET="actionlint_${ACL_VERSION}_windows_amd64.zip"
    BIN="actionlint.exe"
    ;;
  *)
    echo "actionlint: unsupported OS ${OS}" >&2
    exit 2
    ;;
esac

ACL="${CACHE_DIR}/${BIN}"
URL="https://github.com/rhysd/actionlint/releases/download/v${ACL_VERSION}/${ASSET}"

# --- fetch the pinned binary once (same cache dir CI populates) --------------
if [ ! -x "${ACL}" ]; then
  echo "actionlint v${ACL_VERSION}: not cached at ${ACL}, downloading..."
  mkdir -p "${CACHE_DIR}"
  ok=0
  for i in 1 2 3; do
    if curl -fsSL --retry 3 -o "${CACHE_DIR}/${ASSET}" "${URL}"; then
      ok=1
      break
    fi
    echo "actionlint download attempt ${i} failed (transient network); retrying in 10s" >&2
    sleep 10
  done
  [ "${ok}" = "1" ] || { echo "actionlint download failed after 3 attempts" >&2; exit 1; }

  case "${ASSET}" in
    *.zip) (cd "${CACHE_DIR}" && unzip -oq "${ASSET}") ;;
    *)     tar -xzf "${CACHE_DIR}/${ASSET}" -C "${CACHE_DIR}" ;;
  esac
  rm -f "${CACHE_DIR}/${ASSET}"
fi

if [ ! -x "${ACL}" ]; then
  echo "actionlint: binary not found at ${ACL}" >&2
  exit 1
fi

# --- lint, byte-for-byte the CI invocation -----------------------------------
cd "${REPO_ROOT}"
find .github/workflows -maxdepth 1 \( -name "*.yml" -o -name "*.yaml" \) \
  -exec "${ACL}" -config-file .github/actionlint.yaml {} +
