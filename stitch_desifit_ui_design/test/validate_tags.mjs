import fs from 'fs';
const html = fs.readFileSync('index.html', 'utf8');

// Canonical ids from ALL_ANIMATIONS
const ids = [...html.matchAll(/id:'([a-z-]+)'/g)].map((m) => m[1]);
const canon = new Set(ids);

const newCards = [
  'workout_tracker', 'calorie_scanner', 'water_intake', 'macro_scanner',
  'sleep_recovery', 'settings_profile', 'achievements', 'recipe_detail',
  'subscription_plans', 'workout_history', 'recipe_collections',
  'rewards_shop', 'progress_dashboard', 'meal_prep_scheduler', 'habit_tracker',
];

console.log('canonical count:', canon.size);
let bad = [];

for (const slug of newCards) {
  const re = new RegExp(`href="${slug}/code.html"([\\s\\S]{0,600}?)data-animations="([^"]+)"`);
  const m = html.match(re);
  if (!m) {
    bad.push(`${slug}: NO CARD FOUND`);
    console.log(slug.padEnd(20), 'NO CARD');
    continue;
  }
  const cat = m[1].match(/data-category="([^"]+)"/);
  const tokens = m[2].split(',').map((s) => s.trim());
  const missing = tokens.filter((t) => !canon.has(t));
  if (missing.length) bad.push(`${slug}: UNKNOWN -> ${missing.join(',')}`);
  console.log(
    slug.padEnd(20),
    '[' + (cat ? cat[1] : '?') + ']',
    m[2],
    missing.length ? '  !! ' + missing.join(',') : ''
  );
}

console.log(bad.length ? '\nFAIL:\n' + bad.join('\n') : '\nALL TAGS VALID ✔');
process.exit(bad.length ? 1 : 0);
