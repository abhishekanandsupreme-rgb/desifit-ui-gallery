/**
 * DesiFit Text Utils — shared string helpers used by the inlined screenshot
 * export engine (index.html) and by the Playwright fixture (test/fixtures/
 * anim-engine-test.html). Single source of truth so the production gallery
 * and the test harness cannot drift.
 *
 * Loaded as a plain <script src="desifit-text-utils.js"> BEFORE the script
 * that depends on these helpers. Exposes `window.DesifFitTextUtils`.
 */
(function () {
  'use strict';

  // Order matters: & must run first so subsequent replacements don't double-escape.
  function htmlEncode(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  // Allow Unicode letters/numbers/hyphens/spaces; replace whitespace runs with
  // hyphen; strip everything else. The `\p{M}` class (combining marks) keeps
  // Indic scripts like Hindi/Devanagari and emoji ZWJ sequences intact.
  function sanitizeFilename(str) {
    return String(str)
      .replace(/[^\p{L}\p{N}\p{M}\s-]/gu, '')
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-')
      .replace(/^-|-$/g, '');
  }

  window.DesifFitTextUtils = {
    htmlEncode: htmlEncode,
    sanitizeFilename: sanitizeFilename
  };
})();
