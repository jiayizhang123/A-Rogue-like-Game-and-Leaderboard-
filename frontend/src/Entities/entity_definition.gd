class_name EntityDefinition
extends Resource

@export_category("Visuals")
@export var name: String = "Unnamed Entity"
@export var spriteframe: SpriteFrames
@export_color_no_alpha var color: Color = Color.WHITE

@export_category("Mechanics")
@export var is_blocking_movment: bool = true
@export var type: Entity.EntityType

@export_category("Components")
@export var fighter_definition: FighterComponentDefinition
@export var ai_type: Entity.AIType
@export var item_definition: ItemComponentDefinition
@export var inventory_capacity: int = 0
@export var level_info: LevelComponentDefinition
@export var has_equipment: bool = false
