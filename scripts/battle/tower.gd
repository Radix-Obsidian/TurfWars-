class_name Tower
extends Area2D

## Defensive Crown Tower and HQ for Turf Wars

signal destroyed(tower: Tower)
signal damaged(tower: Tower, current: int, max_val: int)

enum Team { PLAYER = 0, ENEMY = 1 }
enum TowerType { CROWN_TOWER = 0, HQ = 1 }
enum Lane { LEFT = 0, RIGHT = 1, CENTER = 2 }

@export var team: Team = Team.PLAYER
@export var tower_type: TowerType = TowerType.CROWN_TOWER
@export var lane: Lane = Lane.LEFT
@export var max_hp: int = 1400
@export var attack_damage: int = 50
@export var attack_interval: float = 0.8
@export var attack_range: float = 185.0

var current_hp: int = 1400
var attack_timer: float = 0.0
var target: Node2D = null
var is_destroyed: bool = false
var is_active: bool = true # HQ activates when attacked or when a friendly crown tower falls
var hit_flash_timer: float = 0.0
var arena: Node = null

# Visual dimensions
var tower_size: Vector2 = Vector2(56, 56)

func _ready() -> void:
	if tower_type == TowerType.HQ:
		max_hp = 2400
		attack_damage = 70
		attack_range = 215.0
		tower_size = Vector2(76, 76)
		is_active = false # Activates when provoked or lane tower falls
	current_hp = max_hp

	# Setup collision shape dynamically if not preset
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = tower_size
	col.shape = rect
	add_child(col)

func _process(delta: float) -> void:
	if is_destroyed:
		return

	if hit_flash_timer > 0.0:
		hit_flash_timer -= delta
		queue_redraw()

	if not is_active:
		return

	attack_timer -= delta
	if attack_timer <= 0.0:
		_find_target()
		if is_instance_valid(target):
			_attack_target()
			attack_timer = attack_interval

func _find_target() -> void:
	if is_instance_valid(target):
		var dist := global_position.distance_to(target.global_position)
		if dist <= attack_range and not target.get("is_dead"):
			return
		target = null

	if arena and arena.has_method("get_units"):
		var enemy_team: int = Team.ENEMY if team == Team.PLAYER else Team.PLAYER
		var units: Array = arena.get_units(enemy_team)
		var closest_dist: float = attack_range
		var best_target: Node2D = null

		for u in units:
			if is_instance_valid(u) and not u.is_dead:
				var d: float = global_position.distance_to(u.global_position)
				if d <= closest_dist:
					closest_dist = d
					best_target = u

		target = best_target

func _attack_target() -> void:
	if not is_instance_valid(target) or not arena:
		return

	var proj_color: Color = Color(0.17, 0.91, 0.47) if team == Team.PLAYER else Color(1, 0.25, 0.35)
	if arena.has_method("spawn_projectile"):
		arena.spawn_projectile(global_position, target, attack_damage, team, proj_color)

	if arena.has_method("play_sfx_name"):
		arena.play_sfx_name("tower_shot")

func take_damage(amount: int) -> void:
	if is_destroyed:
		return

	# Damage activates the HQ if dormant
	if not is_active:
		is_active = true

	current_hp = maxi(0, current_hp - amount)
	hit_flash_timer = 0.12
	damaged.emit(self, current_hp, max_hp)
	queue_redraw()

	if arena and arena.has_method("spawn_floating_text"):
		var text_col: Color = Color(1, 0.82, 0.25) if team == Team.ENEMY else Color(1, 0.3, 0.4)
		arena.spawn_floating_text(str(amount), global_position + Vector2(0, -tower_size.y * 0.5), text_col)

	if current_hp <= 0:
		_destroy()

func _destroy() -> void:
	is_destroyed = true
	is_active = false
	if arena and arena.has_method("add_screen_shake"):
		arena.add_screen_shake(0.6 if tower_type == TowerType.HQ else 0.4)
	if arena and arena.has_method("play_sfx_name"):
		arena.play_sfx_name("explosion")
	destroyed.emit(self)
	queue_redraw()

func _draw() -> void:
	var half := tower_size * 0.5
	var base_rect := Rect2(-half, tower_size)

	if is_destroyed:
		# Rubble appearance
		draw_rect(base_rect, Color(0.12, 0.12, 0.15), true)
		draw_rect(base_rect, Color(0.05, 0.05, 0.07), false, 3.0)
		# Debris cross
		draw_line(-half, half, Color(0.2, 0.2, 0.25), 3.0)
		draw_line(Vector2(-half.x, half.y), Vector2(half.x, -half.y), Color(0.2, 0.2, 0.25), 3.0)
		return

	# Color scheme based on team & state
	var team_accent: Color = Color(0.17, 0.91, 0.47) if team == Team.PLAYER else Color(1, 0.2, 0.33)
	var body_color: Color = Color(0.18, 0.20, 0.26) if team == Team.PLAYER else Color(0.24, 0.16, 0.18)

	if hit_flash_timer > 0.0:
		body_color = Color.WHITE

	# Outer shadow / outline
	draw_rect(Rect2(-half - Vector2(3, 3), tower_size + Vector2(6, 6)), Color(0.04, 0.04, 0.06), true)

	# Main Tower Base
	draw_rect(base_rect, body_color, true)

	# Neon border
	draw_rect(base_rect, team_accent, false, 2.5)

	# Roof Battlements / Spire
	if tower_type == TowerType.HQ:
		# Crown symbol for HQ
		var crown_pts := PackedVector2Array([
			Vector2(-18, 10),
			Vector2(-18, -10),
			Vector2(-9, -2),
			Vector2(0, -14),
			Vector2(9, -2),
			Vector2(18, -10),
			Vector2(18, 10)
		])
		draw_colored_polygon(crown_pts, team_accent)
		draw_polyline(crown_pts, Color(0, 0, 0), 2.0)
	else:
		# Crosshair / spotlight beacon
		draw_circle(Vector2.ZERO, 10.0, Color(0.1, 0.1, 0.15))
		draw_circle(Vector2.ZERO, 6.0, team_accent)
		draw_line(Vector2(-16, 0), Vector2(16, 0), team_accent, 2.0)
		draw_line(Vector2(0, -16), Vector2(0, 16), team_accent, 2.0)

	# Overhead Health Bar
	var bar_w := tower_size.x + 12.0
	var bar_h := 7.0
	var bar_pos := Vector2(-bar_w * 0.5, -half.y - 14.0)
	var pct := clampf(float(current_hp) / float(max_hp), 0.0, 1.0)

	# Bar shadow & border
	draw_rect(Rect2(bar_pos - Vector2(1, 1), Vector2(bar_w + 2, bar_h + 2)), Color(0, 0, 0, 0.9), true)
	# Empty back
	draw_rect(Rect2(bar_pos, Vector2(bar_w, bar_h)), Color(0.2, 0.2, 0.25), true)
	# Filled bar
	var bar_col := Color(0.17, 0.91, 0.47) if team == Team.PLAYER else Color(1, 0.2, 0.33)
	draw_rect(Rect2(bar_pos, Vector2(bar_w * pct, bar_h)), bar_col, true)
