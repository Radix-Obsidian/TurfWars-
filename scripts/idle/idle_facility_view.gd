class_name IdleFacilityView
extends Node2D

## Custom procedural renderer for Turf Wars Idle Hub
## Accurately renders Mockup 02 (02_idle_hub.jpg):
## - Grow Room: Violet grow lamps, 4 strain pots, "STAY DANK" graffiti, grower manager scowl
## - Processing Table: Orange neon, mason jars, drying rack, massive cured bud pile, smoker worker
## - Street-Level Sales: Red neon, product pricing board, counter dealer, "TRUST NO COPS", street boss

var anim_timer: float = 0.0

# Smoke particles for the cigarette worker
var smoke_particles: Array[Dictionary] = []

# Floating click VFX texts
var floating_texts: Array[Dictionary] = []

func _ready() -> void:
	# Seed some initial smoke puffs
	for i in range(5):
		smoke_particles.append({
			"pos": Vector2(515, 520) + Vector2(randf_range(-4, 4), -i * 12),
			"radius": randf_range(4.0, 9.0),
			"alpha": randf_range(0.3, 0.7),
			"vel": Vector2(randf_range(-5, 5), randf_range(-15, -25))
		})

func _process(delta: float) -> void:
	anim_timer += delta
	_update_smoke(delta)
	_update_floating_texts(delta)
	queue_redraw()

func _update_smoke(delta: float) -> void:
	for p in smoke_particles:
		p["pos"] += p["vel"] * delta
		p["radius"] += delta * 6.0
		p["alpha"] -= delta * 0.25
		if p["alpha"] <= 0.05 or p["pos"].y < 460:
			p["pos"] = Vector2(515, 520) + Vector2(randf_range(-3, 3), 0)
			p["radius"] = randf_range(3.0, 6.0)
			p["alpha"] = randf_range(0.5, 0.8)
			p["vel"] = Vector2(randf_range(-8, 3), randf_range(-18, -32))

func _update_floating_texts(delta: float) -> void:
	var remaining: Array[Dictionary] = []
	for ft in floating_texts:
		ft["pos"].y -= 40.0 * delta
		ft["life"] -= delta
		if ft["life"] > 0:
			remaining.append(ft)
	floating_texts = remaining

func spawn_floating_text(text: String, pos: Vector2, color: Color) -> void:
	floating_texts.append({
		"text": text,
		"pos": pos,
		"color": color,
		"life": 1.2,
		"max_life": 1.2
	})

func _draw() -> void:
	var w := 720.0
	var h := 1280.0

	# 1. Base Underground Grunge Wall
	draw_rect(Rect2(0, 0, w, h), Color(0.08, 0.08, 0.10, 1.0))
	_draw_gritty_brick_background(w, h)

	# 2. Section 1: GROW ROOM (y: 90 - 450)
	_draw_grow_room(w)

	# 3. Section 2: PROCESSING TABLE (y: 450 - 730)
	_draw_processing_table(w)

	# 4. Section 3: STREET-LEVEL SALES (y: 730 - 980)
	_draw_street_sales(w)

	# 5. Floating text VFX
	_draw_floating_texts()

# -----------------------------------------------------------------------------
# Background Grunge & Bricks
# -----------------------------------------------------------------------------
func _draw_gritty_brick_background(w: float, h: float) -> void:
	var brick_h := 22.0
	var brick_w := 54.0
	var rows := int(h / brick_h) + 1
	var mortar_col := Color(0.04, 0.04, 0.05, 0.8)

	for r in range(rows):
		var y := r * brick_h
		var offset := (r % 2) * (brick_w * 0.5)
		draw_line(Vector2(0, y), Vector2(w, y), mortar_col, 1.5)

		var cols := int(w / brick_w) + 2
		for c in range(cols):
			var x := c * brick_w - offset
			draw_line(Vector2(x, y), Vector2(x, y + brick_h), mortar_col, 1.0)
			# Subtle brick shading variation
			if (r + c) % 5 == 0:
				draw_rect(Rect2(x + 1, y + 1, brick_w - 2, brick_h - 2), Color(0.12, 0.11, 0.14, 0.35))
			elif (r * 3 + c) % 7 == 0:
				draw_rect(Rect2(x + 1, y + 1, brick_w - 2, brick_h - 2), Color(0.06, 0.06, 0.07, 0.45))

	# Dripping vertical water/sludge stains
	var stains := [Vector2(80, 0), Vector2(240, 0), Vector2(490, 0), Vector2(660, 0)]
	for s in stains:
		var stain_h := 280.0
		draw_line(s, Vector2(s.x, s.y + stain_h), Color(0.03, 0.04, 0.03, 0.4), 4.0)
		draw_line(Vector2(s.x + 2, s.y), Vector2(s.x + 2, s.y + stain_h * 0.7), Color(0.02, 0.03, 0.02, 0.5), 2.0)

