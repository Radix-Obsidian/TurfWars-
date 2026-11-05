class_name BattleAI
extends Node

## AI Opponent for Turf Wars Battle Vertical Slice

var arena: Node = null
var elixir: float = 5.0
var max_elixir: float = 10.0
var elixir_rate: float = 1.0 / 2.8 # 1 elixir every 2.8s
var decision_timer: float = 1.0

var deck: Array[CardData] = []
var hand: Array[CardData] = []
var draw_pile: Array[CardData] = []

func setup(p_arena: Node) -> void:
	arena = p_arena
	_load_deck()

func _load_deck() -> void:
	var card_ids := [
		"street_runner", "brickwall", "chem_thrower", "enforcer",
		"lookout", "rooftop_racer", "molotov", "supply_drop"
	]
	deck.clear()
	for cid in card_ids:
		var c: CardData = load("res://resources/cards/%s.tres" % cid)
		if c:
			deck.append(c)

	deck.shuffle()
	draw_pile = deck.duplicate()
	hand.clear()
	for i in range(4):
		if draw_pile.size() > 0:
			hand.append(draw_pile.pop_front())

func update_ai(delta: float, is_double_elixir: bool) -> void:
	var rate := elixir_rate * (2.0 if is_double_elixir else 1.0)
	elixir = minf(max_elixir, elixir + rate * delta)

	decision_timer -= delta
	if decision_timer <= 0.0:
		_make_decision()
		decision_timer = randf_range(1.2, 2.2)

func _make_decision() -> void:
	if not arena or hand.is_empty():
		return

	# Scan for threats in lanes
	var player_units: Array = arena.get_units(Unit.Team.PLAYER)
	var left_threat: int = 0
	var right_threat: int = 0
	var highest_cluster_pos := Vector2.ZERO
	var highest_cluster_count := 0

	for u in player_units:
		if is_instance_valid(u) and not u.is_dead:
			if u.global_position.x < 360:
				left_threat += 1
			else:
				right_threat += 1

	# Check for Molotov opportunity (if 2+ player units are clustered)
	var molotov_idx := _find_card_in_hand("molotov")
	if molotov_idx != -1 and hand[molotov_idx].elixir_cost <= elixir:
		for u in player_units:
			if is_instance_valid(u) and not u.is_dead and u.global_position.y < arena.RIVER_Y + 100.0:
				var count := 0
				for other in player_units:
					if is_instance_valid(other) and u.global_position.distance_to(other.global_position) < 90.0:
						count += 1
				if count > highest_cluster_count:
					highest_cluster_count = count
					highest_cluster_pos = u.global_position

		if highest_cluster_count >= 2:
			_play_card(molotov_idx, highest_cluster_pos)
			return

	# Defense: If a lane is threatened, play counter near enemy lane tower
	if left_threat > 0 or right_threat > 0:
		var target_lane: int = Unit.Lane.LEFT if left_threat >= right_threat else Unit.Lane.RIGHT
		var playable_idx := _get_affordable_card_index()
		if playable_idx != -1:
			var deploy_x: float = 200.0 if target_lane == Unit.Lane.LEFT else 520.0
			var deploy_y: float = randf_range(320.0, 420.0)
			_play_card(playable_idx, Vector2(deploy_x, deploy_y))
			return

	# Offense: If elixir is high (>= 6), launch push
	if elixir >= 6.0:
		var push_lane: int = Unit.Lane.LEFT if randf() > 0.5 else Unit.Lane.RIGHT
		var deploy_x: float = 200.0 if push_lane == Unit.Lane.LEFT else 520.0
		var deploy_y: float = randf_range(340.0, 440.0)
		var playable_idx := _get_affordable_card_index()
		if playable_idx != -1:
			_play_card(playable_idx, Vector2(deploy_x, deploy_y))

func _find_card_in_hand(card_id: String) -> int:
	for i in range(hand.size()):
		if hand[i].id == card_id:
			return i
	return -1

func _get_affordable_card_index() -> int:
	var affordable: Array[int] = []
	for i in range(hand.size()):
		if hand[i].elixir_cost <= elixir:
			affordable.append(i)
	if affordable.is_empty():
		return -1
	return affordable.pick_random()

func _play_card(hand_idx: int, deploy_pos: Vector2) -> void:
	var card := hand[hand_idx]
	elixir -= float(card.elixir_cost)

	# Deploy to arena
	if arena and arena.has_method("ai_deploy_card"):
		arena.ai_deploy_card(card, deploy_pos)

	# Hand rotation
	hand.remove_at(hand_idx)
	if draw_pile.is_empty():
		draw_pile = deck.duplicate()
		draw_pile.shuffle()
	hand.append(draw_pile.pop_front())
