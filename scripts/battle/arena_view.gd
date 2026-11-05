class_name ArenaView
extends Node2D

## High-Fidelity Procedural Renderer for Turf Wars Battle Arena
## Matches locked reference mockup 01_campaign_map.jpg:
## Dark brick walls with graffiti, cracked asphalt lanes, neon plasma river, and spotlight cones.

var anim_time: float = 0.0

func _process(delta: float) -> void:
	anim_time += delta
	queue_redraw()

func _draw() -> void:
	# 1. Base Cracked Asphalt Surface
	draw_rect(Rect2(0, 0, 720, 1280), Color(0.08, 0.08, 0.10), true)

	# 2. Side Brick Walls (Alley Walls with Graffiti)
	var wall_w := 90.0
	var left_wall := Rect2(0, 60, wall_w, 1020)
	var right_wall := Rect2(720 - wall_w, 60, wall_w, 1020)

	draw_rect(left_wall, Color(0.12, 0.09, 0.11), true)
	draw_rect(right_wall, Color(0.12, 0.09, 0.11), true)

	# Draw Brick Pattern on Side Walls
	_draw_brick_texture(left_wall)
	_draw_brick_texture(right_wall)

	# Graffiti on Left Wall ("RAZOR KINGS", "OLD BLOCK DROP")
	_draw_graffiti_text("RAZOR", Vector2(12, 220), Color(0.55, 0.18, 0.65, 0.85), 20)
	_draw_graffiti_text("KINGS", Vector2(14, 245), Color(0.55, 0.18, 0.65, 0.85), 20)
	_draw_graffiti_text("OLD BLOCK", Vector2(8, 760), Color(0.40, 0.15, 0.50, 0.7), 14)
	_draw_graffiti_text("WILL DROP", Vector2(8, 780), Color(0.40, 0.15, 0.50, 0.7), 14)

	# Graffiti on Right Wall ("KING'S WAY", "RESPECT THE BLOCK")
	_draw_graffiti_text("KING'S", Vector2(642, 220), Color(0.55, 0.18, 0.65, 0.85), 18)
	_draw_graffiti_text("WAY", Vector2(650, 242), Color(0.55, 0.18, 0.65, 0.85), 18)
	_draw_graffiti_text("RESPECT", Vector2(638, 750), Color(0.15, 0.65, 0.35, 0.85), 15)
	_draw_graffiti_text("THE BLOCK", Vector2(634, 772), Color(0.15, 0.65, 0.35, 0.85), 15)

	# Inner Wall Kerb / Curbs
	draw_line(Vector2(wall_w, 60), Vector2(wall_w, 1080), Color(0.04, 0.04, 0.06), 4.0)
	draw_line(Vector2(720 - wall_w, 60), Vector2(720 - wall_w, 1080), Color(0.04, 0.04, 0.06), 4.0)

	# 3. Two Lanes (Paved Cracked Cobblestone / Asphalt)
	var lane_w := 140.0
	var left_lane_x := 200.0
	var right_lane_x := 520.0

	var left_lane_rect := Rect2(left_lane_x - lane_w * 0.5, 60, lane_w, 1020)
	var right_lane_rect := Rect2(right_lane_x - lane_w * 0.5, 60, lane_w, 1020)

	draw_rect(left_lane_rect, Color(0.11, 0.12, 0.16), true)
	draw_rect(right_lane_rect, Color(0.11, 0.12, 0.16), true)

	# Lane Dashed Boundary Markers (Purple/Magenta neon lane dash as in mockup)
	_draw_lane_dashes(wall_w + 10.0, 80.0, 1060.0, Color(0.85, 0.25, 0.95, 0.75))
	_draw_lane_dashes(720.0 - wall_w - 10.0, 80.0, 1060.0, Color(0.85, 0.25, 0.95, 0.75))

	# Center road dashes along each lane
	_draw_dashed_line_y(left_lane_x, 80.0, 1060.0, Color(0.75, 0.65, 0.35, 0.35))
	_draw_dashed_line_y(right_lane_x, 80.0, 1060.0, Color(0.75, 0.65, 0.35, 0.35))

	# 4. Center Electric Purple Flaming Plasma Trench (The River)
	var river_y := 580.0
	var river_h := 46.0
	var river_rect := Rect2(0, river_y - river_h * 0.5, 720, river_h)

	# Dark trench bed
	draw_rect(river_rect, Color(0.08, 0.02, 0.12), true)

	# Turbulent purple plasma layers
	var pulse := sin(anim_time * 4.0) * 0.15 + 0.85
	var plasma_color := Color(0.72 * pulse, 0.15 * pulse, 0.95 * pulse, 0.8)
	draw_rect(Rect2(0, river_y - river_h * 0.35, 720, river_h * 0.7), plasma_color, true)

	# Intense neon core line
	var core_color := Color(0.95, 0.45, 1.0, 0.9)
	draw_line(Vector2(0, river_y), Vector2(720, river_y), core_color, 4.0)

	# River glowing shorelines
	draw_line(Vector2(0, river_y - river_h * 0.5), Vector2(720, river_y - river_h * 0.5), Color(0.85, 0.25, 0.95), 2.5)
	draw_line(Vector2(0, river_y + river_h * 0.5), Vector2(720, river_y + river_h * 0.5), Color(0.85, 0.25, 0.95), 2.5)

	# Plasma flame flickers
	for i in range(18):
		var fx := float(i) * 40.0 + fmod(anim_time * 60.0 + float(i * 15), 40.0)
		var fy := river_y + sin(anim_time * 6.0 + float(i)) * 10.0
		draw_circle(Vector2(fx, fy), 8.0 * pulse, Color(0.85, 0.35, 1.0, 0.5))

	# Center Skull Crest on River Trench (as shown in Mockup 01)
	_draw_skull_crest(Vector2(360, river_y), Color(0.65, 0.15, 0.75), 18.0)

	# "NO MAN'S TURF" Signpost near river left bank
	_draw_signpost(Vector2(105, river_y - 30), "NO MAN'S\nTURF")

	# 5. Spotlights from Enemy HQ (Mockup 01 has purple spotlights shining down)
	_draw_spotlight(Vector2(300, 160), Vector2(250, 380), Color(0.7, 0.2, 0.9, 0.18))
	_draw_spotlight(Vector2(420, 160), Vector2(470, 380), Color(0.7, 0.2, 0.9, 0.18))