# -----------------------------------------------------------------------------
# GROW ROOM
# -----------------------------------------------------------------------------
func _draw_grow_room(w: float) -> void:
	var top_y := 92.0

	# Heavy dark backing with subtle violet ambience
	draw_rect(Rect2(12, top_y, w - 24, 348), Color(0.07, 0.06, 0.10, 0.95))
	draw_rect(Rect2(12, top_y, w - 24, 348), Color(0.35, 0.15, 0.45, 0.3), false, 2.0)

	# Dripping Purple Neon Sign: "GROW ROOM"
	_draw_dripping_sign(Vector2(20, top_y + 12), Vector2(170, 36), "GROW ROOM", Color(0.85, 0.28, 0.95), Color(0.4, 0.08, 0.55))

	# Violet Grow Lamps hanging from chains (3 lamps)
	var lamp_x_positions := [110.0, 235.0, 360.0]
	var lamp_y := top_y + 40.0
	for lx in lamp_x_positions:
		# Hanging chain
		draw_line(Vector2(lx, top_y), Vector2(lx, lamp_y), Color(0.3, 0.3, 0.35), 2.0)
		# Lamp metal hood
		var hood := PackedVector2Array([
			Vector2(lx - 24, lamp_y + 14),
			Vector2(lx + 24, lamp_y + 14),
			Vector2(lx + 16, lamp_y),
			Vector2(lx - 16, lamp_y)
		])
		draw_colored_polygon(hood, Color(0.2, 0.18, 0.25))
		draw_polyline(hood, Color(0.05, 0.05, 0.08), 2.0)

		# Glowing bulb
		draw_circle(Vector2(lx, lamp_y + 14), 7.0, Color(0.9, 0.45, 1.0))
		draw_circle(Vector2(lx, lamp_y + 14), 4.0, Color(1.0, 0.9, 1.0))

		# Conical violet light beam
		var beam_pulse := 0.12 + 0.03 * sin(anim_timer * 2.5 + lx)
		var cone := PackedVector2Array([
			Vector2(lx - 10, lamp_y + 14),
			Vector2(lx + 10, lamp_y + 14),
			Vector2(lx + 70, lamp_y + 180),
			Vector2(lx - 70, lamp_y + 180)
		])
		draw_colored_polygon(cone, Color(0.75, 0.2, 0.95, beam_pulse))

	# Grow Bench / Wooden Table
	var table_y := top_y + 195.0
	draw_rect(Rect2(24, table_y, 440, 24), Color(0.24, 0.17, 0.12, 1.0))
	draw_rect(Rect2(24, table_y, 440, 24), Color(0.10, 0.06, 0.04, 1.0), false, 2.0)
	# Metal brackets and plank lines
	draw_line(Vector2(24, table_y + 8), Vector2(464, table_y + 8), Color(0.18, 0.12, 0.08), 1.5)
	draw_line(Vector2(130, table_y), Vector2(130, table_y + 24), Color(0.12, 0.08, 0.05), 2.0)
	draw_line(Vector2(245, table_y), Vector2(245, table_y + 24), Color(0.12, 0.08, 0.05), 2.0)
	draw_line(Vector2(360, table_y), Vector2(360, table_y + 24), Color(0.12, 0.08, 0.05), 2.0)

	# 4 Strain Potted Plants
	var strains := [
		{"name": "OG KUSH", "x": 80.0, "pot_col": Color(0.55, 0.28, 0.18), "leaf_col": Color(0.2, 0.68, 0.25), "bud_col": Color(0.4, 0.85, 0.35)},
		{"name": "PURPLE\nPUNCH", "x": 190.0, "pot_col": Color(0.45, 0.22, 0.28), "leaf_col": Color(0.28, 0.52, 0.35), "bud_col": Color(0.72, 0.25, 0.85)},
		{"name": "DANK\nWIDOW", "x": 300.0, "pot_col": Color(0.35, 0.24, 0.35), "leaf_col": Color(0.18, 0.45, 0.28), "bud_col": Color(0.85, 0.3, 0.9)},
		{"name": "ZKITZO", "x": 410.0, "pot_col": Color(0.50, 0.30, 0.15), "leaf_col": Color(0.35, 0.78, 0.22), "bud_col": Color(0.95, 0.65, 0.15)}
	]

	for s in strains:
		_draw_cannabis_pot(s["x"], table_y, s["name"], s["pot_col"], s["leaf_col"], s["bud_col"])

	# Purple Wall Graffiti: "STAY DANK" with smiley
	var graf_x := 490.0
	var graf_y := top_y + 60.0
	_draw_spray_text(Vector2(graf_x, graf_y), "STAY\nDANK", Color(0.75, 0.25, 0.88, 0.8), 24)
	# Graffiti smiley
	draw_circle(Vector2(graf_x + 35, graf_y + 70), 16.0, Color(0.75, 0.25, 0.88, 0.8))
	draw_circle(Vector2(graf_x + 35, graf_y + 70), 13.0, Color(0.07, 0.06, 0.10, 1.0))
	draw_circle(Vector2(graf_x + 30, graf_y + 66), 2.5, Color(0.75, 0.25, 0.88, 0.8))
	draw_circle(Vector2(graf_x + 40, graf_y + 66), 2.5, Color(0.75, 0.25, 0.88, 0.8))
	draw_arc(Vector2(graf_x + 35, graf_y + 70), 8.0, 0.2, PI - 0.2, 12, Color(0.75, 0.25, 0.88, 0.8), 2.0)

	# Grower Manager (Scowling guy with purple beanie & hoodie, crossed arms)
	_draw_grower_manager(Vector2(600, top_y + 155))

	# Speech Bubble: "QUALITY STRAIN. QUALITY PAIN."
	_draw_speech_bubble(Vector2(530, top_y + 40), Vector2(170, 48), "QUALITY STRAIN.\nQUALITY PAIN.", Vector2(590, top_y + 90))

