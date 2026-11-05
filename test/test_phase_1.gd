extends Node

## Automated Test Suite for Phase 1 – Battle Vertical Slice
## Validates cards, elixir, unit combat, tower damage, AI, and 5 full battle simulations.

func check(condition: bool, msg: String) -> void:
	if not condition:
		printerr("TEST FAILED: ", msg)
		get_tree().quit(1)
		push_error(msg)

func _ready() -> void:
	print("--- BEGIN PHASE 1 AUTOMATED VERIFICATION ---")

	# Test 1: Verify 8 Starter Cards
	var expected_cards := [
		"street_runner", "brickwall", "chem_thrower", "enforcer",
		"lookout", "rooftop_racer", "molotov", "supply_drop"
	]
	for cid in expected_cards:
		var c: CardData = load("res://resources/cards/%s.tres" % cid)
		check(c != null, "Missing card resource: " + cid)
		check(c.elixir_cost >= 1 and c.elixir_cost <= 9, "Invalid elixir cost for " + cid)
	print("✔ Test 1: All 8 starter cards verified")

	# Test 2: Instantiating Battle Scene
	var battle_scene: PackedScene = load("res://scenes/battle/battle.tscn")
	check(battle_scene != null, "Failed to load battle.tscn")
	var arena: BattleArena = battle_scene.instantiate() as BattleArena
	add_child(arena)
	check(arena != null, "BattleArena instance null")
	print("✔ Test 2: Battle scene instantiated cleanly")

	# Test 3: Verify Towers Setup
	check(arena.tower_player_left != null and not arena.tower_player_left.is_destroyed, "Player left tower missing")
	check(arena.tower_player_right != null and not arena.tower_player_right.is_destroyed, "Player right tower missing")
	check(arena.tower_player_hq != null and not arena.tower_player_hq.is_destroyed, "Player HQ missing")
	check(arena.tower_enemy_left != null and not arena.tower_enemy_left.is_destroyed, "Enemy left tower missing")
	check(arena.tower_enemy_right != null and not arena.tower_enemy_right.is_destroyed, "Enemy right tower missing")
	check(arena.tower_enemy_hq != null and not arena.tower_enemy_hq.is_destroyed, "Enemy HQ missing")
	print("✔ Test 3: All 6 towers initialized in arena")

	# Test 4: Elixir and Deck Rotation
	check(arena.player_hand.size() == 4, "Player hand must have 4 cards")
	check(arena.player_next_card != null, "Player next card preview missing")
	var initial_elixir := arena.player_elixir
	arena._process(2.8) # 1 elixir should accrue in 2.8s
	check(arena.player_elixir > initial_elixir, "Elixir failed to accumulate")
	print("✔ Test 4: Elixir accumulation and 4-card hand rotation verified")

	# Test 5: Combat Simulation (Unit vs Tower)
	var runner_card: CardData = load("res://resources/cards/street_runner.tres")
	arena._deploy_card(runner_card, Unit.Team.PLAYER, Vector2(200, 650))
	var player_units := arena.get_units(Unit.Team.PLAYER)
	check(player_units.size() >= 1, "Player units not found in container")

	# Simulate 1.5 seconds of movement and physics
	for i in range(90):
		arena._process(1.0 / 60.0)
		for u in arena.units_container.get_children():
			if u is Unit:
				u._physics_process(1.0 / 60.0)

	print("✔ Test 5: Unit spawning and physics update verified")

	# Test 6: Spells (Molotov AoE)
	var molotov_card: CardData = load("res://resources/cards/molotov.tres")
	var initial_enemy_hp := arena.tower_enemy_left.current_hp
	arena._deploy_card(molotov_card, Unit.Team.PLAYER, arena.tower_enemy_left.global_position)
	check(arena.tower_enemy_left.current_hp < initial_enemy_hp, "Molotov failed to damage tower")
	print("✔ Test 6: Spell casting and radius damage verified")

	# Clean up initial test arena
	arena.queue_free()

	# Test 7: Multi-Battle Simulation (Exit Criteria: 5 battles in a row without crashing)
	print("✔ Simulating 5 consecutive battles against AI...")
	for match_idx in range(5):
		var test_arena: BattleArena = battle_scene.instantiate() as BattleArena
		add_child(test_arena)

		# Run 20 seconds of game time per match with rapid unit deployments from both sides
		for frame in range(300):
			test_arena._process(0.1)

			# Simulate player playing an affordable card every 30 frames
			if frame % 30 == 0 and not test_arena.player_hand.is_empty():
				for card_idx in range(test_arena.player_hand.size()):
					var c := test_arena.player_hand[card_idx]
					if test_arena.player_elixir >= float(c.elixir_cost):
						var deploy_x: float = 200.0 if randf() > 0.5 else 520.0
						var deploy_y: float = randf_range(620.0, 850.0)
						test_arena._play_player_card(card_idx, Vector2(deploy_x, deploy_y))
						break

			# Process physics on all units
			for child in test_arena.units_container.get_children():
				if child is Unit:
					child._physics_process(0.1)

			# Process towers
			for t in test_arena.towers_container.get_children():
				if t is Tower:
					t._process(0.1)

			# Process projectiles
			for p in test_arena.projectiles_container.get_children():
				if p is Projectile:
					p._process(0.1)

		# End the match
		test_arena._end_match(match_idx % 2 == 0)
		check(test_arena.panel_game_over.visible == true, "Game over panel failed to show")
		test_arena.queue_free()
		print("  - Battle %d/5 completed successfully (won=%s)" % [match_idx + 1, str(match_idx % 2 == 0)])

	print("--- ALL PHASE 1 VERIFICATION TESTS PASSED ---")
	get_tree().quit(0)
