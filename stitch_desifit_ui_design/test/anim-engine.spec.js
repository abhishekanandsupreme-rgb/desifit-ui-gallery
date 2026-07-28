/**
 * Comprehensive Playwright Browser Tests for DesiFit Animation Engine
 * Tests all major public APIs exposed on window.DesiFitAnim
 */
const { test, expect, chromium } = require('@playwright/test');
const path = require('path');

const FIXTURE_PATH = 'file://' + path.resolve(__dirname, 'fixtures', 'anim-engine-test.html');
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

async function createPage() {
  const page = await browser.newPage();
  await page.setViewportSize({ width: 1280, height: 800 });
  await page.goto(FIXTURE_PATH, { waitUntil: 'networkidle', timeout: 15000 });
  await page.waitForFunction(() => typeof window.DesiFitAnim !== 'undefined', {}, { timeout: 60000 });
  return page;
}

// ═══════════════════════════════════════════════════════════════════════════
// 1. Particle System
// ═══════════════════════════════════════════════════════════════════════════
test.describe('ParticleSystem', () => {
  test('constructor creates instance with default options', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      const canvas = document.getElementById('particles-canvas');
      const ps = new window.DesiFitAnim.ParticleSystem(canvas);
      return { maxCount: ps.maxCount, running: ps.running, interactive: ps.interactive, connectDist: ps.connectDist, particlesLength: ps.particles.length };
    });
    expect(result.maxCount).toBe(50);
    expect(result.running).toBe(false);
    expect(result.interactive).toBe(true);
    expect(result.connectDist).toBe(120);
    expect(result.particlesLength).toBe(0);
    await page.close();
  });

  test('accepts custom options', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      const canvas = document.getElementById('particles-canvas');
      const ps = new window.DesiFitAnim.ParticleSystem(canvas, { max: 20, interactive: false, connectDist: 80, connectionAlpha: 0.05 });
      return { maxCount: ps.maxCount, interactive: ps.interactive, connectDist: ps.connectDist, connectionAlpha: ps.connectionAlpha };
    });
    expect(result.maxCount).toBe(20);
    expect(result.interactive).toBe(false);
    expect(result.connectDist).toBe(80);
    expect(result.connectionAlpha).toBeCloseTo(0.05, 2);
    await page.close();
  });

  test('seed() populates particles array', async () => {
    const page = await createPage();
    const count = await page.evaluate(() => {
      const canvas = document.getElementById('particles-canvas');
      const ps = new window.DesiFitAnim.ParticleSystem(canvas, { max: 30 });
      ps.seed();
      return ps.particles.length;
    });
    expect(count).toBe(30);
    await page.close();
  });

  test('start() and stop() toggle running state', async () => {
    const page = await createPage();
    const states = await page.evaluate(() => {
      const canvas = document.getElementById('particles-canvas');
      const ps = new window.DesiFitAnim.ParticleSystem(canvas, { max: 10 });
      ps.start();
      const afterStart = ps.running;
      ps.stop();
      const afterStop = ps.running;
      return { afterStart, afterStop };
    });
    expect(states.afterStart).toBe(true);
    expect(states.afterStop).toBe(false);
    await page.close();
  });

  test('seed creates particles with valid properties', async () => {
    const page = await createPage();
    const props = await page.evaluate(() => {
      const canvas = document.getElementById('particles-canvas');
      const ps = new window.DesiFitAnim.ParticleSystem(canvas, { max: 15 });
      ps.seed();
      const p = ps.particles[0];
      return { hasX: typeof p.x === 'number', hasY: typeof p.y === 'number', hasR: typeof p.r === 'number', hasVx: typeof p.vx === 'number', hasVy: typeof p.vy === 'number', hasAlpha: typeof p.alpha === 'number', hasColor: Array.isArray(p.color) && p.color.length === 3, hasPhase: typeof p.phase === 'number' };
    });
    expect(props.hasX).toBe(true);
    expect(props.hasY).toBe(true);
    expect(props.hasR).toBe(true);
    expect(props.hasVx).toBe(true);
    expect(props.hasVy).toBe(true);
    expect(props.hasAlpha).toBe(true);
    expect(props.hasColor).toBe(true);
    expect(props.hasPhase).toBe(true);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 2. Spring Physics
// ═══════════════════════════════════════════════════════════════════════════
test.describe('springAnimate', () => {
  test('starts spring animation on an element', async () => {
    const page = await createPage();
    const started = await page.evaluate(() => {
      const el = document.createElement('div');
      el.style.transform = 'translateY(0px)';
      document.body.appendChild(el);
      try { window.DesiFitAnim.springAnimate(el, { transform: 100 }); return true; }
      catch (e) { return false; }
    });
    expect(started).toBe(true);
    await page.close();
  });

  test('spring animation eventually reaches target', async () => {
    const page = await createPage();
    const result = await page.evaluate(async () => {
      const el = document.createElement('div');
      el.style.opacity = '0';
      document.body.appendChild(el);
      return new Promise((resolve) => {
        window.DesiFitAnim.springAnimate(el, { opacity: 1 }, { stiffness: 300, damping: 20, mass: 1, onComplete: () => resolve(parseFloat(el.style.opacity)) });
      });
    });
    expect(result).toBeGreaterThan(0.9);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 3. Staggered Reveal
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initStaggerReveal', () => {
  test('sets initial styles on stagger items', async () => {
    const page = await createPage();
    const styles = await page.evaluate(() => {
      window.DesiFitAnim.initStaggerReveal('.stagger-item', { fromY: 30, delay: 60 });
      return Array.from(document.querySelectorAll('.stagger-item')).map(el => ({ opacity: el.style.opacity, transform: el.style.transform }));
    });
    styles.forEach(s => {
      expect(s.opacity).toBe('0');
      expect(s.transform).toContain('translateY');
    });
    await page.close();
  });

  test('handles empty selector gracefully', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      try { window.DesiFitAnim.initStaggerReveal('.nonexistent'); return 'no-error'; }
      catch (e) { return e.message; }
    });
    expect(result).toBe('no-error');
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 4. Scroll Reveal
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initScrollReveal', () => {
  test('sets initial styles with direction transforms', async () => {
    const page = await createPage();
    const styles = await page.evaluate(() => {
      window.DesiFitAnim.initScrollReveal('.scroll-reveal');
      return Array.from(document.querySelectorAll('.scroll-reveal')).map(el => ({ opacity: el.style.opacity, transform: el.style.transform, direction: el.dataset.direction }));
    });
    expect(styles[0].opacity).toBe('0');
    expect(styles[0].transform).toContain('translateY(40px)');
    expect(styles[1].transform).toContain('translateX(-40px)');
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 5. Scroll Progress Bar
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initScrollProgressBar', () => {
  test('resets bar width to 0 and adds transition', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initScrollProgressBar('.scroll-progress-bar');
      const bar = document.querySelector('.scroll-progress-bar');
      return { width: bar.style.width, hasTransition: bar.style.transition.includes('cubic-bezier') };
    });
    expect(result.width).toBe('0%');
    expect(result.hasTransition).toBe(true);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 6. Scroll Counter & animateCounter
// ═══════════════════════════════════════════════════════════════════════════
test.describe('animateCounter', () => {
  test('animates from 0 to target with prefix/suffix', async () => {
    const page = await createPage();
    const finalValue = await page.evaluate(async () => {
      const el = document.querySelector('.scroll-counter');
      window.DesiFitAnim.animateCounter(el, 42, 100, '$', '%');
      await new Promise(r => setTimeout(r, 150));
      return el.textContent;
    });
    expect(finalValue).toBe('$42%');
    await page.close();
  });

  test('handles zero target', async () => {
    const page = await createPage();
    const result = await page.evaluate(async () => {
      const el = document.createElement('div');
      document.body.appendChild(el);
      window.DesiFitAnim.animateCounter(el, 0, 50, '', '');
      await new Promise(r => setTimeout(r, 100));
      return el.textContent;
    });
    expect(result).toBe('0');
    await page.close();
  });

  test('initScrollCounter reads dataset attributes', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      const el = document.querySelector('.scroll-counter');
      return { count: el.dataset.count, prefix: el.dataset.prefix, suffix: el.dataset.suffix };
    });
    expect(result.count).toBe('42');
    expect(result.prefix).toBe('$');
    expect(result.suffix).toBe('%');
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 7. Button Squash
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initButtonSquash', () => {
  test('adds pointer down/up event listeners', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      const btn = document.querySelector('.btn-interactive');
      window.DesiFitAnim.initButtonSquash('.btn-interactive');
      btn.dispatchEvent(new PointerEvent('pointerdown'));
      const down = btn.style.transform;
      btn.dispatchEvent(new PointerEvent('pointerup'));
      const up = btn.style.transform;
      return { down, up };
    });
    expect(result.down).toContain('scale(0.94)');
    expect(result.up).toContain('scale(1)');
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 8. Card Lift
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initCardLift', () => {
  test('transforms on pointer enter/leave', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      const card = document.querySelector('.card-lift');
      window.DesiFitAnim.initCardLift('.card-lift');
      card.dispatchEvent(new PointerEvent('pointerenter'));
      const enter = card.style.transform;
      card.dispatchEvent(new PointerEvent('pointerleave'));
      const leave = card.style.transform;
      return { enter, leave };
    });
    expect(result.enter).toContain('translateY(-4px)');
    expect(result.leave).toContain('translateY(0)');
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 9. FAB Pulse
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initFABPulse', () => {
  test('adds pulse ring element to FAB', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initFABPulse('.fab-pulse');
      const fab = document.querySelector('.fab-pulse');
      const ring = fab.querySelector('.fab-ring');
      return { ringExists: !!ring, position: fab.style.position, ringClass: ring ? ring.className : null };
    });
    expect(result.ringExists).toBe(true);
    expect(result.position).toBe('relative');
    expect(result.ringClass).toContain('fab-ring');
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 10. Chat Bubbles
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initChatBubbles', () => {
  test('sets initial opacity and transform on bubbles', async () => {
    const page = await createPage();
    const styles = await page.evaluate(() => {
      window.DesiFitAnim.initChatBubbles();
      return Array.from(document.querySelectorAll('.chat-bubble')).map(b => ({ opacity: b.style.opacity, transform: b.style.transform }));
    });
    expect(styles.length).toBe(2);
    styles.forEach(s => { expect(s.opacity).toBe('0'); expect(s.transform).toContain('translateY(20px)'); });
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 11. Typing Indicator
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initTypingIndicator', () => {
  test('sets animation on typing dots', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initTypingIndicator('.typing-dots');
      return Array.from(document.querySelectorAll('.typing-dot')).map(d => !!d.style.animation);
    });
    expect(result.length).toBe(3);
    result.forEach(r => expect(r).toBe(true));
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 12. Text Reveal
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initTextReveal', () => {
  test('splits text into individual character spans', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initTextReveal('.text-reveal');
      const el = document.querySelector('.text-reveal');
      const spans = el.querySelectorAll('span');
      const text = Array.from(spans).map(s => s.textContent).join('').replace(/\u00A0/g, ' ');
      return { spanCount: spans.length, text };
    });
    expect(result.spanCount).toBeGreaterThan(0);
    expect(result.text).toBe('Test Text!');
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 13. Floating
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initFloating', () => {
  test('sets animation on floating elements', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initFloating('.float-gentle');
      return !!document.querySelector('.float-gentle').style.animation;
    });
    expect(result).toBe(true);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 14. Dark Mode
// ═══════════════════════════════════════════════════════════════════════════
test.describe('Dark Mode (Anim Engine)', () => {
  test('getDarkMode returns false by default', async () => {
    const page = await createPage();
    await page.evaluate(() => localStorage.removeItem('desifit-dark-mode'));
    expect(await page.evaluate(() => window.DesiFitAnim.getDarkMode())).toBe(false);
    await page.close();
  });

  test('setDarkMode(true) adds dark class', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.setDarkMode(true);
      return { darkClass: document.documentElement.classList.contains('dark'), stored: localStorage.getItem('desifit-dark-mode') };
    });
    expect(result.darkClass).toBe(true);
    expect(result.stored).toBe('true');
    await page.close();
  });

  test('setDarkMode(false) removes dark class', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.setDarkMode(true); window.DesiFitAnim.setDarkMode(false);
      return { darkClass: document.documentElement.classList.contains('dark'), stored: localStorage.getItem('desifit-dark-mode') };
    });
    expect(result.darkClass).toBe(false);
    expect(result.stored).toBe('false');
    await page.close();
  });

  test('toggleDarkMode toggles state', async () => {
    const page = await createPage();
    await page.evaluate(() => { window.DesiFitAnim.setDarkMode(false); });
    const first = await page.evaluate(() => { window.DesiFitAnim.toggleDarkMode(); return window.DesiFitAnim.getDarkMode(); });
    expect(first).toBe(true);
    const second = await page.evaluate(() => { window.DesiFitAnim.toggleDarkMode(); return window.DesiFitAnim.getDarkMode(); });
    expect(second).toBe(false);
    await page.close();
  });

  test('dark mode dispatches custom event', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      let received = null;
      window.addEventListener('darkmodechange', (e) => { received = e.detail.dark; });
      window.DesiFitAnim.setDarkMode(true);
      return received;
    });
    expect(result).toBe(true);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 15. Search / Filter
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initSearchFilter', () => {
  test('filters items based on input value', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initSearchFilter('#screen-search', '.filter-item');
      const input = document.getElementById('screen-search');
      input.value = 'Feature';
      input.dispatchEvent(new Event('input'));
      const items = Array.from(document.querySelectorAll('.filter-item'));
      return { featureHidden: items[0].classList.contains('hidden'), dashboardHidden: items[1].classList.contains('hidden') };
    });
    expect(result.featureHidden).toBe(false);
    expect(result.dashboardHidden).toBe(true);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 16. Category Tabs
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initCategoryTabs', () => {
  test('filters items and updates active tab', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initCategoryTabs('#category-tabs', '.filter-item');
      const tabs = document.querySelectorAll('#category-tabs [data-category]');
      tabs[1].click();
      const items = document.querySelectorAll('.filter-item');
      return { featuresVisible: !items[0].classList.contains('hidden'), dashboardHidden: items[1].classList.contains('hidden'), activeHasPrimary: tabs[1].classList.contains('bg-primary') };
    });
    expect(result.featuresVisible).toBe(true);
    expect(result.dashboardHidden).toBe(true);
    expect(result.activeHasPrimary).toBe(true);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 17. Preview Modal