# -----------------------------------------------------------------------------
# Cannabis Pot & Plant Rendering
# -----------------------------------------------------------------------------
func _draw_cannabis_pot(px: float, table_y: float, strain_name: String, pot_col: Color, leaf_col: Color, bud_col: Color) -> void:
	var pot_h := 38.0
	var pot_top_w := 50.0
	var pot_bot_w := 36.0

	# Pot geometry
	var pot_pts := PackedVector2Array([
		Vector2(px - pot_top_w * 0.5, table_y - pot_h),
		Vector2(px + pot_top_w * 0.5, table_y - pot_h),
		Vector2(px + pot_bot_w * 0.5, table_y),
		Vector2(px - pot_bot_w * 0.5, table_y)
	])
	draw_colored_polygon(pot_pts, pot_col)
	draw_polyline(pot_pts, Color(0.12, 0.08, 0.06), 2.0)
	draw_line(pot_pts[3], pot_pts[0], Color(0.12, 0.08, 0.06), 2.0)

	# Pot rim
	draw_rect(Rect2(px - (pot_top_w * 0.5 + 3), table_y - pot_h - 4, pot_top_w + 6, 6), pot_col.darkened(0.2))
	draw_rect(Rect2(px - (pot_top_w * 0.5 + 3), table_y - pot_h - 4, pot_top_w + 6, 6), Color(0.1, 0.08, 0.05), false, 1.5)

	# Plant Stem & Leaves
	var stem_top := Vector2(px, table_y - pot_h - 60)
	draw_line(Vector2(px, table_y - pot_h), stem_top, Color(0.15, 0.35, 0.15), 4.0)

	# Bushy foliage fan
	var leaf_offsets: Array[Vector2] = [
		Vector2(-24, -20), Vector2(24, -20),
		Vector2(-32, -40), Vector2(32, -40),
		Vector2(-18, -55), Vector2(18, -55),
		Vector2(0, -68)
	]

	for lo in leaf_offsets:
		var leaf_tip: Vector2 = Vector2(px, table_y - pot_h) + lo
		var leaf_base: Vector2 = Vector2(px, table_y - pot_h) + lo * 0.3
		# Draw serrated leaf leaflet
		draw_line(leaf_base, leaf_tip, leaf_col, 5.0)
		draw_circle(leaf_tip, 3.5, bud_col)

	# Center frosty bud colas
	draw_circle(Vector2(px, table_y - pot_h - 45), 11.0, bud_col)
	draw_circle(Vector2(px, table_y - pot_h - 58), 9.0, bud_col.lightened(0.2))
	draw_circle(Vector2(px - 10, table_y - pot_h - 35), 7.0, bud_col)
	draw_circle(Vector2(px + 10, table_y - pot_h - 35), 7.0, bud_col)

	# Pot Label
	var font := ThemeDB.fallback_font
	var font_size := 9
	var lines := strain_name.split("\n")
	var text_y := table_y - pot_h + 14
	for l in lines:
		var str_w := font.get_string_size(l, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
		draw_string(font, Vector2(px - str_w * 0.5, text_y), l, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.95, 0.9, 0.8))
		text_y += 10.0

