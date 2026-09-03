/**
 * Comprehensive Playwright Browser Tests for DesiFit Screen Navigation
 * Tests dark mode persistence, nav injection, and gallery page guard
 */
const { test, expect, chromium } = require('@playwright/test');
const path = require('path');

const SCREEN_NAV_PATH = 'file://' + path.resolve(__dirname, 'fixtures', 'screen-nav-test.html');
const GALLERY_PATH = 'file://' + path.resolve(__dirname, '..', 'index.html');
let browser;

test.beforeAll(async () => {
  browser = await chromium.launch({
    headless: true,
    args: ['--allow-file-access-from-files'],
  });
});

test.afterAll(async () => {
  if (browser) await browser.close();
});

// Shared page: one browser page reused across every test in this file.
// Each beforeEach resets state with a cheap localStorage.clear() + reload
// instead of creating a fresh page (~3.2s/test -> ~0.5s/test).
let page;
let dirty = true; // first test always loads fresh
let lastWasPure = false;

async function resetPage(url, waitForGlobal) {
  if (!page) {
    page = await browser.newPage();
    await page.setViewportSize({ width: 1280, height: 800 });
  } else {
    await page.evaluate(() => localStorage.clear()).catch(() => {});
  }
  await page.goto(url, { waitUntil: 'networkidle', timeout: 15000 });
  if (waitForGlobal) {
    await page.waitForFunction((g) => typeof window[g] !== 'undefined', waitForGlobal, { timeout: 60000 });
  }
}

test.beforeEach(async () => {
  // Tests tagged '@pure' only read the injected nav/DOM (no DOM mutation, no
  // navigation), so consecutive pure tests skip the fixture reload — the
  // reload only runs when this test is impure or the previous test was
  // impure. localStorage is still cleared so nav reads stay clean.
  // The 'Gallery page guard' describe navigates the shared page to the real
  // index.html via its own beforeEach, so its SCREEN_NAV fixture reload is
  // pure waste and is skipped too.
  const pure = test.info().tags.includes('@pure');
  const galleryGuard = test.info().titlePath.some((t) => t === 'Gallery page guard');
  lastWasPure = pure || galleryGuard;
  if (!page) {
    page = await browser.newPage();
    await page.setViewportSize({ width: 1280, height: 800 });
  }
  // localStorage persists across same-origin navigations, so always clear it.
  // On the very first test the page is about:blank — the SecurityError is
  // swallowed and the goto below loads a clean fixture anyway.
  await page.evaluate(() => localStorage.clear()).catch(() => {});
  if (!(pure || galleryGuard) || dirty) {
    if (!galleryGuard) {
      await page.goto(SCREEN_NAV_PATH, { waitUntil: 'networkidle', timeout: 15000 });
      await page.waitForFunction((g) => typeof window[g] !== 'undefined', 'DesiFitNav', { timeout: 60000 });
    }
    dirty = false;
  }
});

test.afterEach(async () => {
  // Impure tests may leave nav/DOM state behind, and a failed pure test may
  // have poisoned the page too — force a reload in either case.
  dirty = !lastWasPure || test.info().status !== 'passed';
});

// ═══════════════════════════════════════════════════════════════════════════
// 1. API Surface
// ═══════════════════════════════════════════════════════════════════════════
test.describe('DesiFitNav API', () => {
  test('exports all expected functions', async () => {
    const api = await page.evaluate(() => {
      const n = window.DesiFitNav;
      return { getDM: typeof n.getDarkMode === 'function', setDM: typeof n.setDarkMode === 'function', toggleDM: typeof n.toggleDarkMode === 'function', initDM: typeof n.initDarkMode === 'function' };
    });
    expect(api.getDM).toBe(true);
    expect(api.setDM).toBe(true);
    expect(api.toggleDM).toBe(true);      expect(api.initDM).toBe(true);
    }, { tag: '@pure' });
});

