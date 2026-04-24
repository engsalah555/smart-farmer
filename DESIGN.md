# Smart Farm 2: Pro Max Design System

This document outlines the design principles, color palettes, and architectural patterns used to deliver a premium, "Pro Max" experience in the Smart Farm 2 application.

## 1. Core Aesthetics
- **Style**: Modern Glassmorphism & Brutalist accents.
- **Typography**: `Outfit` or `Inter` for clean, professional readability.
- **Atmosphere**: Professional Agricultural Intelligence (Dark mode by default, high-contrast accents).

## 2. Color Palette (Pro Max)
| Category | Color Code | Purpose |
| :--- | :--- | :--- |
| **Primary** | `#2ECC71` | Growth, Vitality, Action buttons. |
| **Secondary** | `#3498DB` | Water, Irrigation, Connectivity. |
| **Background** | `#0F172A` | Deep Navy (Premium Dark Mode). |
| **Surface** | `#1E293B` | Card backgrounds, elevated surfaces. |
| **Accent** | `#F1C40F` | Warnings, Sunlight, NPK Balance. |
| **Glass** | `rgba(255, 255, 255, 0.05)` | Glassmorphism overlays. |

## 3. UI Components Architecture
To ensure high performance and maintainability (TDD-friendly):
- **Atomic Design**: 
    - `Atoms`: Buttons, Icons, Text Styles.
    - `Molecules`: Sensor Reading Cards, Navigation Items.
    - `Organisms`: Irrigation Dashboard, Marketplace Grid.
    - `Templates`: Base Page Layout with AppLifecycle management.
- **Deferred Loading**: Use `Skeleton Screens` (Shimmer) instead of generic loaders.
- **Micro-Animations**: Subtle transitions using `AnimateDo` or `Explicit Animations` for state changes.

## 4. Frontend Performance Strategy
- **Offline-First**:
    - Use `Hive` for caching sensor data and crop guides.
    - Sync strategy: Load from Hive first, then update from WebSocket/API.
- **WebSocket Management**:
    - Centralized `WebSocketService` with auto-reconnection and exponential backoff.
    - Stream-based updates to minimize widget rebuilds (using `Selector` or `StreamBuilder`).
- **Lifecycle Optimization**:
    - Pause non-critical syncs when the app is in the background.
    - Re-validate stale data immediately upon `resumed` state without blocking the UI thread.

## 5. Development Standards
- **DRY (Don't Repeat Yourself)**: Extract common UI patterns (Gradients, Card styles) into a `DesignSystem` utility class.
- **Type Safety**: Avoid using `dynamic` or magic strings for API keys and route names.
- **Accessibility**: Ensure WCAG 2.1 compliance for color contrast and touch target sizes.

---
*Created by Antigravity (Advanced Agentic Coding)*
