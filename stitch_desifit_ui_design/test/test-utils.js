/**
 * test-utils.js — shared Playwright test helpers for the DesiFit animation
 * engine suite.
 */

/**
 * Runs an in-page starter function inside `page` and resolves when the
 * animation it starts fires its onComplete — waiting deterministically
 * instead of polling. A hard in-page timer gives up early
 * (stalled-under-load) if the animation is starved of frames under suite
 * load — a frozen main thread fails fast instead of hanging on an
 * rAF-driven waitForFunction poll (which previously froze all the way to
 * the 120s test timeout).
 *
 * The starter is passed as a function (or its source as a string). It is
 * shipped to the page and reconstructed there, so it must only reference
 * page globals, its own parameters, and values supplied via `opts.args` —
 * never Node-side closure variables.
 *
 * @param {import('@playwright/test').Page} page
 * @param {Function|string} fn  In-page starter, invoked as
 *   `fn(settle, registerStall, ...opts.args)`. Pass a real function (its
 *   source is serialized via toString), or a source string that is a full
 *   arrow/function expression (the reconstructor wraps it in `return (...)`
 *   via `new Function`) — never a bare function body. Its arguments:
 *   - `settle(payload)` resolves the helper with `payload` — wire it to the
 *     animation's onComplete.
 *   - `registerStall(reader)` optionally registers `() => payload`, called
 *     if the stall-escape timer fires, so that path can report live in-page
 *     state (default payload: `{ settled: false, reason: 'stalled-under-load' }`).
 *   - `...opts.args` are extra serializable values (JSHandles nest fine).
 * @param {object} [opts]
 * @param {number} [opts.timeout=3000]  Stall-escape timer in ms. Fires on the
 *   in-page timer queue, so it runs even when rAF is starved.
 * @param {Array} [opts.args]  Extra values passed to `fn` after `settle` and
 *   `registerStall`.
 * @returns {Promise<any>}  Whatever `settle` resolved with, or the stall
 *   payload if the timer fired first. The stall payload shape is
 *   `{ settled: false, reason: 'stalled-under-load' }` by default, but a
 *   starter that registers a stall reader controls its own shape — it should
 *   match what `settle` resolves with so callers get a consistent union.
 */
async function waitForAnimationSettle(page, fn, opts = {}) {
  const fnSrc = typeof fn === 'string' ? fn : fn.toString();
  const args = opts.args || [];

  // page.evaluate accepts exactly ONE argument after the function in
  // Playwright, so fnSrc/args/timeout travel as a single array. A JSHandle
  // nested in the array is fine — Playwright serializes handles at any depth
  // and reconstructs the DOM node page-side. The starter source is rebuilt
  // with `new Function` (the same serialization Playwright itself uses).
  const result = await page.evaluate(
    ([fnSrc, args, timeout]) => {
      return new Promise((resolve) => {
        let done = false;
        let stallReader = null;
        const timer = setTimeout(() => {
          if (done) return;
          done = true;
          resolve(stallReader ? stallReader() : { settled: false, reason: 'stalled-under-load' });
        }, timeout || 3000);

        const settle = (payload) => {
          if (done) return;
          done = true;
          clearTimeout(timer);
          resolve(payload);
        };
        const registerStall = (reader) => { stallReader = reader; };

        const starter = new Function('return (' + fnSrc + ');')();
        starter(settle, registerStall, ...args);
      });
    },
    [fnSrc, args, opts.timeout]
  );
  return result;
}

/**
 * Runs springAnimate inside `page` for `el` and resolves with the settled
 * value. A thin wrapper over waitForAnimationSettle that keeps the spring
 * guards (empty props, multi-key requires opts.key) and the read-back logic
 * in one place.
 *
 * @param {import('@playwright/test').Page} page
 * @param {string|import('@playwright/test').JSHandle} el
 *   CSS selector string, or a JSHandle (e.g. from page.evaluateHandle) whose
 *   object is the target DOM element. A selector is resolved with
 *   document.querySelector; a missing node yields { missing: true }.
 * @param {object} props  springAnimate target props, e.g. { opacity: 0.5 }.
 * @param {object} [opts]
 * @param {object} [opts.spring]  Extra springAnimate options forwarded
 *   verbatim (stiffness, damping, mass, settleThreshold, ...).
 * @param {number} [opts.timeout=3000]  Stall-escape timer in ms. Fires on the
 *   in-page timer queue, so it runs even when rAF is starved.
 * @param {string} [opts.key]  Style key to read back at settle time. REQUIRED
 *   when `props` has more than one key (otherwise the read-back could silently
 *   measure the wrong property on a joint all-keys settle); defaults to the
 *   first key of `props` when it has exactly one.
 * @returns {Promise<{ settled: boolean, value: number, reason: string, missing?: boolean }>}
 *   `value` is parseFloat(node.style[key]) — the inline style the engine
 *   writes every frame — read at settle time (or NaN when the node is
 *   missing). Inline is read instead of getComputedStyle because computed
 *   left/top on a static element is "auto" (parseFloat -> NaN).
 */
async function waitForSpringSettle(page, el, props, opts = {}) {
  // When animating more than one property the read-back key must be stated
  // explicitly — silently defaulting to Object.keys(props)[0] could measure
  // the wrong property on a joint all-keys settle. Throw here (Node side,
  // before crossing the evaluate RPC boundary) so the failure is immediate
  // and the message isn't wrapped in Playwright's evaluate error text.
  const propKeys = Object.keys(props);
  if (propKeys.length === 0) {
    throw new Error('waitForSpringSettle: props is empty; pass at least one target property.');
  }
  if (propKeys.length > 1 && !opts.key) {
    throw new Error(
      `waitForSpringSettle: props has ${propKeys.length} keys (${propKeys.join(', ')}), ` +
      'but opts.key was not provided. opts.key is required when animating more than one property.'
    );
  }

  // NOTE: the arrow's params (el, props, opts) are received from opts.args
  // below — NOT captured from this Node-side scope. The starter is serialized
  // with fn.toString() and reconstructed in-page, so it must be fully
  // self-contained; do not reference variables outside its own param list.
  return waitForAnimationSettle(page, (settle, registerStall, el, props, opts) => {
    const node = typeof el === 'string' ? document.querySelector(el) : el;
    if (!node) {
      settle({ settled: true, value: NaN, missing: true, reason: 'missing' });
      return;
    }
    const settleKey = opts.key || Object.keys(props)[0];
    const read = () => parseFloat(node.style[settleKey]);
    registerStall(() => ({ settled: false, value: read(), reason: 'stalled-under-load' }));
    window.DesiFitAnim.springAnimate(node, props, Object.assign({}, opts.spring, {
      onComplete: () => settle({ settled: true, value: read(), reason: 'settled' })
    }));
  }, { args: [el, props, opts], timeout: opts.timeout });
}

module.exports = { waitForAnimationSettle, waitForSpringSettle };
