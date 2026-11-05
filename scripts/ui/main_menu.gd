extends Control

## Main Menu Controller for Turf Wars
## Handles scene routing and Phase 0 verification tests.

@onready var label_cash: Label = %LabelCash
@onready var label_rep: Label = %LabelRep
@onready var label_save_status: Label = %LabelSaveStatus

func _ready() -> void:
	_update_header()
	_update_save_status("Save ready. Loaded: " + str(SaveManager.get_value("test_value", "None")))
	EventBus.cash_changed.connect(func(_new_amt, _delta): _update_header())
	EventBus.rep_changed.connect(func(_new_amt, _delta): _update_header())

func _update_header() -> void:
	if label_cash:
		label_cash.text = "CASH: $" + str(GameManager.get_cash())
	if label_rep:
		label_rep.text = "REP: " + str(GameManager.get_rep())

func _update_save_status(msg: String) -> void:
	if label_save_status:
		label_save_status.text = msg

func _on_campaign_button_pressed() -> void:
	GameManager.load_campaign()

func _on_idle_button_pressed() -> void:
	GameManager.load_idle()

func _on_battle_button_pressed() -> void:
	GameManager.load_battle("territory_01")

func _on_collection_button_pressed() -> void:
	GameManager.load_collection()

# Phase 0 SaveManager Test Handlers
func _on_save_test_pressed() -> void:
	var test_code := "TestVal_" + str(Time.get_unix_time_from_system() % 10000)
	SaveManager.set_value("test_value", test_code)
	var success := SaveManager.save_game()
	if success:
		_update_save_status("SUCCESS: Saved '%s' to disk" % test_code)
	else:
		_update_save_status("ERROR: Save write failed")

func _on_load_test_pressed() -> void:
	var success := SaveManager.load_game()
	if success:
		var val: String = str(SaveManager.get_value("test_value", "Not Found"))
		_update_save_status("SUCCESS: Loaded value '%s'" % val)
		_update_header()
	else:
		_update_save_status("ERROR: Load read failed")

func _on_add_cash_test_pressed() -> void:
	GameManager.add_cash(100)
	SaveManager.save_game()
	_update_save_status("Added $100 cash (Total: $%d)" % GameManager.get_cash())
