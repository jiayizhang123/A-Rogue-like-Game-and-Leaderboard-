extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.animated_sprite.play("attack")

func exit() -> void:
	player.animated_sprite.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func physics_update(delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	player.velocity = direction * player.stats.movespeed
	player.move_and_slide()
	
	
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		finished.emit(MOVE)
	elif direction.is_zero_approx():
		finished.emit(IDLE)
