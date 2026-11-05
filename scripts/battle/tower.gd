class_name Tower
extends Area2D

## Defensive Crown Tower and HQ for Turf Wars
## Matches locked reference mockup 01_campaign_map.jpg:
## Layered brick & metal forts, skull crest shields, spotlights, and sandbags.

signal destroyed(tower: Tower)
signal damaged(tower: Tower, current: int, max_val: int)

enum Team { PLAYER = 0, ENEMY = 1 }
enum TowerType { CROWN_TOWER = 0, HQ = 1 }
enum Lane { LEFT = 0, RIGHT = 1, CENTER = 2 }

@export var team: Team = Team.PLAYER
@export var tower_type: TowerType = TowerType.CROWN_TOWER
@export var lane: Lane = Lane.LEFT
@export var max_hp: int = 3052
@export var attack_damage: int = 55
@export var attack_interval: float = 0.8
@export var attack_range: float = 190.0

var current_hp: int = 3052
var attack_timer: float = 0.0
var target: Node2D = null
var is_destroyed: bool = false
var is_active: bool = true
var hit_flash_timer: float = 0.0
var arena: Node = null

var tower_size: Vector2 = Vector2(68, 68)

func _ready() -> void:
	if tower_type == TowerType.HQ:
		max_hp = 4126
		attack_damage = 75
		attack_range = 225.0
		tower_size = Vector2(100, 80)
		is_active = false
	current_hp = max_hp

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

	var proj_color: Color = Color(0.17, 0.91, 0.47) if team == Team.PLAYER else Color(0.85, 0.25, 0.95)
	if arena.has_method("spawn_projectile"):
		arena.spawn_projectile(global_position, target, attack_damage, team, proj_color)

	if arena.has_method("play_sfx_name"):
		arena.play_sfx_name("tower_shot")

func take_damage(amount: int) -> void:
	if is_destroyed:
		return

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
		# Rubble appearance with cracked stones
		draw_rect(base_rect, Color(0.10, 0.10, 0.12), true)
		draw_rect(base_rect, Color(0.04, 0.04, 0.06), false, 3.0)
		draw_line(-half, half, Color(0.18, 0.18, 0.22), 3.0)
		draw_line(Vector2(-half.x, half.y), Vector2(half.x, -half.y), Color(0.18, 0.18, 0.22), 3.0)
		return

	var crest_color: Color = Color(0.17, 0.91, 0.47) if team == Team.PLAYER else Color(0.85, 0.25, 0.95)
	var brick_color: Color = Color(0.16, 0.14, 0.15) if team == Team.PLAYER else Color(0.20, 0.12, 0.18)

	if hit_flash_timer > 0.0:
		brick_color = Color.WHITE

	# Thick shadow outline
	draw_rect(Rect2(-half - Vector2(3, 3), tower_size + Vector2(6, 6)), Color(0.02, 0.02, 0.03), true)

	# Main Layered Stone / Brick Base
	draw_rect(base_rect, brick_color, true)
	draw_rect(base_rect, Color(0.05, 0.05, 0.07), false, 3.0)

	# Horizontal Layer lines for reinforced stonework
	for i in range(1, 4):
		var y := -half.y + (float(i) * (tower_size.y / 4.0))
		draw_line(Vector2(-half.x, y), Vector2(half.x, y), Color(0.08, 0.07, 0.09), 2.0)

	if tower_type == TowerType.HQ:
		# Central Bunker Structure (Mockup 01)
		if team == Team.PLAYER:
			# Arched entrance with glowing lantern
			draw_circle(Vector2(0, 10), 14.0, Color(0.08, 0.18, 0.12))
			draw_circle(Vector2(0, -6), 5.0, Color(1, 0.8, 0.3)) # Lantern glow
			# Sandbags at base
			for s in range(-3, 4):
				draw_rect(Rect2(float(s) * 14.0 - 6.0, half.y - 8.0, 12.0, 7.0), Color(0.35, 0.30, 0.22), true)
				draw_rect(Rect2(float(s) * 14.0 - 6.0, half.y - 8.0, 12.0, 7.0), Color(0.12, 0.10, 0.07), false, 1.5)
		else:
			# Enemy Barbed wire on roof + spotlights
			draw_line(Vector2(-half.x, -half.y - 4), Vector2(half.x, -half.y - 4), Color(0.3, 0.3, 0.35), 2.0)
			for b in range(-3, 4):
				var bx := float(b) * 14.0
				draw_line(Vector2(bx - 3, -half.y - 7), Vector2(bx + 3, -half.y - 1), Color(0.5, 0.5, 0.55), 1.5)

		# Big Skull Crest in Center of HQ
		_draw_shield_crest(Vector2(0, -14), crest_color, 24.0, true)
	else:
		# Crown Tower Crest Shield
		_draw_shield_crest(Vector2(0, -8), crest_color, 18.0, false)

	# Overhead HP Bar with badge (Exact style of Mockup 01: [2] 3052)
	var bar_w := tower_size.x + 14.0
	var bar_h := 10.0
	var bar_pos := Vector2(-bar_w * 0.5, half.y + 4.0 if team == Team.ENEMY else -half.y - 20.0)
	var pct := clampf(float(current_hp) / float(max_hp), 0.0, 1.0)

	# Black container box
	draw_rect(Rect2(bar_pos - Vector2(1, 1), Vector2(bar_w + 2, bar_h + 2)), Color(0, 0, 0, 0.95), true)
	draw_rect(Rect2(bar_pos, Vector2(bar_w, bar_h)), Color(0.18, 0.18, 0.22), true)
	# Filled bar
	var bar_col: Color = Color(0.17, 0.91, 0.47) if team == Team.PLAYER else Color(0.85, 0.25, 0.95)
	draw_rect(Rect2(bar_pos, Vector2(bar_w * pct, bar_h)), bar_col, true)

	# HP Number Text
	var font := ThemeDB.fallback_font
	var hp_str := str(current_hp)
	draw_string(font, bar_pos + Vector2(2, bar_h - 2), hp_str, HORIZONTAL_ALIGNMENT_CENTER, int(bar_w), 9, Color.WHITE)

