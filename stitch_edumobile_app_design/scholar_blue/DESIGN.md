# Design System Document

## 1. Overview & Creative North Star: "The Intellectual Sanctuary"
This design system moves beyond the "standard app" aesthetic to create **The Intellectual Sanctuary**. In an era of loud, distracting educational tools, this system prioritizes cognitive ease through a high-end editorial lens. We reject the "boxy" nature of traditional Material Design in favor of **Organic Asymmetry** and **Tonal Depth**. 

The goal is to make the user feel they are entering a premium gallery of knowledge rather than a database. We achieve this by using aggressive whitespace, "floating" layers of glass, and a typography scale that favors dramatic contrast between massive displays and hyper-legible body text.

---

## 2. Colors: Tonal Sophistication
Our palette is anchored in deep, authoritative blues and a spectrum of nuanced neutrals. We do not use "colors" as decoration; we use them as functional signposts.

### Core Palette
*   **Primary (#002c98):** Used exclusively for high-intent actions. It represents the "Path of Progress."
*   **Primary Container (#1a43bf):** A softer variant for secondary hero moments or progress fills.
*   **Surface (#f8f9fa):** Our canvas. It is a warm, clean white that prevents eye strain during long study sessions.
*   **Tertiary (#6c1e00):** Reserved for "Momentum" moments—deep orange accents for streaks, achievements, or urgent notifications.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to section content. Boundaries must be defined through background color shifts or tonal transitions. 
*   *Example:* A `surface-container-low` section sitting on a `surface` background provides all the separation the eye needs without the "visual noise" of a line.

### The "Glass & Gradient" Rule
To elevate the experience, use **Glassmorphism** for persistent floating elements (like Bottom Nav or FABs). 
*   **Formula:** `surface-container-lowest` + 70% Opacity + 20px Backdrop Blur.
*   **Signature Textures:** Apply a subtle linear gradient (from `primary` to `primary-container`) on large CTA buttons to provide a "tactile sheen" that flat colors lack.

---

## 3. Typography: The Editorial Voice
We utilize a pairing of **Manrope** (Display/Headline) for its geometric, modern authority and **Inter** (Body/Label) for its world-class legibility.

*   **Display (Manrope, 3.5rem - 2.25rem):** Use for "Welcome" headers or milestone numbers. These should feel like magazine headlines.
*   **Headline (Manrope, 2rem - 1.5rem):** Used for course titles and module names.
*   **Body (Inter, 1rem - 0.75rem):** High-line-height (1.6) for educational content to ensure the brain can process information without fatigue.
*   **Label (Inter, 0.75rem - 0.68rem):** Uppercase with 5-10% letter spacing for metadata or small "Chip" text.

---

## 4. Elevation & Depth: Tonal Layering
Traditional drop shadows are a fallback, not a standard. We create hierarchy through **The Layering Principle**.

### Layering Hierarchy
*   **Level 0 (Base):** `surface`
*   **Level 1 (Sections):** `surface-container-low`
*   **Level 2 (Active Cards):** `surface-container-lowest` (The "Pure White" lift)
*   **Level 3 (Pop-overs):** `surface-bright`

### Ambient Shadows
When a card must "float" (e.g., a featured course card), use an **Ambient Shadow**:
*   **Shadow Color:** 6% Opacity of `on-surface` (#191c1d).
*   **Blur:** 24px - 32px.
*   **Spread:** -4px (to keep the shadow "tucked" under the element).

### The "Ghost Border" Fallback
If contrast is required (e.g., in Dark Mode or high-glare environments), use a **Ghost Border**: `outline-variant` at 15% opacity. Never 100%.

---

## 5. Components: Intentional Primitives

### Cards & Lists
*   **Rule:** Forbid divider lines. 
*   **Implementation:** Use `surface-container-low` cards with a `xl` (1.5rem) corner radius. Separate list items with 16px of vertical whitespace.
*   **Education Context:** Progress cards should use a `primary` to `primary-container` gradient fill for the progress bar to denote "energy."

### Buttons & FABs
*   **Primary Button:** `xl` roundedness. High-contrast `on-primary` text. No shadow.
*   **Floating Action Button (FAB):** Use `surface-container-highest` with a 40% backdrop blur. It should feel like a piece of polished sea glass floating over the content.
*   **Chips:** Use `surface-container-high` for unselected and `primary` for selected. Padding: 12px horizontal, 8px vertical.

### Input Fields
*   **Style:** Minimalist "Soft-Inset." 
*   **States:** Default state uses `surface-container-highest` background. Active state transitions to a `primary` Ghost Border (20% opacity).

### Specialized App Components
*   **The "Focus Ring":** A circular progress indicator for lesson completion. Use a `surface-variant` track and a `primary` stroke with a "glow" effect (soft primary shadow).
*   **Bottom Navigation:** Non-traditional. Instead of a full-width bar, use a "Dock" style—a floating container with `xl` radius and 80% opacity `surface-container-lowest`.

---

## 6. Do's and Don'ts

### Do
*   **Do** use asymmetrical layouts (e.g., a headline aligned left with a 40px margin, while the body text has a 60px margin).
*   **Do** use `display-lg` typography for single-word emotional hooks.
*   **Do** rely on the `surface-container` tiers to guide the eye.

### Don't
*   **Don't** use a 1px line to separate "Lessons" in a list. Use a background shift.
*   **Don't** use pure black (#000000) for text. Use `on-surface` (#191c1d) to maintain the premium, soft-touch feel.
*   **Don't** use standard Material 2 ripples. Use a soft "scale-down" (98%) transform on press for a more tactile, bespoke interaction.