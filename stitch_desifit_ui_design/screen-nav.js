/**
 * DesiFit Screen Navigation & Dark Mode Helper
 * Shared across all individual screens for consistent back nav + dark mode toggle
 */
(function () {
  'use strict';

  const DARK_MODE_KEY = 'desifit-dark-mode';

  function getDarkMode() {
    return localStorage.getItem(DARK_MODE_KEY) === 'true';
  }

  function setDarkMode(enabled) {
    if (enabled) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
    localStorage.setItem(DARK_MODE_KEY, enabled ? 'true' : 'false');
    window.dispatchEvent(new CustomEvent('darkmodechange', { detail: { dark: enabled } }));
  }

  function toggleDarkMode() {
    setDarkMode(!getDarkMode());
  }

  function initDarkMode() {
    const stored = localStorage.getItem(DARK_MODE_KEY);
    if (stored !== null) {
      setDarkMode(stored === 'true');
    } else {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      setDarkMode(prefersDark);
    }
  }

  // Inject navigation bar + dark mode toggle into each screen
  function injectScreenNav() {
    if (document.getElementById('ds-screen-nav')) return;

    // Determine back URL (go to gallery index or fallback)
    const backUrl = '../index.html';

    const nav = document.createElement('div');
    nav.id = 'ds-screen-nav';
    nav.style.cssText = `
      position: fixed; top: 0; left: 0; right: 0; z-index: 99999;
      display: flex; align-items: center; justify-content: space-between;
      padding: 0.5rem 1rem;
      background: rgba(249,249,249,0.85);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      border-bottom: 1px solid rgba(227,191,178,0.15);
      transition: background 0.3s ease;
    `;

    // Back button
    const backBtn = document.createElement('button');
    backBtn.innerHTML = `
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#5a4138" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
        <path d="M19 12H5"/><polyline points="12 19 5 12 12 5"/>
      </svg>
    `;
    backBtn.style.cssText = `
      width: 2.25rem; height: 2.25rem; border-radius: 0.75rem; border: none;
      background: rgba(0,0,0,0.04); cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      transition: all 0.2s cubic-bezier(0.34,1.56,0.64,1);
    `;
    backBtn.addEventListener('mouseenter', () => {
      backBtn.style.transform = 'scale(1.05)';
      backBtn.style.background = 'rgba(0,0,0,0.08)';
    });
    backBtn.addEventListener('mouseleave', () => {
      backBtn.style.transform = 'scale(1)';
      backBtn.style.background = 'rgba(0,0,0,0.04)';
    });
    backBtn.addEventListener('click', () => {
      // Liquid transition effect
      const overlay = document.createElement('div');
      overlay.style.cssText = `
        position: fixed; inset: 0; z-index: 100000;
        background: linear-gradient(135deg, #a43700, #cd4700);
        transform: translateY(100%);
        transition: transform 0.4s cubic-bezier(0.76,0,0.24,1);
        pointer-events: none;
      `;
      document.body.appendChild(overlay);
      requestAnimationFrame(() => {
        overlay.style.transform = 'translateY(0)';
      });
      setTimeout(() => { window.location.href = backUrl; }, 380);
    });

    // Title
    const titleEl = document.createElement('span');
    const pageTitle = document.title.replace('DesiFit', '').replace('DesiFit -', '').trim() || 'Screen';
    titleEl.textContent = pageTitle;
    titleEl.style.cssText = `
      font-family: 'Plus Jakarta Sans', sans-serif;
      font-size: 0.8125rem; font-weight: 700;
      color: #1a1c1c; letter-spacing: -0.01em;
    `;

    // Dark mode toggle
    const dmBtn = document.createElement('button');
    dmBtn.innerHTML = getDarkMode()
      ? `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#a43700" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>`
      : `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#5a4138" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>`;

    dmBtn.style.cssText = `
      width: 2.25rem; height: 2.25rem; border-radius: 0.75rem; border: none;
      background: rgba(0,0,0,0.04); cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      transition: all 0.2s cubic-bezier(0.34,1.56,0.64,1);
    `;
    dmBtn.addEventListener('mouseenter', () => {
      dmBtn.style.transform = 'scale(1.05) rotate(10deg)';
      dmBtn.style.background = 'rgba(0,0,0,0.08)';
    });
    dmBtn.addEventListener('mouseleave', () => {
      dmBtn.style.transform = 'scale(1) rotate(0deg)';
      dmBtn.style.background = 'rgba(0,0,0,0.04)';
    });
    dmBtn.addEventListener('click', () => {
      toggleDarkMode();
      const isDark = getDarkMode();
      dmBtn.innerHTML = isDark
        ? `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#a43700" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>`
        : `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#5a4138" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>`;
    });

    // Listen for theme changes from elsewhere
    window.addEventListener('darkmodechange', (e) => {
      dmBtn.innerHTML = e.detail.dark
        ? `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#a43700" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>`
        : `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#5a4138" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>`;
    });

    // Dark mode styling for the nav itself
    const styleEl = document.createElement('style');
    styleEl.textContent = `
      .dark #ds-screen-nav { background: rgba(18,18,18,0.85) !important; border-bottom-color: rgba(255,255,255,0.08) !important; }
      .dark #ds-screen-nav span { color: #e8e8e8 !important; }
      .dark #ds-screen-nav button { background: rgba(255,255,255,0.06) !important; }
      .dark #ds-screen-nav button:hover { background: rgba(255,255,255,0.1) !important; }
      .dark #ds-screen-nav button svg { stroke: #b0a8a0 !important; }
    `;
    document.head.appendChild(styleEl);

    const centerGroup = document.createElement('div');
    centerGroup.style.cssText = 'display:flex;align-items:center;gap:0.5rem;';
    centerGroup.appendChild(document.createTextNode(''));
    // DesiFit mini badge
    const badge = document.createElement('span');
    badge.textContent = 'DesiFit';
    badge.style.cssText = `
      font-family: 'Plus Jakarta Sans', sans-serif;
      font-size: 0.625rem; font-weight: 800;
      background: linear-gradient(135deg, #a43700, #cd4700);
      -webkit-background-clip: text; -webkit-text-fill-color: transparent;
      background-clip: text; letter-spacing: 0.08em;
    `;
    centerGroup.appendChild(badge);

    nav.appendChild(backBtn);
    nav.appendChild(centerGroup);
    nav.appendChild(dmBtn);

    document.body.prepend(nav);

    // Add padding-top to body or main to account for nav bar height
    const addPadding = () => {
      const mainEl = document.querySelector('main');
      if (mainEl) {
        const currentPt = parseFloat(getComputedStyle(mainEl).paddingTop) || 0;
        // Only add padding if it doesn't already have adequate spacing
        if (currentPt < 40) mainEl.style.paddingTop = '56px';
      } else {
        const bodyPt = parseFloat(getComputedStyle(document.body).paddingTop) || 0;
        if (bodyPt < 40) document.body.style.paddingTop = '56px';
      }
    };
    // Try immediately and on DOMContentLoaded
    addPadding();
    if (document.readyState !== 'complete') {
      document.addEventListener('DOMContentLoaded', addPadding);
    }
  }

  // Auto-initialize (skip for the gallery index page itself)
  if (!window.location.pathname.endsWith('index.html') &&
      !window.location.pathname.endsWith('/') &&
      !window.location.pathname.endsWith('/stitch_desifit_ui_design')) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => {
        initDarkMode();
        injectScreenNav();
      });
    } else {
      initDarkMode();
      injectScreenNav();
    }
  }

  // Export API
  window.DesiFitNav = {
    getDarkMode,
    setDarkMode,
    toggleDarkMode,
    initDarkMode,
  };

})();
