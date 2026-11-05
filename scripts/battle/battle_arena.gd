class_name BattleArena
extends Node2D

## Core Battle Arena Controller for Turf Wars
## Orchestrates 2-lane combat, elixir, cards, AI, towers, and win/loss flow.

signal match_ended(won: bool, crowns_player: int, crowns_enemy: int)

const ARENA_WIDTH: float = 720.0
const ARENA_HEIGHT: float = 1280.0
const RIVER_Y: float = 580.0

const LANE_LEFT_X: float = 200.0
const LANE_RIGHT_X: float = 520.0
const BRIDGE_Y: float = 580.0

@onready var camera: Camera2D = $Camera2D
@onready var units_container: Node2D = $UnitsContainer
@onready var projectiles_container: Node2D = $ProjectilesContainer
@onready var vfx_container: Node2D = $VFXContainer
@onready var towers_container: Node2D = $TowersContainer
@onready var ai_controller: BattleAI = $BattleAI

# UI references
@onready var label_timer: Label = %LabelTimer
@onready var label_elixir: Label = %LabelElixir
@onready var progress_elixir: ProgressBar = %ProgressElixir
@onready var label_crowns_player: Label = %LabelCrownsPlayer
@onready var label_crowns_enemy: Label = %LabelCrownsEnemy
@onready var banner_double_elixir: Control = %BannerDoubleElixir
@onready var panel_game_over: Control = %PanelGameOver
@onready var label_result_title: Label = %LabelResultTitle
@onready var label_result_subtitle: Label = %LabelResultSubtitle
@onready var card_slots_container: HBoxContainer = %CardSlotsContainer
@onready var slot_next_card: Button = %SlotNextCard

# Towers
var tower_player_left: Tower
var tower_player_right: Tower
var tower_player_hq: Tower
var tower_enemy_left: Tower
var tower_enemy_right: Tower
var tower_enemy_hq: Tower

# Match State
var match_timer: float = 180.0 # 3 minutes
var is_double_elixir: bool = false
var is_match_active: bool = false
var crowns_player: int = 0
var crowns_enemy: int = 0

# Player Elixir & Cards
var player_elixir: float = 5.0
const MAX_ELIXIR: float = 10.0
const BASE_ELIXIR_RATE: float = 1.0 / 2.8 # 1 elixir every 2.8s

var player_deck: Array[CardData] = []
var player_draw_pile: Array[CardData] = []
var player_hand: Array[CardData] = [] # Exactly 4 cards
var player_next_card: CardData = null
var selected_card_idx: int = -1

# Camera Shake
var camera_trauma: float = 0.0
var camera_base_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	_init_towers()
	_init_deck()
	_init_ai()
	_start_match()

func _init_towers() -> void:
	# Spawn or locate towers
	tower_enemy_hq = _create_tower(Vector2(360, 160), Tower.Team.ENEMY, Tower.TowerType.HQ, Tower.Lane.CENTER)
	tower_enemy_left = _create_tower(Vector2(LANE_LEFT_X, 310), Tower.Team.ENEMY, Tower.TowerType.CROWN_TOWER, Tower.Lane.LEFT)
	tower_enemy_right = _create_tower(Vector2(LANE_RIGHT_X, 310), Tower.Team.ENEMY, Tower.TowerType.CROWN_TOWER, Tower.Lane.RIGHT)

	tower_player_left = _create_tower(Vector2(LANE_LEFT_X, 850), Tower.Team.PLAYER, Tower.TowerType.CROWN_TOWER, Tower.Lane.LEFT)
	tower_player_right = _create_tower(Vector2(LANE_RIGHT_X, 850), Tower.Team.PLAYER, Tower.TowerType.CROWN_TOWER, Tower.Lane.RIGHT)
	tower_player_hq = _create_tower(Vector2(360, 1000), Tower.Team.PLAYER, Tower.TowerType.HQ, Tower.Lane.CENTER)

func _create_tower(pos: Vector2, team: Tower.Team, type: Tower.TowerType, lane: Tower.Lane) -> Tower:
	var t := Tower.new()
	t.global_position = pos
	t.team = team
	t.tower_type = type
	t.lane = lane
	t.arena = self
	t.destroyed.connect(_on_tower_destroyed)
	towers_container.add_child(t)
	return t

