#!/usr/bin/env bash
#
# Bootstrap a pinned stable Flutter SDK into .sdk/flutter/<version> for local
# runs. The version comes from .flutter-version at the repo root — the same
# pin CI uses (android_release.yml reads it), so local suites and CI exercise
# identical tooling.
#
# Usage:
#   bash tools/bootstrap_flutter.sh          # from anywhere in the repo
#   make bootstrap-flutter                   # equivalent
#
# Exit status: 0 when .sdk/flutter/<version>/bin/flutter is ready; nonzero
# otherwise. The downloaded archive is cached in .sdk/downloads/ so re-running
# after deleting the SDK tree skips the network entirely.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION_FILE="${REPO_ROOT}/.flutter-version"
SDK_ROOT="${REPO_ROOT}/.sdk"
CACHE_DIR="${SDK_ROOT}/downloads"

[ -f "${VERSION_FILE}" ] || { echo "bootstrap: missing ${VERSION_FILE}" >&2; exit 2; }
FLUTTER_VERSION="$(tr -d '[:space:]' < "${VERSION_FILE}")"
[ -n "${FLUTTER_VERSION}" ] || { echo "bootstrap: ${VERSION_FILE} is empty" >&2; exit 2; }

# --- platform detection (matches flutter_infra_release release names) --------
OS="$(uname -s)"
case "${OS}" in
  Linux)          PLATFORM="linux"   ARCHIVE="flutter_${FLUTTER_VERSION}-stable.tar.xz"      EXTRACT="tar" ;;
  Darwin)         PLATFORM="macos"   ARCHIVE="flutter_${FLUTTER_VERSION}-stable-macos.zip"   EXTRACT="unzip" ;;
  MINGW*|MSYS*|CYGWIN*) PLATFORM="windows" ARCHIVE="flutter_windows_${FLUTTER_VERSION}-stable.zip" EXTRACT="unzip" ;;
  *) echo "bootstrap: unsupported OS ${OS}" >&2; exit 2 ;;
esac

DEST="${SDK_ROOT}/flutter/${FLUTTER_VERSION}"
FLUTTER_BIN="${DEST}/bin/flutter"
URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/${PLATFORM}/${ARCHIVE}"

# --- already bootstrapped? ----------------------------------------------------
if [ -x "${FLUTTER_BIN}" ]; then
  echo "bootstrap: Flutter ${FLUTTER_VERSION} already present at ${DEST}"
  "${FLUTTER_BIN}" --version -q 2>/dev/null | head -1 || true
  exit 0
fi

# --- download (cached, 3 attempts like every other fetch in this repo) --------
mkdir -p "${CACHE_DIR}" "${DEST}"
ARCHIVE_PATH="${CACHE_DIR}/${ARCHIVE}"
if [ ! -f "${ARCHIVE_PATH}" ]; then
  echo "bootstrap: downloading Flutter ${FLUTTER_VERSION} (${PLATFORM})..."
  ok=0
  for i in 1 2 3; do
    if curl -fSL --retry 3 --progress-bar -o "${ARCHIVE_PATH}.part" "${URL}"; then
      mv "${ARCHIVE_PATH}.part" "${ARCHIVE_PATH}"
      ok=1
      break
    fi
    echo "bootstrap: download attempt ${i} failed; retrying in 10s" >&2
    sleep 10
  done
  [ "${ok}" = "1" ] || { echo "bootstrap: download failed after 3 attempts" >&2; exit 1; }
else
  echo "bootstrap: using cached archive ${ARCHIVE_PATH}"
fi

# --- extract ------------------------------------------------------------------
echo "bootstrap: extracting into ${DEST}..."
case "${EXTRACT}" in
  tar)
    tar -xJf "${ARCHIVE_PATH}" -C "${DEST}" --strip-components=1
    ;;
  unzip)
    # Windows-only. Prefer the OS-bundled bsdtar (libarchive) when present:
    # it extracts the same zip several times faster than Info-ZIP unzip,
    # which on a slow disk with antivirus scanning can take an hour.
    BSDTAR=""
    for cand in /c/Windows/System32/tar.exe /mnt/c/Windows/System32/tar.exe; do
      [ -f "${cand}" ] && BSDTAR="${cand}" && break
    done
    if [ -n "${BSDTAR}" ]; then
      # --strip-components=1 drops the archive's top-level flutter/ dir so
      # DEST *is* the SDK root (bin/ lives directly under DEST).
      "${BSDTAR}" -xf "${ARCHIVE_PATH}" -C "${DEST}" --strip-components=1
    else
      TMP_EXTRACT="${DEST}.extracting"
      rm -rf "${TMP_EXTRACT}"
      mkdir -p "${TMP_EXTRACT}"
      unzip -oq "${ARCHIVE_PATH}" -d "${TMP_EXTRACT}"
      inner="$(find "${TMP_EXTRACT}" -maxdepth 1 -mindepth 1 -type d | head -1)"
      [ -n "${inner}" ] || { echo "bootstrap: unexpected archive layout" >&2; exit 1; }
      # Move contents up one level (mv across the same volume is instant).
      (shopt -s dotglob; mv "${TMP_EXTRACT}"/*/* "${DEST}/" 2>/dev/null || mv "${inner}"/* "${DEST}/")
      rm -rf "${TMP_EXTRACT}"
    fi
    ;;
esac

[ -f "${FLUTTER_BIN}" ] || { echo "bootstrap: ${FLUTTER_BIN} not found after extraction" >&2; exit 1; }
chmod +x "${FLUTTER_BIN}" 2>/dev/null || true

# --- first-run materialization (Dart SDK is bundled; this just stamps the cache)
echo "bootstrap: running flutter --version (first run)..."
"${FLUTTER_BIN}" --version

echo "bootstrap: done — Flutter ${FLUTTER_VERSION} ready at ${DEST}"
echo "bootstrap: the Makefile targets (test-desifit, test-aurasync) use it automatically."