# -----------------------------------------------------------------------------
# Grower Character
# -----------------------------------------------------------------------------
func _draw_grower_manager(center: Vector2) -> void:
	# Purple Beanie
	draw_circle(Vector2(center.x, center.y - 36), 20.0, Color(0.48, 0.18, 0.58))
	draw_rect(Rect2(center.x - 22, center.y - 32, 44, 10), Color(0.38, 0.12, 0.48))
	draw_rect(Rect2(center.x - 22, center.y - 32, 44, 10), Color(0.1, 0.05, 0.15), false, 2.0)

	# Head & Face
	draw_circle(Vector2(center.x, center.y - 18), 16.0, Color(0.82, 0.62, 0.48))
	# Stubble Beard
	draw_circle(Vector2(center.x, center.y - 12), 12.0, Color(0.35, 0.25, 0.20, 0.6))
	# Mean scowl eyebrows & eyes
	draw_line(Vector2(center.x - 12, center.y - 24), Vector2(center.x - 3, center.y - 21), Color(0.1, 0.08, 0.08), 2.5)
	draw_line(Vector2(center.x + 12, center.y - 24), Vector2(center.x + 3, center.y - 21), Color(0.1, 0.08, 0.08), 2.5)
	draw_circle(Vector2(center.x - 7, center.y - 18), 2.0, Color(0.1, 0.1, 0.1))
	draw_circle(Vector2(center.x + 7, center.y - 18), 2.0, Color(0.1, 0.1, 0.1))
	# Frowning mouth
	draw_arc(Vector2(center.x, center.y - 8), 5.0, PI + 0.3, TAU - 0.3, 8, Color(0.15, 0.08, 0.08), 2.0)

	# Purple Hoodie Body
	var body_pts := PackedVector2Array([
		Vector2(center.x - 26, center.y - 2),
		Vector2(center.x + 26, center.y - 2),
		Vector2(center.x + 30, center.y + 55),
		Vector2(center.x - 30, center.y + 55)
	])
	draw_colored_polygon(body_pts, Color(0.42, 0.15, 0.52))
	draw_polyline(body_pts, Color(0.12, 0.05, 0.16), 2.5)
	draw_line(body_pts[3], body_pts[0], Color(0.12, 0.05, 0.16), 2.5)

	# Folded Arms
	draw_rect(Rect2(center.x - 24, center.y + 16, 48, 16), Color(0.35, 0.12, 0.44))
	draw_rect(Rect2(center.x - 24, center.y + 16, 48, 16), Color(0.1, 0.05, 0.15), false, 2.0)