func _init_deck() -> void:
	var deck_ids: Array = SaveManager.get_value("active_deck", [
		"street_runner", "brickwall", "chem_thrower", "enforcer",
		"lookout", "rooftop_racer", "molotov", "supply_drop"
	])

	player_deck.clear()
	for id_val in deck_ids:
		var c: CardData = load("res://resources/cards/%s.tres" % str(id_val))
		if c:
			player_deck.append(c)

	player_deck.shuffle()
	player_draw_pile = player_deck.duplicate()

	player_hand.clear()
	for i in range(4):
		if player_draw_pile.size() > 0:
			player_hand.append(player_draw_pile.pop_front())

	if player_draw_pile.is_empty():
		player_draw_pile = player_deck.duplicate()
		player_draw_pile.shuffle()

	if player_draw_pile.size() > 0:
		player_next_card = player_draw_pile.pop_front()

	_update_card_ui()

func _init_ai() -> void:
	ai_controller.setup(self)

func _start_match() -> void:
	is_match_active = true
	match_timer = 180.0
	player_elixir = 5.0
	panel_game_over.visible = false
	banner_double_elixir.visible = false
	AudioManager.play_sound("victory")

func _process(delta: float) -> void:
	_process_camera_shake(delta)

	if not is_match_active:
		return

	# Match Timer
	match_timer = maxf(0.0, match_timer - delta)
	var mins := int(match_timer) / 60
	var secs := int(match_timer) % 60
	label_timer.text = "%d:%02d" % [mins, secs]

	# Double Elixir in final 60 seconds
	if match_timer <= 60.0 and not is_double_elixir:
		is_double_elixir = true
		banner_double_elixir.visible = true
		AudioManager.play_sound("victory")
		add_screen_shake(0.3)
		# Fade banner after 2s
		get_tree().create_timer(2.0).timeout.connect(func(): if banner_double_elixir: banner_double_elixir.visible = false)

	# Elixir Accumulation
	var elixir_gain := BASE_ELIXIR_RATE * (2.0 if is_double_elixir else 1.0) * delta
	player_elixir = minf(MAX_ELIXIR, player_elixir + elixir_gain)
	_update_elixir_ui()

	# AI Update
	ai_controller.update_ai(delta, is_double_elixir)

	# Time Out Resolution
	if match_timer <= 0.0:
		_resolve_time_out()

func _update_elixir_ui() -> void:
	if progress_elixir:
		progress_elixir.value = player_elixir
	if label_elixir:
		label_elixir.text = "%d / 10" % int(player_elixir)

	# Update card afford status
	for i in range(card_slots_container.get_child_count()):
		var btn: Button = card_slots_container.get_child(i) as Button
		if i < player_hand.size():
			var card := player_hand[i]
			var can_afford := player_elixir >= float(card.elixir_cost)
			btn.disabled = not can_afford
			btn.modulate = Color.WHITE if can_afford else Color(0.6, 0.6, 0.6, 0.8)

func _update_card_ui() -> void:
	for i in range(card_slots_container.get_child_count()):
		var btn: Button = card_slots_container.get_child(i) as Button
		if i < player_hand.size():
			var card := player_hand[i]
			btn.visible = true
			btn.text = "%s\n[%d⚡]" % [card.display_name, card.elixir_cost]
			if i == selected_card_idx:
				btn.add_theme_color_override("font_color", Color(0.17, 0.91, 0.47))
			else:
				btn.remove_theme_color_override("font_color")
		else:
			btn.visible = false

	if slot_next_card and player_next_card:
		slot_next_card.text = "NEXT:\n%s [%d]" % [player_next_card.display_name, player_next_card.elixir_cost]

func _unhandled_input(event: InputEvent) -> void:
	if not is_match_active:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if selected_card_idx >= 0 and selected_card_idx < player_hand.size():
			var click_pos: Vector2 = event.position
			if _is_valid_player_deploy(click_pos):
				_play_player_card(selected_card_idx, click_pos)
				selected_card_idx = -1
				_update_card_ui()

func _is_valid_player_deploy(pos: Vector2) -> bool:
	# Outside arena bounds check
	if pos.x < 30.0 or pos.x > 690.0:
		return false
	if pos.y < 80.0 or pos.y > 1070.0:
		return false

	# Spells can be cast anywhere on the map!
	if selected_card_idx >= 0 and selected_card_idx < player_hand.size():
		var card := player_hand[selected_card_idx]
		if card.card_type == CardData.CardType.SPELL:
			return true

	# Units normal deploy zone: south of river
	if pos.y >= RIVER_Y:
		return true

	# Advanced deploy zone: if an enemy crown tower is destroyed, can deploy forward into that lane
	if tower_enemy_left.is_destroyed and pos.x < 360.0 and pos.y >= 380.0:
		return true
	if tower_enemy_right.is_destroyed and pos.x >= 360.0 and pos.y >= 380.0:
		return true

	return false

