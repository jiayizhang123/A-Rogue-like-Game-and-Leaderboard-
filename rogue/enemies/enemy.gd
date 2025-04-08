class_name Enemy
extends CharacterBody2D

@export var stats : Stats = preload("res://custom_resources/stats.tres")

func _ready():
	$Hurtbox/CollisionShape2D.shape.set_radius(70)
	stats.set_attack(10)
	stats.set_movespeed(200)
	velocity = Vector2(50,50)

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
