#!/usr/bin/env node
/**
 * Private-key material gate.
 *
 * Scans every tracked file (up to a sane size) for the shapes that indicate
 * real credentials were committed: PEM private key blocks and JSON service
 * account `private_key` fields. Firebase client config (google-services.json,
 * firebase_options.dart) is intentionally committed -- its API keys are
 * client-side identifiers that ship in the app binary. A service-account key
 * or any other private key is NOT, and must never be.
 *
 * Run SDK-free from the repo root:
 *
 *   node tools/check_no_private_keys.js
 */
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const MAX_BYTES = 4 * 1024 * 1024;
const PATTERNS = [
  { re: /-----BEGIN [A-Z ]*PRIVATE KEY-----/, label: 'PEM private key block' },
  { re: /"private_key":\s*"-----BEGIN/, label: 'JSON service-account private_key' },
  { re: /-----BEGIN OPENSSH PRIVATE KEY-----/, label: 'OpenSSH private key' },
  { re: /-----BEGIN PGP PRIVATE KEY BLOCK-----/, label: 'PGP private key block' },
];

// Only files tracked in git are in scope -- gitignored local secrets are
// expected and out of scope by design.
let files;
try {
  files = execSync('git ls-files', { cwd: path.resolve(__dirname, '..'), encoding: 'utf8' })
    .split(/\r?\n/)
    .filter(Boolean);
} catch (e) {
  console.error('Could not list tracked files (run from a git checkout).');
  process.exit(2);
}

const hits = [];
for (const f of files) {
  const full = path.resolve(__dirname, '..', f);
  let stat;
  try {
    stat = fs.statSync(full);
  } catch (e) {
    continue; // deleted on disk (e.g. submodule), skip
  }
  if (!stat.isFile() || stat.size > MAX_BYTES) continue;
  let body;
  try {
    body = fs.readFileSync(full, 'latin1');
  } catch (e) {
    continue;
  }
  // Cheap binary sniff: skip if it contains NUL bytes in the first 8KB.
  if (body.slice(0, 8192).includes('\0')) continue;
  for (const { re, label } of PATTERNS) {
    const idx = body.search(re);
    if (idx !== -1) {
      const line = body.slice(0, idx).split(/\r?\n/).length;
      hits.push(`${f}:${line} — ${label}`);
      break;
    }
  }
}

if (hits.length) {
  console.error(`FAIL: private-key material found in ${hits.length} tracked file(s):`);
  for (const h of hits) console.error('  ' + h);
  console.error('\nRemove the key from the repo, rotate it, and re-run.');
  process.exit(1);
}
console.log(`ok   no private-key material in ${files.length} tracked files`);