// ═══════════════════════════════════════════════════════════════════════════
// 2. Dark Mode Functions
// ═══════════════════════════════════════════════════════════════════════════
test.describe('screen-nav dark mode', () => {
  test('getDarkMode returns false when no localStorage value', async () => {
    await page.evaluate(() => localStorage.removeItem('desifit-dark-mode'));
    expect(await page.evaluate(() => window.DesiFitNav.getDarkMode())).toBe(false);
  });

  test('setDarkMode(true) adds dark class and saves to localStorage', async () => {
    const result = await page.evaluate(() => {
      window.DesiFitNav.setDarkMode(true);
      return { darkClass: document.documentElement.classList.contains('dark'), stored: localStorage.getItem('desifit-dark-mode') };
    });
    expect(result.darkClass).toBe(true);
    expect(result.stored).toBe('true');
  });

  test('toggleDarkMode toggles state', async () => {
    await page.evaluate(() => window.DesiFitNav.setDarkMode(false));
    const first = await page.evaluate(() => { window.DesiFitNav.toggleDarkMode(); return window.DesiFitNav.getDarkMode(); });
    expect(first).toBe(true);
    const second = await page.evaluate(() => { window.DesiFitNav.toggleDarkMode(); return window.DesiFitNav.getDarkMode(); });
    expect(second).toBe(false);
  });

  test('dark mode dispatches custom event', async () => {
    const result = await page.evaluate(() => {
      let received = null;
      window.addEventListener('darkmodechange', (e) => { received = e.detail.dark; });
      window.DesiFitNav.setDarkMode(true);
      return received;
    });
    expect(result).toBe(true);
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 3. Navigation Bar Injection
// ═══════════════════════════════════════════════════════════════════════════
test.describe('injectScreenNav', () => {
  test('creates #ds-screen-nav element', async () => {      expect(await page.evaluate(() => !!document.getElementById('ds-screen-nav'))).toBe(true);
    }, { tag: '@pure' });

  test('nav contains back button with SVG arrow', async () => {
    const result = await page.evaluate(() => {
      const nav = document.getElementById('ds-screen-nav');
      const backBtn = nav.querySelector('button:first-child');
      return { hasBackBtn: !!backBtn, hasSvg: backBtn.innerHTML.includes('svg'), hasArrow: backBtn.innerHTML.includes('M19 12H5') };
    });
    expect(result.hasBackBtn).toBe(true);
    expect(result.hasSvg).toBe(true);      expect(result.hasArrow).toBe(true);
    }, { tag: '@pure' });

  test('nav contains two buttons (back + dark mode)', async () => {
    const btnCount = await page.evaluate(() => document.getElementById('ds-screen-nav').querySelectorAll('button').length);      expect(btnCount).toBe(2);
    }, { tag: '@pure' });

  test('nav contains DesiFit badge', async () => {
    const hasBadge = await page.evaluate(() => {
      const nav = document.getElementById('ds-screen-nav');
      return Array.from(nav.querySelectorAll('span')).some(s => s.textContent === 'DesiFit');
    });      expect(hasBadge).toBe(true);
    }, { tag: '@pure' });

  test('nav is positioned fixed at top', async () => {
    const style = await page.evaluate(() => {
      const n = document.getElementById('ds-screen-nav');
      return { position: n.style.position, top: n.style.top, zIndex: n.style.zIndex };
    });
    expect(style.position).toBe('fixed');
    expect(style.top).toBe('0px');      expect(style.zIndex).toBe('99999');
    }, { tag: '@pure' });

  test('back button hover effect', async () => {
    const result = await page.evaluate(() => {
      const nav = document.getElementById('ds-screen-nav');
      const btn = nav.querySelector('button:first-child');
      btn.dispatchEvent(new MouseEvent('mouseenter'));
      const afterEnter = btn.style.transform;
      btn.dispatchEvent(new MouseEvent('mouseleave'));
      const afterLeave = btn.style.transform;
      return { afterEnter, afterLeave };
    });
    expect(result.afterEnter).toContain('scale(1.05)');
    expect(result.afterLeave).toContain('scale(1)');
  });

  async function clickDarkModeButton(page) {
    await page.evaluate(() => {
      document.getElementById('ds-screen-nav').querySelector('button:last-child').click();
    });
  }

  test('dark mode toggle icon changes on click', async () => {
    await page.evaluate(() => window.DesiFitNav.setDarkMode(false));
    await clickDarkModeButton(page);
    const afterFirst = await page.evaluate(() => {
      const dmBtn = document.getElementById('ds-screen-nav').querySelector('button:last-child');
      return dmBtn.innerHTML.includes('M21 12.79') ? 'moon' : 'sun';
    });
    await clickDarkModeButton(page);
    const afterSecond = await page.evaluate(() => {
      const dmBtn = document.getElementById('ds-screen-nav').querySelector('button:last-child');
      return dmBtn.innerHTML.includes('M21 12.79') ? 'moon' : 'sun';
    });
    expect(afterFirst).toBe('sun');  // Now dark (shows sun)
    expect(afterSecond).toBe('moon'); // Now light (shows moon)
  });

  test('dark mode toggle toggles dark class on html', async () => {
    await page.evaluate(() => window.DesiFitNav.setDarkMode(false));
    await clickDarkModeButton(page);
    expect(await page.evaluate(() => document.documentElement.classList.contains('dark'))).toBe(true);
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 4. Gallery Page Guard
// ═══════════════════════════════════════════════════════════════════════════
test.describe('Gallery page guard', () => {
  // This test targets the real gallery (index.html), not the fixture.
  test.beforeEach(async () => {
    await resetPage(GALLERY_PATH, false);
  });
  test('screen-nav does NOT inject nav on index.html gallery page', async () => {
    await page.waitForTimeout(1000);
    expect(await page.evaluate(() => !!document.getElementById('ds-screen-nav'))).toBe(false);
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 5. Dark mode persistence
// ═══════════════════════════════════════════════════════════════════════════
test.describe('Dark mode persistence', () => {
  test('dark mode persists via localStorage across page reloads', async () => {
    await page.evaluate(() => window.DesiFitNav.setDarkMode(true));
    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForFunction(() => typeof window.DesiFitNav !== 'undefined', {}, { timeout: 10000 });
    await page.waitForTimeout(500);
    expect(await page.evaluate(() => document.documentElement.classList.contains('dark'))).toBe(true);
  });

  test('dark mode from screen-nav matches animation-engine format', async () => {
    const result = await page.evaluate(() => {
      window.DesiFitNav.setDarkMode(true);
      return { nav: window.DesiFitNav.getDarkMode(), stored: localStorage.getItem('desifit-dark-mode') === 'true' };
    });
    expect(result.nav).toBe(true);
    expect(result.stored).toBe(true);
  });
});
