class_name CampaignMapView
extends Node2D

## High-Fidelity Procedural Renderer for Turf Wars Campaign District Map
## Faithfully matches locked reference mockup 03_battle_arena.jpg:
## Dark isometric rainy city streets, neon alley signs, territory compounds with neon fences.

var anim_time: float = 0.0
var selected_territory_id: String = "the_east_crew"

# Territory visual nodes
var territories: Array[TerritoryData] = []
var owned_ids: Array = []

func setup(p_territories: Array[TerritoryData], p_owned_ids: Array, p_selected_id: String) -> void:
	territories = p_territories
	owned_ids = p_owned_ids
	selected_territory_id = p_selected_id
	queue_redraw()

func _process(delta: float) -> void:
	anim_time += delta
	queue_redraw()

func _draw() -> void:
	# 1. Base Dark Rainy Asphalt Surface
	draw_rect(Rect2(0, 0, 720, 1280), Color(0.06, 0.07, 0.09), true)

	# 2. Isometric Street Grid (Wet Roads & Alleys)
	_draw_street_grid()

	# 3. Ambient Rain Streaks
	_draw_rain_streaks()

	# 4. Neon Alley Signs (Matching Mockup 03: "BAR", "PAWN SHOP", "LIVE NUDES", "LIQUOR")
	_draw_neon_sign("BAR", Vector2(40, 260), Color(0.85, 0.20, 0.95))
	_draw_neon_sign("PAWN\nSHOP", Vector2(650, 220), Color(1.0, 0.25, 0.35))
	_draw_neon_sign("LIVE\nNUDES", Vector2(640, 350), Color(0.95, 0.25, 0.85))
	_draw_neon_sign("LIQUOR", Vector2(440, 540), Color(0.65, 0.35, 1.0))
	_draw_neon_sign("STAST\nSIDE", Vector2(60, 680), Color(0.95, 0.25, 0.35))

	# 5. Draw Territories
	for t in territories:
		_draw_territory_compound(t)

	# 6. Floating Crew Badge in bottom right (Mockup 03: "8/12")
	_draw_crew_badge(Vector2(650, 750), "8/12")

func _draw_street_grid() -> void:
	# Diagonal isometric road lines
	var road_color := Color(0.09, 0.10, 0.13)
	var curb_color := Color(0.04, 0.04, 0.06)

	for i in range(-5, 15):
		var y := float(i) * 120.0
		# Cross roads
		draw_line(Vector2(0, y), Vector2(720, y + 260.0), road_color, 24.0)
		draw_line(Vector2(0, y - 2), Vector2(720, y + 258.0), curb_color, 2.0)
		draw_line(Vector2(0, y + 26), Vector2(720, y + 286.0), curb_color, 2.0)

		# Opposite diagonals
		draw_line(Vector2(720, y), Vector2(0, y + 260.0), road_color, 24.0)

func _draw_rain_streaks() -> void:
	var count := 40
	for i in range(count):
		var rx := fmod(float(i * 47) + anim_time * 80.0, 720.0)
		var ry := fmod(float(i * 73) + anim_time * 450.0, 1000.0) + 70.0
		draw_line(Vector2(rx, ry), Vector2(rx - 4.0, ry + 16.0), Color(0.4, 0.5, 0.65, 0.28), 1.2)

func _draw_neon_sign(txt: String, pos: Vector2, col: Color) -> void:
	var font := ThemeDB.fallback_font
	var pulse := sin(anim_time * 5.0 + pos.x) * 0.15 + 0.85
	var glow_col := Color(col.r, col.g, col.b, 0.25 * pulse)
	var main_col := Color(col.r, col.g, col.b, 0.95 * pulse)

	# Outer neon sign box
	var box := Rect2(pos.x - 24, pos.y - 14, 48, 28)
	draw_rect(box, Color(0.04, 0.04, 0.06, 0.9), true)
	draw_rect(box, glow_col, false, 3.5)
	draw_rect(box, main_col, false, 1.5)

	# Text
	draw_string(font, Vector2(pos.x - 20, pos.y + 4), txt, HORIZONTAL_ALIGNMENT_CENTER, 40, 9, main_col)

