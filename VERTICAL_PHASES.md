# VERTICAL_PHASES.md – Development Process
**Strict Phase Gate Approach**

---

## Rules
- Do not start the next phase until the current phase exit criteria are met.
- Each phase must leave the game in a playable state.
- Prefer polishing the current vertical slice over adding new features early.

---

### Phase 0 – Foundation
**Deliverables:**
- Correct folder structure
- Autoloads working
- Main menu → placeholder scenes navigation
- Basic SaveManager (can save/load a test value)
- Project settings for Android export ready

**Exit Criteria:** Project opens cleanly, can switch between empty scenes, exports a blank APK.

---

### Phase 1 – Battle Vertical Slice (Most Important)
**Deliverables:**
- Fully playable arena
- 6–8 cards implemented
- Elixir system
- Unit movement, combat, death
- Towers + HQ
- Win/Lose conditions
- Simple AI opponent
- Basic juice (hit flash, death effect, screen shake)
- Return to map (even if map is placeholder)

**Exit Criteria:**  
You can play 5 battles in a row against AI, win and lose, and it feels fun and responsive. No game-breaking bugs.

---

### Phase 2 – Map + Claiming
**Deliverables:**
- Campaign map scene matching style
- At least 6 territories
- Selecting territory starts battle with correct AI difficulty
- Winning claims the territory (visual + data)
- Claimed territories show income

**Exit Criteria:** Full loop of Map → Battle → Claim → back to Map works.

---

### Phase 3 – Idle Hub
**Deliverables:**
- Idle scene
- Production rates affected by owned territories
- Offline earnings popup
- Basic upgrades

**Exit Criteria:** Owning more territories clearly makes idle income higher. Offline progress works.

---

### Phase 4 – Collection & Deck Building
**Deliverables:**
- Collection screen
- Card leveling
- Deck editor (select 8 cards)
- New cards unlock through progression

**Exit Criteria:** Player can upgrade cards and change deck, and it affects battles.

---

### Phase 5 – Content & AI Expansion
**Deliverables:**
- 2–3 regions
- 20+ cards
- Multiple AI archetypes
- Boss fights
- Reputation gates

**Exit Criteria:** There is enough content for 1–2 hours of meaningful progression.

---

### Phase 6 – Polish & Ship
**Deliverables:**
- Full audio
- VFX and animation pass
- Balancing
- Bug fixing
- Final Android APK
- Basic settings screen

**Exit Criteria:** Game feels complete and fun as a beta. Ready for external testers.
