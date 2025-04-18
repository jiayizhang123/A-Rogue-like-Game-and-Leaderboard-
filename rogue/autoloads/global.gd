extends Node

var score: int = 0
var coins: int = 0
@onready var enemy_scene = preload("res://enemies/enemy.tscn")

func update_score(value: int):
	score += value
