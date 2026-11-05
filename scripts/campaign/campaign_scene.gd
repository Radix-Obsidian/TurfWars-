extends Control

## Campaign Map Scene Controller (Phase 0 Placeholder / Phase 2 Foundation)

func _on_back_pressed() -> void:
	GameManager.load_main_menu()

func _on_attack_territory_pressed(territory_id: String) -> void:
	GameManager.load_battle(territory_id)
