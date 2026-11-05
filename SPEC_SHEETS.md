# SPEC_SHEETS.md – Detailed Systems Spec
**Turf Wars Beta**

---

## 1. Card Spec Template

Every card is a Resource (`CardData.tres`).

**Required Fields:**
- id: String
- display_name: String
- description: String
- card_type: Enum (Unit, Spell, Building)
- elixir_cost: int (1–9)
- rarity: Enum (Common, Rare, Epic, Legendary)
- sprite / portrait
- level_stats: Array of stats per level (HP, Damage, DPS, Speed, etc.)
- target_type
- movement_type (Ground, Air, None)
- special_ability (optional description + parameters)
- unlock_condition

**Starter Cards (Minimum for Vertical Slice):**
1. Street Runner (cheap, fast unit)
2. Brickwall (tank)
3. Chem Thrower (ranged / splash)
4. Lookout (support / reveal or buff)
5. Rooftop Racer (air or jumping unit)
6. Molotov / Street Poison (spell)
7. Supply Drop (spell – spawn or heal)
8. Enforcer (medium all-rounder)

---

## 2. Unit Runtime Spec

When a card is played:
- Spawn unit at lane position
- Assign team (player / enemy)
- Set stats from CardData at current level
- Enter state machine: Move → Attack → Die

**Basic States:**
- Moving
- Attacking
- Idle (if no target)
- Dying

**Combat:**
- Simple damage = Attack Damage
- Attack Speed from data
- Range check
- Death removes from lane and plays VFX

---

## 3. Elixir System

- Starts at 5
- Regenerates 1 elixir every X seconds (faster in double elixir)
- Max 10
- Visual bar + number
- Cannot play card if not enough elixir

---

## 4. Territory Spec

Resource: `TerritoryData.tres`

- id
- display_name
- region
- base_income_per_hour
- position_on_map
- unlock_rep_required
- difficulty_rating
- ai_deck_id
- bonuses_when_owned (multipliers, etc.)
- visual state (neutral / player / enemy)

---

## 5. Idle Production Spec

**Three Lanes of Production:**
1. Grow → produces "Raw"
2. Process → converts Raw → "Product"
3. Sell → converts Product → Cash

Each has:
- Level
- Base rate
- Multipliers from territories + managers + upgrades

**Offline Calculation:**
```
time_away = min(current_time - last_save_time, MAX_OFFLINE_SECONDS)
earnings = calculate_production_over_time(time_away)
```

---

## 6. Save System Spec

Save file contains:
- Player cash, REP, heat, level
- Owned territories + their levels
- Card collection + levels + current deck
- Idle production levels + managers
- Last save timestamp
- Campaign progress flags

Use Godot’s `FileAccess` + JSON or binary Resource saver. Keep it simple and robust.

---

## 7. AI Spec (Beta)

AI has:
- Deck (8 cards)
- Elixir (same rules as player)
- Decision loop every 0.5–1.0 second:
  - Evaluate current board state
  - Choose best card + lane according to archetype weights
  - Play if affordable and sensible

Start with rule-based, add simple scoring later if needed.

---

## 8. Heat System (Light Version)

- Heat increases when winning battles or high activity
- High heat can:
  - Make next AI harder
  - Temporarily reduce income
  - Trigger special “raid” events (future)
- Player can reduce heat by waiting or spending cash

Can be simplified or even delayed to post-vertical-slice if needed.
