extends Node

## GameManager for Turf Wars
## Orchestrates overall game states, scene routing, and high-level progression.

const SCENE_MAIN_MENU: String = "res://scenes/main/main.tscn"
const SCENE_BATTLE: String = "res://scenes/battle/battle.tscn"
const SCENE_CAMPAIGN: String = "res://scenes/campaign/campaign.tscn"
const SCENE_IDLE: String = "res://scenes/idle/idle.tscn"
const SCENE_COLLECTION: String = "res://scenes/ui/collection.tscn"

var current_territory_id: String = ""

func _ready() -> void:
	EventBus.scene_change_requested.connect(change_scene)

func change_scene(scene_path: String) -> void:
	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("GameManager: Failed to switch scene to %s (Error code: %d)" % [scene_path, error])

func load_main_menu() -> void:
	change_scene(SCENE_MAIN_MENU)

func load_campaign() -> void:
	change_scene(SCENE_CAMPAIGN)

func load_idle() -> void:
	change_scene(SCENE_IDLE)

func load_collection() -> void:
	change_scene(SCENE_COLLECTION)

func load_battle(territory_id: String = "territory_01") -> void:
	current_territory_id = territory_id
	EventBus.battle_started.emit(territory_id)
	change_scene(SCENE_BATTLE)

# Economy Helpers
func get_cash() -> int:
	return int(SaveManager.get_value("cash", 0))

func add_cash(amount: int) -> void:
	var current := get_cash()
	var updated := current + amount
	SaveManager.set_value("cash", updated)
	EventBus.cash_changed.emit(updated, amount)

func spend_cash(amount: int) -> bool:
	var current := get_cash()
	if current < amount:
		return false
	var updated := current - amount
	SaveManager.set_value("cash", updated)
	EventBus.cash_changed.emit(updated, -amount)
	return true

func get_rep() -> int:
	return int(SaveManager.get_value("rep", 0))

func add_rep(amount: int) -> void:
	var current := get_rep()
	var updated := current + amount
	SaveManager.set_value("rep", updated)
	EventBus.rep_changed.emit(updated, amount)