func _on_card_slot_pressed(idx: int) -> void:
	if idx < player_hand.size():
		var card := player_hand[idx]
		if player_elixir >= float(card.elixir_cost):
			selected_card_idx = idx if selected_card_idx != idx else -1
			AudioManager.play_sound("card_drop", 0.08)
			_update_card_ui()

func _play_player_card(hand_idx: int, deploy_pos: Vector2) -> void:
	var card := player_hand[hand_idx]
	player_elixir -= float(card.elixir_cost)
	AudioManager.play_sound("card_drop")

	_deploy_card(card, Unit.Team.PLAYER, deploy_pos)

	# Rotate hand
	player_hand.remove_at(hand_idx)
	if player_next_card:
		player_hand.append(player_next_card)
		if player_draw_pile.is_empty():
			player_draw_pile = player_deck.duplicate()
			player_draw_pile.shuffle()
		player_next_card = player_draw_pile.pop_front()

	_update_card_ui()
	_update_elixir_ui()

func ai_deploy_card(card: CardData, deploy_pos: Vector2) -> void:
	_deploy_card(card, Unit.Team.ENEMY, deploy_pos)

func _deploy_card(card: CardData, team: Unit.Team, pos: Vector2) -> void:
	var determined_lane: Unit.Lane = Unit.Lane.LEFT if pos.x < 360.0 else Unit.Lane.RIGHT

	if card.card_type == CardData.CardType.SPELL:
		_cast_spell(card, team, pos)
		return

	# Spawn Unit(s)
	for i in range(card.spawn_count):
		var offset := Vector2(randf_range(-18, 18), randf_range(-18, 18)) if card.spawn_count > 1 else Vector2.ZERO
		var unit_scene: Unit = Unit.new()
		unit_scene.global_position = pos + offset
		units_container.add_child(unit_scene)
		unit_scene.setup(self, card, team, determined_lane, 1)

func _cast_spell(card: CardData, team: Unit.Team, target_pos: Vector2) -> void:
	var radius := card.spell_radius
	var damage := card.get_spell_damage(1)
	AudioManager.play_sound("explosion")
	add_screen_shake(0.35)

	# Visual explosion ring
	var flash := Node2D.new()
	flash.global_position = target_pos
	vfx_container.add_child(flash)
	var spell_color: Color = card.accent_color
	flash.draw.connect(func():
		flash.draw_circle(Vector2.ZERO, radius, Color(spell_color.r, spell_color.g, spell_color.b, 0.45))
		flash.draw_arc(Vector2.ZERO, radius, 0, TAU, 32, spell_color, 3.0)
	)
	get_tree().create_timer(0.35).timeout.connect(flash.queue_free)

	# Damage enemy targets in radius
	var enemy_team: int = Unit.Team.ENEMY if team == Unit.Team.PLAYER else Unit.Team.PLAYER
	var enemies: Array = get_units(enemy_team)
	for u in enemies:
		if is_instance_valid(u) and not u.is_dead and target_pos.distance_to(u.global_position) <= radius:
			u.take_damage(damage)

	# Damage towers in radius
	var enemy_towers: Array = [tower_enemy_left, tower_enemy_right, tower_enemy_hq] if team == Unit.Team.PLAYER else [tower_player_left, tower_player_right, tower_player_hq]
	for t in enemy_towers:
		if is_instance_valid(t) and not t.is_destroyed and target_pos.distance_to(t.global_position) <= radius:
			t.take_damage(int(damage * 0.7)) # Spells deal 70% damage to towers

	# If spell has spawn_unit_id, spawn friendly reinforcement
	if card.spawn_unit_id != "":
		var sub_card: CardData = load("res://resources/cards/%s.tres" % card.spawn_unit_id)
		if sub_card:
			_deploy_card(sub_card, team, target_pos)

	# Heal friendly units in radius if healing spell (Supply Drop)
	if card.id == "supply_drop":
		var friendlies: Array = get_units(team)
		for f in friendlies:
			if is_instance_valid(f) and not f.is_dead and target_pos.distance_to(f.global_position) <= radius:
				f.heal(damage)

func spawn_projectile(start_pos: Vector2, target: Node2D, dmg: int, team: int, col: Color, is_splash: bool = false, splash_radius: float = 0.0) -> void:
	var proj := Projectile.new()
	projectiles_container.add_child(proj)
	proj.setup(self, start_pos, target, dmg, team, col, is_splash, splash_radius)

