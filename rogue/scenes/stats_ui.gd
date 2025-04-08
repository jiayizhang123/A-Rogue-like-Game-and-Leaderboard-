class_name StatsUI
extends Control

@onready var hp_box = $VBoxContainer/hpbox
@onready var hp = $VBoxContainer/hpbox/health
@onready var mp_box = $VBoxContainer/mpbox
@onready var mp = $VBoxContainer/mpbox/mana
var player: Player

func _ready() -> void:
	await owner.ready
	player = owner as Player


func update_stats() -> void:
	hp.value = player.stats.max_health
	mp.value = player.stats.max_mana
	
	hp_box.visible = player.stats.health > 0
	mp_box.visible = player.stats.mana > 0

func _process(delta) -> void:
	update_stats()
