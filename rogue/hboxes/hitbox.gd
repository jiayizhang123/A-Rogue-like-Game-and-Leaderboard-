class_name Hitbox
extends Area2D

@export var damage : int = 1
var hit : bool = false

func _ready():
	collision_layer = 2
	collision_mask = 0

func reset_hit():
	hit = false;

func _on_area_entered(area: Area2D):
	if hit:
		return
	if area is Hurtbox and area.owner.has_method("take_damage"):
		hit = true
		area.owner.take_damage(damage)
		reset_hit()
