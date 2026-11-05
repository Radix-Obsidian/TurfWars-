class_name Projectile
extends Node2D

## Projectile for ranged units, spells, and defensive towers in Turf Wars

signal hit(target)

var target_node: Node2D = null
var target_pos: Vector2 = Vector2.ZERO
var speed: float = 450.0
var damage: int = 20
var is_splash: bool = false
var splash_radius: float = 60.0
var team: int = 0 # 0: Player, 1: Enemy
var proj_color: Color = Color(0.17, 0.91, 0.47)
var arena: Node = null

func setup(p_arena: Node, p_start: Vector2, p_target: Node2D, p_damage: int, p_team: int, p_color: Color, p_is_splash: bool = false, p_splash_radius: float = 0.0) -> void:
	arena = p_arena
	global_position = p_start
	target_node = p_target
	if is_instance_valid(target_node):
		target_pos = target_node.global_position
	else:
		target_pos = p_start + Vector2.UP * 100
	damage = p_damage
	team = p_team
	proj_color = p_color
	is_splash = p_is_splash
	splash_radius = p_splash_radius

func _process(delta: float) -> void:
	if is_instance_valid(target_node):
		target_pos = target_node.global_position

	var dir := (target_pos - global_position)
	var dist := dir.length()
	var step := speed * delta

	if dist <= step or dist < 8.0:
		_impact()
	else:
		global_position += dir.normalized() * step
		queue_redraw()

func _impact() -> void:
	if is_instance_valid(arena) and arena.has_method("apply_projectile_damage"):
		arena.apply_projectile_damage(self, target_pos, target_node, damage, team, is_splash, splash_radius)
	hit.emit(target_node)
	queue_free()

func _draw() -> void:
	# Glow outline
	draw_circle(Vector2.ZERO, 6.0, Color(0, 0, 0, 0.8))
	draw_circle(Vector2.ZERO, 4.5, proj_color)
	draw_circle(Vector2.ZERO, 2.0, Color.WHITE)
