class_name Unit
extends CharacterBody2D

## Battle Unit for Turf Wars
## Handles lane movement, targeting, combat states, and arcade rendering.

signal died(unit: Unit)

enum Team { PLAYER = 0, ENEMY = 1 }
enum State { MOVING, ATTACKING, DYING }
enum Lane { LEFT = 0, RIGHT = 1 }

var team: Team = Team.PLAYER
var lane: Lane = Lane.LEFT
var state: State = State.MOVING
var card_data: CardData = null
var unit_level: int = 1

var max_hp: int = 250
var current_hp: int = 250
var attack_damage: int = 40
var attack_interval: float = 1.0
var attack_range: float = 45.0
var move_speed: float = 75.0
var is_splash: bool = false
var splash_radius: float = 60.0
var is_air: bool = false

var attack_timer: float = 0.0
var hit_flash_timer: float = 0.0
var death_timer: float = 0.0
var is_dead: bool = false
var target_entity: Node2D = null
var arena: Node = null

# Visual animation variables
var walk_anim_time: float = 0.0
var attack_anim_weight: float = 0.0

func setup(p_arena: Node, p_card: CardData, p_team: Team, p_lane: Lane, p_level: int = 1) -> void:
	arena = p_arena
	card_data = p_card
	team = p_team
	lane = p_lane
	unit_level = p_level

	if card_data:
		max_hp = card_data.get_hp(unit_level)
		current_hp = max_hp
		attack_damage = card_data.get_damage(unit_level)
		attack_interval = card_data.attack_interval
		attack_range = card_data.attack_range
		move_speed = card_data.move_speed
		is_splash = card_data.is_splash
		splash_radius = card_data.splash_radius
		is_air = (card_data.movement_type == CardData.MovementType.AIR)
	else:
		current_hp = max_hp

func _ready() -> void:
	# Add collision
	var col := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	col.shape = circle
	add_child(col)

func _physics_process(delta: float) -> void:
	if is_dead:
		death_timer += delta
		if death_timer >= 0.25:
			queue_free()
		else:
			queue_redraw()
		return

	if hit_flash_timer > 0.0:
		hit_flash_timer -= delta
		queue_redraw()

	match state:
		State.MOVING:
			_process_moving(delta)
		State.ATTACKING:
			_process_attacking(delta)

	queue_redraw()

