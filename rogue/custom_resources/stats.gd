## stat class code from: https://github.com/guladam/deck_builder_tutorial/tree/season-1-code

extends Resource
class_name Stats

signal stats_changed

@export var max_health : int = 100
@export var max_mana : int = 100
@export var max_shield : int = 50
@export var attack: int : set = set_attack
@export var movespeed: int : set = set_movespeed
@export var cooldown: float : set = set_cooldown
@export var can_crit: bool : set = set_crittable
@export var is_invulnerable: bool : set = set_invuln

var health: int : set = set_health
var mana: int : set = set_mana
var shield: int : set = set_shield

func set_health(value : int) -> void:
	health = clampi(value, 0, max_health)
	stats_changed.emit()

func set_mana(value : int) -> void:
	mana = clampi(value, 0, max_mana)
	stats_changed.emit()

func set_shield(value : int) -> void:
	shield = clampi(value, 0, max_shield)
	stats_changed.emit()

func set_attack(value : int) -> void:
	attack = value
	stats_changed.emit()

func set_movespeed(value : int) -> void:
	movespeed = value
	stats_changed.emit()

func set_cooldown(value : float) -> void:
	cooldown = value
	stats_changed.emit()

func set_crittable(value : bool) -> void:
	can_crit = value
	stats_changed.emit()

func set_invuln(value : bool) -> void:
	is_invulnerable = value
	stats_changed.emit()

func take_damage(damage : int) -> void:
	if damage <= 0 or is_invulnerable:
		return
# if shield is up, damage shield instead
	if shield > 0:
# if shield is less than damage taken, remove shield and remaining damage reduces health
		if damage > shield:
			var health_damage = damage - self.shield
			self.shield = 0
			self.health -= health_damage
		damage = clampi(shield - damage, 0, damage)
		self.shield -= damage
	self.health -= damage

func create_instance() -> Resource:
	var instance: Stats = self.duplicate()
	instance.health = max_health
	instance.mana = max_mana
	instance.shield = 0
	return instance
