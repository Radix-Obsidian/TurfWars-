# AGENT.md – Instructions for Codex / AI Coding Agent
**Project: Turf Wars (Godot 4 Beta)**

---

## Your Role
You are the lead developer building the Turf Wars beta in Godot 4.  
You must follow the documents in this folder strictly.

**Primary Documents (in order of authority):**
1. ANTI_DRIFT.md (highest priority – never violate)
2. PRD.md
3. DESIGN.md
4. PLAN.md
5. VERTICAL_PHASES.md
6. SPEC_SHEETS.md

---

## Core Directives

### 1. Art & Feel
- Match the locked visual style exactly (dark gritty cartoon, thick outlines, neon, dirty saturated colors).
- When creating UI or requesting art, always reference the style.
- Prioritize readable, juicy, arcade feel in battle.

### 2. Architecture Rules
- Use Godot 4 best practices.
- Prefer Composition and Resources over deep inheritance.
- All game data (cards, territories, upgrades) must be `.tres` Resources.
- Keep scripts focused and short. One major responsibility per script.
- Use Autoloads only for true globals: GameManager, SaveManager, AudioManager, EventBus.
- Signal-based communication preferred over direct references when crossing systems.

### 3. Development Order
You must follow the phase order in VERTICAL_PHASES.md.  
Do not implement later-phase features until the current phase exit criteria are met.

Current focus should always be stated at the start of your work.

### 4. Code Quality
- Clear naming (no abbreviations unless extremely common).
- Comments only where intent is not obvious.
- No premature optimization.
- No unused code or placeholder systems that aren’t needed yet.
- Every feature must be testable in-game quickly.

### 5. When You Are Unsure
- Default to the simplest solution that satisfies the current phase.
- Ask for clarification rather than inventing large new systems.
- Never expand scope.

### 6. Output Expectations
When generating code:
- Provide complete, working scripts/scenes when possible.
- Explain which phase and which files you are touching.
- After major changes, suggest how to test it in the editor.

### 7. Godot Specifics
- Target Godot 4.2+ (or whatever stable 4.x is available).
- Use CharacterBody2D / Area2D as appropriate for units.
- Use TileMap or simple Node2D layout for arena (keep it simple).
- Control nodes for all UI.
- Theme system for consistent UI styling.

---

## Starting Prompt Template (Use this when beginning work)

```
We are building Turf Wars beta in Godot 4.
Current Phase: [Phase Number and Name]
Relevant docs: PRD, DESIGN, PLAN, VERTICAL_PHASES, SPEC_SHEETS, ANTI_DRIFT.

Task: [Clear specific task]

Follow all rules in AGENT.md and ANTI_DRIFT.md strictly.
```

---

## Success Definition for You
A successful contribution moves the current phase closer to its exit criteria without violating anti-drift rules or the locked art direction.
