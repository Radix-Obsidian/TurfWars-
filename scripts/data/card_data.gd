class_name CardData
extends Resource

## Data definition for Cards in Turf Wars

enum CardType { UNIT, SPELL, BUILDING }
enum Rarity { COMMON, RARE, EPIC, LEGENDARY }
enum MovementType { GROUND, AIR, NONE }
enum TargetType { NEAREST_GROUND, NEAREST_ANY, BUILDINGS_ONLY, AREA }

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var card_type: CardType = CardType.UNIT
@export var elixir_cost: int = 3
@export var rarity: Rarity = Rarity.COMMON
@export var movement_type: MovementType = MovementType.GROUND
@export var target_type: TargetType = TargetType.NEAREST_ANY

# Base Stats (Level 1)
@export var base_hp: int = 250
@export var base_damage: int = 45
@export var attack_interval: float = 1.0 # Attack cooldown in seconds
@export var attack_range: float = 50.0 # Range in pixels
@export var move_speed: float = 70.0 # Movement speed

# Scaling per level
@export var hp_growth_per_level: float = 0.10 # +10% per level
@export var damage_growth_per_level: float = 0.10

func get_hp(level: int) -> int:
	return int(round(base_hp * (1.0 + hp_growth_per_level * (level - 1))))

func get_damage(level: int) -> int:
	return int(round(base_damage * (1.0 + damage_growth_per_level * (level - 1))))
