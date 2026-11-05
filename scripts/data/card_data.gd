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

# Base Combat Stats (Level 1)
@export var base_hp: int = 250
@export var base_damage: int = 45
@export var attack_interval: float = 1.0 # Attack cooldown in seconds
@export var attack_range: float = 50.0 # Range in pixels
@export var move_speed: float = 70.0 # Movement speed
@export var is_splash: bool = false
@export var splash_radius: float = 60.0

# Spell Specifics
@export var spell_radius: float = 80.0
@export var base_spell_damage: int = 150
@export var spell_duration: float = 0.5
@export var spawn_count: int = 1
@export var spawn_unit_id: String = ""

# Visual Accent
@export var accent_color: Color = Color(0.17, 0.91, 0.47)

# Scaling per level
@export var hp_growth_per_level: float = 0.10 # +10% per level
@export var damage_growth_per_level: float = 0.10

func get_hp(level: int) -> int:
	return int(round(base_hp * (1.0 + hp_growth_per_level * (level - 1))))

func get_damage(level: int) -> int:
	return int(round(base_damage * (1.0 + damage_growth_per_level * (level - 1))))

func get_spell_damage(level: int) -> int:
	return int(round(base_spell_damage * (1.0 + damage_growth_per_level * (level - 1))))
