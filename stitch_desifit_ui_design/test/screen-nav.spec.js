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

async function createPage(url = SCREEN_NAV_PATH, waitForGlobal = 'DesiFitNav') {
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 800 });
  await page.goto(url, { waitUntil: 'networkidle', timeout: 15000 });
  if (waitForGlobal) {
    await page.waitForFunction((g) => typeof window[g] !== 'undefined', waitForGlobal, { timeout: 60000 });
  }
  return page;
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. API Surface
// ═══════════════════════════════════════════════════════════════════════════
test.describe('DesiFitNav API', () => {
  test('exports all expected functions', async () => {
    const page = await createPage();
    const api = await page.evaluate(() => {
      const n = window.DesiFitNav;
      return { getDM: typeof n.getDarkMode === 'function', setDM: typeof n.setDarkMode === 'function', toggleDM: typeof n.toggleDarkMode === 'function', initDM: typeof n.initDarkMode === 'function' };
    });
    expect(api.getDM).toBe(true);
    expect(api.setDM).toBe(true);
    expect(api.toggleDM).toBe(true);
    expect(api.initDM).toBe(true);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 2. Dark Mode Functions
// ═══════════════════════════════════════════════════════════════════════════
test.describe('screen-nav dark mode', () => {
  test('getDarkMode returns false when no localStorage value', async () => {
    const page = await createPage();
    await page.evaluate(() => localStorage.removeItem('desifit-dark-mode'));
    expect(await page.evaluate(() => window.DesiFitNav.getDarkMode())).toBe(false);
    await page.close();
  });

  test('setDarkMode(true) adds dark class and saves to localStorage', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitNav.setDarkMode(true);
      return { darkClass: document.documentElement.classList.contains('dark'), stored: localStorage.getItem('desifit-dark-mode') };
    });
    expect(result.darkClass).toBe(true);
    expect(result.stored).toBe('true');
    await page.close();
  });

  test('toggleDarkMode toggles state', async () => {
    const page = await createPage();
    await page.evaluate(() => window.DesiFitNav.setDarkMode(false));
    const first = await page.evaluate(() => { window.DesiFitNav.toggleDarkMode(); return window.DesiFitNav.getDarkMode(); });
    expect(first).toBe(true);
    const second = await page.evaluate(() => { window.DesiFitNav.toggleDarkMode(); return window.DesiFitNav.getDarkMode(); });
    expect(second).toBe(false);
    await page.close();
  });

  test('dark mode dispatches custom event', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      let received = null;
      window.addEventListener('darkmodechange', (e) => { received = e.detail.dark; });
      window.DesiFitNav.setDarkMode(true);
      return received;
    });
    expect(result).toBe(true);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 3. Navigation Bar Injection
// ═══════════════════════════════════════════════════════════════════════════
test.describe('injectScreenNav', () => {
  test('creates #ds-screen-nav element', async () => {
    const page = await createPage();
    expect(await page.evaluate(() => !!document.getElementById('ds-screen-nav'))).toBe(true);
    await page.close();
  });

  test('nav contains back button with SVG arrow', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      const nav = document.getElementById('ds-screen-nav');
      const backBtn = nav.querySelector('button:first-child');
      return { hasBackBtn: !!backBtn, hasSvg: backBtn.innerHTML.includes('svg'), hasArrow: backBtn.innerHTML.includes('M19 12H5') };
    });
    expect(result.hasBackBtn).toBe(true);
    expect(result.hasSvg).toBe(true);
    expect(result.hasArrow).toBe(true);
    await page.close();
  });

  test('nav contains two buttons (back + dark mode)', async () => {
    const page = await createPage();
    const btnCount = await page.evaluate(() => document.getElementById('ds-screen-nav').querySelectorAll('button').length);
    expect(btnCount).toBe(2);
    await page.close();
  });

  test('nav contains DesiFit badge', async () => {
    const page = await createPage();
    const hasBadge = await page.evaluate(() => {
      const nav = document.getElementById('ds-screen-nav');
      return Array.from(nav.querySelectorAll('span')).some(s => s.textContent === 'DesiFit');
    });
    expect(hasBadge).toBe(true);
    await page.close();
  });

  test('nav is positioned fixed at top', async () => {
    const page = await createPage();
    const style = await page.evaluate(() => {
      const n = document.getElementById('ds-screen-nav');
      return { position: n.style.position, top: n.style.top, zIndex: n.style.zIndex };
    });
    expect(style.position).toBe('fixed');
    expect(style.top).toBe('0');
    expect(style.zIndex).toBe('99999');
    await page.close();
  });

  test('back button hover effect', async () => {
    const page = await createPage();
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
    await page.close();
  });

  test('dark mode toggle icon changes on click', async () => {
    const page = await createPage();
    await page.evaluate(() => window.DesiFitNav.setDarkMode(false));
    const result = await page.evaluate(() => {
      const nav = document.getElementById('ds-screen-nav');
      const dmBtn = nav.querySelector('button:last-child');
      dmBtn.click();
      const afterFirst = dmBtn.innerHTML.includes('M21 12.79') ? 'moon' : 'sun';
      dmBtn.click();
      const afterSecond = dmBtn.innerHTML.includes('M21 12.79') ? 'moon' : 'sun';
      return { afterFirst, afterSecond };
    });
    expect(result.afterFirst).toBe('sun');  // Now dark (shows sun)
    expect(result.afterSecond).toBe('moon'); // Now light (shows moon)
    await page.close();
  });

  test('dark mode toggle toggles dark class on html', async () => {
    const page = await createPage();
    await page.evaluate(() => window.DesiFitNav.setDarkMode(false));
    const nav = await page.evaluateHandle(() => document.getElementById('ds-screen-nav'));
    const dmBtn = await nav.evaluate((el) => el.querySelector('button:last-child'));
    await dmBtn.click();
    expect(await page.evaluate(() => document.documentElement.classList.contains('dark'))).toBe(true);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 4. Gallery Page Guard
// ═══════════════════════════════════════════════════════════════════════════
test.describe('Gallery page guard', () => {
  test('screen-nav does NOT inject nav on index.html gallery page', async () => {
    const page = await createPage(GALLERY_PATH, false);
    await page.waitForTimeout(1000);
    expect(await page.evaluate(() => !!document.getElementById('ds-screen-nav'))).toBe(false);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 5. Dark mode persistence
// ═══════════════════════════════════════════════════════════════════════════
test.describe('Dark mode persistence', () => {
  test('dark mode persists via localStorage across page reloads', async () => {
    const page = await createPage();
    await page.evaluate(() => window.DesiFitNav.setDarkMode(true));
    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForFunction(() => typeof window.DesiFitNav !== 'undefined', {}, { timeout: 10000 });
    await page.waitForTimeout(500);
    expect(await page.evaluate(() => document.documentElement.classList.contains('dark'))).toBe(true);
    await page.close();
  });

  test('dark mode from screen-nav matches animation-engine format', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitNav.setDarkMode(true);
      return { nav: window.DesiFitNav.getDarkMode(), stored: localStorage.getItem('desifit-dark-mode') === 'true' };
    });
    expect(result.nav).toBe(true);
    expect(result.stored).toBe(true);
    await page.close();
  });
});
