# Google Flow — DesiFit Asset Generation Prompt Pack

A copy‑paste‑ready prompt library for generating **every media asset** the DesiFit
30‑screen UI gallery needs, using **Google Flow** (labs.google/fx/tools/flow).

Google Flow is a generative media studio powered by **Veo 3 / Veo 3.1** (video +
native audio), **Nano Banana** (image generation/editing), and a **Gemini Omni
agent** that turns conversational prompts into cinematic media. It is NOT a
standalone music/icon tool, so this pack adapts: music + icons are prompted
through the agent with precise specs, while video/photo/effects are native.

---

## 1. How to use this pack

### Step 1 — Create the brand "ingredient" once
In Flow, first run the **Brand Anchor** prompt (`00_brand_anchor.md`) and save the
result as a persistent **ingredient** named **`desifit-modern-craftsman`**
(style reference: the image it generates + the prompt text). Every later prompt
below references this ingredient by name so all assets share one visual identity.

### Step 2 — Generate in asset order
| Order | File | Purpose |
|---|---|---|
| 1 | `00_brand_anchor.md` | Master style + tokens + palette swatch image |
| 2 | `01_images.md` | Hero photos, food photography, textures, avatars |
| 3 | `02_icons_graphics.md` | Icons, charts, rings, badges, decorative graphics |
| 4 | `03_video.md` | Cinemagraphs, onboarding motion, food sizzle, transitions |
| 5 | `04_audio.md` | SFX, notifications, ambient loops, music beds |

### Step 3 — Consistency rules (non‑negotiable)
- **Always** open with: `Using the desifit-modern-craftsman ingredient for style…`
  (exception: `04_audio.md` prompts translate the brand into sound language and
  intentionally omit the visual ingredient — see that file's header)
- **Never** change the hex palette. Saffron `#A43700` / `#CD4700`, Leaf `#2E7D32`,
  Surface `#F9F9F9`, Ink `#1A1C1C`. Dark variants: Stone‑950 `#0C0A09`, Card `#1C1917`.
- **No‑Line rule:** no 1px borders, no pure black `#000`, no hard grid lines.
  Depth comes from tonal layering, glass blur, and ambient shadows.
- **Type:** Plus Jakarta Sans (display/headline), Inter (body). Only render text
  when a prompt explicitly asks for it, and keep it to 1–6 words.
- **Budget‑device legibility:** strong contrast, generous padding, large subjects.

### Step 4 — Aspect ratios used across the app
| Asset | Ratio | Notes |
|---|---|---|
| Phone hero / onboarding art | 9:16 (portrait) | full‑bleed, fits 884px+ frame |
| Card thumbnails / previews | 4:5 or 1:1 | recipe + community + collections |
| Food hero / recipe detail | 4:3 or 16:9 | top‑of‑screen hero, text overlay on bottom |
| Wide banners / promo | 16:9 | device‑frame marketing shots |
| Icons | 1:1 (24/48px grid) | Material Symbols stroke family |
| Badges / coins / chips | 1:1 | standalone, transparent or on-tone background |

---

## 2. Asset → screen map (quick reference)

| Screen folder | Assets needed (see file) |
|---|---|
| `onboarding_1_5` | King thali photo, royal food flat‑lay, texture |
| `onboarding_2_5` | Hostel kettle + pantry macro |
| `onboarding_3_5` | Coach Bheem avatar + coaching illustration |
| `onboarding_4_5` | Community hacks collage |
| `onboarding_5_5` | Muscle-up gym hero |
| `home_dashboard_1` | Gauges hero, macro texture |
| `home_dashboard_2` | Conic ring FAB backdrop |
| `ai_dietitian_chat_1` | Coach Bheem avatar (reuse), chat bubbles bg |
| `ai_dietitian_chat_2` | Bento recipe collage |
| `recipe_engine_1/2` | 8+ dish photos, chips |
| `community_feed` | Post images, avatars, like burst |
| `budget_groceries` | Grocery product shots, price tags |
| `workout_tracker` | Exercise iconography, plate/dumbbell |
| `calorie_scanner` | Thali scan target, macro bars |
| `water_intake` | Water glasses, drop, hydration art |
| `macro_scanner` | Barcode + product pack shots |
| `leaderboard` | Podium, coin, contender avatars |
| `sleep_recovery` | Moon float, stage rings, 7-night bars |
| `settings_profile` | Profile avatar (Arjun) |
| `achievements` | 9 badge icons, XP bar, level ring |
| `weekly_jugaad_planner` | Hack cards, sticky notes |
| `recipe_detail` | Masoor Dal Tadka hero |
| `subscription_plans` | Tier icons (Desi/Champ/Ghar) |
| `workout_history` | PR chip, volume sparkline |
| `recipe_collections` | Collection covers ×3 |
| `rewards_shop` | Coin, coupons, merch, donation icons |
| `progress_dashboard` | Protein bars, budget ring, trend chart |
| `meal_prep_scheduler` | Meal container tiles ×7 |
| `habit_tracker` | Streak flame, check circles |

---

## 3. Prompt style guide

Every prompt below is structured as: **Context → Subject → Composition →
Color/Lighting → Style anchor → Ratio → Negatives**. If Flow asks you to simplify,
keep the Subject + Style + Ratio lines and trim the rest. Paste the whole block
anyway — the Gemini agent tolerates long, structured prompts better than short ones.