# -----------------------------------------------------------------------------
# PROCESSING TABLE
# -----------------------------------------------------------------------------
func _draw_processing_table(w: float) -> void:
	var top_y := 445.0

	# Dark gunmetal container
	draw_rect(Rect2(12, top_y, w - 24, 275), Color(0.09, 0.08, 0.07, 0.95))
	draw_rect(Rect2(12, top_y, w - 24, 275), Color(0.55, 0.32, 0.12, 0.3), false, 2.0)

	# Dripping Orange Neon Sign: "PROCESSING TABLE"
	_draw_dripping_sign(Vector2(20, top_y + 10), Vector2(240, 36), "PROCESSING TABLE", Color(1.0, 0.52, 0.15), Color(0.55, 0.22, 0.05))

	# Heavy Wooden Work Table
	var table_y := top_y + 130.0
	draw_rect(Rect2(24, table_y, 450, 26), Color(0.26, 0.18, 0.12))
	draw_rect(Rect2(24, table_y, 450, 26), Color(0.10, 0.06, 0.04), false, 2.0)

	# Mason Jars on left (2 glass jars)
	_draw_mason_jar(Vector2(60, table_y - 28))
	_draw_mason_jar(Vector2(95, table_y - 28))

	# Paper Packaging Baggies
	var bag_col := Color(0.75, 0.65, 0.50)
	draw_rect(Rect2(130, table_y - 18, 24, 18), bag_col)
	draw_rect(Rect2(130, table_y - 18, 24, 18), Color(0.2, 0.15, 0.1), false, 1.5)
	draw_rect(Rect2(160, table_y - 20, 26, 20), bag_col)
	draw_rect(Rect2(160, table_y - 20, 26, 20), Color(0.2, 0.15, 0.1), false, 1.5)

	# Metal Trim Tray piled with cured green bud
	var tray_rect := Rect2(205, table_y - 12, 175, 14)
	draw_rect(tray_rect, Color(0.65, 0.68, 0.72))
	draw_rect(tray_rect, Color(0.2, 0.22, 0.25), false, 2.0)

	# Huge green bud pile on tray
	var pile_pts := PackedVector2Array([
		Vector2(215, table_y - 12),
		Vector2(250, table_y - 42),
		Vector2(290, table_y - 52),
		Vector2(335, table_y - 40),
		Vector2(370, table_y - 12)
	])
	draw_colored_polygon(pile_pts, Color(0.22, 0.58, 0.25))
	# Bud texture dots
	for i in range(16):
		var bx := randf_range(230, 350)
		var by := randf_range(table_y - 45, table_y - 16)
		draw_circle(Vector2(bx, by), 4.5, Color(0.35, 0.75, 0.32))
		draw_circle(Vector2(bx + 1, by + 1), 2.0, Color(0.85, 0.55, 0.2))

	# Smoker Worker Character (Green jacket, watch cap, smoking cigarette)
	_draw_smoker_worker(Vector2(550, top_y + 110))

	# Animated Smoke Puffs
	for p in smoke_particles:
		draw_circle(p["pos"], p["radius"], Color(0.85, 0.85, 0.90, p["alpha"]))

	# Worker Speech Bubble: "CUT IT, DRY IT, BAG IT, FLIP IT."
	_draw_speech_bubble(Vector2(500, top_y + 35), Vector2(195, 46), "CUT IT, DRY IT,\nBAG IT, FLIP IT.", Vector2(560, top_y + 80))

func _draw_mason_jar(pos: Vector2) -> void:
	# Glass Jar body
	draw_rect(Rect2(pos.x - 12, pos.y, 24, 28), Color(0.7, 0.85, 0.9, 0.45))
	draw_rect(Rect2(pos.x - 12, pos.y, 24, 28), Color(0.4, 0.55, 0.65, 0.8), false, 1.5)
	# Metal lid
	draw_rect(Rect2(pos.x - 14, pos.y - 4, 28, 5), Color(0.8, 0.75, 0.65))
	draw_rect(Rect2(pos.x - 14, pos.y - 4, 28, 5), Color(0.2, 0.2, 0.2), false, 1.0)
	# Green herb inside
	draw_circle(Vector2(pos.x, pos.y + 16), 8.0, Color(0.25, 0.65, 0.28, 0.75))

