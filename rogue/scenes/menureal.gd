extends Control

func ready() -> void:
	visible = false

func resume() -> void:
	get_tree().paused = false
	hide()

func pause() -> void:
	get_tree().paused = true
	show()

func testEsc():
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()

func _process(delta: float) -> void:
	testEsc()

func _on_resume_pressed():
	resume()

func _on_options_pressed():
	pass # Replace with function body.


func _on_abilities_pressed():
	pass # Replace with function body.


func _on_upgrades_pressed():
	pass # Replace with function body.


func _on_mainmenu_pressed():
	pass # Replace with function body.


func _on_quit_pressed():
	get_tree().quit()
