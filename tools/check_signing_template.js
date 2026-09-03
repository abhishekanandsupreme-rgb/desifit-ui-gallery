#!/usr/bin/env node
/**
 * Signing-template drift guard.
 *
 * The release-signing contract has exactly four keys -- storePassword,
 * keyPassword, keyAlias, storeFile -- and they must stay in sync across
 * three files:
 *
 *   1. desifit/android/key.properties.example   (the public template)
 *   2. desifit/android/app/build.gradle.kts      (signingConfigs "release")
 *   3. .github/workflows/android_release.yml     (Configure Production Signing)
 *
 * If anyone renames a key in one consumer but not the others, the release
 * build silently signs with the wrong/absent values. This check fails CI
 * instead. Run SDK-free from the repo root:
 *
 *   node tools/check_signing_template.js
 */
const fs = require('fs');
const path = require('path');

const EXPECTED = ['storePassword', 'keyPassword', 'keyAlias', 'storeFile'];
const root = path.resolve(__dirname, '..');

function read(p) {
  return fs.readFileSync(path.join(root, p), 'utf8');
}

function keysFromTemplate() {
  const body = read('desifit/android/key.properties.example');
  const keys = [];
  for (const line of body.split(/\r?\n/)) {
    const m = line.match(/^([A-Za-z]+)=/);
    if (m && !line.trimStart().startsWith('#')) keys.push(m[1]);
  }
  return keys.sort();
}

function keysFromGradle() {
  const body = read('desifit/android/app/build.gradle.kts');
  const keys = new Set();
  for (const m of body.matchAll(/keystoreProperties\["([A-Za-z]+)"\]/g)) {
    keys.add(m[1]);
  }
  return [...keys].sort();
}

function keysFromWorkflow() {
  const body = read('.github/workflows/android_release.yml');
  const keys = new Set();
  for (const m of body.matchAll(/echo "([A-Za-z]+)=/g)) {
    keys.add(m[1]);
  }
  return [...keys].sort();
}

const expected = [...EXPECTED].sort();
const sources = {
  'key.properties.example': keysFromTemplate(),
  'app/build.gradle.kts (signingConfigs)': keysFromGradle(),
  'android_release.yml (Configure Production Signing)': keysFromWorkflow(),
};

let failed = false;
for (const [name, keys] of Object.entries(sources)) {
  if (JSON.stringify(keys) !== JSON.stringify(expected)) {
    failed = true;
    console.error(`FAIL ${name}: expected [${expected.join(', ')}] but found [${keys.join(', ')}]`);
  } else {
    console.log(`ok   ${name}: ${keys.join(', ')}`);
  }
}

if (failed) {
  console.error('\nSigning keys drifted out of sync. Update all three consumers together.');
  process.exit(1);
}
console.log('\nSigning template contract intact.');
