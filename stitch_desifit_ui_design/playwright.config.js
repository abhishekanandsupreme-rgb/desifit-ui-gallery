/**
 * Playwright Configuration for DesiFit UI Tests
 *
 * Parallel model:
 *   - Files run in parallel across workers (workers: 6 locally, 2 in CI), but
 *     tests within a file run sequentially: screen-nav.spec.js reuses ONE
 *     shared page across every test in the file, which races under
 *     fullyParallel (each test would run in its own worker slot).
 *   - anim-engine.spec.js creates a fresh page per test, so it is unaffected.
 *
 * Reporter:
 *   - CI: `dot` (one progress char per test) + `html` artifact for job attachments.
 *   - Local: `list` (one line per test, includes timing) + same `html` artifact
 *     so devs can `npx playwright show-report` for a deeper drill-down.
 *   - Both branches write to ./playwright-report/ (consistent across envs).
 */
const { defineConfig } = require('@playwright/test');

const isCI = !!process.env.CI;

module.exports = defineConfig({
  testDir: './test',
  testMatch: '**/*.spec.js',
  fullyParallel: false,
  workers: isCI ? 2 : 6,
  // Per-test timeout (120s) is the slow ceiling; globalTimeout caps total run.
  timeout: 120000,
  globalTimeout: isCI ? 20 * 60 * 1000 : 30 * 60 * 1000,
  expect: { timeout: 15000 },
  use: {
    headless: true,
    viewport: { width: 1280, height: 800 },
  },
  reporter: isCI
    ? [['dot'], ['html', { outputFolder: 'playwright-report', open: 'never' }]]
    : [['list'], ['html', { outputFolder: 'playwright-report', open: 'never' }]],
  // CI hygiene: forbid `.only` markers so PRs can't silently skip tests.
  forbidOnly: isCI,
  // Fail CI fast when flaky retries hide real regressions.
  retries: isCI ? 1 : 0,
});
