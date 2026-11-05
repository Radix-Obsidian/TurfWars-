class_name CampaignScene
extends Control

## Campaign Map Controller for Turf Wars
## Matches locked reference mockup 03_battle_arena.jpg:
## Profile header, territory selection, income accumulation, and ATTACK TERRITORY action.

@onready var map_view: CampaignMapView = %CampaignMapView
@onready var label_cash_top: Label = %LabelCashTop
@onready var label_rep_top: Label = %LabelRepTop
@onready var label_cash_bottom: Label = %LabelCashBottom
@onready var label_selected_info: Label = %LabelSelectedInfo
@onready var btn_attack_territory: Button = %BtnAttackTerritory

var territories: Array[TerritoryData] = []
var territory_map: Dictionary = {}
var owned_territory_ids: Array = []
var selected_territory_id: String = "the_east_crew"

func _ready() -> void:
	_load_territories()
	_load_player_data()
	_update_ui()
	_setup_map()

	EventBus.battle_ended.connect(_on_battle_ended)
	EventBus.cash_changed.connect(func(_new, _d): _update_ui())
	EventBus.rep_changed.connect(func(_new, _d): _update_ui())

func _load_territories() -> void:
	var ids := ["the_yard", "red_dragon", "the_lockup", "no_mans_block", "the_pit", "the_east_crew", "old_market"]
	territories.clear()
	territory_map.clear()
	for tid in ids:
		var t: TerritoryData = load("res://resources/territories/%s.tres" % tid)
		if t:
			territories.append(t)
			territory_map[t.id] = t

func _load_player_data() -> void:
	# Default starter owned territories: the_yard, the_lockup
	owned_territory_ids = SaveManager.get_value("owned_territories", ["the_yard", "the_lockup"])
	SaveManager.set_value("owned_territories", owned_territory_ids)

func _setup_map() -> void:
	if map_view:
		map_view.setup(territories, owned_territory_ids, selected_territory_id)

func _update_ui() -> void:
	var cash := GameManager.get_cash()
	var rep := GameManager.get_rep()

	if label_cash_top:
		label_cash_top.text = "$ %s +" % _format_number(cash)
	if label_rep_top:
		label_rep_top.text = "💀 %s REP +" % _format_number(rep)
	if label_cash_bottom:
		label_cash_bottom.text = "$ %s" % _format_number(cash)

	_update_selected_territory_info()

func _update_selected_territory_info() -> void:
	var t: TerritoryData = territory_map.get(selected_territory_id)
	if not t:
		return

	var is_owned := owned_territory_ids.has(t.id)

	if is_owned:
		if label_selected_info:
			label_selected_info.text = "TERRITORY SECURED • GENERATING $%d /HR" % t.base_income_per_hour
			label_selected_info.add_theme_color_override("font_color", Color(0.17, 0.91, 0.47))
		if btn_attack_territory:
			btn_attack_territory.text = "PATROL %s\n⚔️ RE-ENGAGE CREW" % t.display_name
			btn_attack_territory.add_theme_color_override("font_color", Color(0.17, 0.91, 0.47))
	else:
		if label_selected_info:
			label_selected_info.text = "CLAIM REWARD: +$%d /HR  •  DIFF: %d⭐" % [t.base_income_per_hour, t.difficulty_rating]
			label_selected_info.add_theme_color_override("font_color", Color(1, 0.82, 0.25))
		if btn_attack_territory:
			btn_attack_territory.text = "ATTACK TERRITORY\n⚔️ %s ⚔️" % t.display_name
			btn_attack_territory.add_theme_color_override("font_color", Color(1, 0.25, 0.35))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var click_pos: Vector2 = event.position
		_check_territory_click(click_pos)

func _check_territory_click(pos: Vector2) -> void:
	for t in territories:
		var dist := pos.distance_to(t.map_position)
		if dist <= 75.0:
			selected_territory_id = t.id
			AudioManager.play_sound("card_drop", 0.1)
			_setup_map()
			_update_selected_territory_info()
			break

func _on_attack_territory_pressed() -> void:
	AudioManager.play_sound("victory")
	GameManager.load_battle(selected_territory_id)

func _on_back_to_menu_pressed() -> void:
	GameManager.load_main_menu()

func _on_facility_button_pressed() -> void:
	AudioManager.play_sound("card_drop")
	GameManager.load_idle()

func _on_battle_ended(won: bool, territory_id: String) -> void:
	if won and territory_id != "":
		if not owned_territory_ids.has(territory_id):
			owned_territory_ids.append(territory_id)
			SaveManager.set_value("owned_territories", owned_territory_ids)
			SaveManager.save_game()
			EventBus.territory_claimed.emit(territory_id)
		_setup_map()
		_update_ui()

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
