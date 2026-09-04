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
| `tools/` | SDK-free CI gates: `check_dart_syntax.js` (bracket balance), `check_signing_template.js` (key.properties contract drift), `check_no_private_keys.js` (no private-key material in the tree). |
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