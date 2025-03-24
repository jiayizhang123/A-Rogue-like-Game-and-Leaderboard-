extends HBoxContainer

var _player: Entity

@onready var level_label: Label = $Level
@onready var attack_label: Label = $Attack
@onready var defense_label: Label = $Defense
@onready var score_label: Label = $Score


func setup(player: Entity) -> void:
	_player = player
	_player.level_component.leveled_up.connect(update_labels)
	_player.equipment_component.equipment_changed.connect(update_labels)
	update_labels()


func update_labels() -> void:
	if not _player.is_inside_tree():
		await _player.ready
	level_label.text = "LVL: %d" % _player.level_component.current_level
	attack_label.text = "ATK: %d" % _player.fighter_component.power
	defense_label.text = "DEF: %d" % _player.fighter_component.defense
	
