class_name FloatingText
extends Node2D

## Floating combat text (damage, heals, criticals)

var text: String = "0"
var color: Color = Color.WHITE
var velocity: Vector2 = Vector2(0, -60)
var lifetime: float = 0.65
var timer: float = 0.0

func setup(p_text: String, p_pos: Vector2, p_color: Color = Color.WHITE) -> void:
	text = p_text
	global_position = p_pos + Vector2(randf_range(-12, 12), randf_range(-5, 5))
	color = p_color
	velocity.x = randf_range(-20, 20)

func _process(delta: float) -> void:
	timer += delta
	global_position += velocity * delta
	velocity.y += 40.0 * delta # Slight gravity deceleration
	if timer >= lifetime:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	var alpha: float = clampf(1.0 - (timer / lifetime), 0.0, 1.0)
	var text_col := Color(color.r, color.g, color.b, alpha)
	var shadow_col := Color(0, 0, 0, alpha * 0.9)
	var font := ThemeDB.fallback_font
	var font_size := 16

	# Shadow offset
	draw_string(font, Vector2(-15, 1), text, HORIZONTAL_ALIGNMENT_CENTER, 30, font_size, shadow_col)
	draw_string(font, Vector2(-16, 0), text, HORIZONTAL_ALIGNMENT_CENTER, 30, font_size, text_col)
