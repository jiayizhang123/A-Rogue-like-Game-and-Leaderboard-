extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity = Vector2(0,0)
	player.animated_sprite.play("idle")

func exit() -> void:
	player.animated_sprite.stop()

func physics_update(_delta: float) -> void:
	player.move_and_slide()

	if Input.is_action_just_pressed("basic_attack"):
		finished.emit(ATTACK)
	elif Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		finished.emit(MOVE)