func _draw_territory_compound(terr: TerritoryData) -> void:
	var pos := terr.map_position
	var is_owned := owned_ids.has(terr.id)
	var is_selected := (terr.id == selected_territory_id)

	# Determine State & Color
	var border_color := Color(0.17, 0.91, 0.47) # Player Toxic Green
	if not is_owned:
		if terr.initial_state == TerritoryData.TerritoryState.ENEMY_CONTROLLED:
			border_color = Color(1.0, 0.22, 0.35) # Enemy Blood Red
		else:
			border_color = Color(0.40, 0.42, 0.48) # Neutral Gray

	# Compound Size
	var size := Vector2(140, 100)
	var rect := Rect2(pos.x - size.x * 0.5, pos.y - size.y * 0.5, size.x, size.y)

	# 1. Glowing Neon Security Perimeter Fence (Signature Mockup 03 visual)
	var glow_pulse := (sin(anim_time * 4.0) * 0.15 + 0.85) if (is_selected or is_owned) else 0.8
	var neon_glow := Color(border_color.r, border_color.g, border_color.b, 0.35 * glow_pulse)

	# Ground Shadow
	draw_rect(Rect2(rect.position + Vector2(6, 8), rect.size), Color(0.02, 0.02, 0.03, 0.85), true)

	# Outer Neon Glow Ring
	draw_rect(Rect2(rect.position - Vector2(4, 4), rect.size + Vector2(8, 8)), neon_glow, false, 6.0)
	# Solid Neon Perimeter Fence
	draw_rect(rect, border_color, false, 2.5)

	# 2. Main Rooftop / Building Body
	var body_color := Color(0.12, 0.13, 0.17) if is_owned else Color(0.16, 0.11, 0.13) if terr.initial_state == TerritoryData.TerritoryState.ENEMY_CONTROLLED else Color(0.11, 0.12, 0.14)
	draw_rect(Rect2(rect.position + Vector2(3, 3), rect.size - Vector2(6, 6)), body_color, true)

	# Rooftop industrial machinery & details
	_draw_compound_internals(pos, terr.crest_icon, border_color)

	# 3. Territory Name & Income Signplate (Top Banner)
	var banner_w := size.x - 12.0
	var banner_rect := Rect2(pos.x - banner_w * 0.5, pos.y - size.y * 0.5 - 18.0, banner_w, 24.0)

	draw_rect(Rect2(banner_rect.position - Vector2(1, 1), banner_rect.size + Vector2(2, 2)), Color(0, 0, 0, 0.95), true)
	draw_rect(banner_rect, Color(0.08, 0.08, 0.11), true)
	draw_rect(banner_rect, border_color, false, 1.5)

	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(banner_rect.position.x + 2, banner_rect.position.y + 16), terr.display_name, HORIZONTAL_ALIGNMENT_CENTER, int(banner_w), 11, Color.WHITE)

	# Income Subtext (e.g. "$1,250 /hr" in gold or "$0 /hr")
	var income_str := "$%d /hr" % terr.base_income_per_hour if is_owned else "$0 /hr" if terr.initial_state == TerritoryData.TerritoryState.NEUTRAL else "$%d /hr" % terr.base_income_per_hour
	var income_col := Color(1, 0.82, 0.25) if is_owned else Color(0.65, 0.65, 0.70)
	draw_string(font, Vector2(pos.x - 40, pos.y + size.y * 0.5 + 14.0), income_str, HORIZONTAL_ALIGNMENT_CENTER, 80, 11, income_col)

	# 4. Selection Highlight Box
	if is_selected:
		var sel_rect := Rect2(rect.position - Vector2(8, 26), rect.size + Vector2(16, 50))
		draw_rect(sel_rect, Color(1, 0.82, 0.25, 0.85), false, 2.5)

func _draw_compound_internals(pos: Vector2, icon_type: String, col: Color) -> void:
	match icon_type:
		"dragon":
			# Dragon emblem outline (Red Dragon Holdings)
			draw_circle(pos + Vector2(0, 4), 16.0, Color(0.3, 0.08, 0.10))
			draw_line(Vector2(pos.x - 12, pos.y + 10), Vector2(pos.x, pos.y - 8), col, 2.5)
			draw_line(Vector2(pos.x, pos.y - 8), Vector2(pos.x + 12, pos.y + 10), col, 2.5)
			draw_line(Vector2(pos.x - 8, pos.y + 2), Vector2(pos.x + 8, pos.y + 2), col, 2.0)
		"skull":
			# Skull emblem (The East Crew)
			draw_circle(pos + Vector2(0, 4), 14.0, Color(0.25, 0.06, 0.08))
			draw_circle(pos + Vector2(-4, 2), 3.0, Color.BLACK)
			draw_circle(pos + Vector2(4, 2), 3.0, Color.BLACK)
			draw_rect(Rect2(pos.x - 4, pos.y + 8, 8, 5), Color.BLACK, true)
		"scales":
			# Scales emblem (Old Market)
			draw_line(Vector2(pos.x - 14, pos.y), Vector2(pos.x + 14, pos.y), col, 2.0)
			draw_line(Vector2(pos.x, pos.y - 8), Vector2(pos.x, pos.y + 12), col, 2.0)
			draw_circle(Vector2(pos.x - 10, pos.y + 6), 5.0, col)
			draw_circle(Vector2(pos.x + 10, pos.y + 6), 5.0, col)
		"question":
			# Question mark (No Man's Block)
			var font := ThemeDB.fallback_font
			draw_string(font, Vector2(pos.x - 8, pos.y + 12), "?", HORIZONTAL_ALIGNMENT_CENTER, 16, 22, Color(0.6, 0.6, 0.7))
		_:
			# Factory / Warehouse machinery stacks
			draw_rect(Rect2(pos.x - 18, pos.y - 4, 14, 18), Color(0.08, 0.16, 0.11), true)
			draw_rect(Rect2(pos.x - 18, pos.y - 4, 14, 18), col, false, 1.5)
			draw_rect(Rect2(pos.x + 2, pos.y - 10, 16, 24), Color(0.08, 0.16, 0.11), true)
			draw_rect(Rect2(pos.x + 2, pos.y - 10, 16, 24), col, false, 1.5)

func _draw_crew_badge(pos: Vector2, txt: String) -> void:
	# Floating circular crew badge in bottom right (Mockup 03)
	draw_circle(pos, 24.0, Color(0.05, 0.05, 0.07, 0.95))
	draw_arc(pos, 24.0, 0, TAU, 24, Color(0.17, 0.91, 0.47), 2.5)
	# 3 mini head silhouettes
	draw_circle(pos + Vector2(-9, -4), 5.0, Color(0.4, 0.6, 0.5))
	draw_circle(pos + Vector2(0, -6), 6.0, Color(0.4, 0.6, 0.5))
	draw_circle(pos + Vector2(9, -4), 5.0, Color(0.4, 0.6, 0.5))
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(pos.x - 18, pos.y + 16), txt, HORIZONTAL_ALIGNMENT_CENTER, 36, 11, Color(0.17, 0.91, 0.47))
