class_name IdleScene
extends Control

## Idle Hub Scene Controller for Turf Wars
## Matches locked reference mockup 02_idle_hub.jpg:
## - Top bar: avatar, cash, hourly income (+4,250/hr), gems, product
## - Offline earnings modal with x2 manager bonus and big purple COLLECT
## - Grow Room: capacity 78/100, tap to harvest
## - Processing Table: 64% progress, Drying Rack Lvl 12, Speed Up x2, Upgrade $6,750
## - Street-Level Sales: product price board, daily sales 89/100, tap counter to sell
## - Quick upgrades: Better Lights, Auto-Trimmer, Security, Sales Boost
## - Bottom 6-tab navigation bar with direct link to Campaign Map

const IdleFacilityViewClass = preload("res://scripts/idle/idle_facility_view.gd")
@onready var facility_view: Node2D = %IdleFacilityView

# Top Bar Labels
@onready var label_cash: Label = %LabelCash
@onready var label_hourly_rate: Label = %LabelHourlyRate
@onready var label_gems: Label = %LabelGems
@onready var label_product: Label = %LabelProduct

# Offline Modal
@onready var modal_offline: Control = %ModalOfflineEarnings
@onready var label_offline_amount: Label = %LabelOfflineAmount
@onready var label_offline_bonus: Label = %LabelOfflineBonus

# Grow Room
@onready var bar_capacity: ProgressBar = %BarCapacity
@onready var label_capacity: Label = %LabelCapacity

# Processing Table
@onready var bar_processing: ProgressBar = %BarProcessing
@onready var label_processing_pct: Label = %LabelProcessingPct
@onready var bar_drying: ProgressBar = %BarDrying
@onready var label_drying_lvl: Label = %LabelDryingLvl
@onready var btn_speedup: Button = %BtnSpeedUp
@onready var btn_upgrade_drying: Button = %BtnUpgradeDrying

# Street Sales
@onready var bar_daily_sales: ProgressBar = %BarDailySales
@onready var label_daily_sales: Label = %LabelDailySales

# Quick Upgrades Buttons & Labels
@onready var label_lights_lvl: Label = %LabelLightsLvl
@onready var bar_lights: ProgressBar = %BarLights
@onready var btn_upgrade_lights: Button = %BtnUpgradeLights

@onready var label_trimmer_lvl: Label = %LabelTrimmerLvl
@onready var bar_trimmer: ProgressBar = %BarTrimmer
@onready var btn_upgrade_trimmer: Button = %BtnUpgradeTrimmer

@onready var label_security_lvl: Label = %LabelSecurityLvl
@onready var bar_security: ProgressBar = %BarSecurity
@onready var btn_upgrade_security: Button = %BtnUpgradeSecurity

@onready var label_boost_lvl: Label = %LabelBoostLvl
@onready var bar_boost: ProgressBar = %BarBoost
@onready var btn_upgrade_boost: Button = %BtnUpgradeBoost

# Simulation state
var processing_pct: float = 64.0
var speedup_timer: float = 0.0
var pending_offline_cash: int = 0

func _ready() -> void:
	_connect_signals()
	_update_header()
	_update_facility_ui()
	_check_offline_earnings()

func _connect_signals() -> void:
	EventBus.cash_changed.connect(func(_new, _d): _update_header())
	EventBus.gems_changed.connect(func(_new, _d): _update_header())
	EventBus.product_changed.connect(func(_new, _d): _update_header())
	EventBus.raw_herb_changed.connect(func(_new, _d): _update_facility_ui())
	EventBus.facility_upgraded.connect(func(_k, _l): _update_facility_ui())
	EventBus.territory_claimed.connect(func(_tid): _update_header())

func _process(delta: float) -> void:
	var speed_mult := 2.0 if speedup_timer > 0.0 else 1.0
	if speedup_timer > 0.0:
		speedup_timer -= delta

	# Continuous processing loop
	var trimmer_lvl := GameManager.get_facility_level("auto_trimmer", 6)
	var process_speed := (12.0 + trimmer_lvl * 1.5) * speed_mult
	processing_pct += delta * process_speed
	if processing_pct >= 100.0:
		processing_pct -= 100.0
		# Convert raw herb to product
		if GameManager.get_raw_herb() >= 5:
			GameManager.spend_raw_herb(5)
			GameManager.add_product(12)
			if facility_view:
				facility_view.spawn_floating_text("+12 BATCH!", Vector2(300, 500), Color(0.2, 0.9, 0.4))

	if bar_processing:
		bar_processing.value = processing_pct
	if label_processing_pct:
		label_processing_pct.text = "%d%%" % int(processing_pct)

func _update_header() -> void:
	var cash := GameManager.get_cash()
	var gems := GameManager.get_gems()
	var product := GameManager.get_product()
	var hourly_rate := GameManager.calculate_hourly_income()

	if label_cash:
		label_cash.text = "$ %s" % _format_number(cash)
	if label_hourly_rate:
		label_hourly_rate.text = "+$%s /hr" % _format_number(hourly_rate)
	if label_gems:
		label_gems.text = "%s" % _format_number(gems)
	if label_product:
		label_product.text = "%s" % _format_number(product)

