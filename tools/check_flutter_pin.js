#!/usr/bin/env node
/**
 * Flutter-pin drift guard.
 *
 * The Flutter SDK version is pinned in exactly one place — `.flutter-version`
 * at the repo root — and two consumers must stay in sync with it:
 *
 *   1. .github/workflows/android_release.yml  (both `Set up Flutter` steps
 *      must pass `flutter-version:` explicitly; `channel: stable` alone
 *      floats and would break local/CI tooling parity)
 *   2. tools/bootstrap_flutter.sh reads the file itself, so it cannot drift
 *      (checked here only to catch accidental hardcoding of a version)
 *
 * If anyone bumps one consumer but not the others, local suites and CI run
 * different SDKs and "works locally, fails in CI" returns. This check fails
 * CI instead. Run SDK-free from the repo root:
 *
 *   node tools/check_flutter_pin.js
 */
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const versionFile = path.join(root, '.flutter-version');
const workflowFile = path.join(root, '.github', 'workflows', 'android_release.yml');
const bootstrapFile = path.join(root, 'tools', 'bootstrap_flutter.sh');

function read(p) {
  return fs.readFileSync(p, 'utf8');
}

let failed = false;

// 1. The pin file itself.
const pin = read(versionFile).trim();
if (!/^\d+\.\d+\.\d+(\+\d+)?$/.test(pin)) {
  console.error(`FAIL .flutter-version: "${pin}" is not a valid Flutter version (expected e.g. 3.47.2)`);
  process.exit(1);
}
console.log(`ok   .flutter-version: ${pin}`);

// 2. Every flutter-version in the workflow must equal the pin.
const workflow = read(workflowFile);
const used = [...workflow.matchAll(/flutter-version:\s*'?([\w.+]+)'?/g)].map(m => m[1]);
if (used.length === 0) {
  failed = true;
  console.error('FAIL android_release.yml: no flutter-version found — CI floats on the stable channel and loses parity with .flutter-version');
} else {
  for (const v of used) {
    if (v !== pin) {
      failed = true;
      console.error(`FAIL android_release.yml: uses Flutter ${v} but .flutter-version pins ${pin}`);
    } else {
      console.log(`ok   android_release.yml: flutter-version ${v}`);
    }
  }
  const setupSteps = (workflow.match(/subosito\/flutter-action@v2/g) || []).length;
  if (setupSteps !== used.length) {
    failed = true;
    console.error(`FAIL android_release.yml: ${setupSteps} flutter-action step(s) but only ${used.length} flutter-version pin(s) — every step must be pinned`);
  }
}

// 3. The bootstrap script must read the pin file, not hardcode a version.
const bootstrap = read(bootstrapFile);
if (!bootstrap.includes('.flutter-version')) {
  failed = true;
  console.error('FAIL tools/bootstrap_flutter.sh: does not read .flutter-version');
} else if (/FLUTTER_VERSION="?[0-9]/.test(bootstrap)) {
  failed = true;
  console.error('FAIL tools/bootstrap_flutter.sh: hardcodes a version instead of reading .flutter-version');
} else {
  console.log('ok   tools/bootstrap_flutter.sh: reads .flutter-version');
}

if (failed) {
  console.error('\nFlutter pin drifted out of sync. Update .flutter-version and every consumer together.');
  process.exit(1);
}
console.log('\nFlutter pin contract intact.');
