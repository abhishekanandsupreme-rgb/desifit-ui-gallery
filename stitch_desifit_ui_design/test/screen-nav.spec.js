/**
 * Comprehensive Playwright Browser Tests for DesiFit Screen Navigation
 * Tests dark mode persistence, nav injection, and gallery page guard
 */
const { test, expect, chromium } = require('@playwright/test');
const fs = require('fs');
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

// Deterministic reset: every test gets a fresh page + fixture load.
// The previous shared-page/@pure skip-reload optimization let impure
// tests leak DOM/async state into the next pure test (the flake class
// seen in run 33795179439). The full reload costs ~0.5s/test.
let page;

async function loadFixture(url, waitForGlobal) {
  if (page) await page.close().catch(() => {});
  page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 800 });
  await page.goto(url, { waitUntil: 'networkidle', timeout: 15000 });
  if (waitForGlobal) {
    await page.waitForFunction((g) => typeof window[g] !== 'undefined', waitForGlobal, { timeout: 60000 });
  }
}

test.beforeEach(async () => {
  const galleryGuard = test.info().titlePath.some((t) => t === 'Gallery page guard');
  if (!galleryGuard) {
    await loadFixture(SCREEN_NAV_PATH, 'DesiFitNav');
  }
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
    await loadFixture(GALLERY_PATH);
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

// ═══════════════════════════════════════════════════════════════════
// 6. Asset manifest wiring (data-assets -> QA overlay + compare overlay)
// ═══════════════════════════════════════════════════════════════════
test.describe('Asset manifest wiring', () => {
  const VALID_KINDS = ['image', 'video', 'audio', 'icon'];

  test.beforeEach(async () => {
    // No waitForGlobal: index.html does not load screen-nav.js, so DesiFitNav
    // never appears here — waiting for it hangs the suite.
    await loadFixture(GALLERY_PATH);
    // The first-visit tour overlay (#tour-overlay.active) intercepts pointer
    // events, blocking clicks on gallery chrome. Seed the completion flag and
    // reload so the tour never starts (deterministic, no 800ms race).
    await page.evaluate(() => localStorage.setItem('desifit-tour-complete', 'true'));
    await page.reload({ waitUntil: 'networkidle' });
  });

  test('all 30 gallery cards carry valid data-assets kinds', async () => {
    const result = await page.evaluate((valid) => {
      const cards = document.querySelectorAll('.filter-item');
      const bad = [];
      let withAssets = 0;
      cards.forEach((card) => {
        const raw = card.dataset.assets || '';
        const kinds = raw.split(',').map((s) => s.trim()).filter(Boolean);
        if (raw) withAssets++;
        for (const k of kinds) {
          if (!valid.includes(k)) bad.push(card.dataset.name + ' -> ' + k);
        }
      });
      return { total: cards.length, withAssets, bad };
    }, VALID_KINDS);
    expect(result.total).toBe(30);
    expect(result.withAssets).toBe(30);
    expect(result.bad).toEqual([]);
  });

  test('QA (VRM) overlay renders one asset chip per card kind', async () => {
    await page.click('#vrm-toggle');
    // state:'attached' — the overlay's entry animation makes the default
    // visible+stable wait racy (element is visible but never "stable").
    await page.waitForSelector('#vrm-overlay.active', { timeout: 10000, state: 'attached' });
    await page.waitForSelector('#vrm-grid .vrm-card', { timeout: 15000, state: 'attached' });
    const result = await page.evaluate(() => {
      const cards = document.querySelectorAll('#vrm-grid .vrm-card');
      let chips = 0;
      cards.forEach((c) => { chips += c.querySelectorAll('.vrm-asset-tag').length; });
      const expected = Array.from(document.querySelectorAll('.filter-item'))
        .reduce((n, card) => n + (card.dataset.assets || '').split(',').filter(Boolean).length, 0);
      return { cards: cards.length, chips, expected };
    });
    expect(result.cards).toBe(30);
    expect(result.chips).toBe(result.expected);
    expect(result.chips).toBeGreaterThan(0);
  });

  test('compare overlay shows asset tags mirroring card data-assets', async () => {
    const result = await page.evaluate(() => {
      const cards = Array.from(document.querySelectorAll('.filter-item'));
      const two = cards.slice(0, 2);
      window._selectedCards.clear();
      two.forEach((c) => window._selectedCards.add(c.getAttribute('href')));
      window._openComparison();
      const overlay = document.getElementById('compare-overlay');
      if (!overlay) return { opened: false };
      const tags = Array.from(overlay.querySelectorAll('.compare-card'));
      const mirrored = tags.map((cc) => ({
        chips: Array.from(cc.querySelectorAll('.asset-tag')).map((t) => {
          const [kind, count] = t.textContent.trim().split(/\s+/);
          return { kind, count, ready: t.classList.contains('ready') };
        }),
      }));
      const expected = two.map((c) => (c.dataset.assetReady || '').split(',').filter(Boolean).map((p) => {
        const [kind, count] = p.split(':');
        return { kind, count, ready: (parseInt(count, 10) || 0) > 0 };
      }));
      return { opened: true, mirrored, expected };
    });
    expect(result.opened).toBe(true);
    expect(result.mirrored).toEqual(result.expected.map((chips) => ({ chips })));
  });

  test('card data-asset-ready chips match manifest totals and registered files on disk', async () => {
    const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, '..', 'google_flow', 'asset_manifest.json'), 'utf8'));
    const registryPath = path.join(__dirname, '..', 'assets', 'registry.json');
    const registry = fs.existsSync(registryPath)
      ? JSON.parse(fs.readFileSync(registryPath, 'utf8'))
      : { files: [] };
    const totals = {};
    const counts = {};
    for (const [slug, entry] of Object.entries(manifest.screens)) {
      totals[slug] = {};
      counts[slug] = {};
      for (const [k, list] of Object.entries(entry.assets || {})) {
        totals[slug][k] = list.length;
        counts[slug][k] = registry.files.filter((f) => f.scope === slug && f.kind === k).length;
      }
    }
    const result = await page.evaluate(({ totals, counts }) => {
      const mismatches = [];
      document.querySelectorAll('.filter-item').forEach((card) => {
        const slug = (card.getAttribute('href') || '').replace(/\/code\.html$/, '');
        if (!totals[slug]) { mismatches.push(slug + ': no manifest entry'); return; }
        // Expected string follows the card's data-assets order (rendering truth).
        const expected = (card.dataset.assets || '').split(',').filter(Boolean).map((k) => {
          return `${k}:${counts[slug][k] || 0}/${totals[slug][k] || 0}`;
        }).join(',');
        if (card.dataset.assetReady !== expected) {
          mismatches.push(`${slug}: html="${card.dataset.assetReady}" expected="${expected}"`);
        }
      });
      return { manifestScreens: Object.keys(totals).length, mismatches };
    }, { totals, counts });
    expect(result.manifestScreens).toBe(30);
    expect(result.mismatches).toEqual([]);
  });
});