func apply_projectile_damage(proj: Projectile, hit_pos: Vector2, target: Node2D, dmg: int, team: int, is_splash: bool, splash_rad: float) -> void:
	if is_splash:
		var enemy_team: int = Unit.Team.ENEMY if team == Unit.Team.PLAYER else Unit.Team.PLAYER
		var enemies: Array = get_units(enemy_team)
		for u in enemies:
			if is_instance_valid(u) and not u.is_dead and hit_pos.distance_to(u.global_position) <= splash_rad:
				u.take_damage(dmg)
	else:
		if is_instance_valid(target) and target.has_method("take_damage"):
			target.take_damage(dmg)

func spawn_floating_text(txt: String, pos: Vector2, col: Color) -> void:
	var ft := FloatingText.new()
	vfx_container.add_child(ft)
	ft.setup(txt, pos, col)

func add_screen_shake(amount: float) -> void:
	camera_trauma = minf(1.0, camera_trauma + amount)

func _process_camera_shake(delta: float) -> void:
	if not camera:
		return
	if camera_trauma > 0.0:
		camera_trauma = maxf(0.0, camera_trauma - delta * 1.5)
		var shake := camera_trauma * camera_trauma * 16.0
		camera.offset = Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
	else:
		camera.offset = Vector2.ZERO

func play_sfx_name(sfx_name: String) -> void:
	AudioManager.play_sound(sfx_name)

# Query Helpers for Units & AI
func get_units(team: int) -> Array:
	var result: Array = []
	for child in units_container.get_children():
		if child is Unit and child.team == team and not child.is_dead:
			result.append(child)
	return result

func get_target_tower(unit_team: Unit.Team, unit_lane: Unit.Lane) -> Tower:
	if unit_team == Unit.Team.PLAYER:
		# Attack enemy towers
		if unit_lane == Unit.Lane.LEFT:
			if not tower_enemy_left.is_destroyed:
				return tower_enemy_left
		else:
			if not tower_enemy_right.is_destroyed:
				return tower_enemy_right
		return tower_enemy_hq
	else:
		# Attack player towers
		if unit_lane == Unit.Lane.LEFT:
			if not tower_player_left.is_destroyed:
				return tower_player_left
		else:
			if not tower_player_right.is_destroyed:
				return tower_player_right
		return tower_player_hq

func get_bridge_position(lane: Unit.Lane) -> Vector2:
	var x: float = LANE_LEFT_X if lane == Unit.Lane.LEFT else LANE_RIGHT_X
	return Vector2(x, BRIDGE_Y)

func _on_tower_destroyed(tower: Tower) -> void:
	if tower.team == Tower.Team.ENEMY:
		crowns_player += 1
		label_crowns_player.text = "CROWNS: %d" % crowns_player
		if tower.tower_type == Tower.TowerType.HQ:
			crowns_player = 3
			_end_match(true)
			return
		# Activate Enemy HQ
		tower_enemy_hq.is_active = true
	else:
		crowns_enemy += 1
		label_crowns_enemy.text = "CROWNS: %d" % crowns_enemy
		if tower.tower_type == Tower.TowerType.HQ:
			crowns_enemy = 3
			_end_match(false)
			return
		# Activate Player HQ
		tower_player_hq.is_active = true

func _resolve_time_out() -> void:
	if crowns_player > crowns_enemy:
		_end_match(true)
	elif crowns_enemy > crowns_player:
		_end_match(false)
	else:
		# Compare HQ HP
		var p_hp := tower_player_hq.current_hp
		var e_hp := tower_enemy_hq.current_hp
		_end_match(p_hp >= e_hp)

func _end_match(player_won: bool) -> void:
	is_match_active = false
	panel_game_over.visible = true

	if player_won:
		label_result_title.text = "VICTORY!"
		label_result_title.add_theme_color_override("font_color", Color(0.17, 0.91, 0.47))
		label_result_subtitle.text = "TERRITORY CLAIMED!\n+$250 CASH  +25 REP"
		GameManager.add_cash(250)
		GameManager.add_rep(25)
		SaveManager.save_game()
		AudioManager.play_sound("victory")
	else:
		label_result_title.text = "DEFEAT"
		label_result_title.add_theme_color_override("font_color", Color(1, 0.22, 0.35))
		label_result_subtitle.text = "RETREAT AND REGROUP\n+$50 PITY CASH"
		GameManager.add_cash(50)
		SaveManager.save_game()
		AudioManager.play_sound("defeat")

	EventBus.battle_ended.emit(player_won, GameManager.current_territory_id)
	match_ended.emit(player_won, crowns_player, crowns_enemy)

func _on_rematch_pressed() -> void:
	GameManager.load_battle(GameManager.current_territory_id)

func _on_return_pressed() -> void:
	GameManager.load_campaign()
