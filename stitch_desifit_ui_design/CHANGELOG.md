# Changelog

All notable changes to the DesiFit UI Gallery will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [Day 3] — 2026-07-30

### Added
- URL hash deep-linking: `#card-N` and `#screen-<slug>` URLs scroll the target card into view and pulse a saffron ring (`hash-pulse` keyframe) for ~2 s. `Escape` strips both the highlight and the hash via `history.replaceState`. Hash resolution is full-DOM-order-stable, not visible-after-filter.
- Per-card share button: hover-revealed at the top-left of every card (mirrors the existing `.selection-check` slot at top-right). Click does `history.replaceState({}, '', '#card-N-<slug>')` then `navigator.clipboard.writeText(location.href)` with a `document.execCommand('copy')` fallback. Shows a green "Link copied!" tooltip for 1.8 s.

### Changed
- New inline IIFE in `index.html` (loaded after `desifit-text-utils.js`) parses the hash, applies highlights, and manages share buttons. Exposes `window.fireHashChange`, `window.reinitShareButtons`, and `window.shareCurrentCard` test hooks.
- Added 7 Playwright tests in `anim-engine.spec.js` under `test.describe('URL hash deep-link + share button')` covering: `#card-N`, `#screen-<slug>`, out-of-range graceful handling, `Escape` clear, share-button count parity, click-to-copy clipboard + `.copied` class (best-effort), and listener-driven hashchange isolation.
- New `createGalleryPage` helper uses `test.beforeAll` / `test.afterAll` with a shared `galleryBrowser` per worker, replacing the previous `createPage()`-then-`page.goto(INDEX_PATH)` double-load that wasted ~1–2 s per test. The 7-test URL-hash suite now runs in **~1.2 m** under the existing 4-worker Playwright config.

---

## [Day 2] — 2026-07-29

### Added
- PWA / Service Worker support — `manifest.json` makes the gallery installable; offline shell cache for repeat visits.
- Device-frame preview — iPhone / iPad / Desktop framed iframes for capturing marketing-style shots.
- Live theme editor — mutate CSS custom properties on the fly with a WCAG contrast badge and copy-as-CSS-string button.
- Per-card bookmarks — persisted to `localStorage` under `desifit-bookmarks`; new "Saved" filter chip in the category bar (disambiguated via `data-bookmark-tab`).
- Screen comparison overlay — pick 2 screens in a dark-editorial two-up plate layout with shared/highlighted animation tags.
- Screenshot export modal — captures every card into a PNG gallery with individual download buttons and a staggered "Download All" action.
- Accessibility audit (in-page).
- Visual regression matrix — `visual-regression.spec.js` covering category filtering, bookmark tab, dark-mode toggle, preview modal, and compare overlay.
- Console-error monitor + screen-comparison Playwright helpers.

### Changed
- Visual-regression suite optimized by bumping `workers` (4 → 6) in `playwright.config.js` and switching `waitUntil: 'networkidle'` → `'domcontentloaded'` across the three spec files.
- New selectors `#category-tabs` and the `:not([data-bookmark-tab])` disambiguator added throughout `visual-regression.spec.js` to bypass strict-mode multi-match failures caused by `#saved-tab` sharing `data-category="all"`.
- `getStats` rewritten to return a JSON-serializable `searchCounts: { Dashboard, Recipe, Onboarding }` object (functions strip out of `page.evaluate` round-trips).

---

## [Day 1] — 2026-07-28

### Added
Animation Engine v4 (Track 2) — three flagship features, all performance-tier-aware via `isMotionSafe()`:
- `initSwipeGestures(selector, callbacks)` — touch/mouse swipe detection with configurable thresholds, damping, and direction filters.
- `initSkeletonLoaders(selector)` — pulse-placeholder skeletons until the real content is ready.
- `pageTransition(fromPath, toPath, opts)` — slide-with-overlay transitions between routes, with rebound ease.

Plus three v4 second-batch features:
- `initCardCarousel(...)` — 3D tilt-on-scroll carousel.
- `initMagneticHover(...)` — magnetic-pull hover effect for icon/orb buttons.
- `initScrollTimeline(...)` — scroll-position-driven keyframe triggers.

Three initial-scaffold gallery screens with seeded simulated data:
- Progress Dashboard — weekly charts, streaks, summary stats.
- Meal Prep Scheduler — drag-to-reorder weekly meal grid.
- Habit Tracker — check-in grid with streak persistence.

Documentation:
- `ANIMATION_ENGINE.md` + `ANIMATION_API.md` — full catalog of every animation feature with runnable usage examples and §10 *Shared utilities* (sanitizeFilename + htmlEncode).
- Animation Playbook — designer's guide to picking the right effect for the right moment (motion-tier guidance, gesture grammar, perf-budget guidance).

### Changed
- `animation-engine.js` now exposes the animation features cataloged in `ANIMATION_API.md` across `window.DesiFitAnim` + local IIFE helpers.
- `desifit-text-utils.js` extracted as a shared `<script src>` helper for sanitizing filenames + HTML-escaping injected text — consumed by both production `index.html` and the Playwright fixture.
- Spec count grew from ~80 → ~120 tests in `anim-engine.spec.js` to cover every new feature.
- v4 features ship with `isMotionSafe()` automatic downgrades so low-tier devices skip heavy effects up-front.
