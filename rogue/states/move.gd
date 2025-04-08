extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animated_sprite.play("move")

func exit() -> void:
	player.animated_sprite.stop()

func physics_update(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	player.velocity = direction * player.stats.movespeed
	player.move_and_slide()
	
	if Input.is_action_just_pressed("basic_attack"):
		finished.emit(ATTACK)
	elif direction.is_zero_approx():
		finished.emit(IDLE)
