class_name LevelUpMenu
extends CanvasLayer

signal level_up_completed

var player: Entity

@onready var health_upgrade_button: Button = $"%HealthUpgradeButton"
@onready var power_upgrade_button: Button = $"%PowerUpgradeButton"
@onready var defense_upgrade_button: Button = $"%DefenseUpgradeButton"

var audio_player2

func _ready() -> void:
	audio_player2 = AudioStreamPlayer.new() 
	add_child(audio_player2)
	audio_player2.stream = load('res://assets/sounds/Power_up_6.wav')
	

func setup(player: Entity) -> void:
	audio_player2.play()
	self.player = player
	var fighter: FighterComponent = player.fighter_component
	health_upgrade_button.text = "(a) Constitution (+20 HP, from %d)" % fighter.max_hp
	power_upgrade_button.text = "(b) Strength (+1 attack, from %d)" % fighter.power
	defense_upgrade_button.text = "(c) Agility (+1 defense, from %d)" % fighter.defense
	health_upgrade_button.grab_focus()
	


func _on_health_upgrade_button_pressed() -> void:
	player.level_component.increase_max_hp()
	queue_free()
	level_up_completed.emit()

func _on_power_upgrade_button_pressed() -> void:
	player.level_component.increase_power()
	queue_free()
	level_up_completed.emit()


func _on_defense_upgrade_button_pressed() -> void:
	player.level_component.increase_defense()
	queue_free()
	level_up_completed.emit()
