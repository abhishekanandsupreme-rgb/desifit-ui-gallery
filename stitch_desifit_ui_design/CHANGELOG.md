# Changelog

All notable changes to the DesiFit UI Gallery will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- **Playwright suite gated in CI** — `test/anim-engine.spec.js` and `test/screen-nav.spec.js`
  (≈158 tests) now run headless on every push and PR via the `gallery-e2e` job: browsers
  are cached and install-retried, tests retry twice on flake, and traces + test results
  upload as artifacts on failure.

### Fixed
- **Suite record corrected** — entries below reference a `visual-regression.spec.js` and a
  three-spec layout that describe the author’s pre-merge snapshot and were never part of
  this repository’s tracked suite. The tracked suite is the two spec files above plus
  `test-utils.js` (console-error monitor + screen-comparison helpers) and
  `test/validate_tags.mjs`; the older entries are kept for history.


---

## [Day 6] — 2026-08-03

### Changed
- **Compare overlay accuracy pass** — the 15 screens built on Day 5 still carried generic placeholder animation tags on their gallery cards (`scan-animation`, `macro-pop`, `progress-bar`, `bar-rise`, `chart-line`, `drop-in`, `scroll-reveal`, etc.) that existed nowhere in the canonical `ALL_ANIMATIONS` glossary, so the compare overlay rendered every animation tag as *missing* for those cards. Each card's `data-animations` now lists only canonical IDs that match what its screen actually ships:
  - **workout_tracker** → `counter-animate,timer-pulse,button-squash,stagger-reveal` (rep counter, pulsing rest timer, squash steppers, staggered set list)
  - **calorie_scanner** / **macro_scanner** → `scan-line,pop-in` (sweeping viewfinder line + result pop-in)
  - **water_intake** → `water-fill,pop-in` (rising drop fill + quick-add glass pop)
  - **sleep_recovery** → `float,progress-ring,stagger-reveal` (floating moon, sleep-score ring, staggered sections)
  - **settings_profile** → `stagger-reveal,dark-mode` (staggered rows + shipped dark variant)
  - **achievements** → `badge-pop,stagger-reveal`
  - **recipe_detail** → `stagger-reveal,button-squash` (stepper squash)
  - **subscription_plans** → `stagger-reveal,pop-in`
  - **workout_history** / **recipe_collections** / **meal_prep_scheduler** → `stagger-reveal`
  - **rewards_shop** → `stagger-reveal,coin-glow` (glowing coin halo)
  - **progress_dashboard** → `bar-grow,counter-animate,progress-ring` (growing protein bars, stat counters, budget ring)
  - **habit_tracker** → `check-pop,streak-fire` (checkmark pop + flickering streak flame)
- **Six new canonical animation types** added to `ALL_ANIMATIONS` so the compare overlay and glossary can represent the Day-5 screens accurately: `scan-line`, `bar-grow`, `timer-pulse`, `check-pop`, `streak-fire`, `coin-glow` — each with label, description, Material icon, category, difficulty, `usedIn` list, and a glossary demo (reusing existing demo types). Glossary count grows 26 → 32 types.
- `usedIn` arrays refreshed for existing entries (`stagger-reveal`, `counter-animate`, `progress-ring`, `pop-in`, `float`, `shimmer`) to name the new screens that ship them.
- **Category badges corrected** — `sleep_recovery` and `settings_profile` moved `fun` → `features` (they ship sleep-tracking and account settings, not gamification), matching the card's filter category to its screen. `progress_dashboard` stays `features` per its dashboard-section placement.
- Added `test/validate_tags.mjs` — a Node script asserting every card's `data-animations` tokens resolve to canonical `ALL_ANIMATIONS` ids (all 30 cards pass), so future screens can't reintroduce orphan tags.

---

## [Day 5] — 2026-08-03

### Added
- Completed the full 30-screen gallery — built 15 missing standalone screens as self-contained `code.html` files, each matching the "Modern Craftsman" design language (Material 3 tokens, saffron→leaf gradient CTAs, glassmorphism bottom nav, no-line hierarchy) and its gallery-card metadata:
  - **Progress Dashboard** — weekly protein bars, budget ring + spend breakdown, weight trend chart.
  - **Meal Prep Scheduler** — day strip, meal slots with drag indicators, weekly coverage + budget meters.
  - **Habit Tracker** — 7-day check-in strip, streak flames, per-habit check buttons.
  - **Achievements Badges** — level hero card, XP progress, 3×3 locked/unlocked badge grid.
  - **Calorie Scanner** — camera viewfinder with corner brackets + animated scan line, AI thali result card with macro bars, recent scans.
  - **Macro Barcode Scanner** — barcode viewfinder with laser sweep, scanned-product macro tiles, ₹-per-gram verdict, scan history.
  - **Water Intake** — hydration hero with progress bar, 250ml/500ml/1L quick-add, daily log timeline, 7-day chart.
  - **Recipe Collections** — featured gradient collection hero, saved collection list, create-collection CTA.
  - **Recipe Detail** — hero with back/save, meta chips (time/kcal/protein/cost), servings stepper, ingredients, numbered steps, jugaad tip.
  - **Rewards Shop** — Sattu balance hero with glowing coin, coupon/merch/donation reward grid, earn-how strip.
  - **Settings & Profile** — profile card with verified badge, goal stats, grouped account/preferences/privacy/about rows with toggles.
  - **Sleep Recovery** — sleep-score ring hero, stage breakdown, 7-night bars, coach's recovery note.
  - **Subscription Plans** — monthly/yearly toggle, Free / Champ (featured gradient) / Ghar tier cards, trust strip.
  - **Workout History** — session summary stats, date-grouped workout log with PR + volume chips, filter chips.
  - **Workout Tracker (Reps)** — active-exercise rep stepper, 60s rest timer, exercise checklist with done/in-progress/up-next states.
- Every new screen ships with staggered entrance animations (`.badge-pop`, `.scan-line`, `.bar-grow`, `.drop-fill`, `.rep-pop`, etc.) and active-press micro-interactions consistent with the existing 15 screens.

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
