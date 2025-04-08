class_name Hurtbox
extends Area2D

var invulnerable : bool = false : set = set_invulnerable

@onready var timer = $Timer

signal invuln_start
signal invuln_ended

func set_invulnerable(value: bool) -> void:
	invulnerable = value
	if invulnerable:
		emit_signal("invuln_start")
	else:
		emit_signal("invuln_end")
		

func start_invuln(duration: float) -> void:
	self.invulnerable = true
	timer.start(duration)

func _init():
	collision_layer = 0
	collision_mask = 2

func _on_timer_timeout():
	self.invulnerable = false

func _on_invuln_start():
	monitorable = false

func _on_invuln_ended():
	monitorable = true
