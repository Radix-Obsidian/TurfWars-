# Product Requirements Document (PRD)
## Project Codename: Turf Wars
**Version:** 1.0 (Beta Spec)  
**Date:** November 2026  
**Status:** Locked for Beta Development  
**Engine:** Godot 4  
**Target Platform:** Android (APK) first, iOS later  

---

### 1. Vision
Build a single-player hybrid game that combines the addictive progression of an idle tycoon (Weed Inc style) with real-time lane-based card battles (Clash Royale style).  

The player runs a street crew, claims city blocks through battles, and turns those territories into automated income generators. Battles feel arcade-juicy and skillful. Idle progression feels satisfying and meaningful because it is directly powered by battle victories.

**Tone & Art Direction (Non-Negotiable):**  
Dark, rainy, neon-gritty cartoon with thick black outlines, dirty saturated purples/greens/reds, exaggerated street-crew characters, and strong arcade juice. Every screen must match the locked POC mockups.

---

### 2. Core Pillars
1. **Battle is King** – Real-time lane combat must feel excellent.
2. **Idle with Meaning** – Every territory you own makes your empire stronger.
3. **Strong Single-Player AI** – Campaign opponents must be challenging and varied.
4. **Tight Hybrid Loop** – Win battles → claim territory → better idle income → stronger cards → harder battles.
5. **Mobile First & Simple Stack** – Godot 4 only. No unnecessary complexity for beta.

---

### 3. Target Audience
- Fans of Clash Royale, Brawl Stars, idle tycoons, and street/gang aesthetic games.
- Players who enjoy short skillful battles mixed with long-term progression.
- Mobile-first players (Android priority).

---

### 4. Scope for Beta (MVP)
**In Scope:**
- Single-player campaign with 3–4 regions and 12–18 territories.
- Core real-time battle system (2 lanes, elixir, 8-card decks, towers + HQ).
- Strong rule-based + simple behavior-tree AI opponents.
- Idle production system linked to owned territories.
- Offline earnings.
- Card collection, leveling, and basic upgrades.
- Simple prestige / reputation system.
- Full visual style matching the locked mockups.
- Local save system.
- Android APK export.

**Out of Scope for Beta:**
- Multiplayer / PvP
- Real money shop / IAP (can be stubbed)
- Complex live-ops events
- Advanced analytics
- Multiple languages
- Cloud save
- Complex narrative / cutscenes

---

### 5. Success Metrics for Beta
- Player can complete a full 20–40 minute session loop: battle → claim territory → upgrade idle → fight stronger AI.
- Battle feels responsive and fun (target 60 FPS on mid-range Android).
- Offline progress works correctly.
- Visual style is consistent across all screens.
- No critical bugs that block progression.
- Clear sense of power growth.

---

### 6. Key Systems Overview
- **Campaign Map** – City view with claimable territories.
- **Battle Arena** – Clash-style real-time combat.
- **Idle Hub** – Production, processing, sales, managers.
- **Card / Crew Collection** – Units and spells.
- **Economy** – Cash, Reputation (REP), Heat.
- **Progression** – Card levels, territory upgrades, player level / reputation ranks.
- **AI** – Multiple archetypes (Aggressive, Control, Swarm, Turtle, Boss).

---

### 7. Risks & Mitigations
| Risk | Mitigation |
|------|----------|
| Battle feels bad | Vertical slice battle first and polish heavily |
| Idle feels disconnected | Force strong mechanical link (territory → production multiplier) |
| Scope creep | Strict phase-based development + anti-drift rules |
| Art inconsistency | Locked style guide + reference images |
| Performance | Profile early on real devices |

---

### 8. Timeline Philosophy
Vertical slice first → expand systems → content → polish.  
Ship a fun, complete beta loop rather than a half-finished large game.