func _update_facility_ui() -> void:
	var raw_herb := GameManager.get_raw_herb()
	var raw_cap := GameManager.get_facility_level("grow_capacity_max", 100)
	if bar_capacity:
		bar_capacity.max_value = raw_cap
		bar_capacity.value = raw_herb
	if label_capacity:
		label_capacity.text = "%d / %d" % [raw_herb, raw_cap]

	var drying_lvl := GameManager.get_facility_level("drying_rack_level", 12)
	if label_drying_lvl:
		label_drying_lvl.text = "LVL %d" % drying_lvl
	if bar_drying:
		bar_drying.value = (drying_lvl % 20) * 5.0

	var daily_sales := GameManager.get_facility_level("daily_sales_progress", 89)
	var daily_max := GameManager.get_facility_level("daily_sales_max", 100)
	if bar_daily_sales:
		bar_daily_sales.max_value = daily_max
		bar_daily_sales.value = daily_sales
	if label_daily_sales:
		label_daily_sales.text = "%d / %d" % [daily_sales, daily_max]

	# Quick upgrades
	var lights_lvl := GameManager.get_facility_level("better_lights", 8)
	if label_lights_lvl: label_lights_lvl.text = "LVL %d" % lights_lvl
	if bar_lights: bar_lights.value = (lights_lvl % 10) * 10.0
	if btn_upgrade_lights: btn_upgrade_lights.text = "$%s" % _format_number(lights_lvl * 1562)

	var trimmer_lvl := GameManager.get_facility_level("auto_trimmer", 6)
	if label_trimmer_lvl: label_trimmer_lvl.text = "LVL %d" % trimmer_lvl
	if bar_trimmer: bar_trimmer.value = (trimmer_lvl % 10) * 10.0
	if btn_upgrade_trimmer: btn_upgrade_trimmer.text = "$%s" % _format_number(trimmer_lvl * 1550)

	var security_lvl := GameManager.get_facility_level("security", 7)
	if label_security_lvl: label_security_lvl.text = "LVL %d" % security_lvl
	if bar_security: bar_security.value = (security_lvl % 10) * 10.0
	if btn_upgrade_security: btn_upgrade_security.text = "$%s" % _format_number(security_lvl * 2142)

	var boost_lvl := GameManager.get_facility_level("sales_boost", 5)
	if label_boost_lvl: label_boost_lvl.text = "LVL %d" % boost_lvl
	if bar_boost: bar_boost.value = (boost_lvl % 10) * 10.0
	if btn_upgrade_boost: btn_upgrade_boost.text = "%d 💎" % (boost_lvl * 24)

func _check_offline_earnings() -> void:
	var last_save: float = float(SaveManager.get_value("last_save_time", 0.0))
	var cur_time: float = Time.get_unix_time_from_system()
	var elapsed := cur_time - last_save

	# Only show modal if away for more than 60 seconds (or on first boot)
	if last_save > 0.0 and elapsed < 60.0:
		if modal_offline:
			modal_offline.visible = false
		return

	var calc_time := maxf(elapsed, 7200.0) if last_save == 0.0 else elapsed
	var calc := GameManager.calculate_offline_earnings(calc_time)
	pending_offline_cash = int(calc["cash"])
	if pending_offline_cash <= 0:
		if modal_offline:
			modal_offline.visible = false
		return

	if modal_offline:
		if label_offline_amount:
			label_offline_amount.text = "$%s" % _format_number(pending_offline_cash)
		if label_offline_bonus:
			label_offline_bonus.text = "💀 x%.0f Manager Bonus Applied!" % calc.get("manager_bonus", 2.0)
		modal_offline.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var pos: Vector2 = event.position
		# Grow Room plant tap (y: 190-320, x: 50-480)
		if pos.y >= 190 and pos.y <= 320 and pos.x >= 50 and pos.x <= 480:
			_tap_harvest_plants(pos)
		# Street Sales counter tap (y: 750-920, x: 20-400)
		elif pos.y >= 750 and pos.y <= 920 and pos.x >= 20 and pos.x <= 400:
			_tap_sell_counter(pos)

func _tap_harvest_plants(click_pos: Vector2) -> void:
	AudioManager.play_sound("harvest", 0.1)
	GameManager.add_raw_herb(10)
	if facility_view:
		facility_view.spawn_floating_text("+10 RAW HERB!", click_pos, Color(0.3, 0.9, 0.4))
	_update_facility_ui()

func _tap_sell_counter(click_pos: Vector2) -> void:
	if GameManager.get_product() >= 3:
		GameManager.spend_product(3)
		GameManager.add_cash(90)
		AudioManager.play_sound("cash_register", 0.1)
		if facility_view:
			facility_view.spawn_floating_text("+$90 CASH!", click_pos, Color(1.0, 0.85, 0.2))
		_update_header()
	else:
		if facility_view:
			facility_view.spawn_floating_text("OUT OF STOCK!", click_pos, Color(0.9, 0.3, 0.3))

