extends Node

var character_scene: PackedScene = preload("res://player/player.tscn")
var player: Player = null

func _ready() -> void:
	player = character_scene.instantiate()
	
