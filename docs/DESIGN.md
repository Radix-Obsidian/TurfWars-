# DESIGN.md – Turf Wars
**Visual + Game Design Specification**

---

## 1. Art Direction (LOCKED – ABSOLUTE SOURCE OF TRUTH)

**THIS IS THE MOST IMPORTANT SECTION.**

The game **must** look exactly like the four reference images located in:

`art_references/`

- `01_campaign_map.jpg`
- `02_idle_hub.jpg`
- `03_battle_arena.jpg`
- `04_collection_screen.jpg`

These images are the **final visual target**. Any deviation into cute, childish, bright, clean, or cartoony-in-a-kids-game way is a critical failure.

**Style Keywords:** Dark gritty cartoon, neon-noir, thick black outlines, dirty saturated colors, arcade energy, exaggerated street characters, rainy night atmosphere, grunge, underground crew aesthetic.

**Color Palette (Core):**
- Deep blacks and dark grays for backgrounds
- Toxic / neon green (player controlled territories & UI)
- Blood / warning red (enemy)
- Electric purple / magenta (special, elixir, neon lights)
- Dirty yellow / gold for currency
- Muted dirty blues and oranges for accents

**Character Style:**
- Chunky, readable silhouettes
- Exaggerated proportions
- Streetwear + tactical / gang gear mix
- Strong, slightly menacing personality in every unit
- NOT cute. NOT childish. NOT soft.

**UI Style:**
- Heavy black outlines
- Slight grunge / dirt / wear
- Clear hierarchy
- Big readable numbers
- Satisfying arcade button feedback
- Dark panels with neon accents

**Mandatory Rule:**  
Before creating or approving any visual (UI, character, environment, card, effect), compare it directly against the four reference images in `art_references/`. If it does not feel like it belongs in the same game as those images, reject it.

---

## 2. Core Game Loop

1. Look at Campaign Map
2. Choose a territory to attack
3. Fight real-time battle (3 minutes max)
4. Win → Claim territory
5. Territory starts generating idle income + bonuses
6. Spend income to upgrade cards, production, and unlock new areas
7. Repeat with stronger opposition

**Secondary Loop:** Collect offline earnings → upgrade → push further.

---

## 3. Battle Design

**Arena:**
- Vertical view
- Two lanes
- Center "river" (neon barrier / no-man’s land)
- Player side: 2 towers + 1 HQ
- Enemy side: 2 towers + 1 HQ
- Bridges or crossing points

**Resource:** Elixir (0–10), regenerates over time. Double elixir in final minute.

**Deck:** Exactly 8 cards. 4 visible at a time + next card preview.

**Win Conditions:**
- Destroy enemy HQ
- Or have more HQ HP when timer hits 0 (overtime possible)

**Card Types:**
- Units (ground / air)
- Spells (damage, buff, debuff, spawn)
- Buildings / Traps (limited)

**Targeting Rules (Simplified for Beta):**
- Units walk toward nearest valid target in lane
- Prefer enemy units → towers → HQ
- Some units can change lanes or have special targeting

---

## 4. Idle / Empire Design

**Three Main Sections:**
1. Grow Room – Produces raw product
2. Processing – Turns raw into sellable
3. Street Sales – Converts into cash

**Key Link to Battles:**
Every owned territory gives:
- Flat cash per hour
- Production speed multiplier
- Possible unique bonuses (cheaper upgrades, better card drops, reduced heat, etc.)

**Managers:** Simple multiplier characters that can be assigned (data-driven).

**Offline Progress:** Calculate time away (capped, e.g. 8–12 hours) and give earnings on return.

---

## 5. Progression Systems

- **Player Reputation (REP):** Increases through wins. Unlocks new regions and higher tier cards.
- **Card Levels:** Upgrade with common currency + card copies.
- **Territory Levels:** Upgrade individual blocks for better income.
- **Heat:** Optional risk system. High heat can trigger harder AI or temporary penalties. Can be reduced by laying low or paying.

---

## 6. AI Design (Beta)

Multiple archetypes:
- **Aggressive** – Fills lanes early, high pressure
- **Control** – Defends well, punishes overextend
- **Swarm** – Many cheap units
- **Turtle** – Heavy defense + big spells
- **Boss** – Modified rules, higher stats, unique cards

AI should feel smart enough that winning feels earned.

---

## 7. Economy (Soft)

**Currencies:**
- Cash (main)
- Reputation (progress)
- Card copies / dust (upgrades)
- Premium currency (stub only for beta)

Keep numbers juicy but readable. Use abbreviations (K, M) when needed.

---

## 8. Non-Goals for Design
- Deep story or dialogue
- Complex base building
- Real-time multiplayer
- Trading / social features
- Extremely deep card crafting