func _process_moving(delta: float) -> void:
	walk_anim_time += delta * (move_speed / 50.0)
	_acquire_target()

	if is_instance_valid(target_entity) and _is_in_range(target_entity):
		state = State.ATTACKING
		attack_timer = 0.15 # Quick initial swing
		velocity = Vector2.ZERO
		return

	# Determine destination waypoint
	var dest: Vector2 = _get_navigation_waypoint()
	var dir := (dest - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()

func _process_attacking(delta: float) -> void:
	if not is_instance_valid(target_entity) or target_entity.get("is_dead") or target_entity.get("is_destroyed"):
		target_entity = null
		state = State.MOVING
		return

	if not _is_in_range(target_entity):
		state = State.MOVING
		return

	attack_timer -= delta
	if attack_timer <= 0.0:
		_execute_attack()
		attack_timer = attack_interval

func _is_in_range(target: Node2D) -> bool:
	if not is_instance_valid(target):
		return false
	var dist := global_position.distance_to(target.global_position)
	return dist <= (attack_range + 15.0)

func _acquire_target() -> void:
	if not arena:
		return

	# 1. Scan for nearby enemy units within aggro range (140px)
	var enemy_team: int = Team.ENEMY if team == Team.PLAYER else Team.PLAYER
	var enemy_units: Array = arena.get_units(enemy_team)
	var closest_unit: Node2D = null
	var min_unit_dist: float = 140.0

	for u in enemy_units:
		if is_instance_valid(u) and not u.is_dead:
			# If unit cannot hit air, skip air enemies
			if u.is_air and card_data and card_data.target_type == CardData.TargetType.NEAREST_GROUND:
				continue
			var d := global_position.distance_to(u.global_position)
			if d < min_unit_dist:
				min_unit_dist = d
				closest_unit = u

	if closest_unit:
		target_entity = closest_unit
		return

	# 2. Otherwise target the active lane tower or HQ
	target_entity = arena.get_target_tower(team, lane)

func _get_navigation_waypoint() -> Vector2:
	if is_instance_valid(target_entity):
		# Ground units must cross through lane bridge if on the wrong side of the river
		if not is_air and arena:
			var river_y: float = arena.RIVER_Y
			var is_crossing_river := false

			if team == Team.PLAYER and global_position.y > river_y and target_entity.global_position.y < river_y:
				is_crossing_river = true
			elif team == Team.ENEMY and global_position.y < river_y and target_entity.global_position.y > river_y:
				is_crossing_river = true

			if is_crossing_river:
				var bridge_pos: Vector2 = arena.get_bridge_position(lane)
				if absf(global_position.y - bridge_pos.y) > 20.0:
					return bridge_pos

		return target_entity.global_position

	# Fallback direction
	var forward: float = -1.0 if team == Team.PLAYER else 1.0
	return global_position + Vector2(0, forward * 200.0)

func _execute_attack() -> void:
	if not is_instance_valid(target_entity):
		return

	attack_anim_weight = 1.0

	if attack_range > 75.0: # Ranged attack
		var proj_col: Color = card_data.accent_color if card_data else Color.GREEN
		if arena and arena.has_method("spawn_projectile"):
			arena.spawn_projectile(
				global_position,
				target_entity,
				attack_damage,
				team,
				proj_col,
				is_splash,
				splash_radius
			)
		if arena and arena.has_method("play_sfx_name"):
			arena.play_sfx_name("ranged_attack")
	else: # Melee attack
		if target_entity.has_method("take_damage"):
			target_entity.take_damage(attack_damage)
		if arena and arena.has_method("play_sfx_name"):
			arena.play_sfx_name("melee_hit")

func take_damage(amount: int) -> void:
	if is_dead:
		return

	current_hp = maxi(0, current_hp - amount)
	hit_flash_timer = 0.12

	if arena and arena.has_method("spawn_floating_text"):
		var text_col: Color = Color(1, 0.82, 0.25) if team == Team.ENEMY else Color(1, 0.3, 0.4)
		arena.spawn_floating_text(str(amount), global_position + Vector2(0, -22), text_col)

	if current_hp <= 0:
		_die()

func heal(amount: int) -> void:
	if is_dead:
		return
	current_hp = mini(max_hp, current_hp + amount)
	if arena and arena.has_method("spawn_floating_text"):
		arena.spawn_floating_text("+" + str(amount), global_position + Vector2(0, -22), Color(0.2, 1.0, 0.4))
	queue_redraw()

func _die() -> void:
	is_dead = true
	state = State.DYING
	died.emit(self)
	if arena and arena.has_method("play_sfx_name"):
		arena.play_sfx_name("unit_death")

func _draw() -> void:
	var team_col: Color = Color(0.17, 0.91, 0.47) if team == Team.PLAYER else Color(1, 0.22, 0.35)
	var accent: Color = card_data.accent_color if card_data else team_col

	if is_dead:
		var death_pct := clampf(1.0 - (death_timer / 0.25), 0.0, 1.0)
		draw_circle(Vector2.ZERO, 14.0 * death_pct, Color(team_col.r, team_col.g, team_col.b, death_pct * 0.6))
		return

	# Hit flash override
	var draw_body_col := Color.WHITE if hit_flash_timer > 0.0 else Color(0.12, 0.12, 0.18)

	# Shadow
	draw_ellipse(Vector2(0, 10), Vector2(14, 6), Color(0, 0, 0, 0.45))

	# Team Ring (thick neon outline around base)
	draw_arc(Vector2(0, 4), 14.0, 0, TAU, 24, team_col, 2.5)

	# Base body silhouette
	draw_circle(Vector2.ZERO, 13.0, draw_body_col)
	draw_arc(Vector2.ZERO, 13.0, 0, TAU, 24, Color(0, 0, 0), 2.5)

	# Character Distinct Archetype Art
	var cid: String = card_data.id if card_data else "enforcer"
	match cid:
		"street_runner":
			# Dual blades / sprint silhouette
			var bob := sin(walk_anim_time * 6.0) * 3.0
			draw_circle(Vector2(0, -3 + bob), 6.0, accent)
			draw_line(Vector2(-10, bob), Vector2(-15, -6 + bob), accent, 2.5)
			draw_line(Vector2(10, bob), Vector2(15, -6 + bob), accent, 2.5)
		"brickwall":
			# Massive riot shield with hazard stripes
			draw_rect(Rect2(-12, -10, 24, 18), Color(0.2, 0.22, 0.28), true)
			draw_rect(Rect2(-12, -10, 24, 18), accent, false, 2.5)
			draw_line(Vector2(-8, -4), Vector2(8, 4), accent, 2.0)
			draw_line(Vector2(-8, 4), Vector2(8, -4), accent, 2.0)
		"chem_thrower":
			# Hazmat hood + glowing flask
			draw_circle(Vector2(0, -2), 8.0, Color(0.2, 0.25, 0.2))
			draw_circle(Vector2(6, 4), 5.0, accent) # Flask
			draw_arc(Vector2(6, 4), 5.0, 0, TAU, 12, Color.BLACK, 1.5)
		"lookout":
			# Scoped rifle barrel
			draw_circle(Vector2(0, -2), 7.0, accent)
			var aim_dir := -1.0 if team == Team.PLAYER else 1.0
			draw_line(Vector2(0, 0), Vector2(0, aim_dir * 18.0), Color(0.8, 0.8, 0.9), 3.0)
		"rooftop_racer":
			# Glider wings
			draw_line(Vector2(-18, 0), Vector2(18, 0), accent, 3.5)
			draw_circle(Vector2(0, -4), 6.0, team_col)
		_:
			# Enforcer / default: Spiked bat
			draw_circle(Vector2(0, -2), 7.0, accent)
			draw_line(Vector2(6, 4), Vector2(14, -8), Color(0.9, 0.7, 0.2), 3.0)

	# Health Bar
	var bar_w := 26.0
	var bar_h := 4.5
	var bar_pos := Vector2(-bar_w * 0.5, -22.0)
	var pct := clampf(float(current_hp) / float(max_hp), 0.0, 1.0)

	# Bar background + outline
	draw_rect(Rect2(bar_pos - Vector2(1, 1), Vector2(bar_w + 2, bar_h + 2)), Color(0, 0, 0, 0.9), true)
	draw_rect(Rect2(bar_pos, Vector2(bar_w, bar_h)), Color(0.2, 0.2, 0.25), true)
	draw_rect(Rect2(bar_pos, Vector2(bar_w * pct, bar_h)), team_col, true)

func draw_ellipse(pos: Vector2, radii: Vector2, color: Color) -> void:
	var pts := PackedVector2Array()
	var count := 16
	for i in range(count):
		var rad := (float(i) / float(count)) * TAU
		pts.append(pos + Vector2(cos(rad) * radii.x, sin(rad) * radii.y))
	draw_colored_polygon(pts, color)