func _draw_shield_crest(pos: Vector2, col: Color, radius: float, is_hq: bool) -> void:
	# Shield border
	var pts := PackedVector2Array([
		pos + Vector2(-radius, -radius * 0.6),
		pos + Vector2(radius, -radius * 0.6),
		pos + Vector2(radius * 0.8, radius * 0.6),
		pos + Vector2(0, radius * 1.1),
		pos + Vector2(-radius * 0.8, radius * 0.6)
	])
	# Black outline
	draw_colored_polygon(pts, Color(0.04, 0.04, 0.06))
	# Colored inner shield
	var inner_pts := PackedVector2Array([
		pos + Vector2(-radius + 2, -radius * 0.6 + 2),
		pos + Vector2(radius - 2, -radius * 0.6 + 2),
		pos + Vector2(radius * 0.8 - 2, radius * 0.6 - 2),
		pos + Vector2(0, radius * 1.1 - 3),
		pos + Vector2(-radius * 0.8 + 2, radius * 0.6 - 2)
	])
	draw_colored_polygon(inner_pts, col)

	# Skull emblem inside shield
	var skull_r := radius * 0.42
	draw_circle(pos + Vector2(0, -radius * 0.05), skull_r, Color(0.06, 0.06, 0.08))
	# Skull eyes
	draw_circle(pos + Vector2(-skull_r * 0.45, -radius * 0.05), skull_r * 0.32, col)
	draw_circle(pos + Vector2(skull_r * 0.45, -radius * 0.05), skull_r * 0.32, col)
	# Teeth box
	draw_rect(Rect2(pos.x - skull_r * 0.5, pos.y + skull_r * 0.3, skull_r, skull_r * 0.5), Color(0.06, 0.06, 0.08), true)

	# Crown on top of shield
	var crown_y := pos.y - radius * 0.65
	var crown_w := radius * 0.9
	var crown_pts := PackedVector2Array([
		Vector2(pos.x - crown_w, crown_y),
		Vector2(pos.x - crown_w, crown_y - 7),
		Vector2(pos.x - crown_w * 0.5, crown_y - 3),
		Vector2(pos.x, crown_y - 10),
		Vector2(pos.x + crown_w * 0.5, crown_y - 3),
		Vector2(pos.x + crown_w, crown_y - 7),
		Vector2(pos.x + crown_w, crown_y)
	])
	draw_colored_polygon(crown_pts, Color(1, 0.82, 0.25))
	draw_polyline(crown_pts, Color.BLACK, 1.5)
