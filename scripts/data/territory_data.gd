class_name TerritoryData
extends Resource

## Data definition for Claimable Map Territories in Turf Wars

enum TerritoryState { NEUTRAL, PLAYER_OWNED, ENEMY_CONTROLLED }

@export var id: String = ""
@export var display_name: String = ""
@export var region: String = "region_01"
@export var base_income_per_hour: int = 1200
@export var map_position: Vector2 = Vector2.ZERO
@export var unlock_rep_required: int = 0
@export var difficulty_rating: int = 1
@export var ai_deck_id: String = "ai_starter"
@export var speed_multiplier: float = 1.05
@export var initial_state: TerritoryState = TerritoryState.NEUTRAL
@export var crest_icon: String = "skull"
@export var crew_flavor: String = "South Side Crew"
