extends Node

func _ready() -> void:
	print("--- BEGIN PHASE 0 AUTOMATED VERIFICATION ---")

	# Test 1: Verify Autoloads exist
	assert(EventBus != null, "EventBus autoload missing")
	assert(SaveManager != null, "SaveManager autoload missing")
	assert(GameManager != null, "GameManager autoload missing")
	assert(AudioManager != null, "AudioManager autoload missing")
	print("✔ Test 1: All 4 Autoloads verified")

	# Test 2: Verify SaveManager save and load test value
	var test_code := "Phase0_Verification_" + str(int(Time.get_unix_time_from_system()))
	SaveManager.set_value("test_value", test_code)
	var save_res := SaveManager.save_game()
	assert(save_res == true, "SaveManager failed to write save")

	SaveManager.set_value("test_value", "overwritten_temporary")
	var load_res := SaveManager.load_game()
	assert(load_res == true, "SaveManager failed to read save")
	var loaded_val = SaveManager.get_value("test_value")
	assert(loaded_val == test_code, "Loaded test value did not match expected value")
	print("✔ Test 2: SaveManager save & load test passed. Value: " + loaded_val)

	# Test 3: Economy helpers
	var start_cash := GameManager.get_cash()
	GameManager.add_cash(250)
	assert(GameManager.get_cash() == start_cash + 250, "Cash addition failed")
	var spent := GameManager.spend_cash(100)
	assert(spent == true, "Cash spend failed")
	assert(GameManager.get_cash() == start_cash + 150, "Cash balance mismatch")
	print("✔ Test 3: GameManager economy logic verified (Cash: " + str(GameManager.get_cash()) + ")")

	# Test 4: Verify Resource loading
	var runner_card: CardData = load("res://resources/cards/street_runner.tres")
	assert(runner_card != null, "Failed to load street_runner.tres")
	assert(runner_card.id == "street_runner", "Card ID mismatch")
	assert(runner_card.get_hp(1) == 180, "Card HP calculation mismatch")
	assert(runner_card.get_hp(2) == 198, "Card HP growth mismatch")

	var terr: TerritoryData = load("res://resources/territories/block_01.tres")
	assert(terr != null, "Failed to load block_01.tres")
	assert(terr.id == "block_01", "Territory ID mismatch")
	print("✔ Test 4: CardData and TerritoryData resources verified")

	# Test 5: Verify all scenes load cleanly
	var scenes_to_check := [
		"res://scenes/main/main.tscn",
		"res://scenes/battle/battle.tscn",
		"res://scenes/campaign/campaign.tscn",
		"res://scenes/idle/idle.tscn",
		"res://scenes/ui/collection.tscn"
	]
	for sc_path in scenes_to_check:
		var scene_res = load(sc_path)
		assert(scene_res != null, "Failed to load scene: " + sc_path)
		var instance = scene_res.instantiate()
		assert(instance != null, "Failed to instantiate scene: " + sc_path)
		instance.queue_free()
	print("✔ Test 5: All 5 core scenes instantiated cleanly")

	print("--- ALL PHASE 0 VERIFICATION TESTS PASSED ---")
	get_tree().quit(0)
