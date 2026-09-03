# 02 — Icons, Graphics & Effect Overlays

> Google Flow's image model (Nano Banana) is strongest at raster graphics and
> illustrated assets. For crisp icon sets, prompt one **sprite sheet** per family,
> then slice in Flow, or generate single icons at high resolution and downscale.
> All icons follow **Material Symbols Outlined** semantics: 24px optical size,
> 2px stroke, rounded caps, no fill (unless specified).

---

## 1. App icon

```
Using the desifit-modern-craftsman ingredient for style, create a square 1:1
Android app icon for "DesiFit": a rounded-square deep-saffron #A43700 to
#CD4700 135-degree gradient background with a subtle jute texture, centered
symbol of a dumbbell formed by two steel tiffin boxes (creative fusion of
fitness + Indian food), leaf-green #2E7D32 accent on the tiffin clips, crisp
edges, safe-zone padding, no text, no shadows outside the icon, flat premium
style. + neg
```

## 2. Tab-bar icon set (5 icons — one sprite sheet)

```
Using the desifit-modern-craftsman ingredient for style, generate a single
sprite sheet of 5 material line icons in a horizontal row, each 1:1 within its
own cell, deep saffron #A43700 stroke on transparent/cream #F9F9F9 background,
2px consistent stroke, rounded caps: (1) home, (2) restaurant (food), (3)
fitness_center (dumbbell), (4) bar_chart, (5) person. No fill, no outlines
around cells, no text, no grid lines. 5x1 layout. + neg
```

## 3. Feature icon set (16 icons — sprite sheet 4x4)

```
Using the desifit-modern-craftsman ingredient for style, generate a 4x4 sprite
sheet of 16 material line icons, deep saffron #A43700 on cream #F9F9F9, 2px
stroke, rounded caps, Material Symbols Outlined style: water_drop, local_fire_department
(flame), timer, qr_code_scanner, check_circle, favorite, currency_rupee, emoji_events
(trophy), monitor_heart (heart pulse), scale, bolt, bedtime (moon), egg_alt,
lunch_dining (thali), shopping_bag, group. No fill, no text, no grid lines. + neg
```

## 4. Progress-ring / gauge graphics

```
Using the desifit-modern-craftsman ingredient for style, generate a square 1:1
circular progress-ring graphic: a large ring in leaf-green #2E7D32 that is 72%
filled around the arc (gap at the bottom-left), resting on a very light
terracotta track ring, on surface #F9F9F9, with a soft saffron-tinted ambient
glow on the filled arc, no text, no numbers, no icons in the center. Used as a
sleep-score / budget ring. + neg
```

## 5. Bar-chart graphics (3 variants)

```
Using the desifit-modern-craftsman ingredient for style, generate a 16:9
minimal bar chart graphic, no axes, no gridlines, no labels: [VARIANT] —
(1) seven vertical rounded bars (Mon–Sun) alternating saffron #CD4700 and
leaf-green #2E7D32 on cream; (2) a horizontal 3-bar comparison in terracotta;
(3) a single large gradient bar 70% filled in saffron→#CD4700 with a leaf-green
target marker dot. Soft ambient shadows, editorial data-art feel. + neg
```

## 6. Sparkline / trend graphic

```
Using the desifit-modern-craftsman ingredient for style, generate a 16:9
minimal area-chart graphic: a gently rising smooth trend line in leaf-green
#2E7D32 with a soft gradient fill fading to transparent, one saffron #CD4700
highlight dot near the peak, on surface #F9F9F9, no axes, no gridlines, no
numbers, no text. Used for weight / protein trends. + neg
```

## 7. Badge & chip graphics

```
Using the desifit-modern-craftsman ingredient for style, generate a 1:1 badge
chip graphic: a rounded-full pill in [saffron #CD4700 / leaf-green #2E7D32 /
cream #FFF] with a subtle 15% ghost border and a tiny matching symbol inside
(no readable text — abstract icon only), soft tonal depth, premium sticker
feel. Variants needed: "high-protein" (chicken-leg symbol), "budget" (rupee),
"PR" (flag), "streak" (flame), "new" (sparkle). No readable letters. + neg
```

## 8. Reward coin & coupon graphics

```
Using the desifit-modern-craftsman ingredient for style, generate a 1:1 coin
graphic: a golden-edged coin, cream center, with a leaf-green rupee symbol
(simple "₹" shape, no numbers) embossed, soft radial glow, slight top-down
tilt, on warm terracotta background. And a second 4:3 coupon graphic: a
rounded coupon ticket in cream with a saffron dashed fold line and blank
discount area (no numbers), scissor-cut notches. No readable text. + neg
```

## 9. Decorative graphics

```
Using the desifit-modern-craftsman ingredient for style, generate a 16:9
decorative hero graphic: a large, soft, oversized Plus Jakarta Sans "&" or an
abstract terracotta arch motif in deep saffron #A43700 at 20% opacity over
surface #F9F9F9 with jute texture, single leaf-green leaf accent, editorial
whitespace. Used behind headlines. No readable words. + neg
```

## 10. Texture & gradient tiles (reuse from 00, §3)

Generate `desifit-tex-jute`, `desifit-tex-clay`, `desifit-tex-silk`,
`desifit-tex-foliage` as ingredients per `00_brand_anchor.md` §3.

## 11. Effect overlays (raster, for compositing in code)

### Scan-line overlay (calorie / macro scanner)
```
Using the desifit-modern-craftsman ingredient for style, generate a square 1:1
transparent-friendly overlay: a single thin horizontal line of light in
leaf-green #2E7D32 with a soft glow trail, centered vertically on a transparent
(or pure #F9F9F9) background, sharp in the middle and fading at the edges,
used as an animated scan-line sweep. No text, no objects. + neg
```

### Confetti burst overlay (achievements / habit completion)
```
Using the desifit-modern-craftsman ingredient for style, generate a square 1:1
overlay of a celebratory confetti burst: small terracotta, saffron #CD4700,
leaf-green #2E7D32, and cream paper pieces exploding from center, dynamic arcs,
soft motion blur on the fastest pieces, on transparent/pure #F9F9F9 background,
no text, no people. + neg
```

### Shimmer sweep overlay (subscription / rewards)
```
Using the desifit-modern-craftsman ingredient for style, generate a wide 16:9
overlay of a diagonal soft white-to-transparent light streak sweeping across a
transparent background, gentle blur, warm highlight, used as a shimmer effect
over badges and plan cards. No text, no objects. + neg
```

### Glass panel overlay (floating nav)
```
Using the desifit-modern-craftsman ingredient for style, generate a wide 16:9
overlay of a frosted-glass horizontal pill: white at 80% opacity, 24px backdrop
blur, rounded-3xl, soft saffron-tinted ambient shadow beneath, edges faintly
luminous, no border lines, transparent ends for compositing a bottom nav bar.
No icons, no text. + neg
```
