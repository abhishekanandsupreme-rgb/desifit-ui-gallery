#!/usr/bin/env node
'use strict';
/**
 * Stamp every gallery card with data-asset-ready="<kind>:<n>/<total>,..."
 * derived from google_flow/asset_manifest.json (totals) and
 * stitch_desifit_ui_design/assets/registry.json (real files, registered by
 * tools/register_assets.js). The compare and QA overlays render these counts.
 *
 * Idempotent: strips any existing data-asset-ready attribute, then inserts
 * fresh values. CRLF-safe. Run after every register_assets.js round and
 * commit index.html together with registry.json.
 */
const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const GALLERY = path.join(ROOT, 'stitch_desifit_ui_design', 'index.html');
const MANIFEST = path.join(ROOT, 'stitch_desifit_ui_design', 'google_flow', 'asset_manifest.json');
const REGISTRY = path.join(ROOT, 'stitch_desifit_ui_design', 'assets', 'registry.json');

const manifest = JSON.parse(fs.readFileSync(MANIFEST, 'utf8'));
const registry = fs.existsSync(REGISTRY)
  ? JSON.parse(fs.readFileSync(REGISTRY, 'utf8'))
  : { files: [] };

let html = fs.readFileSync(GALLERY, 'utf8');
const hadCrlf = html.includes('\r\n');
if (hadCrlf) html = html.replace(/\r\n/g, '\n');

const cardRe = /(<a href="([a-z0-9_]+)\/code\.html"[\s\S]{0,400}?data-assets="([^"]+)")/g;
let stamped = 0;
html = html.replace(cardRe, (full, head, slug, assetsAttr) => {
  const kinds = assetsAttr.split(',').map((s) => s.trim()).filter(Boolean);
  const chips = kinds.map((k) => {
    const total = ((manifest.screens[slug] || {}).assets || {})[k]?.length || 0;
    const n = (registry.files || []).filter((f) => f.scope === slug && f.kind === k).length;
    return `${k}:${n}/${total}`;
  }).join(',');
  stamped++;
  return head.replace(/\s*data-asset-ready="[^"]*"/, '') + ` data-asset-ready="${chips}"`;
});

if (stamped !== 30) {
  console.error(`✗ build_asset_chips: expected 30 cards, stamped ${stamped} — aborting`);
  process.exit(1);
}
if (hadCrlf) html = html.replace(/\n/g, '\r\n');
fs.writeFileSync(GALLERY, html);
console.log(`✓ chips: stamped data-asset-ready on ${stamped} cards from manifest + ${registry.files.length} registered files`);