func _draw_smoker_worker(center: Vector2) -> void:
	# Black knit cap
	draw_circle(Vector2(center.x, center.y - 32), 18.0, Color(0.18, 0.18, 0.20))
	draw_rect(Rect2(center.x - 20, center.y - 28, 40, 8), Color(0.12, 0.12, 0.14))

	# Head & Scruffy Stubble
	draw_circle(Vector2(center.x, center.y - 16), 15.0, Color(0.80, 0.60, 0.46))
	draw_circle(Vector2(center.x - 4, center.y - 10), 10.0, Color(0.3, 0.22, 0.18, 0.55))

	# Eyes squinting through smoke
	draw_line(Vector2(center.x - 10, center.y - 19), Vector2(center.x - 2, center.y - 18), Color(0.1, 0.1, 0.1), 2.0)
	draw_line(Vector2(center.x + 2, center.y - 18), Vector2(center.x + 10, center.y - 19), Color(0.1, 0.1, 0.1), 2.0)

	# Cigarette sticking out of mouth
	var cig_tip := Vector2(center.x - 18, center.y - 8)
	var cig_mouth := Vector2(center.x - 4, center.y - 11)
	draw_line(cig_mouth, cig_tip, Color(0.95, 0.95, 0.95), 3.0)
	draw_circle(cig_tip, 2.5, Color(1.0, 0.35, 0.1)) # glowing cherry ember

	# Olive Tactical Jacket
	var jacket_pts := PackedVector2Array([
		Vector2(center.x - 24, center.y),
		Vector2(center.x + 24, center.y),
		Vector2(center.x + 28, center.y + 50),
		Vector2(center.x - 28, center.y + 50)
	])
	draw_colored_polygon(jacket_pts, Color(0.28, 0.38, 0.24))
	draw_polyline(jacket_pts, Color(0.08, 0.12, 0.08), 2.5)
	draw_line(jacket_pts[3], jacket_pts[0], Color(0.08, 0.12, 0.08), 2.5)

# -----------------------------------------------------------------------------
# STREET-LEVEL SALES
# -----------------------------------------------------------------------------
func _draw_street_sales(w: float) -> void:
	var top_y := 728.0

	# Dark dispensary facade
	draw_rect(Rect2(12, top_y, w - 24, 245), Color(0.09, 0.06, 0.07, 0.95))
	draw_rect(Rect2(12, top_y, w - 24, 245), Color(0.65, 0.18, 0.22, 0.3), false, 2.0)

	# Dripping Red Neon Sign: "STREET-LEVEL SALES"
	_draw_dripping_sign(Vector2(20, top_y + 10), Vector2(250, 34), "STREET-LEVEL SALES", Color(1.0, 0.25, 0.30), Color(0.55, 0.08, 0.12))

	# Red neon "PRODUCTS" badge
	draw_rect(Rect2(130, top_y + 44, 95, 20), Color(0.55, 0.08, 0.12, 0.8))
	draw_rect(Rect2(130, top_y + 44, 95, 20), Color(1.0, 0.25, 0.30), false, 1.5)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(142, top_y + 58), "PRODUCTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1.0, 0.8, 0.8))

	# Product Pricing Board (1/8 oz $25, 1/4 oz $45, 1 oz $90)
	var board_x := 245.0
	var board_y := top_y + 42.0
	draw_rect(Rect2(board_x, board_y, 160, 68), Color(0.12, 0.12, 0.14, 0.9))
	draw_rect(Rect2(board_x, board_y, 160, 68), Color(0.35, 0.35, 0.40), false, 2.0)

	# 3 product tiers
	var tiers := [
		{"weight": "1/8 oz", "price": "$25", "leaves": 1, "ox": 12.0},
		{"weight": "1/4 oz", "price": "$45", "leaves": 2, "ox": 64.0},
		{"weight": "1 oz", "price": "$90", "leaves": 3, "ox": 116.0}
	]
	for t in tiers:
		var tx: float = board_x + float(t["ox"])
		draw_line(Vector2(tx + 40, board_y + 4), Vector2(tx + 40, board_y + 64), Color(0.25, 0.25, 0.3), 1.0)
		draw_string(font, Vector2(tx, board_y + 18), t["weight"], HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.7, 0.7, 0.75))
		draw_string(font, Vector2(tx, board_y + 34), t["price"], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1.0, 0.85, 0.3))
		# Little green weed leaf symbols
		for l in range(t["leaves"]):
			draw_circle(Vector2(tx + 6 + l * 8, board_y + 50), 3.5, Color(0.25, 0.85, 0.35))

	# Wall Graffiti: "TRUST NO COPS"
	var graf_x := 430.0
	var graf_y := top_y + 42.0
	_draw_spray_text(Vector2(graf_x, graf_y), "TRUST\nNO\nCOPS", Color(0.7, 0.25, 0.85, 0.85), 18)
	draw_circle(Vector2(graf_x + 18, graf_y + 60), 6.0, Color(0.7, 0.25, 0.85, 0.75))

	# Left Dealer behind counter
	_draw_counter_dealer(Vector2(85, top_y + 115))

	# Speech Bubble: "BEST DEAL ON THE BLOCK."
	_draw_speech_bubble(Vector2(20, top_y + 60), Vector2(170, 38), "BEST DEAL\nON THE BLOCK.", Vector2(85, top_y + 100))

	# Right Boss Character ('G' Cap, gold chain, shades, leather jacket)
	_draw_street_boss(Vector2(580, top_y + 105))

	# Speech Bubble: "MOVE FAST. STAY SHADOWED."
	_draw_speech_bubble(Vector2(480, top_y + 45), Vector2(185, 42), "MOVE FAST.\nSTAY SHADOWED.", Vector2(580, top_y + 90))

