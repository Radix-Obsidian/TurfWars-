extends Node

## SaveManager for Turf Wars
## Handles local persistence of player data, economy, territories, and cards.

const SAVE_PATH: String = "user://turf_wars_save.json"

var data: Dictionary = {}

func _ready() -> void:
	if not load_game():
		_initialize_default_data()

func _initialize_default_data() -> void:
	data = {
		"version": 1,
		"test_value": "Phase 3 Verified",
		"cash": 248735,
		"gems": 1250,
		"product": 342,
		"raw_herb": 78,
		"rep": 3250,
		"heat": 75,
		"owned_territories": ["the_yard", "the_lockup"],
		"facility_levels": {
			"grow_capacity": 78,
			"grow_capacity_max": 100,
			"drying_rack_level": 12,
			"processing_pct": 64.0,
			"daily_sales_progress": 89,
			"daily_sales_max": 100,
			"better_lights": 8,
			"auto_trimmer": 6,
			"security": 7,
			"sales_boost": 5
		},
		"manager_bonus": 2.0,
		"active_deck": [
			"street_runner", "brickwall", "chem_thrower", "enforcer",
			"lookout", "rooftop_racer", "molotov", "supply_drop"
		],
		"unlocked_cards": [
			"street_runner", "brickwall", "chem_thrower", "enforcer",
			"lookout", "rooftop_racer", "molotov", "supply_drop"
		],
		"card_levels": {
			"street_runner": 1,
			"brickwall": 1,
			"chem_thrower": 1,
			"enforcer": 1,
			"lookout": 1,
			"rooftop_racer": 1,
			"molotov": 1,
			"supply_drop": 1
		},
		"last_save_time": Time.get_unix_time_from_system()
	}

func save_game() -> bool:
	data["last_save_time"] = Time.get_unix_time_from_system()
	var json_string := JSON.stringify(data, "\t")
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: Failed to open save file for writing: %s" % error_string(FileAccess.get_open_error()))
		EventBus.save_completed.emit(false)
		return false

	file.store_string(json_string)
	file.close()
	EventBus.save_completed.emit(true)
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: Failed to open save file for reading: %s" % error_string(FileAccess.get_open_error()))
		EventBus.save_loaded.emit(false)
		return false

	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(content)
	if error != OK:
		push_error("SaveManager: JSON parse error in save file: %s" % json.get_error_message())
		EventBus.save_loaded.emit(false)
		return false

	if json.data is Dictionary:
		data = json.data
		var starter_cards: Array = [
			"street_runner", "brickwall", "chem_thrower", "enforcer",
			"lookout", "rooftop_racer", "molotov", "supply_drop"
		]
		var cur_deck: Array = data.get("active_deck", [])
		for cid in starter_cards:
			if not cur_deck.has(cid):
				cur_deck.append(cid)
		data["active_deck"] = cur_deck

		if not data.has("gems"):
			data["gems"] = 1250
		if not data.has("product"):
			data["product"] = 342
		if not data.has("raw_herb"):
			data["raw_herb"] = 78
		if not data.has("manager_bonus"):
			data["manager_bonus"] = 2.0
		if not data.has("facility_levels") or not (data["facility_levels"] is Dictionary):
			data["facility_levels"] = {
				"grow_capacity": 78,
				"grow_capacity_max": 100,
				"drying_rack_level": 12,
				"processing_pct": 64.0,
				"daily_sales_progress": 89,
				"daily_sales_max": 100,
				"better_lights": 8,
				"auto_trimmer": 6,
				"security": 7,
				"sales_boost": 5
			}
		if not data.has("owned_territories") or (data["owned_territories"] as Array).is_empty():
			data["owned_territories"] = ["the_yard", "the_lockup"]

		EventBus.save_loaded.emit(true)
		return true

	EventBus.save_loaded.emit(false)
	return false

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func reset_save() -> void:
	_initialize_default_data()
	save_game()

func get_value(key: String, default_value: Variant = null) -> Variant:
	return data.get(key, default_value)

func set_value(key: String, value: Variant) -> void:
	data[key] = value
