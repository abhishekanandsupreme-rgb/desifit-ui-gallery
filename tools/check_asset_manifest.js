#!/usr/bin/env node
'use strict';
/**
 * CI gate: google_flow/asset_manifest.json <-> gallery <-> spec files.
 *
 * Fails when:
 *  1. manifest screens != gallery cards (missing/extra, or name/category drift)
 *  2. a manifest entry references a `section:` heading that no longer exists
 *     in its `spec:` file (prompts were renamed/removed without updating the manifest)
 *
 * Same contract-guard pattern as check_signing_template.js / check_flutter_pin.js:
 * the manifest is the machine-readable contract for the Google Flow asset pack,
 * and the gallery + spec docs must stay in lockstep with it.
 */
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const GALLERY = path.join(ROOT, 'stitch_desifit_ui_design', 'index.html');
const MANIFEST = path.join(ROOT, 'stitch_desifit_ui_design', 'google_flow', 'asset_manifest.json');
const FLOW_DIR = path.join(ROOT, 'stitch_desifit_ui_design', 'google_flow');

const errors = [];
function fail(msg) { errors.push(msg); }

let manifest;
try {
  manifest = JSON.parse(fs.readFileSync(MANIFEST, 'utf8'));
} catch (e) {
  console.error('✗ asset_manifest.json is not valid JSON:', e.message);
  process.exit(1);
}

// ── 1. Gallery cards ────────────────────────────────────────────────────────
const html = fs.readFileSync(GALLERY, 'utf8');
const cardRe = /<a href="([a-z0-9_]+)\/code\.html"[\s\S]{0,400}?data-category="([^"]+)"[\s\S]{0,400}?data-name="([^"]+)"[\s\S]{0,400}?data-animations="([^"]*)"/g;
const cards = new Map();
let m;
while ((m = cardRe.exec(html)) !== null) {
  const [, slug, category, name] = m;
  if (cards.has(slug)) fail(`duplicate gallery card for slug "${slug}"`);
  cards.set(slug, { category, name });
}
if (cards.size !== 30) fail(`expected 30 gallery cards, found ${cards.size}`);

// ── 2. Screen-set + metadata agreement ──────────────────────────────────────
const manifestSlugs = Object.keys(manifest.screens || {});
for (const slug of manifestSlugs) {
  if (!cards.has(slug)) fail(`manifest screen "${slug}" has no gallery card`);
}
for (const [slug, card] of cards) {
  const entry = manifest.screens[slug];
  if (!entry) { fail(`gallery card "${slug}" missing from manifest`); continue; }
  if (entry.name !== card.name) {
    fail(`name drift for "${slug}": manifest="${entry.name}" gallery="${card.name}"`);
  }
  if (entry.category !== card.category) {
    fail(`category drift for "${slug}": manifest="${entry.category}" gallery="${card.category}"`);
  }
  if (!entry.assets || typeof entry.assets !== 'object') {
    fail(`screen "${slug}" has no assets object`);
  }
}

// ── 3. Every referenced section must exist in its spec file ────────────────
const specCache = new Map();
function specHasHeading(specFile, section) {
  let text = specCache.get(specFile);
  if (text === undefined) {
    const p = path.join(FLOW_DIR, specFile);
    try { text = fs.readFileSync(p, 'utf8'); } catch (e) {
      fail(`spec file not found: ${specFile}`); text = ''; 
    }
    specCache.set(specFile, text);
  }
  // Section strings may be "Heading" or "Heading — Sub-heading"; both parts
  // must appear in the file (sub-heading may wrap, so match loosely).
  const parts = section.split(' — ').map(s => s.trim()).filter(Boolean);
  return parts.every(part => text.includes(part));
}

function checkAsset(kind, a, ctx) {
  if (!a || typeof a !== 'object') { fail(`${ctx}: malformed ${kind} asset entry`); return; }
  if (!a.prompt) fail(`${ctx}: ${kind} asset missing "prompt"`);
  if (!a.spec) fail(`${ctx}: ${kind} asset "${a.prompt}" missing "spec" file`);
  if (!a.section) fail(`${ctx}: ${kind} asset "${a.prompt}" missing "section"`);
  else if (a.spec && !specHasHeading(a.spec, a.section)) {
    fail(`${ctx}: ${kind} asset "${a.prompt}" references missing section in ${a.spec}: "${a.section}"`);
  }
}

for (const [slug, entry] of Object.entries(manifest.screens || {})) {
  for (const [kind, list] of Object.entries(entry.assets || {})) {
    if (!Array.isArray(list)) { fail(`screen "${slug}": assets.${kind} must be an array`); continue; }
    list.forEach((a, i) => checkAsset(kind, a, `screen "${slug}" assets.${kind}[${i}]`));
  }
}
for (const [group, g] of Object.entries(manifest.shared || {})) {
  const list = g && g.prompts;
  if (!Array.isArray(list)) { fail(`shared.${group} must have a prompts array`); continue; }
  list.forEach((a, i) => {
    // Group-level "spec" is the fallback when a prompt doesn't carry its own.
    const withSpec = Object.assign({}, a, { spec: a.spec || (g && g.spec) });
    checkAsset('shared', withSpec, `shared.${group}.prompts[${i}]`);
  });
}

// ── Report ──────────────────────────────────────────────────────────────────
if (errors.length) {
  console.error(`✗ asset manifest gate: ${errors.length} problem(s)`);
  for (const e of errors) console.error('  - ' + e);
  process.exit(1);
}
console.log(`✓ asset manifest gate: ${cards.size} gallery screens <-> ${manifestSlugs.length} manifest screens, all spec sections resolve`);
