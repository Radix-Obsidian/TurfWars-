# PLAN.md – Turf Wars Beta
**Godot 4 | Single Player | Dark Gritty Cartoon Arcade**

---

## Goal of This Document
Give Codex (and any human) a clear, ordered plan to build a complete, fun, shippable beta APK without scope creep.

---

## Development Philosophy
1. **Vertical Slice First** – Make one complete fun loop before adding width.
2. **Battle > Idle** – Spend more time making combat feel great.
3. **Data-Driven** – Cards, territories, upgrades are Resources (.tres).
4. **Simple & Robust** – Prefer clear code over clever code.
5. **Match the Locked Art Style Exactly**.

---

## High-Level Phases

### Phase 0 – Project Foundation (Day 1)
- Create Godot 4 project with correct folder structure.
- Set up Autoloads: GameManager, SaveManager, AudioManager, EventBus.
- Basic scene switching.
- Import style reference images.
- Placeholder art pipeline.

### Phase 1 – Vertical Slice: Core Battle (Highest Priority)
Build a fully playable battle against a simple AI.
- Arena scene (2 lanes + river).
- Elixir system.
- 6–8 starter cards (mix of units + 1–2 spells).
- Unit spawning, movement, targeting, combat.
- Towers + HQ destruction win condition.
- Basic AI that plays cards.
- Juice: hit effects, screen shake, sound placeholders.
- Win/Lose screen that returns to map.

**Exit Criteria:** You can fight a full battle, win or lose, and it feels fun.

### Phase 2 – Campaign Map + Territory Claiming
- City map scene matching the locked mockup style.
- 6–9 territories in first region.
- Click territory → start battle.
- Win battle → claim territory (changes color, starts generating income).
- Simple player profile header (cash, REP, heat).

### Phase 3 – Idle Production Hub
- Idle scene with Grow / Process / Sell sections.
- Production rates modified by number + level of owned territories.
- Offline earnings calculation on load.
- Basic upgrades (speed, capacity, multipliers).
- Managers as simple multipliers (can be data-only at first).

### Phase 4 – Card Collection & Progression
- Collection screen.
- Card leveling (use common currency).
- Deck building (8 cards).
- Unlock new cards through campaign progress.

### Phase 5 – AI Variety + Content Expansion
- Multiple AI archetypes.
- 2–3 full regions.
- Boss territories with modified rules.
- More cards (aim for 20–25 total for beta).
- Heat system (optional light risk/reward).

### Phase 6 – Polish, Juice, Meta
- Full audio pass (even if placeholder then replace).
- Animation and VFX pass.
- UI polish and responsiveness.
- Balancing pass.
- Save/Load robustness.
- Android export + testing on real devices.
- Basic settings (music/sfx volume, etc.).

---

## Folder Structure (Mandatory)

```
res://
├── assets/
│   ├── art/
│   ├── audio/
│   └── fonts/
├── resources/
│   ├── cards/
│   ├── territories/
│   ├── upgrades/
│   └── ai_decks/
├── scenes/
│   ├── ui/
│   ├── battle/
│   ├── idle/
│   ├── campaign/
│   └── main/
├── scripts/
│   ├── autoload/
│   ├── battle/
│   ├── idle/
│   ├── campaign/
│   ├── data/
│   └── ui/
├── themes/
└── docs/          # These markdown files live here too
```

---

## Definition of Done for Beta
- Player can progress through at least 2 full regions.
- Battles are fun and reasonably balanced against AI.
- Idle income feels rewarding and is clearly linked to territories.
- Visual style is consistent with locked mockups.
- Game saves and loads correctly.
- Stable 60 FPS on mid-range Android devices.
- Can be exported as a working APK.