func _draw_brick_texture(rect: Rect2) -> void:
	var brick_h := 18.0
	var brick_w := 30.0
	var y := rect.position.y
	var row := 0
	while y < rect.position.y + rect.size.y:
		draw_line(Vector2(rect.position.x, y), Vector2(rect.position.x + rect.size.x, y), Color(0.06, 0.05, 0.06), 1.5)
		var x := rect.position.x + (15.0 if row % 2 == 1 else 0.0)
		while x < rect.position.x + rect.size.x:
			draw_line(Vector2(x, y), Vector2(x, minf(y + brick_h, rect.position.y + rect.size.y)), Color(0.06, 0.05, 0.06), 1.5)
			x += brick_w
		y += brick_h
		row += 1

func _draw_graffiti_text(txt: String, pos: Vector2, col: Color, size: int) -> void:
	var font := ThemeDB.fallback_font
	draw_string(font, pos + Vector2(2, 2), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0, 0, 0, 0.8))
	draw_string(font, pos, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)

func _draw_lane_dashes(x: float, y_start: float, y_end: float, col: Color) -> void:
	var dash := 12.0
	var gap := 10.0
	var y := y_start
	while y < y_end:
		if absf(y - 580.0) > 30.0:
			draw_line(Vector2(x, y), Vector2(x, minf(y + dash, y_end)), col, 3.0)
		y += dash + gap

func _draw_dashed_line_y(x: float, y_start: float, y_end: float, col: Color) -> void:
	var dash := 16.0
	var gap := 14.0
	var y := y_start
	while y < y_end:
		if absf(y - 580.0) > 30.0:
			draw_line(Vector2(x, y), Vector2(x, minf(y + dash, y_end)), col, 2.0)
		y += dash + gap

func _draw_skull_crest(pos: Vector2, col: Color, radius: float) -> void:
	# Outer shield
	draw_circle(pos, radius + 3.0, Color.BLACK)
	draw_circle(pos, radius, col)
	# Skull eyes & jaw
	draw_circle(pos + Vector2(-5, -2), 3.5, Color.BLACK)
	draw_circle(pos + Vector2(5, -2), 3.5, Color.BLACK)
	draw_rect(Rect2(pos.x - 5, pos.y + 4, 10, 6), Color.BLACK, true)
	draw_line(Vector2(pos.x - 2, pos.y + 4), Vector2(pos.x - 2, pos.y + 10), col, 1.5)
	draw_line(Vector2(pos.x + 2, pos.y + 4), Vector2(pos.x + 2, pos.y + 10), col, 1.5)

func _draw_signpost(pos: Vector2, txt: String) -> void:
	# Wooden board
	var rect := Rect2(pos.x - 30, pos.y - 18, 60, 36)
	draw_rect(rect, Color(0.24, 0.18, 0.14), true)
	draw_rect(rect, Color(0.08, 0.05, 0.04), false, 2.0)
	draw_line(Vector2(pos.x, pos.y + 18), Vector2(pos.x, pos.y + 36), Color(0.15, 0.10, 0.08), 3.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(pos.x - 26, pos.y - 2), txt, HORIZONTAL_ALIGNMENT_CENTER, 52, 10, Color(0.85, 0.25, 0.35))

func _draw_spotlight(origin: Vector2, target: Vector2, col: Color) -> void:
	var dir := (target - origin).normalized()
	var perp := Vector2(-dir.y, dir.x)
	var pts := PackedVector2Array([
		origin + perp * 6.0,
		origin - perp * 6.0,
		target - perp * 45.0,
		target + perp * 45.0
	])
	draw_colored_polygon(pts, col)
