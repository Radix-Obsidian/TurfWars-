extends Control

## Battle Scene Controller (Phase 0 Placeholder / Phase 1 Foundation)

@onready var label_territory: Label = %LabelTerritory

func _ready() -> void:
	if label_territory:
		label_territory.text = "TERRITORY: " + GameManager.current_territory_id.to_upper()

func _on_back_pressed() -> void:
	GameManager.load_main_menu()
