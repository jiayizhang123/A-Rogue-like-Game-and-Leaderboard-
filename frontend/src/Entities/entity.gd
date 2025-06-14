class_name Entity
extends AnimatedSprite2D

enum AIType {NONE, HOSTILE}
enum EntityType {CORPSE, ITEM, ACTOR}

const entity_types = {
	"player": "res://assets/definitions/entities/actors/entity_definition_player.tres",
	"orc": "res://assets/definitions/entities/actors/entity_definition_orc.tres",
	"troll": "res://assets/definitions/entities/actors/entity_definition_troll.tres",
	"health_potion": "res://assets/definitions/entities/items/health_potion_definition.tres",
	"lightning_scroll": "res://assets/definitions/entities/items/lightning_scroll_definition.tres",
	"confusion_scroll": "res://assets/definitions/entities/items/confusion_scroll_definition.tres",
	"fireball_scroll": "res://assets/definitions/entities/items/fireball_scroll_definition.tres",
	"dagger": "res://assets/definitions/entities/items/dagger_definition.tres",
	"sword": "res://assets/definitions/entities/items/sword_definition.tres",
	"chainmail": "res://assets/definitions/entities/items/chainmail_definition.tres",
	"leather_armor": "res://assets/definitions/entities/items/leather_armor_definition.tres",
}

var grid_position: Vector2i:
	set(value):
		grid_position = value
		position = Grid.grid_to_world(grid_position)

var _definition: EntityDefinition
var entity_name: String
var blocks_movement: bool
var type: EntityType:
	set(value):
		type = value
		z_index = type
var map_data: MapData
var key: String

var fighter_component: FighterComponent
var ai_component: BaseAIComponent
var consumable_component: ConsumableComponent
var equippable_component: EquippableComponent
var inventory_component: InventoryComponent
var level_component: LevelComponent
var equipment_component: EquipmentComponent
var direction_self = ''
var audio_player1
var score = 0


func _init(map_data: MapData, start_position: Vector2i, key: String = "") -> void:
	#centered = false
	audio_player1 = AudioStreamPlayer.new()
	add_child(audio_player1)
	if key == 'orc':
		offset = Vector2(8,10)
	elif key == 'player':
		offset = Vector2(8,0)
		audio_player1.stream = load('res://assets/sounds/sword-sound-2-36274.wav') 
	elif key == 'troll':
		offset = Vector2(8,10)
	elif key == 'health_potion':
		offset = Vector2(8,10)
	else:
		offset = Vector2(8,10)
	grid_position = start_position
	self.map_data = map_data
	if key != "":
		set_entity_type(key)


func set_entity_type(key: String) -> void:
	self.key = key
	var entity_definition: EntityDefinition = load(entity_types[key])
	_definition = entity_definition
	type = _definition.type
	blocks_movement = _definition.is_blocking_movment
	entity_name = _definition.name
	#texture = entity_definition.texture
	if key == 'orc' || key == 'player' || key == 'troll':
		set_sprite_frames(entity_definition.spriteframe)
		play('idle')
	set_sprite_frames(entity_definition.spriteframe)
	play('idle')
	modulate = entity_definition.color
	
	match entity_definition.ai_type:
		AIType.HOSTILE:
			ai_component = HostileEnemyAIComponent.new()
			add_child(ai_component)
	
	if entity_definition.fighter_definition:
		fighter_component = FighterComponent.new(entity_definition.fighter_definition)
		add_child(fighter_component)
		
	var item_definition: ItemComponentDefinition = entity_definition.item_definition
	if item_definition:
		if item_definition is ConsumableComponentDefinition:
			_handle_consumable(item_definition)
		else:
			equippable_component = EquippableComponent.new(item_definition)
	
	if entity_definition.inventory_capacity > 0:
		inventory_component = InventoryComponent.new(entity_definition.inventory_capacity)
		add_child(inventory_component)
	
	if entity_definition.level_info:
		level_component = LevelComponent.new(entity_definition.level_info)
		add_child(level_component)
	
	
	if entity_definition.has_equipment:
		equipment_component = EquipmentComponent.new()
		add_child(equipment_component)
		equipment_component.entity = self


func move(move_offset: Vector2i) -> void:
	map_data.unregister_blocking_entity(self)
	grid_position += move_offset
	
	if move_offset.x >0:
		set_flip_h(false)
		play('left')
		direction_self = 'left'
	elif move_offset.x < 0:
		set_flip_h(true)
		play('left')
		direction_self = 'right'
	elif move_offset.y < 0:
		play('up')
		direction_self = 'up'
	elif move_offset.y > 0:
		play('down')
		direction_self = 'down'
	map_data.register_blocking_entity(self)
	visible = map_data.get_tile(grid_position).is_in_view


func distance(other_position: Vector2i) -> int:
	var relative: Vector2i = other_position - grid_position
	return maxi(abs(relative.x), abs(relative.y))


func is_blocking_movement() -> bool:
	return blocks_movement


func get_entity_name() -> String:
	return entity_name


func get_entity_type() -> int:
	return _definition.type


func is_alive() -> bool:
	return ai_component != null


func _handle_consumable(consumable_definition: ConsumableComponentDefinition) -> void:
	if consumable_definition is HealingConsumableComponentDefinition:
		consumable_component = HealingConsumableComponent.new(consumable_definition)
	elif consumable_definition is LightningDamageConsumableComponentDefinition:
		consumable_component = LightningDamageConsumableComponent.new(consumable_definition)
	elif consumable_definition is ConfusionConsumableComponentDefinition:
		consumable_component = ConfusionConsumableComponent.new(consumable_definition)
	elif consumable_definition is FireballDamageConsumableComponentDefinition:
		consumable_component = FireballDamageConsumableComponent.new(consumable_definition)
	
	if consumable_component:
		add_child(consumable_component)
	consumable_component.entity = self


func get_save_data() -> Dictionary:
	var save_data: Dictionary = {
		"x": grid_position.x,
		"y": grid_position.y,
		"key": key,
	}
	if fighter_component:
		save_data["fighter_component"] = fighter_component.get_save_data()
	if ai_component:
		save_data["ai_component"] = ai_component.get_save_data()
	if inventory_component:
		save_data["inventory_component"] = inventory_component.get_save_data()
	if equipment_component:
		save_data["equipment_component"] = equipment_component.get_save_data()
	if level_component:
		save_data["level_component"] = level_component.get_save_data()
	return save_data


func restore(save_data: Dictionary) -> void:
	grid_position = Vector2i(save_data["x"], save_data["y"])
	set_entity_type(save_data["key"])
	if fighter_component and save_data.has("fighter_component"):
		fighter_component.restore(save_data["fighter_component"])
	if ai_component and save_data.has("ai_component"):
		var ai_data: Dictionary = save_data["ai_component"]
		if ai_data["type"] == "ConfusedEnemyAI":
			var confused_enemy_ai := ConfusedEnemyAIComponent.new(ai_data["turns_remaining"])
			add_child(confused_enemy_ai)
	if inventory_component and save_data.has("inventory_component"):
		inventory_component.restore(save_data["inventory_component"])
	if equipment_component and save_data.has("equipment_component"):
		equipment_component.restore(save_data["equipment_component"])
	if level_component and save_data.has("level_component"):
		level_component.restore(save_data["level_component"])
