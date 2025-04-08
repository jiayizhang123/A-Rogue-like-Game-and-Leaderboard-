class_name CharacterStats
extends Stats

@export var crit_chance: float : set = set_critchance
@export var crit_attack: float : set = set_critattack
@export var score_mult: float : set = set_score_mult

func set_critchance(value : float) -> void:
	crit_chance = value
	stats_changed.emit()

func set_critattack(value : float) -> void:
	crit_attack = value
	stats_changed.emit()

func set_score_mult(value: float) -> void:
	score_mult = value
	stats_changed.emit()

func take_damage(damage: int) -> void:
	var initial_health := health
	super.take_damage(damage)

func create_instance() -> Resource:
	var instance: CharacterStats = self.duplicate()
	instance.health = max_health
	instance.mana = max_mana
	instance.shield = 0
	instance.attack = 10
	instance.movespeed = 500
	instance.cooldown = 0.5
	instance.critchance = 0.10
	instance.critattack = 1.2
	instance.score_mult =  1.0
	return instance
