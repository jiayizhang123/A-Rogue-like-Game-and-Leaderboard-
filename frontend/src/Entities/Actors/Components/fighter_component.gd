class_name FighterComponent
extends Component

signal hp_changed(hp, max_hp)
const game_over_scene: PackedScene = preload("res://src/GUI/MainMenu/game_over.tscn")

var max_hp: int
var hp: int:
	set(value):
		hp = clampi(value, 0, max_hp)
		hp_changed.emit(hp, max_hp)
		if hp <= 0:
			var die_silently := false
			if not is_inside_tree():
				die_silently = true
				await ready
			die(not die_silently)
var base_defense: int
var base_power: int
var defense: int: 
	get:
		return base_defense + get_defense_bonus()
var power: int: 
	get:
		return base_power + get_power_bonus()


var death_texture: Texture
var death_color: Color
var audio_player2


func _init(definition: FighterComponentDefinition) -> void:
	max_hp = definition.max_hp
	hp = definition.max_hp
	base_defense = definition.defense
	base_power = definition.power
	death_texture = definition.death_texture
	death_color = definition.death_color
	audio_player2 = AudioStreamPlayer.new()
	add_child(audio_player2)
	audio_player2.stream = load('res://assets/sounds/mixkit-wrong-answer-fail-notification-946.wav') 


func heal(amount: int) -> int:
	if hp == max_hp:
		return 0
	
	var new_hp_value: int = hp + amount
	
	if new_hp_value > max_hp:
		new_hp_value = max_hp
		
	var amount_recovered: int = new_hp_value - hp
	hp = new_hp_value
	return amount_recovered


func take_damage(amount: int) -> void:
	hp -= amount


func die(trigger_side_effects := true) -> void:
	var death_message: String
	var death_message_color: Color
	
	if get_map_data().player == entity:
		
		var game_over: GameOverMenu = game_over_scene.instantiate()
		add_child(game_over)
		death_message = "You died!"
		audio_player2.play()
		death_message_color = GameColors.PLAYER_DIE
		SignalBus.player_died.emit()
	else:
		death_message = "%s is dead!" % entity.get_entity_name()
		death_message_color = GameColors.ENEMY_DIE
		if entity.get_entity_name() == 'Orc':
			get_map_data().player.score = get_map_data().player.score + Config.orc_score
		elif entity.get_entity_name() == 'Troll':
			get_map_data().player.score = get_map_data().player.score + Config.troll_score
				
	
	if trigger_side_effects:
		MessageLog.send_message(death_message, death_message_color)
		get_map_data().player.level_component.add_xp(entity.level_component.xp_given)
	#entity.texture = death_texture
	entity.play('die')
	entity.modulate = death_color
	entity.ai_component.queue_free()
	entity.ai_component = null
	entity.entity_name = "Remains of %s" % entity.entity_name
	entity.blocks_movement = false
	entity.type = Entity.EntityType.CORPSE
	get_map_data().unregister_blocking_entity(entity)


func get_defense_bonus() -> int:
	if entity.equipment_component:
		return entity.equipment_component.get_defense_bonus()
	return 0


func get_power_bonus() -> int:
	if entity.equipment_component:
		return entity.equipment_component.get_power_bonus()
	return 0


func get_save_data() -> Dictionary:
	return {
		"max_hp": max_hp,
		"hp": hp,
		"power": base_power,
		"defense": base_defense
	}


func restore(save_data: Dictionary) -> void:
	max_hp = save_data["max_hp"]
	hp = save_data["hp"]
	base_power = save_data["power"]
	base_defense = save_data["defense"]
