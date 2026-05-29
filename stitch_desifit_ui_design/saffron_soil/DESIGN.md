# Design System Strategy: The Earthbound Editorial

## 1. Overview & Creative North Star: "The Modern Craftsman"
This design system moves away from the sterile, cookie-cutter "Material" look to embrace a philosophy we call **The Modern Craftsman**. It is a high-end, editorial interpretation of Indian heritage—blending the raw, tactile energy of terracotta and foliage with the precision of contemporary digital layouts. 

While we use Material Design 3 as our logical foundation, our visual execution is **Asymmetric & Layered**. We break the rigid grid by allowing imagery to bleed, using aggressive typography scales, and replacing structural lines with tonal depth. The result is a UI that feels "grown," not "built," optimized specifically for high legibility on budget Android devices without sacrificing a premium aesthetic.

---

## 2. Colors: Tonal Earth & Light
Our palette is rooted in the "Deep Saffron" of baked earth and the "Leaf Green" of monsoon flora.

### The "No-Line" Rule
**Lines are a failure of hierarchy.** Within this system, 1px solid borders are strictly prohibited for sectioning. Boundaries must be defined through background shifts. 
- A card (`surface-container-lowest`) should sit on a section of `surface-container-low`.
- A header should be defined by a shift from `surface` to `surface-bright`, never a divider line.

### Surface Hierarchy & Nesting
Treat the UI as a series of physical, stacked layers of hand-pressed paper.
- **Base Layer:** `surface` (#F9F9F9)
- **Secondary Sections:** `surface-container-low` (#F3F3F3)
- **Interactive Cards:** `surface-container-lowest` (#FFFFFF)

### The "Glass & Gradient" Rule
To inject "soul" into functional layouts:
- **CTAs:** Instead of a flat `primary`, use a subtle linear gradient from `primary` (#A43700) to `primary-container` (#CD4700) at a 135-degree angle. This adds a "fired clay" sheen.
- **Floating Navigation:** Use Glassmorphism. Apply `surface` at 80% opacity with a `24px` backdrop blur. This prevents the UI from feeling "heavy" on smaller screens.

---

## 3. Typography: The Editorial Voice
We utilize **Plus Jakarta Sans** for high-impact displays and **Inter** for bulletproof legibility. Given our focus on budget Android devices, we prioritize x-height and generous leading.

*   **Display (Plus Jakarta Sans):** Bold, expressive, and slightly tightened letter spacing (-2%). Use `display-lg` (3.5rem) for hero moments to create an "Editorial" feel.
*   **Headline (Plus Jakarta Sans):** Authoritative and energetic. Use `headline-md` (1.75rem) to anchor content blocks.
*   **Body (Inter):** Optimized for readability. Even on "budget" screens, we never go below `body-md` (0.875rem). 
*   **Cultural Resonance:** Use `title-lg` (1.375rem) in semi-bold for section headers to mimic the weight of traditional Indian broadsheets.

---

## 4. Elevation & Depth: Tonal Layering
We reject the "drop shadow" of 2014. Depth in this system is achieved through light and material density.

*   **The Layering Principle:** Softness is key. Place a `primary-fixed` element over a `surface-container-high` background to create a "lift" that feels organic.
*   **Ambient Shadows:** When an object must float (e.g., a FAB), use a multi-layered shadow:
    *   `box-shadow: 0 4px 20px rgba(164, 55, 0, 0.08), 0 8px 40px rgba(0, 0, 0, 0.04);`
    *   The shadow color must be a tint of `on-surface` or `primary`, never pure black.
*   **The Ghost Border:** If a container requires a boundary for accessibility, use `outline-variant` at **15% opacity**. It should be felt, not seen.

---

## 5. Components: Tactile & Functional

### Buttons (The Kinetic Element)
- **Primary:** Gradient fill (`primary` to `primary-container`), `xl` (1.5rem) roundedness. High contrast `on-primary` text.
- **Secondary:** Outlined with a "Ghost Border." No fill. High-energy `leaf-green` text.
- **Sizing:** Tap targets are a minimum of **56dp** to accommodate all user demographics and device qualities.

### Cards & Lists (The "No-Divider" Approach)
- **Cards:** Forbid the use of divider lines. Separate content using `16px` or `24px` of vertical white space.
- **Lists:** Use a subtle background shift on hover/touch (`surface-container-high`).
- **Nesting:** Place `surface-container-highest` elements inside a `surface-container-low` parent to highlight specific data points without adding visual clutter.

### Inputs (The Modern Form)
- Filled style using `surface-container-highest`. 
- The "active" state is indicated by a `2px` bottom-bar in `primary` saffron, rather than a full bounding box. This keeps the form feeling "open."

---

## 6. Do’s and Don’ts

### Do:
*   **Do** use intentional asymmetry. Align a headline to the left and a supporting image slightly offset to the right.
*   **Do** leverage the `secondary` Leaf Green (#2E7D32) for success states and "organic" growth metrics; it balances the heat of the Saffron.
*   **Do** use large, high-quality photography of textures (jute, clay, silk) as subtle background watermarks in hero sections.

### Don’t:
*   **Don’t** use 1px black or grey dividers. Use white space or tonal shifts.
*   **Don’t** use sharp corners. Our roundedness scale defaults to `0.5rem` to maintain an "earthy" softness.
*   **Don’t** crowd the interface. On budget devices, "clutter" equals "confusion." Increase padding by 20% compared to standard Material defaults.
*   **Don’t** use pure black (#000000). Use `on-surface` (#1A1C1C) to maintain the organic, high-end feel.