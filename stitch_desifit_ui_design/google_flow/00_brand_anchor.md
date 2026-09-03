# 00 — Brand Anchor: "The Modern Craftsman" (create ONCE, reuse everywhere)

> **How to use:** Run this file's **Master Style Prompt** in Google Flow first.
> Save the generated image + this prompt as a persistent **ingredient** named
> **`desifit-modern-craftsman`**. Every asset prompt in this pack opens with
> "Using the **desifit-modern-craftsman** ingredient for style…".

---

## 1. Master Style Prompt (paste verbatim into Flow)

```
Create a brand style-defining image for "DesiFit", an Indian fitness & nutrition
app. Style name: "The Modern Craftsman" — a high-end editorial interpretation of
Indian heritage. Think terracotta clay, jute, monsoon foliage, hand-pressed paper,
and fired-clay pottery, executed with precise contemporary digital layout.

COMPOSITION: A wide 16:9 moodboard. Left third: a deep-saffron gradient panel
(from #A43700 to #CD4700 at 135 degrees) with a subtle woven-jute texture overlay
at 8% opacity, and one large Plus Jakarta Sans wordmark "DesiFit" in white,
letter-spacing -2%, weight 800. Right two-thirds: a flat-lay of objects — a clay
terracotta bowl of dal, fresh green coriander leaves, a steel tiffin, a dumbbell,
a steel water glass, scattered spice seeds — photographed from directly above,
soft morning window light, warm neutral shadows. Leaf-green (#2E7D32) accent
elements: a small "MONSOON" label chip and a success ring.

PALETTE (exact hex): primary saffron #A43700, primary-container #CD4700,
secondary leaf-green #2E7D32, surface #F9F9F9, surface-container-low #F3F3F3,
surface-container-lowest #FFFFFF, ink #1A1C1C.

MATERIAL LANGUAGE: surfaces stack like hand-pressed paper — cards on a slightly
darker section, NO 1px border lines anywhere, depth only through tonal shifts,
24px backdrop-blur glass on floating elements, ambient shadows tinted saffron
(rgba 164,55,0,0.08) never pure black.

MOOD: warm, earthy, premium, editorial, legible on a budget Android display.
Rounded corners 0.5rem+. Generous padding. High contrast, no clutter.

NEGATIVES: no pure black background, no neon, no gradients of purple/blue, no
cyberpunk, no skeuomorphic gloss, no watermark, no text other than the DesiFit
wordmark, no border lines, no drop shadows that are black.
```

## 2. Design tokens reference (paste into any prompt needing exact colors)

```
PRIMARY saffron:      #A43700   (text-on-primary: #FFFFFF)
PRIMARY CONTAINER:    #CD4700   (fired-clay sheen; CTA gradients go #A43700 → #CD4700 at 135°)
SECONDARY leaf:       #2E7D32   (success, growth, organic metrics)
SECONDARY CONTAINER:  #A5D6A7 / light leaf tint for chips
SURFACE (base):       #F9F9F9
SURFACE LOW:          #F3F3F3   (section background)
SURFACE LOWEST:       #FFFFFF   (cards)
ON-SURFACE ink:       #1A1C1C   (never pure black)
DARK base:            #0C0A09 (stone-950)
DARK card:            #1C1917 (stone-900)
DARK track:           #292524 (stone-800)
DARK accent:          #FF8A50 (light saffron), #FFCCBC (light primary-container)
WHITE:                #FFFFFF (on-dark text)
FONTS: Plus Jakarta Sans (display/headline, weight 600-800, tracking -2%),
       Inter (body, weight 400-600)
ICONS: Material Symbols Outlined family, optical size 24px
```

## 3. Texture library (subtle backgrounds for heroes)

Each of these is a **1:1 or 16:9 tile** at low opacity (5–12%) designed to sit
behind UI as a watermark texture. Generate all four in one Flow session and save
as ingredients `desifit-tex-jute`, `desifit-tex-clay`, `desifit-tex-silk`,
`desifit-tex-foliage`.

```
Using the desifit-modern-craftsman ingredient for style, generate a seamless,
top-down, close-up texture tile of tightly woven natural jute fiber, warm beige
#E8DFD3, extremely soft diffuse lighting, no shadows, no objects, flat and
uniform, subtle natural weave pattern filling the entire frame, muted and
desaturated so it works as a 8%-opacity watermark behind UI. Square 1:1. No
text, no borders, no pure black.

Using the desifit-modern-craftsman ingredient for style, generate a seamless
texture of smooth fired terracotta clay, deep saffron #A43700 to burnt orange
#CD4700, matte ceramic surface with very subtle tonal mottling, soft even
lighting, no reflections, no objects, uniform and flat, muted for watermark
use behind a phone screen. Square 1:1. No text, no borders, no pure black.

Using the desifit-modern-craftsman ingredient for style, generate a seamless
texture of soft raw silk fabric in a neutral stone tone #E5E0D8, fine woven
grain, gentle sheen, even diffuse light, flat and uniform, desaturated for
watermark use behind UI. Square 1:1. No text, no borders, no pure black.

Using the desifit-modern-craftsman ingredient for style, generate a seamless
texture of fresh monsoon foliage — small green leaves #2E7D32 and darker
#1B5E20 — densely packed, soft top-down natural light, flat, muted and
desaturated for watermark use behind UI. Square 1:1. No text, no borders.
```

## 4. Glassmorphism hero swatch

```
Using the desifit-modern-craftsman ingredient for style, generate a UI element
swatch on a 1:1 tile: a rounded-3xl frosted-glass panel (white at 80% opacity,
24px backdrop blur) floating over the deep-saffron #A43700→#CD4700 gradient,
with a soft saffron-tinted ambient shadow beneath it, edges slightly luminous,
no border lines. This is a reusable glass panel for the app's floating bottom
navigation. No text, no icons, no pure black.
```

## 5. Global negative-prompt appendix (append to EVERY image prompt)

```
NEGATIVES: no pure black background, no neon, no purple/blue gradients, no
cyberpunk, no skeuomorphic gloss, no watermark, no visible border lines, no
black drop shadows, no lens flare, no HDR blowout, no text unless requested,
no extra fingers or distorted anatomy, no crowded composition, no clutter.
```
