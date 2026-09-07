#!/usr/bin/env node
'use strict';
/**
 * CI gate: real asset files <-> registry <-> manifest <-> gallery chips.
 *
 * The Google Flow pipeline (google_flow/README.md) drops generated media into
 * stitch_desifit_ui_design/assets/<kind>/<scope>/<prompt>.<ext> and registers
 * it via tools/register_assets.js, which pins bytes + sha256 into
 * assets/registry.json. This gate enforces that:
 *
 *  1. every registered file exists on disk, is non-empty, and still matches
 *     its pinned size/hash — a registered asset can never silently vanish
 *     or be swapped (the missing-asset ratchet: pending is legal, broken is not)
 *  2. registry entries are unique, convention-shaped, and resolve to a real
 *     manifest prompt (screen-level or shared)
 *  3. every gallery card's data-asset-ready chips equal the counts derived
 *     from manifest totals + registry files — chips cannot drift from reality
 *
 * Same contract-guard pattern as check_asset_manifest.js.
 */
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

const ROOT = path.resolve(__dirname, '..');
const GALLERY = path.join(ROOT, 'stitch_desifit_ui_design', 'index.html');
const MANIFEST = path.join(ROOT, 'stitch_desifit_ui_design', 'google_flow', 'asset_manifest.json');
const REGISTRY = path.join(ROOT, 'stitch_desifit_ui_design', 'assets', 'registry.json');

const EXT_FOR_KIND = {
  image: ['png', 'jpg', 'webp'],
  video: ['mp4', 'webm'],
  audio: ['mp3', 'm4a', 'wav', 'aac', 'ogg'],
  icon: ['svg'],
};
const PATH_RE = /^stitch_desifit_ui_design\/assets\/(image|video|audio|icon)\/(shared|[a-z0-9_]+)\/([a-z0-9-]+)\.([a-z0-9]+)$/;

const errors = [];
function fail(msg) { errors.push(msg); }

const manifest = JSON.parse(fs.readFileSync(MANIFEST, 'utf8'));

// ── 1. Registry structure ───────────────────────────────────────────────────
let registry = { files: [] };
if (fs.existsSync(REGISTRY)) {
  try {
    registry = JSON.parse(fs.readFileSync(REGISTRY, 'utf8'));
  } catch (e) {
    console.error('✗ assets/registry.json is not valid JSON:', e.message);
    process.exit(1);
  }
  if (!Array.isArray(registry.files)) fail('registry.files must be an array');
}
const seenUnits = new Set();
const seenPaths = new Set();