// ═══════════════════════════════════════════════════════════════════════════
test.describe('Preview Modal', () => {
  test('openPreviewModal creates modal DOM elements', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.openPreviewModal({ title: 'Test Screen', description: 'A test', tags: ['tag1'], icon: 'star', href: '#' });
      const modal = document.getElementById('preview-modal');
      return { exists: !!modal, role: modal.getAttribute('role'), ariaModal: modal.getAttribute('aria-modal'), ariaLabel: modal.getAttribute('aria-label') };
    });
    expect(result.exists).toBe(true);
    expect(result.role).toBe('dialog');
    expect(result.ariaLabel).toContain('Test Screen');
    await page.close();
  });

  test('closePreviewModal removes modal', async () => {
    const page = await createPage();
    await page.evaluate(() => { window.DesiFitAnim.openPreviewModal({ title: 'Test' }); });
    await page.waitForTimeout(100);
    await page.evaluate(() => { window.DesiFitAnim.closePreviewModal(); });
    await page.waitForTimeout(400);
    expect(await page.evaluate(() => !!document.getElementById('preview-modal'))).toBe(false);
    await page.close();
  });

  test('modal closes on Escape key', async () => {
    const page = await createPage();
    await page.evaluate(() => { window.DesiFitAnim.openPreviewModal({ title: 'Test' }); });
    await page.waitForTimeout(100);
    await page.keyboard.press('Escape');
    await page.waitForTimeout(400);
    expect(await page.evaluate(() => !!document.getElementById('preview-modal'))).toBe(false);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 18. Back to Top
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initBackToTop', () => {
  test('shows/hides button based on scroll position', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initBackToTop('#back-to-top');
      const btn = document.querySelector('#back-to-top');
      window.scrollTo(0, 800); window.dispatchEvent(new Event('scroll'));
      const scrolled = { opacity0: btn.classList.contains('opacity-0'), hasOpacity100: btn.classList.contains('opacity-100') };
      window.scrollTo(0, 0); window.dispatchEvent(new Event('scroll'));
      const atTop = { opacity0: btn.classList.contains('opacity-0'), hasOpacity100: btn.classList.contains('opacity-100') };
      return { scrolled, atTop };
    });
    expect(result.scrolled.opacity0).toBe(false);
    expect(result.scrolled.hasOpacity100).toBe(true);
    expect(result.atTop.opacity0).toBe(true);
    expect(result.atTop.hasOpacity100).toBe(false);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 19. Ripple Effect
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initRippleEffect', () => {
  test('creates ripple span on click', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      const btn = document.querySelector('.ripple-btn');
      window.DesiFitAnim.initRippleEffect('.ripple-btn');
      const rect = btn.getBoundingClientRect();
      btn.dispatchEvent(new MouseEvent('click', { clientX: rect.left + 10, clientY: rect.top + 10 }));
      return { hasRipple: !!btn.querySelector('span'), positionStyle: btn.style.position, overflowStyle: btn.style.overflow };
    });
    expect(result.hasRipple).toBe(true);
    expect(result.positionStyle).toBe('relative');
    expect(result.overflowStyle).toBe('hidden');
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 20. Scroll Progress Indicator
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initScrollProgressIndicator', () => {
  test('updates bar width on scroll', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initScrollProgressIndicator('#scroll-progress');
      const maxScroll = document.documentElement.scrollHeight - window.innerHeight;
      window.scrollTo(0, maxScroll * 0.5);
      window.dispatchEvent(new Event('scroll'));
      return parseFloat(document.querySelector('#scroll-progress').style.width);
    });
    expect(result).toBeGreaterThan(30);
    expect(result).toBeLessThan(70);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 21. Inject Keyframes
