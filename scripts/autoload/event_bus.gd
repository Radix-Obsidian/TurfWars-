extends Node

## Central Event Bus for Turf Wars
## Handles global decoupled signal communication across systems.

signal scene_change_requested(scene_path: String)
signal save_requested
signal save_completed(success: bool)
signal save_loaded(success: bool)

# Economy & Progression signals
signal cash_changed(new_amount: int, delta: int)
signal rep_changed(new_amount: int, delta: int)
signal heat_changed(new_amount: int, delta: int)

# Battle lifecycle signals
signal battle_started(territory_id: String)
signal battle_ended(won: bool, territory_id: String)

# Territory & Empire signals
signal territory_claimed(territory_id: String)
signal idle_collected(amount: int)