func _draw_counter_dealer(center: Vector2) -> void:
	# Wooden counter & boxes
	draw_rect(Rect2(center.x - 45, center.y + 15, 90, 40), Color(0.3, 0.2, 0.14))
	draw_rect(Rect2(center.x - 45, center.y + 15, 90, 40), Color(0.1, 0.06, 0.04), false, 2.0)
	# Cardboard shipping boxes
	draw_rect(Rect2(center.x - 40, center.y - 2, 22, 18), Color(0.65, 0.50, 0.35))
	draw_rect(Rect2(center.x - 40, center.y - 2, 22, 18), Color(0.2, 0.15, 0.1), false, 1.5)

	# Hooded clerk
	draw_circle(Vector2(center.x + 8, center.y - 12), 16.0, Color(0.18, 0.18, 0.22)) # hood
	draw_circle(Vector2(center.x + 8, center.y - 10), 11.0, Color(0.78, 0.58, 0.44)) # face
	draw_line(Vector2(center.x + 2, center.y - 12), Vector2(center.x + 6, center.y - 12), Color(0.1, 0.1, 0.1), 2.0)
	draw_line(Vector2(center.x + 10, center.y - 12), Vector2(center.x + 14, center.y - 12), Color(0.1, 0.1, 0.1), 2.0)

func _draw_street_boss(center: Vector2) -> void:
	# Baseball cap with neon green 'G'
	draw_circle(Vector2(center.x, center.y - 30), 18.0, Color(0.15, 0.15, 0.18))
	draw_rect(Rect2(center.x - 22, center.y - 26, 44, 7), Color(0.1, 0.1, 0.12))
	# Neon green 'G' logo
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(center.x - 4, center.y - 26), "G", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.2, 0.95, 0.35))

	# Face & Aviator Sunglasses
	draw_circle(Vector2(center.x, center.y - 14), 14.0, Color(0.80, 0.60, 0.45))
	# Aviators
	draw_rect(Rect2(center.x - 11, center.y - 18, 9, 7), Color(0.08, 0.08, 0.10))
	draw_rect(Rect2(center.x + 2, center.y - 18, 9, 7), Color(0.08, 0.08, 0.10))
	draw_line(Vector2(center.x - 2, center.y - 15), Vector2(center.x + 2, center.y - 15), Color(0.85, 0.75, 0.2), 1.5)

	# Thick Gold Chain
	draw_arc(Vector2(center.x, center.y - 2), 12.0, 0.2, PI - 0.2, 10, Color(0.95, 0.8, 0.25), 3.0)

	# Black Leather Bomber Jacket
	var jacket_pts := PackedVector2Array([
		Vector2(center.x - 26, center.y + 2),
		Vector2(center.x + 26, center.y + 2),
		Vector2(center.x + 30, center.y + 55),
		Vector2(center.x - 30, center.y + 55)
	])
	draw_colored_polygon(jacket_pts, Color(0.12, 0.12, 0.14))
	draw_polyline(jacket_pts, Color(0.04, 0.04, 0.05), 2.5)
	draw_line(jacket_pts[3], jacket_pts[0], Color(0.04, 0.04, 0.05), 2.5)
	# Crossed arms
	draw_rect(Rect2(center.x - 22, center.y + 18, 44, 16), Color(0.16, 0.16, 0.18))
	draw_rect(Rect2(center.x - 22, center.y + 18, 44, 16), Color(0.05, 0.05, 0.06), false, 2.0)

