class_name MeleeAction
extends ActionWithDirection


func perform() -> bool:
	var target: Entity = get_target_actor()
	if not target:
		if entity == get_map_data().player:
			MessageLog.send_message("Nothing to attack.", GameColors.IMPOSSIBLE)
		return false
	
	var damage: int = entity.fighter_component.power - target.fighter_component.defense
	if entity.get_entity_name() == 'Player':
		entity.audio_player1.play()
		if entity.direction_self == 'left':
			entity.set_flip_h(false)
			entity.play('fight_left')
		elif entity.direction_self == 'right':
			entity.set_flip_h(true)
			entity.play('fight_left')
		elif entity.direction_self == 'up':
			entity.play('fight_up')
		elif entity.direction_self == 'down':
			entity.play('fight_down')
	var attack_color: Color
	if entity == get_map_data().player:
		attack_color = GameColors.PLAYER_ATTACK
	else:
		attack_color = GameColors.ENEMY_ATTACK
	var attack_description: String = "%s attacks %s" % [entity.get_entity_name(), target.get_entity_name()]
	if damage > 0:
		attack_description += " for %d hit points." % damage
		MessageLog.send_message(attack_description, attack_color)
		target.fighter_component.hp -= damage
	else:
		attack_description += " but does no damage."
		MessageLog.send_message(attack_description, attack_color)
	return true
