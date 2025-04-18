extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true

func _on_resume_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/test.tscn")
