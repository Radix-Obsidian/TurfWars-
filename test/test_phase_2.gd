extends Node

## Automated Test Suite for Phase 2 – Campaign Map & Territory Claiming
## Validates 6+ territory resources, map rendering, selection, battle launching, and claiming loop.

func check(condition: bool, msg: String) -> void:
	if not condition:
		printerr("TEST FAILED: ", msg)
		get_tree().quit(1)
		push_error(msg)

func _ready() -> void:
	print("--- BEGIN PHASE 2 AUTOMATED VERIFICATION ---")

	# Test 1: Verify 7 Territory Resources
	var territory_ids := [
		"the_yard", "red_dragon", "the_lockup", "no_mans_block",
		"the_pit", "the_east_crew", "old_market"
	]
	for tid in territory_ids:
		var t: TerritoryData = load("res://resources/territories/%s.tres" % tid)
		check(t != null, "Missing territory resource: " + tid)
		check(t.base_income_per_hour > 0, "Territory %s has invalid income" % tid)
		check(t.map_position != Vector2.ZERO, "Territory %s missing map position" % tid)
	print("✔ Test 1: All 7 territory resources verified")

	# Test 2: Instantiating Campaign Scene
	var campaign_scene_res: PackedScene = load("res://scenes/campaign/campaign.tscn")
	check(campaign_scene_res != null, "Failed to load campaign.tscn")
	var campaign: Node = campaign_scene_res.instantiate()
	add_child(campaign)
	check(campaign != null, "CampaignScene instance null")
	check(campaign.territories.size() >= 6, "Must have at least 6 territories loaded")
	print("✔ Test 2: Campaign scene and map view instantiated cleanly with %d territories" % campaign.territories.size())

	# Test 3: Territory Selection & Intel Updates
	campaign._check_territory_click(Vector2(180, 680)) # Coordinates of the_east_crew
	check(campaign.selected_territory_id == "the_east_crew", "Failed to select the_east_crew")
	check(campaign.btn_attack_territory.text.contains("THE EAST CREW"), "Attack button failed to update text")
	print("✔ Test 3: Territory selection and attack button intel verified")

	# Test 4: Battle Claiming Loop (Map -> Battle Win -> Claim -> Map)
	SaveManager.set_value("owned_territories", ["the_yard", "the_lockup"])
	campaign.owned_territory_ids = ["the_yard", "the_lockup"]
	campaign._setup_map()
	check(not campaign.owned_territory_ids.has("the_east_crew"), "the_east_crew should not be owned initially")

	# Simulate battle victory on the_east_crew
	campaign._on_battle_ended(true, "the_east_crew")
	check(campaign.owned_territory_ids.has("the_east_crew"), "the_east_crew failed to claim after battle victory")

	# Verify persistence in SaveManager
	var saved_owned: Array = SaveManager.get_value("owned_territories", [])
	check(saved_owned.has("the_east_crew"), "Claimed territory failed to persist in SaveManager")
	print("✔ Test 4: Full battle win -> claim -> persistence loop verified")

	# Clean up scene
	campaign.queue_free()

	print("--- ALL PHASE 2 VERIFICATION TESTS PASSED ---")
	get_tree().quit(0)
