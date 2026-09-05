# DesiFit UI Gallery

Monorepo for the DesiFit wellness app: the Flutter app, its companion app, the
30-screen HTML UI gallery with its animation engine, and the CI gates that keep
them all honest.

## Repository layout

| Path | What it is |
|---|---|
| `desifit/` | The main Flutter app (dashboard, calorie counter, workout, Sasta protein calculator). `flutter analyze` + `flutter test` are gated in CI. |
| `AuraSync/` | Companion Flutter app (analyze + tests gated in CI). |
| `stitch_desifit_ui_design/` | The 30-screen HTML gallery: `index.html`, `animation-engine.js` (window.DesiFitAnim), `screen-nav.js`, per-screen folders, `google_flow/` (asset-generation prompts for images/videos/graphics/icons/effects/sound/music), and `test/` (Playwright specs). |
| `tools/` | SDK-free CI gates: `check_dart_syntax.js` (bracket balance), `check_signing_template.js` (key.properties contract drift), `check_no_private_keys.js` (no private-key material in the tree), `lint_workflows.sh` (local actionlint runner, same binary + invocation as CI). |
| `.githooks/` + `Makefile` | Local mirrors of the CI gates: a pre-push hook and `make` targets (see [Local developer workflow](#local-developer-workflow)). |
| `.github/workflows/android_release.yml` | The entire CI pipeline (see below). |
| `firestore.rules` | The real Firestore security boundary — its header comment documents the security model and the Firebase client-config tracking policy. |

## CI model (`android_release.yml`)

One workflow, four jobs, `needs: syntax-gate`:

1. **Dart syntax balance** (SDK-free, runs on every push and PR) — the three
   `tools/` gates plus **actionlint** (pinned v1.7.12, cached, retried) which
   rejects malformed workflow YAML loudly instead of GitHub's silent zero-job
   failure.
2. **Analyze & Test AuraSync** — `flutter analyze` + `flutter test`.
3. **Test gallery screens (Playwright)** — headless Chromium against the real
   gallery; browsers cached and install-retried; `retries: 2` in CI; traces
   and test results uploaded on failure.
4. **Build Release AAB** — the Android release build. Signing/build/upload
   steps are `push`-only, so PRs run the checks without building.

## Local developer workflow

The CI syntax-gate has a 1:1 local mirror. Enable it once per clone:

```bash
make install-hooks      # sets core.hooksPath to .githooks/
```

After that, every `git push` runs only the gates relevant to the pushed
range, so a mistake is caught on your machine instead of in a CI round-trip:

| Local gate (pre-push hook) | Trigger — runs when the push touches | CI counterpart (syntax-gate job) |
|---|---|---|
| `tools/lint_workflows.sh` (actionlint v1.7.12) | `.github/workflows/` | "Lint workflow files with actionlint" |
| `node tools/check_dart_syntax.js` | any `.dart` file | "Check Dart bracket balance (desifit + AuraSync)" |
| `node tools/check_signing_template.js` | `key.properties.example`, `app/build.gradle.kts`, or `android_release.yml` | "Check signing-template drift" |
| `node tools/check_no_private_keys.js` | **any file** — a key can hide in any file type, so the repo-wide scan is never skipped | "Check for private-key material" |

Scope rules: a new branch (or an unknown remote tip) runs every gate rather
than risk a false negative; branch deletions run nothing; if `node` is not
installed the Node gates are skipped with a warning, never failed.

To run everything by hand, without pushing:

```bash
make lint-local         # all four gates in one command
make lint-workflows     # actionlint only
make uninstall-hooks    # disable the pre-push hook
```

`make lint-local` is also the fastest way to preview exactly what the
syntax-gate job will do to a branch before opening the PR.

## Security model

- **Signing material is never committed.** `desifit/android/key.properties`
  and `key.jks` are git-ignored; `key.properties.example` is the committed
  template and its header documents the four-key contract with the build
  script and CI. `tools/check_signing_template.js` fails CI if they drift.
- **No private keys in the tree.** `tools/check_no_private_keys.js` scans
  every tracked file and fails the build if `BEGIN ... PRIVATE KEY` material
  appears.
- **Firebase client config (tracked by design).** `firebase_options.dart` and
  `google-services.json` contain only client-side identifiers that ship in
  the app binary anyway; access control lives in `firestore.rules` (owner-only
  writes). Never commit a service-account key — the gate will fail you.

## Running the Flutter suites locally

The Flutter SDK version is pinned once, in `.flutter-version`, and three
consumers stay in sync with it (enforced by `tools/check_flutter_pin.js`
in CI): the local bootstrap, and both `Set up Flutter` steps in the release
workflow. To run the desifit/AuraSync suites on the exact tooling CI uses:

```bash
make bootstrap-flutter   # downloads + installs the pinned SDK into .sdk/ (cached)
make test-desifit        # pub get + flutter test (auto-bootstraps the SDK first)
make test-aurasync       # same, for AuraSync
```

The SDK lives under `.sdk/` (git-ignored); the downloaded archive is kept in
`.sdk/downloads/` so deleting the SDK tree and re-bootstrapping skips the
network. CI pins the same version, so local results transfer.

## Running the gallery tests locally

```bash
cd stitch_desifit_ui_design
npm install
npx playwright install chromium
npx playwright test
```

The suite is ~158 tests across `test/anim-engine.spec.js` (animation engine
API) and `test/screen-nav.spec.js` (per-screen nav, dark mode, compare
overlay). Both specs share the same page-per-file model, so tests within a
file run sequentially (see `playwright.config.js`).