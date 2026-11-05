# ANTI_DRIFT.md – Non-Negotiable Rules
**Highest Authority Document**

This file exists to prevent the project from slowly turning into something else.  
Any AI agent or human developer must obey these rules.

---

## 1. Scope Lock
- Beta is **single-player only**. No multiplayer networking code.
- No real-money shop implementation (stub UI is acceptable).
- No complex narrative, dialogue trees, or cutscene systems.
- No base-building beyond the existing Idle Hub.
- No new major systems not listed in PRD/PLAN without explicit human approval.

## 2. Art Direction Lock (CRITICAL)
- The visual style is permanently locked to the four reference images in the `art_references/` folder.
- Those images are the single source of truth.
- The style is: Dark, rainy, neon-gritty cartoon with thick black outlines, dirty saturated colors, adult street-crew energy.
- **FORBIDDEN**: cute, childish, bright, soft, clean, colorful kids-game look, anime-cute, chibi, or anything that feels light-hearted.
- Do not clean it up. Do not brighten it. Do not make characters friendlier.
- Every new visual must pass the test: “Does this look like it belongs next to the four reference images?” If no, reject it.

## 3. Architecture Lock
- Stay on Godot 4. Do not suggest migrating to Unity, Unreal, or web-only.
- Do not introduce heavy external frameworks or plugins unless absolutely required for a core feature and approved.
- Keep the stack minimal.

## 4. Phase Discipline
- Never start implementing features from a future phase while the current phase exit criteria are unmet.
- If asked to do something that violates phase order, refuse and explain why.

## 5. Complexity Creep
- Prefer simple, readable solutions.
- Do not build elaborate generic frameworks “for the future”.
- Do not add configuration options, debug tools, or abstraction layers that are not needed for the current phase.

## 6. Data vs Hardcoding
- Game content (cards, territories, balances) must be data-driven (Resources).
- Do not hardcode large tables of stats inside scripts.

## 7. When in Doubt
- Choose the option that keeps the project closer to the original vision and closer to a shippable beta.
- Ask the human instead of inventing.

---

**Violation of this document is considered project failure.**
