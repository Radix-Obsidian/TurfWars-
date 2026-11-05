class_name ArenaView
extends Node2D

## Procedural Visual Renderer for Turf Wars 2-Lane Street Arena
## Renders dark gritty cartoon asphalt, lane dividers, neon river, and bridges.

func _draw() -> void:
	# 1. Base Arena Surface (Rain-slicked Dark Asphalt)
	draw_rect(Rect2(0, 0, 720, 1280), Color(0.06, 0.06, 0.08), true)

	# 2. Left and Right Lanes (Paved Streets)
	var lane_width := 140.0
	var left_lane_rect := Rect2(200.0 - lane_width * 0.5, 80.0, lane_width, 1000.0)
	var right_lane_rect := Rect2(520.0 - lane_width * 0.5, 80.0, lane_width, 1000.0)

	draw_rect(left_lane_rect, Color(0.10, 0.11, 0.15), true)
	draw_rect(right_lane_rect, Color(0.10, 0.11, 0.15), true)

	# Lane Borders (Dark Curbs)
	draw_rect(left_lane_rect, Color(0.04, 0.04, 0.06), false, 3.0)
	draw_rect(right_lane_rect, Color(0.04, 0.04, 0.06), false, 3.0)

	# Dashed Yellow Road Markings along lanes
	_draw_dashed_lane_line(200.0, 100.0, 1060.0)
	_draw_dashed_lane_line(520.0, 100.0, 1060.0)

	# 3. Center River (Toxic Neon Canal / No-Man's Land)
	var river_y := 580.0
	var river_h := 36.0
	var river_rect := Rect2(0, river_y - river_h * 0.5, 720, river_h)
	draw_rect(river_rect, Color(0.03, 0.15, 0.18), true) # Toxic water base
	draw_line(Vector2(0, river_y - river_h * 0.5), Vector2(720, river_y - river_h * 0.5), Color(0.0, 0.9, 0.85, 0.7), 2.0)
	draw_line(Vector2(0, river_y + river_h * 0.5), Vector2(720, river_y + river_h * 0.5), Color(0.0, 0.9, 0.85, 0.7), 2.0)

	# 4. Metal Street Bridges across River
	_draw_bridge(Vector2(200.0, river_y))
	_draw_bridge(Vector2(520.0, river_y))

	# 5. Team Half-Line indicators
	# Player deploy dashed line
	_draw_dashed_horizontal(580.0 + river_h * 0.5 + 4.0, Color(0.17, 0.91, 0.47, 0.35))
	# Enemy deploy dashed line
	_draw_dashed_horizontal(580.0 - river_h * 0.5 - 4.0, Color(1.0, 0.22, 0.35, 0.35))

func _draw_bridge(pos: Vector2) -> void:
	var bw := 90.0
	var bh := 48.0
	var rect := Rect2(pos.x - bw * 0.5, pos.y - bh * 0.5, bw, bh)

	# Bridge foundation
	draw_rect(rect, Color(0.18, 0.20, 0.25), true)
	draw_rect(rect, Color(0.03, 0.03, 0.05), false, 3.0)

	# Metal Grate Lines
	for i in range(-3, 4):
		var y_off := float(i) * 6.0
		draw_line(Vector2(pos.x - bw * 0.5 + 4, pos.y + y_off), Vector2(pos.x + bw * 0.5 - 4, pos.y + y_off), Color(0.12, 0.14, 0.18), 1.5)

	# Neon Bridge Railings
	draw_line(Vector2(pos.x - bw * 0.5, pos.y - bh * 0.5), Vector2(pos.x - bw * 0.5, pos.y + bh * 0.5), Color(1, 0.82, 0.25), 3.0)
	draw_line(Vector2(pos.x + bw * 0.5, pos.y - bh * 0.5), Vector2(pos.x + bw * 0.5, pos.y + bh * 0.5), Color(1, 0.82, 0.25), 3.0)

func _draw_dashed_lane_line(x: float, y_start: float, y_end: float) -> void:
	var dash_len := 18.0
	var gap := 14.0
	var y := y_start
	while y < y_end:
		if absf(y - 580.0) > 30.0: # Skip over river
			draw_line(Vector2(x, y), Vector2(x, minf(y + dash_len, y_end)), Color(1, 0.82, 0.25, 0.4), 2.0)
		y += dash_len + gap

func _draw_dashed_horizontal(y: float, col: Color) -> void:
	var dash := 15.0
	var gap := 10.0
	var x := 30.0
	while x < 690.0:
		draw_line(Vector2(x, y), Vector2(minf(x + dash, 690.0), y), col, 2.0)
		x += dash + gap