# -----------------------------------------------------------------------------
# Reusable Procedural UI & FX Elements
# -----------------------------------------------------------------------------
func _draw_dripping_sign(pos: Vector2, size: Vector2, text: String, glow_col: Color, dark_col: Color) -> void:
	# Outer glow border
	draw_rect(Rect2(pos.x - 2, pos.y - 2, size.x + 4, size.y + 4), glow_col * 0.4, false, 3.0)
	# Inner dark sign plate
	draw_rect(Rect2(pos.x, pos.y, size.x, size.y), dark_col)
	draw_rect(Rect2(pos.x, pos.y, size.x, size.y), glow_col, false, 1.5)

	# Paint drip drops hanging from the bottom of the sign
	var drips: Array[float] = [pos.x + 15.0, pos.x + 45.0, pos.x + 85.0, pos.x + 130.0, pos.x + 180.0]
	for d in drips:
		if d < pos.x + size.x - 10:
			var dh := 8.0 + 5.0 * sin(d + pos.x)
			draw_line(Vector2(d, pos.y + size.y), Vector2(d, pos.y + size.y + dh), glow_col, 2.0)
			draw_circle(Vector2(d, pos.y + size.y + dh + 1), 2.0, glow_col)

	# Neon Text
	var font := ThemeDB.fallback_font
	var font_size := 14
	var tw := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
	var tx: float = pos.x + (size.x - tw) * 0.5
	var ty := pos.y + size.y * 0.5 + 5.0
	draw_string(font, Vector2(tx + 1, ty + 1), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0, 0, 0, 0.8))
	draw_string(font, Vector2(tx, ty), text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, glow_col.lightened(0.3))

func _draw_speech_bubble(pos: Vector2, size: Vector2, text: String, tail_target: Vector2) -> void:
	# White bubble with comic border
	draw_rect(Rect2(pos.x, pos.y, size.x, size.y), Color(0.96, 0.96, 0.98))
	draw_rect(Rect2(pos.x, pos.y, size.x, size.y), Color(0.08, 0.08, 0.1), false, 2.0)

	# Comic tail pointing toward character
	var tail_base := Vector2(pos.x + size.x * 0.5, pos.y + size.y)
	var tail_pts := PackedVector2Array([
		Vector2(tail_base.x - 8, tail_base.y),
		Vector2(tail_base.x + 8, tail_base.y),
		tail_target
	])
	draw_colored_polygon(tail_pts, Color(0.96, 0.96, 0.98))
	draw_line(tail_pts[0], tail_pts[2], Color(0.08, 0.08, 0.1), 2.0)
	draw_line(tail_pts[1], tail_pts[2], Color(0.08, 0.08, 0.1), 2.0)

	# Text lines
	var font := ThemeDB.fallback_font
	var font_size := 10
	var lines := text.split("\n")
	var line_y := pos.y + 16.0
	for l in lines:
		var tw := font.get_string_size(l, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
		draw_string(font, Vector2(pos.x + (size.x - tw) * 0.5, line_y), l, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.08, 0.08, 0.1))
		line_y += 13.0

func _draw_spray_text(pos: Vector2, text: String, color: Color, font_size: int) -> void:
	var font := ThemeDB.fallback_font
	var lines := text.split("\n")
	var cur_y := pos.y + font_size
	for l in lines:
		# Multiple offset draws for blurry graffiti effect
		draw_string(font, Vector2(pos.x + 1, cur_y + 1), l, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(color.r, color.g, color.b, 0.3))
		draw_string(font, Vector2(pos.x - 1, cur_y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(color.r, color.g, color.b, 0.4))
		draw_string(font, Vector2(pos.x, cur_y), l, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
		cur_y += font_size * 1.1

func _draw_floating_texts() -> void:
	var font := ThemeDB.fallback_font
	for ft in floating_texts:
		var alpha := clampf(ft["life"] / ft["max_life"], 0.0, 1.0)
		var c: Color = ft["color"]
		c.a = alpha
		draw_string(font, ft["pos"] + Vector2(1, 1), ft["text"], HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(0, 0, 0, alpha))
		draw_string(font, ft["pos"], ft["text"], HORIZONTAL_ALIGNMENT_CENTER, -1, 16, c)
