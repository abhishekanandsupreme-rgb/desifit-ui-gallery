/**
 * DesiFit Animation Engine — Full Immersion v3
 * Provides: interactive particles, parallax, spring physics, staggered reveals,
 *           micro-interactions, dark mode, scroll progress, search/filter, preview modal,
 *           performance detection, water fill, fire flame, morph shapes, breath circle,
 *           flip card, slide transitions
 * Loaded by each screen's <script src="animation-engine.js"></script>
 */
(function () {
  'use strict';

  /* ─── Color Palette (from DESIGN.md) ─── */
  const COLORS = {
    primary: [164, 55, 0],       // #A43700 saffron
    secondary: [46, 125, 50],    // #2E7D32 leaf green
    tertiary: [0, 90, 183],      // #005AB7
    surface: [249, 249, 249],
    white: [255, 255, 255],
  };

  /* ═══════════════════════════════════════════
     0. PERFORMANCE DETECTION
     ═══════════════════════════════════════════ */
  let _performanceTier = 'high'; // 'high', 'medium', 'low'
  let _reducedMotion = false;
  let _darkMode = false;           // dark-mode-aware tier: reduces particle/parallax
  let _cleanupFns = [];

  function detectPerformanceTier() {
    const nav = navigator;

    // Check for reduced motion preference first
    _reducedMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    // Device memory API (Chrome-only, but good indicator)
    const deviceMemory = nav.deviceMemory || 8; // Default 8GB if unavailable
    const cpuCores = nav.hardwareConcurrency || 4;

    if (deviceMemory <= 2 || cpuCores <= 2 || _reducedMotion) {
      _performanceTier = 'low';
    } else if (deviceMemory <= 4 || cpuCores <= 4) {
      _performanceTier = 'medium';
    } else {
      _performanceTier = 'high';
    }
  }

  function isMotionSafe() {
    return !_reducedMotion;
  }

  function getPerformanceTier() {
    return _performanceTier;
  }

  function setPerformanceTier(tier) {
    if (['low', 'medium', 'high'].indexOf(tier) !== -1) {
      _performanceTier = tier;
    }
  }

  function getParticleCount() {
    switch (_performanceTier) {
      case 'low': return _darkMode ? 5 : 8;
      case 'medium': return _darkMode ? 15 : 25;
      default: return _darkMode ? 30 : 50;
    }
  }

  function shouldUseInteractiveParticles() {
    return _performanceTier !== 'low';
  }

  function getBlurRadius() {
    if (_performanceTier === 'low') return 0;
    return _darkMode ? 8 : 16;
  }

  function registerCleanup(fn) {
    _cleanupFns.push(fn);
  }

  function runAllCleanup() {
    _cleanupFns.forEach(fn => { try { fn(); } catch (_) {} });
    _cleanupFns = [];
  }

  function initPerformanceMode() {
    detectPerformanceTier();
    console.log(`[DesiFit Anim] Performance tier: ${_performanceTier}${_reducedMotion ? ' (reduced motion)' : ''}`);

    // Listen for reduced-motion changes
    const motionQuery = window.matchMedia('(prefers-reduced-motion: reduce)');
    const handler = (e) => {
      _reducedMotion = e.matches;
      if (_reducedMotion) {
        runAllCleanup();
      }
    };
    if (motionQuery.addEventListener) {
      motionQuery.addEventListener('change', handler);
    }
    registerCleanup(() => {
      if (motionQuery.removeEventListener) {
        motionQuery.removeEventListener('change', handler);
      }
    });

    // Start dark-mode-aware animation tier
    initDarkModeTier();

    return _performanceTier;
  }

  /* ═══════════════════════════════════════════
     1. INTERACTIVE PARTICLE SYSTEM
     ═══════════════════════════════════════════ */
  class ParticleSystem {
    constructor(canvas, opts = {}) {
      this.canvas = canvas;
      this.ctx = canvas.getContext('2d');
      this.particles = [];
      // Use performance-aware particle count
      this.maxCount = opts.max || getParticleCount();
      this.mouse = { x: -1000, y: -1000, active: false };
      this.connectDist = opts.connectDist || (_performanceTier === 'low' ? 0 : 120);
      this.connectionAlpha = opts.connectionAlpha || (_performanceTier === 'low' ? 0 : 0.12);
      this.running = false;
      this.interactive = opts.interactive !== false && shouldUseInteractiveParticles();
      this._cleanupRegistered = false;

      this._resize = this._resize.bind(this);
      this._tick = this._tick.bind(this);
      this._onMouse = this._onMouse.bind(this);
      this._onTouch = this._onTouch.bind(this);

      window.addEventListener('resize', this._resize);

      if (this.interactive) {
        this.canvas.style.pointerEvents = 'none';
        window.addEventListener('mousemove', this._onMouse);
        window.addEventListener('mouseleave', () => { this.mouse.active = false; });
        window.addEventListener('touchmove', this._onTouch, { passive: true });
        window.addEventListener('touchend', () => { this.mouse.active = false; });
      }

      this._resize();
    }

    _resize() {
      const dpr = _performanceTier === 'low' ? 1 : (window.devicePixelRatio || 1);
      this.canvas.width = this.canvas.offsetWidth * dpr;
      this.canvas.height = this.canvas.offsetHeight * dpr;
      this.ctx.scale(dpr, dpr);
    }

    _onMouse(e) {
      this.mouse.x = e.clientX;
      this.mouse.y = e.clientY;
      this.mouse.active = true;
    }

    _onTouch(e) {
      const touch = e.touches[0];
      if (touch) {
        this.mouse.x = touch.clientX;
        this.mouse.y = touch.clientY;
        this.mouse.active = true;
      }
    }

    seed() {
      const w = this.canvas.offsetWidth;
      const h = this.canvas.offsetHeight;
      const palette = [COLORS.primary, COLORS.secondary, COLORS.tertiary, COLORS.white];
      for (let i = this.particles.length; i < this.maxCount; i++) {
        const c = palette[Math.floor(Math.random() * palette.length)];
        this.particles.push({
          x: Math.random() * w,
          y: Math.random() * h,
          r: 1.5 + Math.random() * (_performanceTier === 'low' ? 1.5 : 3.5),
          vx: (Math.random() - 0.5) * (_performanceTier === 'low' ? 0.2 : 0.4),
          vy: -0.12 - Math.random() * (_performanceTier === 'low' ? 0.15 : 0.3),
          alpha: 0.06 + Math.random() * 0.15,
          color: c,
          phase: Math.random() * Math.PI * 2,
        });
      }
    }

    start() {
      if (this.running) return;
      if (!isMotionSafe()) return;
      this.running = true;
      this.seed();
      this._tick();
    }

    stop() {
      this.running = false;
      if (this._raf) {
        cancelAnimationFrame(this._raf);
        this._raf = null;
      }
    }

    destroy() {
      this.stop();
      window.removeEventListener('resize', this._resize);
      window.removeEventListener('mousemove', this._onMouse);
      window.removeEventListener('mouseleave', () => { this.mouse.active = false; });
      window.removeEventListener('touchmove', this._onTouch);
      window.removeEventListener('touchend', () => { this.mouse.active = false; });
    }

    _tick() {
      if (!this.running) return;
      const w = this.canvas.offsetWidth;
      const h = this.canvas.offsetHeight;
      this.ctx.clearRect(0, 0, w, h);

      const pts = this.particles;

      for (const p of pts) {
        p.phase += 0.008;
        p.x += p.vx + Math.sin(p.phase) * 0.2;
        p.y += p.vy;

        if (this.mouse.active && this.interactive) {
          const dx = p.x - this.mouse.x;
          const dy = p.y - this.mouse.y;
          const dist = Math.sqrt(dx * dx + dy * dy);
          if (dist < 150 && dist > 0) {
            const force = (150 - dist) / 150 * 0.5;
            p.x += (dx / dist) * force;
            p.y += (dy / dist) * force;
          }
        }

        if (p.y < -10) { p.y = h + 10; p.x = Math.random() * w; }
        if (p.x < -10) p.x = w + 10;
        if (p.x > w + 10) p.x = -10;

        this.ctx.beginPath();
        this.ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
        this.ctx.fillStyle = `rgba(${p.color[0]},${p.color[1]},${p.color[2]},${p.alpha})`;
        this.ctx.fill();
      }

      if (this.interactive && _performanceTier !== 'low') {
        for (let i = 0; i < pts.length; i++) {
          for (let j = i + 1; j < pts.length; j++) {
            const dx = pts[i].x - pts[j].x;
            const dy = pts[i].y - pts[j].y;
            const dist = Math.sqrt(dx * dx + dy * dy);
            if (dist < this.connectDist) {
              const alpha = (1 - dist / this.connectDist) * this.connectionAlpha;
              this.ctx.beginPath();
              this.ctx.moveTo(pts[i].x, pts[i].y);
              this.ctx.lineTo(pts[j].x, pts[j].y);
              this.ctx.strokeStyle = `rgba(164,55,0,${alpha})`;
              this.ctx.lineWidth = 0.5;
              this.ctx.stroke();
            }
          }
        }

        if (this.mouse.active) {
          for (const p of pts) {
            const dx = p.x - this.mouse.x;
            const dy = p.y - this.mouse.y;
            const dist = Math.sqrt(dx * dx + dy * dy);
            if (dist < this.connectDist) {
              const alpha = (1 - dist / this.connectDist) * 0.2;
              this.ctx.beginPath();
              this.ctx.moveTo(p.x, p.y);
              this.ctx.lineTo(this.mouse.x, this.mouse.y);
              this.ctx.strokeStyle = `rgba(205,71,0,${alpha})`;
              this.ctx.lineWidth = 0.5;
              this.ctx.stroke();
            }
          }
        }
      }

      this._raf = requestAnimationFrame(this._tick);
    }
  }

  /* ═══════════════════════════════════════════
     2. SPRING PHYSICS
     ═══════════════════════════════════════════ */
  function springAnimate(el, props, { stiffness = 180, damping = 12, mass = 1, onComplete } = {}) {
    if (!isMotionSafe()) {
      // Skip spring animation, just apply final values
      for (const key in props) {
        el.style[key] = props[key] + (key.includes('scale') || key.includes('opacity') ? '' : 'px');
      }
      if (onComplete) onComplete();
      return;
    }

    const starts = {};
    const targets = {};
    const velocities = {};

    for (const key in props) {
      starts[key] = parseFloat(getComputedStyle(el)[key]) || 0;
      targets[key] = props[key];
      velocities[key] = 0;
    }

    let lastTime = performance.now();
    let rafId = null;

    function step(now) {
      const dt = Math.min((now - lastTime) / 1000, 0.064);
      lastTime = now;
      let settled = true;

      for (const key in targets) {
        const displacement = starts[key] - targets[key];
        const springForce = -stiffness * displacement;
        const dampingForce = -damping * velocities[key];
        const acceleration = (springForce + dampingForce) / mass;
        velocities[key] += acceleration * dt;
        starts[key] += velocities[key] * dt;

        el.style[key] = starts[key] + (key.includes('scale') || key.includes('opacity') ? '' : 'px');

        if (Math.abs(velocities[key]) > 0.1 || Math.abs(displacement) > 0.5) settled = false;
      }

      if (!settled) rafId = requestAnimationFrame(step);
      else { if (onComplete) onComplete(); }
    }

    rafId = requestAnimationFrame(step);

    // Return cancel function
    return () => {
      if (rafId) cancelAnimationFrame(rafId);
    };
  }

  /* ═══════════════════════════════════════════
     3. STAGGERED REVEAL (IntersectionObserver)
     ═══════════════════════════════════════════ */
  function initStaggerReveal(selector = '.stagger-item', opts = {}) {
    if (!isMotionSafe()) return;
    const items = document.querySelectorAll(selector);
    if (!items.length) return;

    items.forEach((el, i) => {
      el.style.opacity = '0';
      el.style.transform = opts.fromY != null ? `translateY(${opts.fromY || 30}px)` : 'translateY(24px)';
      el.style.transition = `opacity 0.5s cubic-bezier(0.34,1.56,0.64,1) ${(i * (opts.delay || 60))}ms, transform 0.5s cubic-bezier(0.34,1.56,0.64,1) ${(i * (opts.delay || 60))}ms`;
    });

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.style.opacity = '1';
          entry.target.style.transform = 'translateY(0)';
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: opts.threshold || 0.15 });

    items.forEach(el => observer.observe(el));

    registerCleanup(() => observer.disconnect());
  }

  /* ═══════════════════════════════════════════
     4. PARALLAX SCROLL
     ═══════════════════════════════════════════ */
  function initParallax(selector = '.parallax-layer', opts = {}) {
    if (!isMotionSafe()) return;
    const layers = document.querySelectorAll(selector);
    if (!layers.length) return;

    var baseSpeed = _performanceTier === 'low' ? 0 : 0.4;
    if (_darkMode && baseSpeed > 0) baseSpeed *= 0.6; // reduce parallax depth on dark theme
    const speed = opts.speed || baseSpeed;

    function onScroll() {
      const scrollY = window.scrollY || window.pageYOffset;
      layers.forEach(el => {
        const rate = parseFloat(el.dataset.rate) || speed;
        if (rate > 0) {
          el.style.transform = `translate3d(0, ${scrollY * rate}px, 0)`;
        }
      });
    }

    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();

    registerCleanup(() => window.removeEventListener('scroll', onScroll));
  }

  function initScrollParallax(selector = '.scroll-parallax', opts = {}) {
    if (!isMotionSafe() || _performanceTier === 'low') return;
    const els = document.querySelectorAll(selector);
    if (!els.length) return;
    const speed = opts.speed || (_darkMode ? 0.18 : 0.3);

    function onScroll() {
      const vh = window.innerHeight;
      els.forEach(el => {
        const rect = el.getBoundingClientRect();
        const progress = (vh - rect.top) / (vh + rect.height);
        const clamped = Math.max(0, Math.min(1, progress));
        const rate = parseFloat(el.dataset.rate) || speed;
        const yOffset = (clamped - 0.5) * 100 * rate;
        el.style.transform = `translate3d(0, ${yOffset}px, 0)`;
      });
    }

    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();

    registerCleanup(() => window.removeEventListener('scroll', onScroll));
  }

  function initScrollReveal(selector = '.scroll-reveal', opts = {}) {
    if (!isMotionSafe()) return;
    const els = document.querySelectorAll(selector);
    if (!els.length) return;

    els.forEach((el, i) => {
      const direction = el.dataset.direction || 'up';
      const delay = parseFloat(el.dataset.delay) || (i * (opts.delay || 80));
      const duration = opts.duration || 600;
      const transforms = {
        up: 'translateY(40px)',
        down: 'translateY(-40px)',
        left: 'translateX(-40px)',
        right: 'translateX(40px)',
        scale: 'scale(0.85)',
      };

      el.style.opacity = '0';
      el.style.transform = transforms[direction] || transforms.up;
      el.style.transition = `opacity ${duration}ms cubic-bezier(0.34,1.56,0.64,1) ${delay}ms, transform ${duration}ms cubic-bezier(0.34,1.56,0.64,1) ${delay}ms`;
      // willChange is set temporarily and will be removed after animation
      el.style.willChange = 'opacity, transform';
    });

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.style.opacity = '1';
          entry.target.style.transform = 'none';
          // Remove willChange after animation completes to free GPU memory
          setTimeout(() => {
            entry.target.style.willChange = 'auto';
          }, opts.duration || 600);
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: opts.threshold || 0.15, rootMargin: opts.rootMargin || '0px 0px -40px 0px' });

    els.forEach(el => observer.observe(el));

    registerCleanup(() => observer.disconnect());
  }

  function initScrollProgressBar(selector = '.scroll-progress-bar') {
    const bars = document.querySelectorAll(selector);
    if (!bars.length) return;

    bars.forEach(bar => {
      const targetWidth = bar.style.width || '0%';
      bar.style.width = '0%';
      bar.style.transition = 'width 1.2s cubic-bezier(0.34,1.56,0.64,1)';

      const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setTimeout(() => { bar.style.width = targetWidth; }, 200);
            observer.unobserve(entry.target);
          }
        });
      }, { threshold: 0.3 });
      observer.observe(bar);
    });
  }

  function initScrollCounter(selector = '.scroll-counter') {
    if (!isMotionSafe()) return;
    const els = document.querySelectorAll(selector);
    if (!els.length) return;

    els.forEach(el => {
      const target = parseInt(el.dataset.count) || 0;
      const prefix = el.dataset.prefix || '';
      const suffix = el.dataset.suffix || '';
      let animated = false;

      const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting && !animated) {
            animated = true;
            animateCounter(el, target, 1200, prefix, suffix);
            observer.unobserve(entry.target);
          }
        });
      }, { threshold: 0.3 });
      observer.observe(el);
    });
  }

  function initScrollHeader(selector = '.scroll-header') {
    if (!isMotionSafe()) return;
    const els = document.querySelectorAll(selector);
    if (!els.length) return;

    els.forEach((el, i) => {
      el.style.opacity = '0';
      el.style.transform = 'scale(0.9) translateY(20px)';
      el.style.transition = `opacity 0.6s cubic-bezier(0.34,1.56,0.64,1) ${i * 100}ms, transform 0.6s cubic-bezier(0.34,1.56,0.64,1) ${i * 100}ms`;
    });

    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.style.opacity = '1';
          entry.target.style.transform = 'scale(1) translateY(0)';
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.2 });

    els.forEach(el => observer.observe(el));
    registerCleanup(() => observer.disconnect());
  }

  function initScrollStagger(selector = '.scroll-stagger-container') {
    if (!isMotionSafe()) return;
    const containers = document.querySelectorAll(selector);
    if (!containers.length) return;

    const observers = [];
    containers.forEach(container => {
      const children = container.querySelectorAll('.scroll-stagger-item');
      if (!children.length) return;

      children.forEach((child, i) => {
        child.style.opacity = '0';
        child.style.transform = 'translateY(30px) scale(0.95)';
        child.style.transition = `opacity 0.5s cubic-bezier(0.34,1.56,0.64,1) ${i * 80}ms, transform 0.5s cubic-bezier(0.34,1.56,0.64,1) ${i * 80}ms`;
      });

      const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const items = entry.target.querySelectorAll('.scroll-stagger-item');
            items.forEach(item => {
              item.style.opacity = '1';
              item.style.transform = 'none';
            });
            observer.unobserve(entry.target);
          }
        });
      }, { threshold: 0.15 });

      observer.observe(container);
      observers.push(observer);
    });

    registerCleanup(() => observers.forEach(o => o.disconnect()));
  }

  function initScrollProgressRing(selector = '.scroll-ring') {
    if (!isMotionSafe()) return;
    const rings = document.querySelectorAll(selector);
    if (!rings.length) return;

    rings.forEach(ring => {
      const circle = ring.querySelector('.progress-ring__circle[data-target]');
      if (!circle) return;

      const target = parseFloat(circle.dataset.target);
      const circumference = parseFloat(circle.getAttribute('stroke-dasharray'));
      const offset = circumference - (circumference * target);
      circle.style.strokeDashoffset = circumference;

      const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setTimeout(() => {
              circle.style.transition = 'stroke-dashoffset 1.5s cubic-bezier(0.34,1.56,0.64,1)';
              circle.style.strokeDashoffset = offset;
            }, 300);
            observer.unobserve(entry.target);
          }
        });
      }, { threshold: 0.3 });
      observer.observe(ring);
    });
  }

  /* ═══════════════════════════════════════════
     5. MICRO-INTERACTIONS
     ═══════════════════════════════════════════ */

  function initButtonSquash(selector = 'button, .btn-interactive') {
    document.querySelectorAll(selector).forEach(btn => {
      const onDown = () => {
        btn.style.transition = 'transform 0.1s cubic-bezier(0.34,1.56,0.64,1)';
        btn.style.transform = 'scale(0.94)';
      };
      const onUp = () => { btn.style.transform = 'scale(1)'; };
      const onLeave = () => { btn.style.transform = 'scale(1)'; };

      btn.addEventListener('pointerdown', onDown);
      btn.addEventListener('pointerup', onUp);
      btn.addEventListener('pointerleave', onLeave);
    });
  }

  function initIconWiggle(selector = '.icon-wiggle') {
    document.querySelectorAll(selector).forEach(icon => {
      icon.addEventListener('mouseenter', () => {
        icon.style.animation = 'wiggle 0.4s ease-in-out';
      });
      icon.addEventListener('animationend', () => {
        icon.style.animation = '';
      });
    });
  }

  function initFABPulse(selector = '.fab-pulse') {
    document.querySelectorAll(selector).forEach(fab => {
      const ring = document.createElement('div');
      ring.className = 'fab-ring';
      ring.style.cssText = `
        position:absolute; inset:-4px; border-radius:50%;
        border:2px solid rgba(164,55,0,0.3);
        animation: fab-pulse-ring 3s ease-in-out infinite;
        pointer-events:none;
      `;
      fab.style.position = 'relative';
      fab.appendChild(ring);
    });
  }

  function animateCounter(el, target, duration = 1200, prefix = '', suffix = '') {
    const start = performance.now();
    const initial = 0;
    const rafId = requestAnimationFrame(function tick(now) {
      const elapsed = now - start;
      const progress = Math.min(elapsed / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      const current = Math.round(initial + (target - initial) * eased);
      el.textContent = prefix + current + suffix;
      if (progress < 1) requestAnimationFrame(tick);
    });
    return () => cancelAnimationFrame(rafId);
  }

  function animateProgressRings() {
    document.querySelectorAll('.progress-ring__circle[data-target]').forEach(circle => {
      const target = parseFloat(circle.dataset.target);
      const circumference = parseFloat(circle.getAttribute('stroke-dasharray'));
      const offset = circumference - (circumference * target);
      circle.style.strokeDashoffset = circumference;

      const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setTimeout(() => {
              circle.style.transition = 'stroke-dashoffset 1.5s cubic-bezier(0.34,1.56,0.64,1)';
              circle.style.strokeDashoffset = offset;
            }, 200);
            observer.unobserve(entry.target);
          }
        });
      }, { threshold: 0.3 });
      observer.observe(circle);
    });
  }

  /* ═══════════════════════════════════════════
     6. CHAT BUBBLE SPRING IN
     ═══════════════════════════════════════════ */
  function initChatBubbles() {
    if (!isMotionSafe()) return;
    const bubbles = document.querySelectorAll('.chat-bubble');
    bubbles.forEach((b, i) => {
      b.style.opacity = '0';
      b.style.transform = 'translateY(20px) scale(0.95)';
      b.style.transition = `opacity 0.45s cubic-bezier(0.34,1.56,0.64,1) ${i * 120}ms, transform 0.45s cubic-bezier(0.34,1.56,0.64,1) ${i * 120}ms`;
    });
    const obs = new IntersectionObserver(entries => {
      entries.forEach(e => {
        if (e.isIntersecting) {
          e.target.style.opacity = '1';
          e.target.style.transform = 'translateY(0) scale(1)';
          obs.unobserve(e.target);
        }
      });
    }, { threshold: 0.1 });
    bubbles.forEach(b => obs.observe(b));
    registerCleanup(() => obs.disconnect());
  }

  function initTypingIndicator(selector = '.typing-dots') {
    document.querySelectorAll(selector).forEach(container => {
      const dots = container.querySelectorAll('.typing-dot');
      dots.forEach((dot, i) => {
        dot.style.animation = `typing-bounce 1.4s ease-in-out ${i * 0.2}s infinite`;
      });
    });
  }

  function initCardLift(selector = '.card-lift') {
    document.querySelectorAll(selector).forEach(card => {
      card.addEventListener('pointerenter', () => {
        card.style.transition = 'transform 0.3s cubic-bezier(0.34,1.56,0.64,1), box-shadow 0.3s ease';
        card.style.transform = 'translateY(-4px) scale(1.01)';
        card.style.boxShadow = '0 8px 32px rgba(164,55,0,0.12), 0 4px 16px rgba(0,0,0,0.06)';
      });
      card.addEventListener('pointerleave', () => {
        card.style.transform = 'translateY(0) scale(1)';
        card.style.boxShadow = '';
      });
    });
  }

  function initTextReveal(selector = '.text-reveal') {
    if (!isMotionSafe()) return;
    document.querySelectorAll(selector).forEach(el => {
      const text = el.textContent;
      el.innerHTML = '';
      el.style.opacity = '1';

      [...text].forEach((char, i) => {
        const span = document.createElement('span');
        span.textContent = char === ' ' ? '\u00A0' : char;
        span.style.cssText = `
          opacity:0; display:inline-block;
          transition: opacity 0.3s ease ${i * 25}ms, transform 0.3s cubic-bezier(0.34,1.56,0.64,1) ${i * 25}ms;
          transform: translateY(8px);
        `;
        el.appendChild(span);
      });

      const obs = new IntersectionObserver(entries => {
        entries.forEach(e => {
          if (e.isIntersecting) {
            e.target.querySelectorAll('span').forEach(s => {
              s.style.opacity = '1';
              s.style.transform = 'translateY(0)';
            });
            obs.unobserve(e.target);
          }
        });
      }, { threshold: 0.3 });
      obs.observe(el);
      registerCleanup(() => obs.disconnect());
    });
  }

  function initFloating(selector = '.float-gentle') {
    if (!isMotionSafe()) return;
    document.querySelectorAll(selector).forEach((el, i) => {
      el.style.animation = `float-gentle ${3 + (i % 3)}s ease-in-out ${(i * 0.5)}s infinite`;
    });
  }

  function initNavSlide() {
    const nav = document.querySelector('nav');
    if (!nav) return;
    const active = nav.querySelector('[class*="bg-[#FFCCBC]"], [class*="bg-primary"]');
    if (active) {
      active.style.transition = 'all 0.3s cubic-bezier(0.34,1.56,0.64,1)';
    }
  }

  /* ═══════════════════════════════════════════
     7. DARK MODE TOGGLE
     ═══════════════════════════════════════════ */
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

  function initDarkMode(defaultDark = false) {
    const stored = localStorage.getItem(DARK_MODE_KEY);
    if (stored !== null) {
      setDarkMode(stored === 'true');
    } else {
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
      setDarkMode(prefersDark || defaultDark);
    }
  }

  /* ─── Dark-mode-aware animation tier (Day 4) ─── */
  function isDarkMode() {
    return _darkMode;
  }

  function _updateDarkModeTier() {
    var stored = localStorage.getItem(DARK_MODE_KEY);
    if (stored !== null) {
      _darkMode = stored === 'true';
    } else {
      _darkMode = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    }
  }

  function initDarkModeTier() {
    // Sync initial state
    _updateDarkModeTier();

    // Listen for system-level dark mode changes (OS preference)
    var schemeQuery = window.matchMedia('(prefers-color-scheme: dark)');
    var onSchemeChange = function () { _updateDarkModeTier(); };
    if (schemeQuery.addEventListener) {
      schemeQuery.addEventListener('change', onSchemeChange);
    }

    // Listen for user toggles (setDarkMode dispatches a 'darkmodechange' CustomEvent)
    var onUserToggle = function () { _updateDarkModeTier(); };
    window.addEventListener('darkmodechange', onUserToggle);

    registerCleanup(function () {
      if (schemeQuery.removeEventListener) {
        schemeQuery.removeEventListener('change', onSchemeChange);
      }
      window.removeEventListener('darkmodechange', onUserToggle);
    });
  }

  /* ═══════════════════════════════════════════
     8. SCROLL PROGRESS INDICATOR
     ═══════════════════════════════════════════ */
  function initScrollProgressIndicator(selector = '#scroll-progress') {
    const bar = document.querySelector(selector);
    if (!bar) return;

    function update() {
      const scrollTop = window.scrollY || window.pageYOffset;
      const docHeight = document.documentElement.scrollHeight - window.innerHeight;
      const progress = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
      bar.style.width = progress + '%';
    }

    window.addEventListener('scroll', update, { passive: true });
    update();
    registerCleanup(() => window.removeEventListener('scroll', update));
  }

  /* ═══════════════════════════════════════════
     9. SEARCH / FILTER
     ═══════════════════════════════════════════ */
  function initSearchFilter(inputSelector = '#screen-search', itemsSelector = '.filter-item') {
    const input = document.querySelector(inputSelector);
    const items = document.querySelectorAll(itemsSelector);
    if (!input || !items.length) return;

    input.addEventListener('input', () => {
      const query = input.value.toLowerCase().trim();
      items.forEach(item => {
        const name = (item.dataset.name || item.textContent || '').toLowerCase();
        if (!query || name.includes(query)) {
          item.classList.remove('hidden');
        } else {
          item.classList.add('hidden');
        }
      });
    });
  }

  /* ═══════════════════════════════════════════
     10. CATEGORY TABS FILTER
     ═══════════════════════════════════════════ */
  function initCategoryTabs(containerSelector = '#category-tabs', itemsSelector = '.filter-item') {
    const container = document.querySelector(containerSelector);
    const items = document.querySelectorAll(itemsSelector);
    if (!container) return;

    const tabs = container.querySelectorAll('[data-category]');

    tabs.forEach(tab => {
      tab.addEventListener('click', () => {
        const category = tab.dataset.category;

        tabs.forEach(t => {
          t.classList.remove('bg-primary', 'text-on-primary');
          t.classList.add('bg-surface-container-highest', 'text-on-surface-variant');
        });
        tab.classList.remove('bg-surface-container-highest', 'text-on-surface-variant');
        tab.classList.add('bg-primary', 'text-on-primary');

        items.forEach(item => {
          if (category === 'all' || item.dataset.category === category) {
            item.classList.remove('hidden');
          } else {
            item.classList.add('hidden');
          }
        });
      });
    });
  }

  /* ═══════════════════════════════════════════
     11. PREVIEW MODAL
     ═══════════════════════════════════════════ */
  function openPreviewModal({ title, description, tags, icon, bgGradient, href }) {
    const existing = document.getElementById('preview-modal');
    if (existing) existing.remove();

    const modal = document.createElement('div');
    modal.id = 'preview-modal';
    modal.setAttribute('role', 'dialog');
    modal.setAttribute('aria-modal', 'true');
    modal.setAttribute('aria-label', `Preview: ${title}`);
    modal.style.cssText = `
      position: fixed; inset: 0; z-index: 10000;
      display: flex; align-items: center; justify-content: center;
      padding: 1.5rem;
      opacity: 0;
      transition: opacity 0.3s ease;
    `;

    const backdrop = document.createElement('div');
    backdrop.style.cssText = `
      position: absolute; inset: 0;
      background: rgba(0,0,0,0.5);
      backdrop-filter: blur(${getBlurRadius()}px);
    `;
    backdrop.addEventListener('click', closePreviewModal);
    modal.appendChild(backdrop);

    const card = document.createElement('div');
    card.style.cssText = `
      position: relative;
      background: white;
      border-radius: 1.5rem;
      max-width: 380px;
      width: 100%;
      overflow: hidden;
      box-shadow: 0 25px 80px rgba(0,0,0,0.3);
      transform: scale(0.9) translateY(20px);
      transition: transform 0.4s cubic-bezier(0.34,1.56,0.64,1);
    `;

    const thumbnail = document.createElement('div');
    thumbnail.style.cssText = `
      aspect-ratio: 9/16;
      background: ${bgGradient || 'linear-gradient(135deg, #a43700, #cd4700)'};
      display: flex; align-items: center; justify-content: center;
      position: relative; overflow: hidden;
    `;

    const iconEl = document.createElement('span');
    iconEl.className = 'material-symbols-outlined';
    iconEl.style.cssText = 'font-size: 4rem; color: white; opacity: 0.8; font-variation-settings: "FILL" 1;';
    iconEl.textContent = icon || 'smartphone';
    thumbnail.appendChild(iconEl);

    const shimmer = document.createElement('div');
    shimmer.style.cssText = `
      position: absolute; inset: 0;
      background: linear-gradient(90deg, transparent 30%, rgba(255,255,255,0.15) 50%, transparent 70%);
      background-size: 200% 100%;
      animation: ${isMotionSafe() ? 'shimmer 3s infinite' : 'none'};
    `;
    thumbnail.appendChild(shimmer);

    card.appendChild(thumbnail);

    const body = document.createElement('div');
    body.style.cssText = 'padding: 1.5rem;';

    const titleEl = document.createElement('h3');
    titleEl.style.cssText = 'font-family: "Plus Jakarta Sans", sans-serif; font-size: 1.25rem; font-weight: 800; color: #1a1c1c; margin-bottom: 0.5rem;';
    titleEl.textContent = title;
    body.appendChild(titleEl);

    if (description) {
      const descEl = document.createElement('p');
      descEl.style.cssText = 'font-size: 0.875rem; color: #5a4138; line-height: 1.5; margin-bottom: 1rem;';
      descEl.textContent = description;
      body.appendChild(descEl);
    }

    if (tags && tags.length) {
      const tagContainer = document.createElement('div');
      tagContainer.style.cssText = 'display: flex; flex-wrap: wrap; gap: 0.375rem; margin-bottom: 1.25rem;';
      tags.forEach(tag => {
        const tagEl = document.createElement('span');
        tagEl.style.cssText = 'font-size: 0.625rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; background: #f3f3f3; color: #5a4138; padding: 0.25rem 0.625rem; border-radius: 9999px;';
        tagEl.textContent = tag;
        tagContainer.appendChild(tagEl);
      });
      body.appendChild(tagContainer);
    }

    const actions = document.createElement('div');
    actions.style.cssText = 'display: flex; gap: 0.75rem;';

    const launchBtn = document.createElement('a');
    launchBtn.href = href || '#';
    launchBtn.setAttribute('role', 'button');
    launchBtn.style.cssText = `
      flex: 1; display: flex; align-items: center; justify-content: center; gap: 0.5rem;
      background: linear-gradient(135deg, #a43700, #cd4700);
      color: white; font-weight: 700; font-size: 0.875rem;
      padding: 0.75rem; border-radius: 0.75rem;
      text-decoration: none; cursor: pointer;
      transition: transform 0.2s cubic-bezier(0.34,1.56,0.64,1);
    `;
    launchBtn.innerHTML = 'Launch Screen <span class="material-symbols-outlined" style="font-size: 1.125rem;">open_in_new</span>';
    launchBtn.addEventListener('mouseenter', () => { launchBtn.style.transform = 'scale(1.02)'; });
    launchBtn.addEventListener('mouseleave', () => { launchBtn.style.transform = 'scale(1)'; });
    launchBtn.addEventListener('click', (e) => {
      if (href && href !== '#') {
        e.preventDefault();
        closePreviewModal();
        liquidNavigate(e, href);
      }
    });
    actions.appendChild(launchBtn);

    const closeBtn = document.createElement('button');
    closeBtn.style.cssText = `
      padding: 0.75rem 1rem; border-radius: 0.75rem;
      background: #eeeeee; color: #1a1c1c; font-weight: 600; font-size: 0.875rem;
      border: none; cursor: pointer; transition: transform 0.2s cubic-bezier(0.34,1.56,0.64,1);
    `;
    closeBtn.textContent = 'Close';
    closeBtn.addEventListener('click', closePreviewModal);
    actions.appendChild(closeBtn);

    body.appendChild(actions);
    card.appendChild(body);
    modal.appendChild(card);

    document.body.appendChild(modal);

    requestAnimationFrame(() => {
      modal.style.opacity = '1';
      card.style.transform = 'scale(1) translateY(0)';
    });

    const escHandler = (e) => {
      if (e.key === 'Escape') { closePreviewModal(); window.removeEventListener('keydown', escHandler); }
    };
    window.addEventListener('keydown', escHandler);
  }

  function closePreviewModal() {
    const modal = document.getElementById('preview-modal');
    if (!modal) return;
    const card = modal.querySelector('div:last-child');
    modal.style.opacity = '0';
    if (card) card.style.transform = 'scale(0.9) translateY(20px)';
    setTimeout(() => modal.remove(), 300);
  }

  /* ═══════════════════════════════════════════
     12. BACK TO TOP BUTTON
     ═══════════════════════════════════════════ */
  function initBackToTop(selector = '#back-to-top') {
    const btn = document.querySelector(selector);
    if (!btn) return;

    function onScroll() {
      if (window.scrollY > 600) {
        btn.classList.remove('opacity-0', 'pointer-events-none');
        btn.classList.add('opacity-100');
      } else {
        btn.classList.add('opacity-0', 'pointer-events-none');
        btn.classList.remove('opacity-100');
      }
    }

    window.addEventListener('scroll', onScroll, { passive: true });

    btn.addEventListener('click', () => {
      window.scrollTo({ top: 0, behavior: 'smooth' });
    });

    registerCleanup(() => window.removeEventListener('scroll', onScroll));
  }

  /* ═══════════════════════════════════════════
     13. RIPPLE EFFECT
     ═══════════════════════════════════════════ */
  function initRippleEffect(selector = '.ripple-btn') {
    document.querySelectorAll(selector).forEach(btn => {
      btn.addEventListener('click', function (e) {
        const rect = this.getBoundingClientRect();
        const ripple = document.createElement('span');
        const size = Math.max(rect.width, rect.height);
        const x = e.clientX - rect.left - size / 2;
        const y = e.clientY - rect.top - size / 2;
        ripple.style.cssText = `
          position: absolute; width: ${size}px; height: ${size}px;
          left: ${x}px; top: ${y}px;
          border-radius: 50%;
          background: rgba(164,55,0,0.15);
          animation: ripple-expand 0.6s ease-out forwards;
          pointer-events: none;
        `;
        this.style.position = 'relative';
        this.style.overflow = 'hidden';
        this.appendChild(ripple);
        setTimeout(() => ripple.remove(), 600);
      });
    });
  }

  /* ═══════════════════════════════════════════
     14. TOAST / SNACKBAR NOTIFICATION
     ═══════════════════════════════════════════ */
  function showToast(message, type = 'info', duration = 2500) {
    let container = document.getElementById('desifit-toast-container');
    if (!container) {
      container = document.createElement('div');
      container.id = 'desifit-toast-container';
      container.style.cssText = `
        position: fixed; bottom: 5rem; left: 50%; transform: translateX(-50%);
        z-index: 99999; display: flex; flex-direction: column; gap: 0.5rem;
        pointer-events: none; max-width: 90vw;
      `;
      document.body.appendChild(container);
    }

    const colors = {
      info: { bg: '#a43700', icon: 'info' },
      success: { bg: '#2e7d32', icon: 'check_circle' },
      warning: { bg: '#e6a800', icon: 'warning' },
      error: { bg: '#d32f2f', icon: 'error' },
    };
    const c = colors[type] || colors.info;

    const toast = document.createElement('div');
    toast.innerHTML = `<span class="material-symbols-outlined" style="font-size:1.125rem;font-variation-settings:'FILL'1">${c.icon}</span><span style="font-weight:600;font-size:0.8125rem">${message}</span>`;
    toast.style.cssText = `
      display: flex; align-items: center; gap: 0.5rem;
      padding: 0.75rem 1.25rem;
      background: ${c.bg}; color: white;
      border-radius: 1rem;
      box-shadow: 0 8px 32px rgba(0,0,0,0.2);
      font-family: 'Inter', sans-serif;
      transform: translateY(20px) scale(0.9); opacity: 0;
      transition: all 0.35s cubic-bezier(0.34,1.56,0.64,1);
      pointer-events: auto;
      cursor: pointer;
    `;
    container.appendChild(toast);

    requestAnimationFrame(() => {
      toast.style.transform = 'translateY(0) scale(1)';
      toast.style.opacity = '1';
    });

    toast.addEventListener('click', () => {
      toast.style.transform = 'translateY(20px) scale(0.9)';
      toast.style.opacity = '0';
      setTimeout(() => toast.remove(), 350);
    });

    setTimeout(() => {
      if (toast.parentNode) {
        toast.style.transform = 'translateY(20px) scale(0.9)';
        toast.style.opacity = '0';
        setTimeout(() => toast.remove(), 350);
      }
    }, duration);
  }

  /* ═══════════════════════════════════════════
     15. SHIMMER LOADING PLACEHOLDER
     ═══════════════════════════════════════════ */
  function initShimmerPlaceholders(selector = '.shimmer-placeholder') {
    document.querySelectorAll(selector).forEach(el => {
      el.style.cssText += `
        background: linear-gradient(90deg,
          rgba(164,55,0,0.04) 0%,
          rgba(164,55,0,0.1) 40%,
          rgba(164,55,0,0.04) 60%,
          rgba(164,55,0,0.02) 100%
        );
        background-size: 300% 100%;
        border-radius: inherit;
      `;
      el.classList.add('anim-shimmer-loading');
    });
  }

  /* ═══════════════════════════════════════════
     16. STAGGERED CHILDREN ANIMATION
     ═══════════════════════════════════════════ */
  function initStaggerChildren(selector = '.stagger-children') {
    if (!isMotionSafe()) return;
    document.querySelectorAll(selector).forEach(container => {
      const children = container.children;
      if (!children.length) return;
      Array.from(children).forEach((child, i) => {
        child.style.opacity = '0';
        child.style.transform = 'translateY(16px) scale(0.97)';
        child.style.transition = `opacity 0.45s cubic-bezier(0.34,1.56,0.64,1) ${i * 60}ms, transform 0.45s cubic-bezier(0.34,1.56,0.64,1) ${i * 60}ms`;
      });
      const obs = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            Array.from(entry.target.children).forEach(child => {
              child.style.opacity = '1';
              child.style.transform = 'translateY(0) scale(1)';
            });
            obs.unobserve(entry.target);
          }
        });
      }, { threshold: 0.1 });
      obs.observe(container);
      registerCleanup(() => obs.disconnect());
    });
  }

  /* ═══════════════════════════════════════════
     17. HOVER CARD DEPTH (3D tilt effect)
     ═══════════════════════════════════════════ */
  function initCardTilt(selector = '.card-tilt') {
    if (!isMotionSafe() || _performanceTier === 'low') return;
    document.querySelectorAll(selector).forEach(card => {
      card.addEventListener('pointerenter', function() {
        this.style.transition = 'transform 0.1s ease';
      });
      card.addEventListener('pointermove', function(e) {
        const rect = this.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;
        const centerX = rect.width / 2;
        const centerY = rect.height / 2;
        const rotateX = ((y - centerY) / centerY) * -6;
        const rotateY = ((x - centerX) / centerX) * 6;
        this.style.transform = `perspective(600px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) translateY(-3px)`;
      });
      card.addEventListener('pointerleave', function() {
        this.style.transition = 'transform 0.35s cubic-bezier(0.34,1.56,0.64,1)';
        this.style.transform = 'perspective(600px) rotateX(0deg) rotateY(0deg) translateY(0)';
      });
    });
  }

  /* ═══════════════════════════════════════════
     18. CONFETTI BURST (for celebrations)
     ═══════════════════════════════════════════ */
  function burstConfetti(element, count = 24) {
    if (!isMotionSafe()) return;

    const rect = element.getBoundingClientRect();
    const cx = rect.left + rect.width / 2;
    const cy = rect.top + rect.height / 2;
    const colors = ['#a43700','#cd4700','#2e7d32','#e6a800','#005ab7','#f44336','#9c27b0'];
    const particleCount = _performanceTier === 'low' ? Math.min(count, 8) :
                          _performanceTier === 'medium' ? Math.min(count, 12) : count;

    for (let i = 0; i < particleCount; i++) {
      const dot = document.createElement('div');
      const color = colors[Math.floor(Math.random() * colors.length)];
      const size = 4 + Math.random() * 6;
      const angle = (Math.PI * 2 / particleCount) * i + (Math.random() - 0.5) * 0.5;
      const velocity = 60 + Math.random() * 100;
      const tx = Math.cos(angle) * velocity;
      const ty = Math.sin(angle) * velocity - 40;

      dot.style.cssText = `
        position: fixed; left: ${cx}px; top: ${cy}px;
        width: ${size}px; height: ${size}px;
        border-radius: ${Math.random() > 0.5 ? '50%' : '2px'};
        background: ${color};
        pointer-events: none;
        z-index: 99999;
        transition: all 0.6s cubic-bezier(0.25,0.46,0.45,0.94);
        opacity: 1;
      `;
      document.body.appendChild(dot);

      requestAnimationFrame(() => {
        dot.style.transform = `translate(${tx}px, ${ty}px) rotate(${Math.random() * 360}deg)`;
        dot.style.opacity = '0';
      });

      setTimeout(() => dot.remove(), 700);
    }
  }

  /* ═══════════════════════════════════════════
     19. SMOOTH ANCHOR SCROLL
     ═══════════════════════════════════════════ */
  function initSmoothAnchors(selector = 'a[href^="#"]') {
    document.querySelectorAll(selector).forEach(anchor => {
      anchor.addEventListener('click', function(e) {
        const id = this.getAttribute('href');
        if (id === '#') return;
        const target = document.querySelector(id);
        if (target) {
          e.preventDefault();
          target.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
      });
    });
  }

  /* ═══════════════════════════════════════════
     20. LIQUID PAGE TRANSITION
     ═══════════════════════════════════════════ */
  function liquidNavigate(e, url) {
    e.preventDefault();
    const overlay = document.getElementById('liquid-overlay');
    if (overlay && isMotionSafe()) {
      overlay.classList.add('active');
      setTimeout(() => { window.location.href = url; }, 400);
    } else {
      window.location.href = url;
    }
  }

  /* ═══════════════════════════════════════════
     21. WATER FILL (Matka hydration tracker)
     ═══════════════════════════════════════════ */
  function initWaterFill(selector = '.water-fill', opts = {}) {
    if (!isMotionSafe()) return;
    document.querySelectorAll(selector).forEach(container => {
      const fillEl = container.querySelector('.water-fill-level');
      if (!fillEl) return;

      const target = parseFloat(fillEl.dataset.target) || 0;
      const waveHeight = opts.waveHeight || 6;
      const waveLength = opts.waveLength || 40;
      const duration = opts.duration || 2000;
      let phase = 0;
      let rafId = null;
      let animating = false;

      function drawWave() {
        if (!animating) return;
        phase += 0.05;
        const w = container.offsetWidth;
        const h = container.offsetHeight;
        const fillHeight = h * (1 - Math.min(target, 1));
        const canvas = fillEl.querySelector('canvas') || (() => {
          const c = document.createElement('canvas');
          c.width = w;
          c.height = h;
          c.style.width = '100%';
          c.style.height = '100%';
          c.style.position = 'absolute';
          c.style.bottom = '0';
          c.style.left = '0';
          fillEl.appendChild(c);
          return c;
        })();

        canvas.width = w;
        canvas.height = h;
        const ctx = canvas.getContext('2d');

        ctx.clearRect(0, 0, w, h);

        // Draw wave
        ctx.beginPath();
        ctx.moveTo(0, h);

        for (let x = 0; x <= w; x++) {
          const y = fillHeight + Math.sin((x / waveLength) + phase) * waveHeight;
          ctx.lineTo(x, y);
        }

        ctx.lineTo(w, h);
        ctx.closePath();
        ctx.fillStyle = opts.color || 'rgba(164,55,0,0.5)';
        ctx.fill();

        // Draw second wave for depth
        ctx.beginPath();
        ctx.moveTo(0, h);
        for (let x = 0; x <= w; x++) {
          const y = fillHeight + Math.sin((x / waveLength) + phase + Math.PI) * waveHeight * 0.7;
          ctx.lineTo(x, y);
        }
        ctx.lineTo(w, h);
        ctx.closePath();
        ctx.fillStyle = opts.secondaryColor || 'rgba(164,55,0,0.3)';
        ctx.fill();

        // Draw fill below wave
        ctx.fillStyle = opts.fillColor || 'rgba(164,55,0,0.6)';
        ctx.fillRect(0, fillHeight + waveHeight * 2, w, h - fillHeight);

        rafId = requestAnimationFrame(drawWave);
      }

      // Animate fill level
      let startTime = null;
      const startFill = 0;
      const endFill = Math.min(target, 1);

      function animateIn(ts) {
        if (!startTime) startTime = ts;
        const elapsed = ts - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const eased = 1 - Math.pow(1 - progress, 3);
        const currentFill = startFill + (endFill - startFill) * eased;
        fillEl.dataset.currentTarget = currentFill;
        if (progress < 1) {
          requestAnimationFrame(animateIn);
        } else {
          animating = true;
          drawWave();
        }
      }

      const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting && !startTime) {
            requestAnimationFrame(animateIn);
            observer.unobserve(entry.target);
          }
        });
      }, { threshold: 0.2 });
      observer.observe(container);
    });

    return () => {
      document.querySelectorAll(selector).forEach(container => {
        const fillEl = container.querySelector('.water-fill-level');
        if (fillEl) {
          const canvas = fillEl.querySelector('canvas');
          if (canvas) canvas.remove();
        }
      });
    };
  }

  /* ═══════════════════════════════════════════
     22. FIRE FLAME (streak fire visualization)
     ═══════════════════════════════════════════ */
  function initFireFlame(selector = '.fire-flame', opts = {}) {
    if (!isMotionSafe()) return;
    document.querySelectorAll(selector).forEach(container => {
      const canvas = document.createElement('canvas');
      canvas.style.cssText = 'position:absolute;inset:0;width:100%;height:100%;pointer-events:none;';
      container.style.position = 'relative';
      container.appendChild(canvas);

      const ctx = canvas.getContext('2d');
      const particles = [];
      const maxParticles = _performanceTier === 'medium' ? 20 : 40;

      function resize() {
        canvas.width = container.offsetWidth;
        canvas.height = container.offsetHeight;
      }
      resize();
      window.addEventListener('resize', resize);

      const colors = ['#ff4500', '#ff6b00', '#ffaa00', '#ffdd00', '#ff2200'];

      function emitParticle() {
        const w = canvas.width;
        const h = canvas.height;
        const cx = w / 2;
        const cy = h;

        particles.push({
          x: cx + (Math.random() - 0.5) * w * 0.3,
          y: cy,
          vx: (Math.random() - 0.5) * 2,
          vy: -2 - Math.random() * 4,
          size: 2 + Math.random() * 4,
          life: 1,
          decay: 0.008 + Math.random() * 0.012,
          color: colors[Math.floor(Math.random() * colors.length)],
          alpha: 0.8 + Math.random() * 0.2,
        });
      }

      let rafId = null;

      function tick() {
        ctx.clearRect(0, 0, canvas.width, canvas.height);

        if (particles.length < maxParticles && Math.random() > 0.3) {
          emitParticle();
        }

        for (let i = particles.length - 1; i >= 0; i--) {
          const p = particles[i];
          p.x += p.vx + (Math.random() - 0.5) * 0.5;
          p.y += p.vy;
          p.vy *= 0.99;
          p.life -= p.decay;
          p.size *= 0.995;

          if (p.life <= 0) {
            particles.splice(i, 1);
            continue;
          }

          ctx.globalAlpha = p.life * p.alpha;
          ctx.beginPath();
          ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
          ctx.fillStyle = p.color;
          ctx.fill();

          // Glow effect
          ctx.shadowColor = p.color;
          ctx.shadowBlur = _performanceTier === 'low' ? 0 : 10;
          ctx.beginPath();
          ctx.arc(p.x, p.y, p.size * 0.5, 0, Math.PI * 2);
          ctx.fill();
          ctx.shadowBlur = 0;
        }

        ctx.globalAlpha = 1;
        rafId = requestAnimationFrame(tick);
      }

      tick();
      registerCleanup(() => {
        if (rafId) cancelAnimationFrame(rafId);
        window.removeEventListener('resize', resize);
      });
    });
  }

  /* ═══════════════════════════════════════════
     23. MORPH SHAPE (SVG path morphing)
     ═══════════════════════════════════════════ */
  function initMorphShape(selector = '.morph-shape', opts = {}) {
    if (!isMotionSafe()) return;
    document.querySelectorAll(selector).forEach(el => {
      const path = el.tagName === 'path' ? el : el.querySelector('path');
      if (!path) return;

      const fromPath = path.getAttribute('data-morph-from') || path.getAttribute('d');
      const toPath = path.getAttribute('data-morph-to');
      if (!toPath) return;

      const duration = opts.duration || 600;
      const delay = parseFloat(el.dataset.morphDelay) || 0;

      // Simple path morphing using CSS transitions
      const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setTimeout(() => {
              path.style.transition = `d ${duration}ms cubic-bezier(0.34,1.56,0.64,1)`;
              path.setAttribute('d', toPath);
            }, delay);
            observer.unobserve(entry.target);
          }
        });
      }, { threshold: 0.2 });
      observer.observe(el);
    });
  }

  /* ═══════════════════════════════════════════
     24. BREATH CIRCLE (meditation/breathwork)
     ═══════════════════════════════════════════ */
  function initBreathCircle(selector = '.breath-circle', opts = {}) {
    if (!isMotionSafe()) return;
    document.querySelectorAll(selector).forEach(container => {
      const circle = container.querySelector('.breath-circle-ring');
      if (!circle) return;

      const inhaleTime = opts.inhale || 4000;
      const holdTime = opts.hold || 2000;
      const exhaleTime = opts.exhale || 4000;
      const maxScale = opts.maxScale || 1.3;
      const labelEl = container.querySelector('.breath-circle-label');

      function cycle() {
        // Inhale
        circle.style.transition = `transform ${inhaleTime}ms cubic-bezier(0.4,0,0.2,1)`;
        circle.style.transform = `scale(${maxScale})`;
        if (labelEl) labelEl.textContent = 'Inhale...';

        setTimeout(() => {
          // Hold
          circle.style.transition = 'none';
          if (labelEl) labelEl.textContent = 'Hold...';

          setTimeout(() => {
            // Exhale
            circle.style.transition = `transform ${exhaleTime}ms cubic-bezier(0.4,0,0.2,1)`;
            circle.style.transform = 'scale(1)';
            if (labelEl) labelEl.textContent = 'Exhale...';

            setTimeout(() => {
              // Rest
              if (labelEl) labelEl.textContent = 'Rest...';
              setTimeout(cycle, 1000);
            }, exhaleTime);
          }, holdTime);
        }, inhaleTime);
      }

      const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            setTimeout(cycle, 500);
            observer.unobserve(entry.target);
          }
        });
      }, { threshold: 0.3 });
      observer.observe(container);

      registerCleanup(() => observer.disconnect());
    });
  }

  /* ═══════════════════════════════════════════
     25. FLIP CARD (3D card flip)
     ═══════════════════════════════════════════ */
  function initFlipCard(selector = '.flip-card') {
    if (!isMotionSafe() || _performanceTier === 'low') return;
    document.querySelectorAll(selector).forEach(card => {
      card.addEventListener('click', function() {
        this.classList.toggle('flipped');
      });
    });
  }

  /* ═══════════════════════════════════════════
     26. SLIDE PAGE TRANSITION
     ═══════════════════════════════════════════ */
  function initSlideTransition(selector = '.slide-page', opts = {}) {
    if (!isMotionSafe()) return;
    document.querySelectorAll(selector).forEach(el => {
      const direction = el.dataset.slideDirection || opts.direction || 'left';
      const duration = opts.duration || 400;
      const distance = opts.distance || 30;

      const transformMap = {
        left: `translateX(-${distance}px)`,
        right: `translateX(${distance}px)`,
        up: `translateY(-${distance}px)`,
        down: `translateY(${distance}px)`,
      };

      el.style.opacity = '0';
      el.style.transform = transformMap[direction] || transformMap.left;
      el.style.transition = `opacity ${duration}ms cubic-bezier(0.34,1.56,0.64,1), transform ${duration}ms cubic-bezier(0.34,1.56,0.64,1)`;

      const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translate(0, 0)';
            observer.unobserve(entry.target);
          }
        });
      }, { threshold: 0.1 });
      observer.observe(el);
      registerCleanup(() => observer.disconnect());
    });
  }

  /* ═══════════════════════════════════════════
     CSS KEYFRAMES (injected once)
     ═══════════════════════════════════════════ */

  /* ===== 27. SWIPE GESTURE ENGINE (v4) ===== */
  function initSwipeGestures(selector, callbacks = {}) {
    if (!isMotionSafe() || _performanceTier === 'low') return;
    const els = document.querySelectorAll(selector);
    if (!els.length) return;

    const minDistance = 30;
    const maxTime = 400;

    const touchStarts = [];
    const touchEnds = [];
    els.forEach(el => {
      let startX = 0, startY = 0, startTime = 0;

      const startHandler = function(e) {
        const t = e.changedTouches[0];
        startX = t.screenX;
        startY = t.screenY;
        startTime = Date.now();
      };
      const endHandler = function(e) {
        const t = e.changedTouches[0];
        const dx = t.screenX - startX;
        const dy = t.screenY - startY;
        const dt = Date.now() - startTime;
        if (dt > maxTime) return;

        const absDx = Math.abs(dx);
        const absDy = Math.abs(dy);

        if (absDx < minDistance && absDy < minDistance) return;

        let direction;
        if (absDx > absDy) {
          direction = dx > 0 ? 'right' : 'left';
        } else {
          direction = dy > 0 ? 'down' : 'up';
        }

        el.dispatchEvent(new CustomEvent('swipe', {
          detail: { direction, dx, dy, dt, absDx, absDy },
          bubbles: true,
        }));

        const cb = callbacks[direction] || callbacks.swipe;
        if (cb) cb.call(el, { direction, dx, dy, dt, absDx, absDy });
      };

      el.addEventListener('touchstart', startHandler, { passive: true });
      el.addEventListener('touchend', endHandler, { passive: true });
      touchStarts.push({ el, handler: startHandler, type: 'touchstart' });
      touchEnds.push({ el, handler: endHandler, type: 'touchend' });
    });
    registerCleanup(function() {
      touchStarts.forEach(function(r) { r.el.removeEventListener(r.type, r.handler); });
      touchEnds.forEach(function(r) { r.el.removeEventListener(r.type, r.handler); });
    });
  }

  /* ===== 28. SKELETON LOADING STATES (v4) ===== */
  function initSkeletonLoaders(selector = '.skeleton-loader', opts = {}) {
    if (!isMotionSafe()) return;
    const els = document.querySelectorAll(selector);
    if (!els.length) return;

    const variant = opts.variant || 'shimmer';
    const baseColor = opts.baseColor || 'rgba(164,55,0,0.06)';
    const shimmerColor = opts.shimmerColor || 'rgba(164,55,0,0.12)';
    const modified = [];

    els.forEach(el => {
      const shape = el.dataset.skeleton || 
        (el.classList.contains('skeleton-circle') ? 'circle' :
         el.classList.contains('skeleton-text') ? 'text' : 'rect');

      if (_performanceTier === 'low') {
        el.style.background = baseColor;
        el.style.borderRadius = shape === 'circle' ? '50%' : shape === 'text' ? '4px' : '8px';
        if (shape === 'text') el.style.height = '12px';
        return;
      }

      if (variant === 'shimmer') {
        el.style.background = 'linear-gradient(90deg, ' + baseColor + ' 25%, ' + shimmerColor + ' 50%, ' + baseColor + ' 75%)';
        el.style.backgroundSize = '200% 100%';
        el.style.animation = 'skeleton-shimmer 1.5s ease-in-out infinite';
      } else if (variant === 'pulse') {
        el.style.animation = 'skeleton-pulse 1.5s ease-in-out infinite';
        el.style.background = baseColor;
      } else {
        el.style.background = baseColor;
      }

      if (shape === 'circle') {
        el.style.borderRadius = '50%';
      } else if (shape === 'text') {
        el.style.borderRadius = '4px';
        el.style.height = '12px';
      } else {
        el.style.borderRadius = '8px';
      }
      el.classList.add('anim-skeleton');
      modified.push(el);
    });
    registerCleanup(function() {
      modified.forEach(function(el) {
        el.style.background = '';
        el.style.backgroundSize = '';
        el.style.animation = '';
        el.style.borderRadius = '';
        el.style.height = '';
        el.classList.remove('anim-skeleton');
      });
    });
  }

  /* ===== 29. PAGE TRANSITION EFFECTS (v4) ===== */
  function pageTransition(type, opts = {}) {
    const duration = opts.duration || 400;
    const color = opts.color || '#a43700';
    const direction = opts.direction || 'left';
    const onComplete = opts.onComplete || null;

    if (!isMotionSafe() || _performanceTier === 'low') {
      if (onComplete) setTimeout(onComplete, 10);
      return;
    }

    let overlay = document.getElementById('ds-page-transition');
    if (!overlay) {
      overlay = document.createElement('div');
      overlay.id = 'ds-page-transition';
      overlay.style.cssText = 'position:fixed;inset:0;z-index:99999;pointer-events:none;';
      document.body.appendChild(overlay);
      registerCleanup(function() {
        var o = document.getElementById('ds-page-transition');
        if (o) o.parentNode.removeChild(o);
      });
    }

    overlay.style.transition = 'none';
    overlay.style.opacity = '0';
    overlay.style.transform = 'none';
    void overlay.offsetHeight;

    if (type === 'fade') {
      overlay.style.background = color;
      overlay.style.opacity = '0';
      overlay.style.transition = 'opacity ' + duration + 'ms ease';
      requestAnimationFrame(function() { overlay.style.opacity = '1'; });
      setTimeout(function() {
        overlay.style.transition = 'opacity ' + duration + 'ms ease';
        overlay.style.opacity = '0';
        if (onComplete) setTimeout(onComplete, duration);
      }, duration);
    } 
    else if (type === 'slide') {
      overlay.style.background = color;
      overlay.style.transform = direction === 'right' ? 'translateX(-100%)' : 'translateX(100%)';
      overlay.style.transition = 'transform ' + duration + 'ms cubic-bezier(0.76,0,0.24,1)';
      requestAnimationFrame(function() { overlay.style.transform = 'translateX(0)'; });
      if (onComplete) setTimeout(onComplete, duration + 50);
    }
    else if (type === 'flip') {
      overlay.style.background = color;
      overlay.style.transform = 'rotateY(90deg)';
      overlay.style.opacity = '1';
      overlay.style.transition = 'transform ' + duration + 'ms cubic-bezier(0.4,0,0.2,1)';
      requestAnimationFrame(function() { overlay.style.transform = 'rotateY(0deg)'; });
      if (onComplete) setTimeout(onComplete, duration + 50);
    }
    else {
      overlay.style.background = color;
      overlay.style.opacity = '0';
      overlay.style.transition = 'opacity ' + duration + 'ms ease';
      requestAnimationFrame(function() { overlay.style.opacity = '1'; });
      setTimeout(function() {
        overlay.style.opacity = '0';
        if (onComplete) setTimeout(onComplete, duration);
      }, duration);
    }
  }



  /* ===== 30. 3D CARD CAROUSEL ===== */
  function initCardCarousel(selector = '.card-carousel', opts = {}) {
    if (!isMotionSafe()) return;
    const container = document.querySelector(selector);
    if (!container) return;

    const gap = opts.gap || 16;
    const scale = opts.scale || 0.85;
    const translateZ = opts.translateZ || -60;
    const opacity = opts.opacity || 0.5;
    const rotateY = opts.rotateY || 15;

    const items = container.querySelectorAll(':scope > *');
    if (!items.length) return;
    const modifiedItems = [];

    // Set up 3D perspective on container
    container.style.perspective = '1200px';
    container.style.overflowX = 'auto';
    container.style.scrollSnapType = 'x mandatory';
    container.style.display = 'flex';
    container.style.gap = gap + 'px';
    container.style.padding = '20px 0';
    container.style.scrollBehavior = 'smooth';
    container.style.WebkitOverflowScrolling = 'touch';
    container.classList.add('carousel-container');

    items.forEach(function(item, idx) {
      item.style.flex = '0 0 auto';
      item.style.scrollSnapAlign = 'center';
      item.style.transition = 'transform 0.4s cubic-bezier(0.34,1.56,0.64,1), opacity 0.4s ease';
      item.style.transformStyle = 'preserve-3d';
      item.style.willChange = 'transform, opacity';
      modifiedItems.push(item);
    });

    function updateCarousel() {
      var containerRect = container.getBoundingClientRect();
      var center = containerRect.left + containerRect.width / 2;

      items.forEach(function(item) {
        var rect = item.getBoundingClientRect();
        var itemCenter = rect.left + rect.width / 2;
        var dist = Math.abs(center - itemCenter);
        var maxDist = containerRect.width / 2 + rect.width;
        var progress = Math.min(dist / maxDist, 1);

        if (_performanceTier === 'low') {
          item.style.opacity = progress > 0.6 ? '0.3' : '1';
          item.style.transform = 'scale(' + (1 - progress * 0.15) + ')';
          return;
        }

        var s = 1 - progress * (1 - scale);
        var tz = progress * translateZ;
        var ry = (itemCenter < center ? 1 : -1) * progress * rotateY;
        item.style.opacity = 1 - progress * (1 - opacity);
        item.style.transform = 'perspective(1200px) translateZ(' + tz + 'px) rotateY(' + ry + 'deg) scale(' + s + ')';

        if (_performanceTier === 'low') {
          item.style.filter = '';
        } else {
          item.style.filter = progress > 0.5 ? 'blur(' + (progress - 0.5) * 4 + 'px)' : '';
        }
      });
    }

    // Throttled scroll handler
    var ticking = false;
    container.addEventListener('scroll', function() {
      if (!ticking) {
        requestAnimationFrame(function() { updateCarousel(); ticking = false; });
        ticking = true;
      }
    }, { passive: true });

    updateCarousel();
    registerCleanup(function() {
      container.style.perspective = '';
      container.style.overflowX = '';
      container.style.scrollSnapType = '';
      container.style.display = '';
      container.style.gap = '';
      container.style.padding = '';
      container.style.scrollBehavior = '';
      container.classList.remove('carousel-container');
      modifiedItems.forEach(function(item) {
        item.style.flex = '';
        item.style.scrollSnapAlign = '';
        item.style.transition = '';
        item.style.transformStyle = '';
        item.style.willChange = '';
        item.style.opacity = '';
        item.style.transform = '';
        item.style.filter = '';
      });
    });
  }

  /* ===== 31. MAGNETIC HOVER EFFECT ===== */
  function initMagneticHover(selector = '.magnetic-hover', opts = {}) {
    if (!isMotionSafe() || _performanceTier === 'low') return;
    const els = document.querySelectorAll(selector);
    if (!els.length) return;

    const strength = opts.strength || 0.3;
    const radius = opts.radius || 120;
    const transitionDuration = opts.transitionDuration || 400;
    const modified = [];

    els.forEach(function(el) {
      el.style.position = el.style.position || 'relative';
      el.style.transition = 'transform ' + transitionDuration + 'ms cubic-bezier(0.34,1.56,0.64,1)';
      el.style.willChange = 'transform';
      modified.push(el);

      var handleMove = function(e) {
        var rect = el.getBoundingClientRect();
        var cx = rect.left + rect.width / 2;
        var cy = rect.top + rect.height / 2;
        var dx = e.clientX - cx;
        var dy = e.clientY - cy;
        var dist = Math.sqrt(dx * dx + dy * dy);

        if (dist < radius) {
          var force = (1 - dist / radius) * strength;
          var tx = dx * force;
          var ty = dy * force;
          el.style.transform = 'translate(' + tx + 'px, ' + ty + 'px)';
          if (_performanceTier !== 'low') {
            el.style.filter = 'brightness(1.08)';
          }
        } else {
          el.style.transform = 'translate(0, 0)';
          el.style.filter = 'brightness(1)';
        }
      };

      var handleLeave = function() {
        el.style.transition = 'transform ' + transitionDuration + 'ms cubic-bezier(0.34,1.56,0.64,1), filter ' + transitionDuration + 'ms ease';
        el.style.transform = 'translate(0, 0)';
        el.style.filter = 'brightness(1)';
      };

      el.addEventListener('mousemove', handleMove, { passive: true });
      el.addEventListener('mouseleave', handleLeave, { passive: true });
    });

    registerCleanup(function() {
      modified.forEach(function(el) {
        el.style.position = '';
        el.style.transition = '';
        el.style.willChange = '';
        el.style.transform = '';
        el.style.filter = '';
      });
    });
  }

  /* ===== 32. SCROLL-TRIGGERED TIMELINE ===== */
  function initScrollTimeline(selector = '.scroll-timeline', opts = {}) {
    if (!isMotionSafe() || _performanceTier === 'low') return;
    const timeline = document.querySelector(selector);
    if (!timeline) return;

    const stepSelector = opts.stepSelector || '.timeline-step';
    const staggerDelay = opts.staggerDelay || 100;
    const threshold = opts.threshold || 0.2;

    const steps = timeline.querySelectorAll(stepSelector);
    if (!steps.length) return;

    // Create vertical timeline line
    var line = document.createElement('div');
    line.className = 'timeline-line-progress';
    line.style.cssText = 'position:absolute;left:16px;top:0;bottom:0;width:2px;background:rgba(164,55,0,0.12);transform-origin:top;border-radius:1px;pointer-events:none;z-index:0;';
    if (!timeline.querySelector('.timeline-line-progress')) {
      timeline.style.position = 'relative';
      timeline.insertBefore(line, timeline.firstChild);
    }

    var fill = document.createElement('div');
    fill.className = 'timeline-line-fill';
    fill.style.cssText = 'position:absolute;left:0;top:0;width:100%;height:0%;background:linear-gradient(180deg,#a43700,#cd4700);border-radius:1px;transition:height 0.1s linear;';
    line.appendChild(fill);

    var revealed = [];
    var observer = new IntersectionObserver(function(entries) {
      entries.forEach(function(entry) {
        if (entry.isIntersecting) {
          var idx = Array.prototype.indexOf.call(steps, entry.target);
          if (idx !== -1 && !revealed[idx]) {
            revealed[idx] = true;
            entry.target.style.opacity = '0';
            entry.target.style.transform = 'translateX(-20px)';
            entry.target.style.transition = 'opacity 0.5s cubic-bezier(0.34,1.56,0.64,1) ' + (idx * staggerDelay) + 'ms, transform 0.5s cubic-bezier(0.34,1.56,0.64,1) ' + (idx * staggerDelay) + 'ms';
            requestAnimationFrame(function() {
              entry.target.style.opacity = '1';
              entry.target.style.transform = 'translateX(0)';
            });
            entry.target.classList.add('timeline-revealed');
          }
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: threshold });

    steps.forEach(function(step, idx) {
      // Style step for timeline appearance
      step.style.opacity = '0';
      step.style.transform = 'translateX(-20px)';
      step.style.transition = 'opacity 0.5s cubic-bezier(0.34,1.56,0.64,1), transform 0.5s cubic-bezier(0.34,1.56,0.64,1)';
      step.style.position = 'relative';
      step.style.paddingLeft = '40px';
      step.style.willChange = 'opacity, transform';

      // Add dot indicator
      if (!step.querySelector('.timeline-dot')) {
        var dot = document.createElement('div');
        dot.className = 'timeline-dot';
        dot.style.cssText = 'position:absolute;left:10px;top:8px;width:14px;height:14px;border-radius:50%;background:#a43700;border:2px solid rgba(255,255,255,0.8);box-shadow:0 0 0 3px rgba(164,55,0,0.15);z-index:1;transition:all 0.4s cubic-bezier(0.34,1.56,0.64,1);';
        step.insertBefore(dot, step.firstChild);
      }

      observer.observe(step);
    });

    // Progress line update
    var progressObserver = new IntersectionObserver(function() {
      var total = steps.length;
      var count = 0;
      steps.forEach(function(s) {
        if (s.classList.contains('timeline-revealed')) count++;
      });
      var pct = total > 0 ? (count / total) * 100 : 0;
      fill.style.height = pct + '%';
    }, { threshold: 0.5 });

    steps.forEach(function(s) { progressObserver.observe(s); });

    registerCleanup(function() {
      observer.disconnect();
      progressObserver.disconnect();
      var tlLine = timeline.querySelector('.timeline-line-progress');
      if (tlLine) tlLine.remove();
      steps.forEach(function(s) {
        s.style.opacity = '';
        s.style.transform = '';
        s.style.transition = '';
        s.style.position = '';
        s.style.paddingLeft = '';
        s.style.willChange = '';
        s.classList.remove('timeline-revealed');
        var dot = s.querySelector('.timeline-dot');
        if (dot) dot.remove();
      });
    });
  }


  function injectKeyframes() {
    if (document.getElementById('desifit-animations')) return;
    const style = document.createElement('style');
    style.id = 'desifit-animations';
    style.textContent = `
      @media (prefers-reduced-motion: reduce) {
        .anim-fade-in-up, .anim-pop-in, .anim-bounce-in,
        .anim-slide-left, .anim-slide-right, .anim-shimmer,
        .anim-glow, .anim-gradient, .anim-spin-slow {
          animation: none !important;
        }
        .anim-fade-in-up, .anim-pop-in, .anim-bounce-in,
        .anim-slide-left, .anim-slide-right {
          opacity: 1 !important;
          transform: none !important;
        }
        #particles-bg {
          display: none !important;
        }
      }
    ` + `
      @keyframes wiggle {
        0%,100% { transform: rotate(0deg); }
        25% { transform: rotate(-8deg); }
        75% { transform: rotate(8deg); }
      }
      @keyframes fab-pulse-ring {
        0% { transform: scale(1); opacity: 0.6; }
        50% { transform: scale(1.25); opacity: 0; }
        100% { transform: scale(1); opacity: 0; }
      }
      @keyframes typing-bounce {
        0%,60%,100% { transform: translateY(0); }
        30% { transform: translateY(-6px); }
      }
      @keyframes float-gentle {
        0%,100% { transform: translateY(0) rotate(0deg); }
        33% { transform: translateY(-8px) rotate(1deg); }
        66% { transform: translateY(4px) rotate(-1deg); }
      }
      @keyframes shimmer {
        0% { background-position: -200% 0; }
        100% { background-position: 200% 0; }
      }
      @keyframes ripple-expand {
        0% { transform: scale(0); opacity: 0.6; }
        100% { transform: scale(4); opacity: 0; }
      }
      @keyframes progress-fill {
        from { stroke-dashoffset: var(--circumference); }
        to { stroke-dashoffset: var(--target-offset); }
      }
      @keyframes slide-in-bottom {
        from { transform: translateY(30px); opacity: 0; }
        to { transform: translateY(0); opacity: 1; }
      }
      @keyframes slide-in-left {
        from { transform: translateX(-20px); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
      }
      @keyframes slide-in-right {
        from { transform: translateX(20px); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
      }
      @keyframes pop-in {
        0% { transform: scale(0.8); opacity: 0; }
        60% { transform: scale(1.05); }
        100% { transform: scale(1); opacity: 1; }
      }
      @keyframes glow-pulse {
        0%,100% { box-shadow: 0 0 8px rgba(164,55,0,0.2); }
        50% { box-shadow: 0 0 20px rgba(164,55,0,0.4); }
      }
      @keyframes fade-in-up {
        from { opacity: 0; transform: translateY(16px); }
        to { opacity: 1; transform: translateY(0); }
      }
      @keyframes bounce-in {
        0% { transform: scale(0.3); opacity: 0; }
        50% { transform: scale(1.05); }
        70% { transform: scale(0.9); }
        100% { transform: scale(1); opacity: 1; }
      }
      @keyframes gradient-shift {
        0% { background-position: 0% 50%; }
        50% { background-position: 100% 50%; }
        100% { background-position: 0% 50%; }
      }
      @keyframes counter-pop {
        0% { transform: scale(1); }
        50% { transform: scale(1.2); }
        100% { transform: scale(1); }
      }
      @keyframes spin-slow {
        from { transform: rotate(0deg); }
        to { transform: rotate(360deg); }
      }
      @keyframes pulse-ring {
        0% { box-shadow: 0 0 0 0 rgba(164,55,0,0.4); }
        70% { box-shadow: 0 0 0 12px rgba(164,55,0,0); }
        100% { box-shadow: 0 0 0 0 rgba(164,55,0,0); }
      }
      @keyframes shimmer-loading {
        0% { background-position: -300% 0; }
        100% { background-position: 300% 0; }
      }
      .anim-shimmer-loading {
        animation: shimmer-loading 1.5s ease-in-out infinite;
      }
      @keyframes toast-in {
        from { transform: translateY(20px) scale(0.9); opacity: 0; }
        to { transform: translateY(0) scale(1); opacity: 1; }
      }
      @keyframes water-wave {
        0% { transform: translateX(0); }
        50% { transform: translateX(-25%); }
        100% { transform: translateX(0); }
      }
      @keyframes flame-flicker {
        0%,100% { opacity: 0.8; transform: scale(1); }
        50% { opacity: 1; transform: scale(1.05); }
      }
      @keyframes breathe-in {
        from { transform: scale(1); opacity: 0.6; }
        to { transform: scale(1.3); opacity: 1; }
      }
      @keyframes breathe-out {
        from { transform: scale(1.3); opacity: 1; }
        to { transform: scale(1); opacity: 0.6; }
      }

      .anim-fade-in-up { animation: fade-in-up 0.5s cubic-bezier(0.34,1.56,0.64,1) both; }
      .anim-pop-in { animation: pop-in 0.4s cubic-bezier(0.34,1.56,0.64,1) both; }
      .anim-bounce-in { animation: bounce-in 0.5s cubic-bezier(0.34,1.56,0.64,1) both; }
      .anim-slide-left { animation: slide-in-left 0.4s ease both; }
      .anim-slide-right { animation: slide-in-right 0.4s ease both; }
      .anim-shimmer {
        background: linear-gradient(90deg, transparent 30%, rgba(255,255,255,0.3) 50%, transparent 70%);
        background-size: 200% 100%;
        animation: shimmer 2s infinite;
      }
      .anim-glow { animation: glow-pulse 2s ease-in-out infinite; }
      .anim-gradient {
        background-size: 200% 200%;
        animation: gradient-shift 4s ease infinite;
      }
      .anim-spin-slow { animation: spin-slow 8s linear infinite; }
      .anim-flame { animation: flame-flicker 1.5s ease-in-out infinite; }


      @keyframes skeleton-shimmer {
        0% { background-position: -200% 0; }
        100% { background-position: 200% 0; }
      }
      @keyframes skeleton-pulse {
        0%, 100% { opacity: 0.4; }
        50% { opacity: 0.7; }
      }
      @keyframes swipe-hint {
        0% { transform: translateX(0); opacity: 0.3; }
        50% { transform: translateX(6px); opacity: 0.6; }
        100% { transform: translateX(0); opacity: 0.3; }
      }

      @keyframes carousel-glow {
        0%,100% { box-shadow: 0 0 8px rgba(164,55,0,0.15); }
        50% { box-shadow: 0 0 20px rgba(164,55,0,0.3); }
      }
      @keyframes timeline-dot-pulse {
        0%,100% { box-shadow: 0 0 0 3px rgba(164,55,0,0.15); }
        50% { box-shadow: 0 0 0 6px rgba(164,55,0,0.08); }
      }
      @keyframes magnetic-spring {
        0% { transform: translate(0,0); }
        40% { transform: translate(2px,-2px); }
        70% { transform: translate(-1px,1px); }
        100% { transform: translate(0,0); }
      }
      .carousel-container::-webkit-scrollbar { height: 4px; }
      .carousel-container::-webkit-scrollbar-track { background: transparent; }
      .carousel-container::-webkit-scrollbar-thumb { background: rgba(164,55,0,0.2); border-radius: 2px; }
      .carousel-container::-webkit-scrollbar-thumb:hover { background: rgba(164,55,0,0.35); }
      .timeline-revealed .timeline-dot {
        background: #cd4700 !important;
        box-shadow: 0 0 0 4px rgba(205,71,0,0.2) !important;
      }
      /* Flip card styles */
      .flip-card { perspective: 1000px; cursor: pointer; }
      .flip-card-inner {
        position: relative; width: 100%; height: 100%;
        transition: transform 0.6s cubic-bezier(0.4,0,0.2,1);
        transform-style: preserve-3d;
      }
      .flip-card.flipped .flip-card-inner { transform: rotateY(180deg); }
      .flip-card-front, .flip-card-back {
        position: absolute; inset: 0;
        backface-visibility: hidden;
        -webkit-backface-visibility: hidden;
      }
      .flip-card-back { transform: rotateY(180deg); }
    `;
    document.head.appendChild(style);
  }

  /* ═══════════════════════════════════════════
     PUBLIC API
     ═══════════════════════════════════════════ */
  window.DesiFitAnim = {
    // Performance
    initPerformanceMode,
    getPerformanceTier,
    setPerformanceTier,
    getParticleCount,
    getBlurRadius,

    // Particles
    ParticleSystem,

    // Springs
    springAnimate,

    // Scroll animations
    initStaggerReveal,
    initParallax,
    initScrollParallax,
    initScrollReveal,
    initScrollProgressBar,
    initScrollCounter,
    initScrollHeader,
    initScrollStagger,
    initScrollProgressRing,

    // Micro-interactions
    initButtonSquash,
    initIconWiggle,
    initFABPulse,
    initChatBubbles,
    initTypingIndicator,
    initCardLift,
    initTextReveal,
    initFloating,
    initNavSlide,
    initRippleEffect,

    // Animation utilities
    animateCounter,
    animateProgressRings,

    // Dark mode
    getDarkMode,
    setDarkMode,
    toggleDarkMode,
    initDarkMode,
    initDarkModeTier,
    isDarkMode,

    // Scroll progress
    initScrollProgressIndicator,

    // Search & filter
    initSearchFilter,
    initCategoryTabs,

    // Preview modal
    openPreviewModal,
    closePreviewModal,

    // Navigation
    initBackToTop,
    liquidNavigate,

    // Micro-interactions (v2)
    showToast,
    initShimmerPlaceholders,
    initStaggerChildren,
    initCardTilt,
    burstConfetti,
    initSmoothAnchors,

    // NEW v3 animations
    initWaterFill,
    initFireFlame,
    initMorphShape,
    initBreathCircle,
    initFlipCard,
    initSlideTransition,
    // ===== v4 animation upgrades =====
    initSwipeGestures,
    initSkeletonLoaders,
    pageTransition,
    // ===== v4 animation upgrades (pt 2) =====
    initCardCarousel,
    initMagneticHover,
    initScrollTimeline,



    // Cleanup
    runAllCleanup,

    // CSS injection
    injectKeyframes,

    COLORS,
  };

  // Auto-detect performance and inject keyframes on load
  detectPerformanceTier();
  injectKeyframes();
})();