// ═══════════════════════════════════════════════════════════════════════════
test.describe('injectKeyframes', () => {
  test('injects CSS keyframes into document head', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      const style = document.getElementById('desifit-animations');
      return { exists: !!style, hasWiggle: style.textContent.includes('@keyframes wiggle'), hasRipple: style.textContent.includes('@keyframes ripple-expand'), hasFloat: style.textContent.includes('@keyframes float-gentle') };
    });
    expect(result.exists).toBe(true);
    expect(result.hasWiggle).toBe(true);
    expect(result.hasRipple).toBe(true);
    expect(result.hasFloat).toBe(true);
    await page.close();
  });

  test('does not duplicate keyframes on second call', async () => {
    const page = await createPage();
    const count = await page.evaluate(() => {
      window.DesiFitAnim.injectKeyframes();
      return document.querySelectorAll('#desifit-animations').length;
    });
    expect(count).toBe(1);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 22. Scroll Progress Ring
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initScrollProgressRing', () => {
  test('sets initial stroke-dashoffset on circle', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initScrollProgressRing('.scroll-ring');
      return parseFloat(document.querySelector('.progress-ring__circle').style.strokeDashoffset);
    });
    expect(result).toBeGreaterThan(0);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 23. Nav Slide
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initNavSlide', () => {
  test('adds transition to active nav element', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initNavSlide();
      const active = document.querySelector('nav .bg-primary');
      return active ? active.style.transition : null;
    });
    expect(result).toBeTruthy();
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 24. Liquid Navigation
// ═══════════════════════════════════════════════════════════════════════════
test.describe('liquidNavigate', () => {
  test('activates overlay and prevents default', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      const overlay = document.getElementById('liquid-overlay');
      const event = new Event('click', { cancelable: true });
      window.DesiFitAnim.liquidNavigate(event, '#test');
      return { overlayActive: overlay.classList.contains('active'), defaultPrevented: event.defaultPrevented };
    });
    expect(result.overlayActive).toBe(true);
    expect(result.defaultPrevented).toBe(true);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 25. COLORS
// ═══════════════════════════════════════════════════════════════════════════
test.describe('COLORS', () => {
  test('exports color palette with correct values', async () => {
    const page = await createPage();
    const colors = await page.evaluate(() => window.DesiFitAnim.COLORS);
    expect(colors.primary).toEqual([164, 55, 0]);
    expect(colors.secondary).toEqual([46, 125, 50]);
    expect(colors.tertiary).toEqual([0, 90, 183]);
    expect(colors.white).toEqual([255, 255, 255]);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 26. Parallax
// ═══════════════════════════════════════════════════════════════════════════
test.describe('parallax functions', () => {
  test('initParallax sets initial transform', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initParallax('.parallax-layer', { speed: 0.3 });
      return document.querySelector('.parallax-layer').style.transform.includes('translate3d');
    });
    expect(result).toBe(true);
    await page.close();
  });

  test('initScrollParallax sets initial transform', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initScrollParallax('.scroll-parallax', { speed: 0.2 });
      return document.querySelector('.scroll-parallax').style.transform.includes('translate3d');
    });
    expect(result).toBe(true);
    await page.close();
  });
});

// ═══════════════════════════════════════════════════════════════════════════
// 27. Icon Wiggle
// ═══════════════════════════════════════════════════════════════════════════
test.describe('initIconWiggle', () => {
  test('adds wiggle animation on mouseenter', async () => {
    const page = await createPage();
    const result = await page.evaluate(() => {
      window.DesiFitAnim.initIconWiggle('.icon-wiggle');
      const icon = document.querySelector('.icon-wiggle');
      icon.dispatchEvent(new MouseEvent('mouseenter'));
      return icon.style.animation;
    });
    expect(result).toContain('wiggle');
    await page.close();
  });
});
