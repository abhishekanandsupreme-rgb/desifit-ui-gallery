#!/usr/bin/env node
/**
 * Dart syntax-balance gate.
 *
 * Scans every .dart file under the given roots and verifies that braces,
 * parentheses and brackets are balanced *outside* of string literals and
 * comments (both line and block, single/double/triple-quoted, and raw
 * strings). Code inside Dart string interpolations (`'${foo(bar)}'`) is
 * scanned as code: entering an interpolation pushes the enclosing string
 * state onto a stack, so nested strings and interpolations inside it are
 * handled recursively. An unbalanced delimiter at this level means the
 * file cannot compile, and it is the failure mode that line-oriented
 * tools and manual edits most often introduce.
 *
 * This is intentionally NOT a substitute for `dart analyze` — it is a cheap,
 * SDK-free first gate that runs in CI before any Flutter tooling is set up.
 *
 * Usage:
 *   node tools/check_dart_syntax.js [dir ...]
 *
 * Defaults to the lib/test trees of both apps. Exits 0 when every file is
 * balanced, 1 when any file has an issue.
 */

const fs = require('fs');
const path = require('path');

const DEFAULT_ROOTS = ['desifit/lib', 'desifit/test', 'AuraSync/lib', 'AuraSync/test'];

/** Collects every .dart file under a root directory. */
function collectDartFiles(root) {
  const out = [];
  const walk = (dir) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const p = path.join(dir, entry.name);
      if (entry.isDirectory()) walk(p);
      else if (entry.name.endsWith('.dart')) out.push(p);
    }
  };
  walk(root);
  return out;
}

const isIdentChar = (c) => c !== undefined && /[A-Za-z0-9_]/.test(c);

/**
 * Comment- and string-aware balance scan with Dart interpolation support.
 * Returns { issues: string[] } with a human-readable entry per problem.
 */
function scanFile(file) {
  const s = fs.readFileSync(file, 'utf8');
  const n = s.length;
  const issues = [];
  let depth = 0;
  let minDepth = 0;
  let line = 1;
  // state: code | lineComment | blockComment | sq | dq | tq
  // When an interpolation `$ { ... }` is entered, the enclosing string
  // state is pushed onto stack; interpDepth counts the unclosed `{`s
  // inside the interpolation (starting at 1 for its own `{`). The
  // interpolation's own `{`/`}` pair is not counted in `depth`.
  let state = 'code';
  const stack = [];

  let i = 0;
  while (i < n) {
    const c = s[i];
    const nx = s[i + 1];
    const nxx = s[i + 2];
    if (c === '\n') line++;
    switch (state) {
      case 'code': {
        if (c === '/' && nx === '/') { state = 'lineComment'; i += 2; break; }
        if (c === '/' && nx === '*') { state = 'blockComment'; i += 2; break; }
        // Raw strings have no interpolation: skip to the closing quote.
        if ((c === 'r' || c === 'R') && (nx === "'" || nx === '"')) {
          const q = nx;
          i += 2;
          while (i < n && s[i] !== q) { if (s[i] === '\n') line++; i++; }
          if (i < n) i++; // consume closing quote
          break;
        }
        if (c === "'") {
          if (nx === "'" && nxx === "'") { state = 'tq'; i += 3; } else { state = 'sq'; i++; }
          break;
        }
        if (c === '"') {
          if (nx === '"' && nxx === '"') { state = 'tq'; i += 3; } else { state = 'dq'; i++; }
          break;
        }
        if (c === '{' || c === '(' || c === '[') {
          depth++;
          if (c === '{' && stack.length > 0) {
            stack[stack.length - 1].interpDepth++;
          }
        } else if (c === '}' || c === ')' || c === ']') {
          if (c === '}' && stack.length > 0) {
            const top = stack[stack.length - 1];
            if (top.interpDepth === 1) {
              // Closes the interpolation's own `{`: return to the
              // enclosing string without touching the balance counters.
              state = top.stringState;
              stack.pop();
              i++;
              break;
            }
            top.interpDepth--;
          }
          depth--;
          if (depth < minDepth) {
            minDepth = depth;
            issues.push(`${file}:${line}: unmatched closing '${c}'`);
          }
        }
        i++;
        break;
      }
      case 'lineComment':
        if (c === '\n') state = 'code';
        i++;
        break;
      case 'blockComment':
        if (c === '*' && nx === '/') { state = 'code'; i += 2; } else i++;
        break;
      case 'sq':
      case 'dq':
      case 'tq': {
        if (c === '\\') { i += 2; break; }
        // Start of a Dart interpolation: switch to code, remember the string.
        if (c === '$' && nx === '{') {
          stack.push({ stringState: state, interpDepth: 1 });
          state = 'code';
          i += 2;
          break;
        }
        // `$identifier` shorthand — nothing to balance, skip the identifier.
        if (c === '$' && isIdentChar(nx)) {
          i += 2;
          while (isIdentChar(s[i])) i++;
          break;
        }
        if (state === 'sq' && c === "'") { state = 'code'; i++; break; }
        if (state === 'dq' && c === '"') { state = 'code'; i++; break; }
        if (state === 'tq' &&
            ((c === "'" && nx === "'" && nxx === "'") ||
             (c === '"' && nx === '"' && nxx === '"'))) {
          state = 'code';
          i += 3;
          break;
        }
        i++;
        break;
      }
    }
  }
  if (stack.length > 0 || state === 'sq' || state === 'dq' || state === 'tq') {
    issues.push(`${file}: unterminated string literal`);
  }
  if (depth !== 0) {
    issues.push(`${file}: ${depth > 0 ? 'unbalanced: ' + depth + ' unclosed opener(s)' : 'unbalanced: ' + (-depth) + ' too many closers'}`);
  }
  return issues;
}

function main() {
  const roots = process.argv.length > 2 ? process.argv.slice(2) : DEFAULT_ROOTS;
  const files = [];
  for (const root of roots) {
    if (!fs.existsSync(root)) {
      console.warn(`skip (not found): ${root}`);
      continue;
    }
    files.push(...collectDartFiles(root));
  }

  const failures = [];
  for (const f of files) {
    try {
      failures.push(...scanFile(f));
    } catch (err) {
      failures.push(`${f}: could not read (${err.code || err.message})`);
    }
  }

  console.log(`Scanned ${files.length} Dart files across: ${roots.join(', ')}`);
  if (failures.length > 0) {
    console.error(`\n${failures.length} issue(s) found:`);
    for (const issue of failures) console.error('  ' + issue);
    process.exit(1);
  }
  console.log('All files balanced.');
}

main();