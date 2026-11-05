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

# Gems
func get_gems() -> int:
	return int(SaveManager.get_value("gems", 1250))

func add_gems(amount: int) -> void:
	var current := get_gems()
	var updated := current + amount
	SaveManager.set_value("gems", updated)
	EventBus.gems_changed.emit(updated, amount)

func spend_gems(amount: int) -> bool:
	var current := get_gems()
	if current < amount:
		return false
	var updated := current - amount
	SaveManager.set_value("gems", updated)
	EventBus.gems_changed.emit(updated, -amount)
	return true

# Product & Raw Stock
func get_product() -> int:
	return int(SaveManager.get_value("product", 342))

func add_product(amount: int) -> void:
	var current := get_product()
	var updated := current + amount
	SaveManager.set_value("product", updated)
	EventBus.product_changed.emit(updated, amount)

func spend_product(amount: int) -> bool:
	var current := get_product()
	if current < amount:
		return false
	var updated := current - amount
	SaveManager.set_value("product", updated)
	EventBus.product_changed.emit(updated, -amount)
	return true

func get_raw_herb() -> int:
	return int(SaveManager.get_value("raw_herb", 78))

func add_raw_herb(amount: int) -> void:
	var current := get_raw_herb()
	var max_cap := get_facility_level("grow_capacity_max", 100)
	var updated: int = mini(current + amount, max_cap)
	var delta := updated - current
	SaveManager.set_value("raw_herb", updated)
	EventBus.raw_herb_changed.emit(updated, delta)

func spend_raw_herb(amount: int) -> bool:
	var current := get_raw_herb()
	if current < amount:
		return false
	var updated := current - amount
	SaveManager.set_value("raw_herb", updated)
	EventBus.raw_herb_changed.emit(updated, -amount)
	return true

# Facility Upgrades
func get_facility_level(key: String, default_val: int = 1) -> int:
	var levels: Dictionary = SaveManager.get_value("facility_levels", {})
	return int(levels.get(key, default_val))

func set_facility_level(key: String, level: int) -> void:
	var levels: Dictionary = SaveManager.get_value("facility_levels", {})
	levels[key] = level
	SaveManager.set_value("facility_levels", levels)
	EventBus.facility_upgraded.emit(key, level)

func upgrade_facility(key: String, cost: int, cost_type: String = "cash") -> bool:
	if cost_type == "cash":
		if not spend_cash(cost):
			return false
	elif cost_type == "gems":
		if not spend_gems(cost):
			return false

	var cur_lvl := get_facility_level(key, 1)
	set_facility_level(key, cur_lvl + 1)
	SaveManager.save_game()
	return true

# Production & Hourly Income Calculations
func calculate_hourly_income() -> int:
	var owned_ids: Array = SaveManager.get_value("owned_territories", ["the_yard", "the_lockup"])
	var territory_payouts := {
		"the_yard": 1250,
		"the_lockup": 975,
		"the_pit": 1500,
		"no_mans_block": 0,
		"old_market": 0,
		"red_dragon": 1800,
		"the_east_crew": 1600
	}

	var base_territory_rate := 0
	for tid in owned_ids:
		if territory_payouts.has(tid):
			base_territory_rate += territory_payouts[tid]
		else:
			# Fallback for dynamic territory resources
			var res_path := "res://resources/territories/%s.tres" % tid
			if ResourceLoader.exists(res_path):
				var t: TerritoryData = load(res_path)
				if t:
					base_territory_rate += t.base_income_per_hour

	if base_territory_rate == 0:
		base_territory_rate = 500 # minimum baseline production

	var lights_lvl := get_facility_level("better_lights", 8)
	var trimmer_lvl := get_facility_level("auto_trimmer", 6)
	var boost_lvl := get_facility_level("sales_boost", 5)

	# Multipliers: +5% per light lvl, +4% per trimmer lvl, +6% per boost lvl
	var multiplier := 1.0 + (lights_lvl * 0.04) + (trimmer_lvl * 0.03) + (boost_lvl * 0.05)
	var total_rate := int(round(base_territory_rate * multiplier))
	return maxi(total_rate, 100)

func calculate_offline_earnings(time_away_seconds: float) -> Dictionary:
	var max_offline := 12.0 * 3600.0 # 12 hours cap
	var capped_time := clampf(time_away_seconds, 0.0, max_offline)
	var hourly_rate := calculate_hourly_income()
	var manager_mult: float = float(SaveManager.get_value("manager_bonus", 2.0))
	var base_cash := int(round((float(hourly_rate) / 3600.0) * capped_time))
	var total_cash := int(round(base_cash * manager_mult))

	return {
		"cash": total_cash,
		"time_away": capped_time,
		"hourly_rate": hourly_rate,
		"manager_bonus": manager_mult
	}

func claim_offline_earnings(amount: int) -> void:
	if amount > 0:
		add_cash(amount)
		EventBus.idle_collected.emit(amount)
	SaveManager.data["last_save_time"] = Time.get_unix_time_from_system()
	SaveManager.save_game()
