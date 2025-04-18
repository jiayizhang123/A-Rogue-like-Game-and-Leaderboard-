extends Node2D

@onready var enemies = $SpawnedEnemies
var xpos : int = randi_range(-500, 500)
var ypos : int = randi_range(-500, 500)
const MAX_ENEMIES : int = 5
var enemy_count : int = 0
 
func spawn_enemy():
	var enemy = Global.enemy_scene.instantiate()
	enemy.position = Vector2(xpos, ypos)
	enemies.add_child(enemy)

func _on_timer_timeout():
	if enemy_count < MAX_ENEMIES:
		spawn_enemy()
		enemy_count += 1
	