# -----------------------------------------------------------------------------
# Action Handlers
# -----------------------------------------------------------------------------
func _on_collect_offline_pressed() -> void:
	AudioManager.play_sound("cash_register", 0.05)
	GameManager.claim_offline_earnings(pending_offline_cash)
	if facility_view:
		facility_view.spawn_floating_text("+$%s COLLECTED!" % _format_number(pending_offline_cash), Vector2(360, 200), Color(0.17, 0.91, 0.47))
	if modal_offline:
		modal_offline.visible = false
	_update_header()

func _on_close_offline_pressed() -> void:
	if modal_offline:
		modal_offline.visible = false

func _on_upgrade_capacity_pressed() -> void:
	var cur_cap := GameManager.get_facility_level("grow_capacity_max", 100)
	var cost := cur_cap * 50
	if GameManager.spend_cash(cost):
		AudioManager.play_sound("upgrade")
		GameManager.set_facility_level("grow_capacity_max", cur_cap + 25)
		SaveManager.save_game()
		if facility_view:
			facility_view.spawn_floating_text("CAPACITY UP!", Vector2(360, 380), Color(0.7, 0.3, 0.9))
		_update_facility_ui()

func _on_speed_up_pressed() -> void:
	if GameManager.spend_gems(2):
		AudioManager.play_sound("speedup")
		speedup_timer = 15.0
		if facility_view:
			facility_view.spawn_floating_text("SPEED x2 (15s)!", Vector2(600, 680), Color(0.8, 0.4, 1.0))
		_update_header()

func _on_upgrade_drying_pressed() -> void:
	var cur_lvl := GameManager.get_facility_level("drying_rack_level", 12)
	var cost := 6750
	if GameManager.spend_cash(cost):
		AudioManager.play_sound("upgrade")
		GameManager.set_facility_level("drying_rack_level", cur_lvl + 1)
		SaveManager.save_game()
		if facility_view:
			facility_view.spawn_floating_text("DRYING RACK LVL %d!" % (cur_lvl + 1), Vector2(600, 680), Color(0.2, 0.9, 0.4))
		_update_facility_ui()
		_update_header()

func _on_upgrade_daily_sales_pressed() -> void:
	var cur_max := GameManager.get_facility_level("daily_sales_max", 100)
	var cost := cur_max * 40
	if GameManager.spend_cash(cost):
		AudioManager.play_sound("upgrade")
		GameManager.set_facility_level("daily_sales_max", cur_max + 20)
		SaveManager.save_game()
		if facility_view:
			facility_view.spawn_floating_text("SALES CAP UP!", Vector2(360, 950), Color(1.0, 0.3, 0.3))
		_update_facility_ui()

# Quick Upgrades Handlers
func _on_upgrade_lights_pressed() -> void:
	var lvl := GameManager.get_facility_level("better_lights", 8)
	var cost := lvl * 1562
	if GameManager.upgrade_facility("better_lights", cost, "cash"):
		AudioManager.play_sound("upgrade")
		if facility_view:
			facility_view.spawn_floating_text("LIGHTS LVL %d!" % (lvl + 1), Vector2(90, 1050), Color(1.0, 0.85, 0.3))
		_update_facility_ui()
		_update_header()

func _on_upgrade_trimmer_pressed() -> void:
	var lvl := GameManager.get_facility_level("auto_trimmer", 6)
	var cost := lvl * 1550
	if GameManager.upgrade_facility("auto_trimmer", cost, "cash"):
		AudioManager.play_sound("upgrade")
		if facility_view:
			facility_view.spawn_floating_text("TRIMMER LVL %d!" % (lvl + 1), Vector2(270, 1050), Color(0.2, 0.9, 0.4))
		_update_facility_ui()
		_update_header()

func _on_upgrade_security_pressed() -> void:
	var lvl := GameManager.get_facility_level("security", 7)
	var cost := lvl * 2142
	if GameManager.upgrade_facility("security", cost, "cash"):
		AudioManager.play_sound("upgrade")
		if facility_view:
			facility_view.spawn_floating_text("SECURITY LVL %d!" % (lvl + 1), Vector2(450, 1050), Color(0.4, 0.7, 1.0))
		_update_facility_ui()
		_update_header()

func _on_upgrade_boost_pressed() -> void:
	var lvl := GameManager.get_facility_level("sales_boost", 5)
	var cost := lvl * 24
	if GameManager.upgrade_facility("sales_boost", cost, "gems"):
		AudioManager.play_sound("upgrade")
		if facility_view:
			facility_view.spawn_floating_text("BOOST LVL %d!" % (lvl + 1), Vector2(630, 1050), Color(0.8, 0.4, 1.0))
		_update_facility_ui()
		_update_header()

# Bottom Tabs Navigation
func _on_map_tab_pressed() -> void:
	AudioManager.play_sound("card_drop")
	GameManager.load_campaign()

func _on_back_pressed() -> void:
	GameManager.load_main_menu()

func _format_number(n: int) -> String:
	var s := str(n)
	var len := s.length()
	if len <= 3:
		return s
	var res := ""
	var count := 0
	for i in range(len - 1, -1, -1):
		res = s[i] + res
		count += 1
		if count % 3 == 0 and i > 0:
			res = "," + res
	return res
