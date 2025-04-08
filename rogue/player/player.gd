class_name Player
extends CharacterBody2D

@export var stats : CharacterStats = load("res://custom_resources/char_stats.tres")
@onready var fsm = $StateMachine
@onready var label = $Label
@onready var animated_sprite = $AnimatedSprite2D
@onready var stats_ui = $MenuUI

var damage: int : set = set_damage

func _ready():
	stats = stats.duplicate()
	$Hurtbox/CollisionShape2D.shape.set_radius(40)
	$HitboxPivot/Hitbox/CollisionShape2D.disabled
	

func _process(_delta: float) -> void:
	label.text = fsm.state.name


func _on_area_entered(hitbox: Hitbox):
	if hitbox == null:
		return
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
		print(owner, "has taken", damage, "damage")

func set_damage(value: int) -> void:
	damage = value

func determine_crit(value: float) -> bool:
	var random = randf()
	
	if random < value:
		return true
	else:
		return false

func basic_attack(attack: int) -> int:
	var damage_dealt = stats.attack + 10
	
	if stats.can_crit and determine_crit(stats.crit_chance):
		damage_dealt *= stats.crit_attack
	
	return damage_dealt