// ── 2. Per-entry integrity ──────────────────────────────────────────────────
for (const [i, e] of (registry.files || []).entries()) {
  const ctx = `registry.files[${i}]`;
  for (const k of ['kind', 'scope', 'prompt', 'file', 'bytes', 'sha256']) {
    if (e[k] === undefined) fail(`${ctx}: missing "${k}"`);
  }
  if (errors.length && errors[errors.length - 1].startsWith(ctx)) continue;
  const unitKey = `${e.kind}/${e.scope}/${e.prompt}`;
  if (seenUnits.has(unitKey)) fail(`${ctx}: duplicate unit ${unitKey}`);
  seenUnits.add(unitKey);
  if (seenPaths.has(e.file)) fail(`${ctx}: duplicate path ${e.file}`);
  seenPaths.add(e.file);

  const m = PATH_RE.exec(e.file || '');
  if (!m) { fail(`${ctx}: file "${e.file}" violates the convention <kind>/<scope>/<prompt>.<ext>`); continue; }
  const [, pathKind, pathScope, pathPrompt, ext] = m;
  if (pathKind !== e.kind) fail(`${ctx}: kind "${e.kind}" disagrees with path segment "${pathKind}"`);
  if (pathScope !== e.scope) fail(`${ctx}: scope "${e.scope}" disagrees with path segment "${pathScope}"`);
  if (pathPrompt !== e.prompt) fail(`${ctx}: prompt "${e.prompt}" disagrees with path segment "${pathPrompt}"`);
  if (!(EXT_FOR_KIND[e.kind] || []).includes(ext)) {
    fail(`${ctx}: .${ext} not allowed for kind "${e.kind}" (want ${(EXT_FOR_KIND[e.kind] || []).join('|')})`);
  }

  // Prompt must resolve in the manifest.
  if (e.scope === 'shared') {
    const group = Object.values(manifest.shared || {}).find(
      (g) => g.assetKind === e.kind && (g.prompts || []).some((p) => p.prompt === e.prompt)
    );
    if (!group) fail(`${ctx}: no shared prompt "${e.prompt}" with assetKind "${e.kind}"`);
  } else {
    const scr = manifest.screens[e.scope];
    if (!scr) fail(`${ctx}: unknown screen scope "${e.scope}"`);
    else if (!(scr.assets[e.kind] || []).some((a) => a.prompt === e.prompt)) {
      fail(`${ctx}: screen "${e.scope}" has no ${e.kind} prompt "${e.prompt}"`);
    }
  }

  // The file itself: exists, non-empty, hash-pinned.
  const abs = path.join(ROOT, e.file);
  if (!fs.existsSync(abs)) { fail(`${ctx}: registered file missing on disk: ${e.file}`); continue; }
  const buf = fs.readFileSync(abs);
  if (buf.length === 0) fail(`${ctx}: file is empty: ${e.file}`);
  if (buf.length !== e.bytes) fail(`${ctx}: bytes drifted for ${e.file} (registry ${e.bytes}, disk ${buf.length})`);
  const sha = crypto.createHash('sha256').update(buf).digest('hex');
  if (sha !== e.sha256) fail(`${ctx}: sha256 drifted for ${e.file} — re-run tools/register_assets.js if the asset was intentionally replaced`);
}

// ── 3. Gallery chips must equal manifest totals + registry counts ───────────
const html = fs.readFileSync(GALLERY, 'utf8');
const cardRe = /<a href="([a-z0-9_]+)\/code\.html"[\s\S]{0,400}?data-assets="([^"]+)"/g;
let mCard;
let chipsChecked = 0;
while ((mCard = cardRe.exec(html)) !== null) {
  const [, slug, assetsAttr] = mCard;
  const kinds = assetsAttr.split(',').map((s) => s.trim()).filter(Boolean);
  const expected = kinds.map((k) => {
    const total = ((manifest.screens[slug] || {}).assets || {})[k]?.length || 0;
    const n = (registry.files || []).filter((f) => f.scope === slug && f.kind === k).length;
    return `${k}:${n}/${total}`;
  }).join(',');
  const cardChunk = html.slice(cardRe.lastIndex - 800, cardRe.lastIndex + 400);
  const have = (cardChunk.match(/data-asset-ready="([^"]*)"/) || [])[1];
  if (have === undefined) {
    fail(`card "${slug}" has no data-asset-ready attribute — re-run tools/build_asset_chips.js`);
  } else if (have !== expected) {
    fail(`card "${slug}" chip drift: html="${have}" expected="${expected}" — re-run tools/build_asset_chips.js`);
  } else {
    chipsChecked++;
  }
}
if (chipsChecked !== 30) fail(`expected chip verification for 30 cards, got ${chipsChecked}`);

// ── Report ──────────────────────────────────────────────────────────────────
const totalUnits = Object.values(manifest.screens || {}).reduce(
  (n, e) => n + Object.values(e.assets || {}).reduce((x, l) => x + l.length, 0), 0
) + Object.values(manifest.shared || {}).reduce((n, g) => n + (g.prompts || []).length, 0);
const reg = (registry.files || []).length;
if (errors.length) {
  console.error(`✗ asset files gate: ${errors.length} problem(s)`);
  for (const e of errors) console.error('  - ' + e);
  process.exit(1);
}
console.log(`✓ asset files gate: ${reg}/${totalUnits} units have hash-pinned files, 30 cards' chips match reality`);
if (reg < totalUnits) console.log(`  ${totalUnits - reg} pending generation (legal; run tools/register_assets.js after each Flow export)`);
