---
name: Smart Farmer 2
description: Aerospace-grade agricultural intelligence interface.
colors:
  primary: "#69A14B"
  primary-action: "#2ECC71"
  neutral-bg: "#FDFDFC"
  neutral-dark-bg: "#0F1410"
  neutral-surface: "#19201B"
  text-primary: "#1A1D1A"
  text-mint: "#E8F2E9"
  status-success: "#2E9B5C"
  status-error: "#DC4545"
typography:
  display:
    fontFamily: "Cairo, sans-serif"
    fontSize: "32px"
    fontWeight: 900
    lineHeight: 1.2
  headline:
    fontFamily: "Cairo, sans-serif"
    fontSize: "24px"
    fontWeight: 700
    lineHeight: 1.3
  body:
    fontFamily: "Outfit, sans-serif"
    fontSize: "16px"
    fontWeight: 400
    lineHeight: 1.6
  label:
    fontFamily: "Outfit, sans-serif"
    fontSize: "14px"
    fontWeight: 600
    lineHeight: 1.4
    letterSpacing: "0.5px"
rounded:
  sm: "10px"
  md: "16px"
  lg: "32px"
  xl: "48px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "48px"
components:
  control-tile:
    backgroundColor: "{colors.neutral-surface}"
    rounded: "{rounded.md}"
    padding: "12px 16px"
  instrument-module:
    backgroundColor: "{colors.neutral-dark-bg}"
    rounded: "{rounded.lg}"
    padding: "24px"
  precision-button:
    rounded: "14px"
    size: "44px"
---

# Design System: Smart Farmer 2

## 1. Overview

**Creative North Star: "The Aerospace Greenhouse Control"**

Smart Farmer 2 is a high-precision agricultural intelligence platform. The interface is designed to feel like a modern aerospace control system—crisp, deliberate, and high-density—rather than a traditional "farm log." It prioritizes real-time sensor data and expert-level tooling over decorative imagery or pastoral clichés.

The aesthetic communicates professional competence through "Tech-forward precision." Surfaces are information-dense but organized with a clear hierarchy that respects the user's intelligence and time.

**Key Characteristics:**
- **Expert Instrumentation**: Elements feel like physical control modules or instrumentation readouts.
- **Tonal Layering**: Depth is conveyed through subtle color shifts rather than heavy shadows.
- **Precision Typography**: Multi-script support (Arabic/English) with a clear scale contrast.
- **Dark-First Doctrine**: Optimized for high-glare environments (greenhouses) and early/late field checks.

## 2. Colors

The palette is a "Committed" strategy where a vibrant action emerald carries the focus against a deep, rich forest-neutral background.

### Primary
- **Precision Emerald** (#69A14B): The brand anchor. Used for secondary actions and branding.
- **Action Green** (#2ECC71): The "Action" color in dark mode. High visibility for primary CTAs and status-normal signals.

### Neutral
- **Void Forest** (#0F1410): The core dark mode background. A deep, rich neutral tinted with the brand green to prevent "dead gray" or pure black.
- **Minty Sage** (#E8F2E9): The primary dark mode text color. Softened to reduce eye strain compared to pure white.
- **Ivory Seed** (#FDFDFC): The light mode background. A warm, tinted neutral.

### Named Rules
**The One Action Rule.** The vibrant Action Green (#2ECC71) is reserved for high-intent interactive elements and "Normal" sensor states. It never appears in background decoration.

## 3. Typography

**Display Font:** Cairo (900) - For bold, impactful headings.
**Body Font:** Outfit (400) - For technical readouts and long-form data.
**Label/Data Font:** Outfit (600/900) - For precise numeric values and instrumentation labels.

### Hierarchy
- **Display** (900, 32px, 1.2): Section headers and primary screen titles.
- **Headline** (700, 24px, 1.3): Major feature headings.
- **Title** (600, 18px, 1.4): Card titles and section headers.
- **Body** (400, 16px, 1.6): Descriptions and secondary data.
- **Label** (600/900, 14px, 1.4, 0.5px): Instrumentation labels, button text, and timestamps.

## 4. Elevation

The system uses tonal layering and subtle, structural shadows to convey depth.

### Shadow Vocabulary
- **Ambient Struct** (0 10px 30px rgba(0,0,0,0.2)): Used on primary feature cards to lift them from the background.
- **Low Depth** (0 4px 12px rgba(0,0,0,0.1)): Used on interactive tiles to provide a subtle "tactile" hover response.

### Named Rules
**The Tonal Layering Rule.** Depth is primarily communicated through background tint shifts (e.g., card background vs. surface background) rather than stack-based shadows. Shadows are reserved for floating actions or primary containment units.

## 5. Components

Components are designed to feel like "Tactile Instrumentation"—fast, responsive, and durable.

### Buttons
- **Shape:** Rounded Square (14px) or Circular.
- **Precision Button:** 44px base size with 18-20px icon. Always includes a 1px defined border and high-end ripple feedback.
- **Primary CTA:** Rounded (30px radius), high-contrast background with scale-up micro-interactions.

### Tiles & Readouts
- **Control Tile (PlantInfoGridTile):** 16px radius. Uses `symmetric(8, 12)` padding to remain robust under varying font scales. Displays label (11px) over value (13px).
- **Instrument Module (PremiumSectionWrapper):** 32px to 48px radius. A high-level container that groups related data readouts into a single logical "module."

### Cards
- **Corner Style:** 32px radius.
- **Background:** Rich tinted neutrals (AppColors.darkCard / AppColors.cardLight).
- **Border:** Subtle defined stroke (1px) in a slightly lighter/darker neutral tint.

## 6. Do's and Don'ts

### Do:
- **Do** use OKLCH-derived opacity tokens (`context.opacityMedium`) for all transparency.
- **Do** tint every neutral toward the brand emerald (chroma 0.005–0.01).
- **Do** use `Semantics(header: true)` for all section headers.

### Don't:
- **Don't** use pure `#000` or pure `#FFF`.
- **Don't** use rustic or pastoral imagery (barns, cartoon farmers, clichéd vegetables).
- **Don't** use side-stripe borders (border-left/right > 1px as an accent).
- **Don't** use glassmorphism as a default decoration; use it only for floating overlays.
